//
//  CNjacob_CBCharacteristic+Private.m
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import "CNjacob_CBCharacteristic+Private.h"

#import "CNjacob_CoreBluetoothManager+Private.h"
#import "CNjacob_CBCentralManager.h"
#import "CNjacob_CBCentralManagerOptions.h"

#import "CNjacob_CBPeripheral+Private.h"

#import "CNjacob_CBAttribute.h"
#import "CNjacob_CBService+Private.h"

@interface CNjacob_CBCharacteristicWriteQueueData ()

@property (nonatomic, assign, readwrite) NSInteger retryTimes;

@end





@implementation CNjacob_CBCharacteristicWriteQueueData

- (instancetype)initWithData:(NSData *)data retryTimes:(NSInteger)retryTimes callback:(CNjacob_CBCharacteristicWriteDataCallback)writeCallback {
    
    self = [super init];
    
    if (self) {
        _data = data;
        _writeCallback = writeCallback;
        _retryTimes = retryTimes;
    }
    
    return self;
}

@end





@implementation CNjacob_CBCharacteristic (Private)

@dynamic readCallback;
@dynamic readDelayCallback;
@dynamic writeDelayCallback;
@dynamic notificationStateCallback;
@dynamic discoverDescriptorCallback;
@dynamic appleCharacteristic;
@dynamic readReceived;
@dynamic writeReceived;
@dynamic writingQueue;
@dynamic service;
@dynamic discoveredDescriptors;

- (instancetype)initWithCharacteristic:(CBCharacteristic *)characteristic service:(CNjacob_CBService *)service {
    
    self = [super init];
    
    if (self) {
        self.appleCharacteristic = characteristic;
        
        self.service = service;
        
        self.discoveredDescriptors = [NSMutableDictionary<NSString *, CNjacob_CBDescriptor *> dictionary];
        
        self.writingQueue = [NSMutableArray<CNjacob_CBCharacteristicWriteQueueData *> array];
        
        // Set write received status to YES as default status, make sure it can write next value
        self.writeReceived = YES;
    }
    
    return self;
}

- (void)removeAllDescriptors {
    
    [self.discoveredDescriptors removeAllObjects];
}

- (void)didUpdateValue:(NSError *)error {
    
    self.readReceived = YES;
    
    CNJACOB_ASYNC_CALLBACK(self.readCallback,
                           self.readCallback(self, error),
                           CNjacob_CBCharacteristic,
                           self.centralManager);
    
    // Cancel read delay callback
    [self.centralManager cancelDelayCallback:self.readDelayCallback];
    
    // Free read delay callback
    self.readDelayCallback = nil;
}

- (void)didWriteValue:(NSError *)error {
    
    // Cancel delay callback
    [self.centralManager cancelDelayCallback:self.writeDelayCallback];
    
    // Free write delay callback
    self.writeDelayCallback = nil;
    
    // Write received
    self.writeReceived = YES;
    
    // Check if current write finished
    BOOL finished = YES;
    
    // Check queue data retry times
    CNjacob_CBCharacteristicWriteQueueData *queueData =
    self.writingQueue.count > 0 ? self.writingQueue.firstObject : nil;
    if (error && queueData && queueData.retryTimes > 0) {
        // Check auto rewrite and connect status
        if (self.centralManager.options.autoRewriteAfterFailure &&
            self.service.peripheral.state == CNjacob_CBPeripheralStateConnected) {
            finished = NO;
            queueData.retryTimes --;
        }
    }
    
    if (finished) {
        if (queueData) {
            CNJACOB_ASYNC_CALLBACK(queueData.writeCallback,
                                   queueData.writeCallback(self, queueData.data, error),
                                   CNjacob_CBCharacteristic,
                                   self.centralManager);
        }
        
        if (self.writingQueue.count > 0) {
            @synchronized (self.writingQueue) {
                [self.writingQueue removeObjectAtIndex:0];
            }
        }
    }
    [self writeQueueData];
}

- (void)writeQueueData {
    
    if (!self.writeReceived || self.writingQueue.count <= 0) {
        return ;
    }
    
    if (![self propertyEnabled:CNjacob_CBCharacteristicPropertyWrite]) {
        [self writeNotSupportErrorCallback];
        return ;
    }
    
    CNjacob_CBCharacteristicWriteQueueData *queueData = self.writingQueue.firstObject;
    if (self.service.peripheral.state == CNjacob_CBPeripheralStateConnected) {
        
        [self.service.peripheral.applePeripheral writeValue:queueData.data forCharacteristic:self.appleCharacteristic type:CBCharacteristicWriteWithResponse];
        self.writeReceived = NO;
        [self writeTimeout];
        
    } else {
        NSError *error = [self.centralManager error:@{NSLocalizedDescriptionKey : [NSString stringWithFormat: @"%@ can only accept this command while in the connected state.", self.class]}];
        [self didWriteValue:error];
    }
}

- (void)writeTimeout {
    
    NSTimeInterval timeoutInterval = self.centralManager.options.writeTimeoutInterval;
    if (timeoutInterval <= 0) {
        return ;
    }
    
    __weak typeof(self) weakSelf = self;
    self.writeDelayCallback = dispatch_block_create(0, ^{
        [weakSelf handleWriteTimeout];
    });
    
    // Cancel delay callback
    [self.centralManager delayCallback:timeoutInterval withBlock:self.writeDelayCallback];
}

- (void)handleWriteTimeout {
    if (self.writeReceived) {
        return ;
    }
    // Write timeout, cancel peripheral connection
//        [self.centralManager.cbCentralManager
//            cancelPeripheralConnection:self.service.peripheral.cbPeripheral];
    
    NSError *error = [self.centralManager error:@{NSLocalizedDescriptionKey: @"Write data timeout."}];
    [self didWriteValue:error];
}

- (void)writeNotSupportErrorCallback {
    
    if (self.writingQueue.count <= 0) {
        return ;
    }
    
    CNjacob_CBCharacteristicWriteQueueData *queueData = self.writingQueue.firstObject;
    NSError *error = [self.centralManager error:@{NSLocalizedDescriptionKey: @"Write not supported."}];
    
    CNJACOB_ASYNC_CALLBACK(queueData.writeCallback,
                           queueData.writeCallback(self, queueData.data, error),
                           CNjacob_CBCharacteristic,
                           self.centralManager);
    
    [self.writingQueue removeObject:queueData];
}

- (void)didUpdateNotificationState:(NSError *)error {
    
    CNJACOB_ASYNC_CALLBACK(self.notificationStateCallback,
                           self.notificationStateCallback(self, error),
                           CNjacob_CBCharacteristic,
                           self.centralManager);
}

- (void)didDiscoverDescriptors:(NSError *)error {
    
    CNJACOB_ASYNC_CALLBACK(self.discoverDescriptorCallback,
                           self.discoverDescriptorCallback(self, error),
                           CNjacob_CBCharacteristic,
                           self.centralManager);
}

- (CNjacob_CBCentralManager *)centralManager {
    
    return self.service.peripheral.centralManager;
}

@end
