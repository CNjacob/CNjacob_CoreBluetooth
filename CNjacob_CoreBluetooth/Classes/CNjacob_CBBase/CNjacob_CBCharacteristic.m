//
//  CNjacob_CBCharacteristic.m
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import "CNjacob_CBCharacteristic.h"
#import <CoreBluetooth/CoreBluetooth.h>

#import "CNjacob_CoreBluetoothManager+Private.h"
#import "CNjacob_CBCentralManager.h"
#import "CNjacob_CBCentralManagerOptions.h"

#import "CNjacob_CBPeripheral+Private.h"

#import "CNjacob_CBAttribute.h"
#import "CNjacob_CBService+Private.h"
#import "CNjacob_CBCharacteristic+Private.h"

@interface CNjacob_CBCharacteristic () {
    CBUUID *_UUID;
}

@property (nonatomic, strong) CBCharacteristic *appleCharacteristic;

@property (nonatomic, strong) NSMutableDictionary<NSString *, CNjacob_CBDescriptor *> *discoveredDescriptors;

@property (nonatomic, copy) dispatch_block_t readDelayCallback;

@property (nonatomic, copy) dispatch_block_t writeDelayCallback;

@property (nonatomic, copy) CNjacob_CBCharacteristicCallback readCallback;

@property (nonatomic, copy) CNjacob_CBCharacteristicCallback notificationStateCallback;

@property (nonatomic, copy) CNjacob_CBCharacteristicCallback discoverDescriptorCallback;

@property (nonatomic, assign) BOOL readReceived;

@property (nonatomic, assign) BOOL writeReceived;

@property (nonatomic, assign) CNjacob_CBService *service;

@property (nonatomic, strong) NSMutableArray<CNjacob_CBCharacteristicWriteQueueData *> *writingQueue;

@end





@implementation CNjacob_CBCharacteristic

- (BOOL)isNotifying {
    
    return self.appleCharacteristic.isNotifying;
}

- (CBUUID *)UUID {
    
    if (!_UUID) {
        _UUID = _appleCharacteristic.UUID;
    }
    
    return _UUID;
}

- (NSString *)name {
    
    return @"Unkown";
}

- (NSData *)value {
    
    return self.appleCharacteristic.value;
}

- (NSArray<CNjacob_CBDescriptor *> *)descriptors {
    
    return self.discoveredDescriptors.allValues;
}

- (BOOL)propertyEnabled:(CNjacob_CBCharacteristicProperties)property {
    
    return (self.appleCharacteristic.properties & (CBCharacteristicProperties)property);
}

- (void)readData:(CNjacob_CBCharacteristicCallback)readCallback {
    
    if (!readCallback) {
        return ;
    }
    
    self.readCallback = readCallback;
    
    // Check read property
    if ([self propertyEnabled:CNjacob_CBCharacteristicPropertyRead]) {
        self.readReceived = NO;
        [self.service.peripheral.applePeripheral readValueForCharacteristic:self.appleCharacteristic];
        [self readTimeout];
        
    } else {
        [self readNotSupportErrorCallback];
    }
}

- (void)receiveUpdates:(CNjacob_CBCharacteristicCallback)notifyCallback {
    
    if (!notifyCallback) {
        return ;
    }
    
    if (![self propertyEnabled:CNjacob_CBCharacteristicPropertyNotify]) {
        return ;
    }
    
    self.readCallback = notifyCallback;
}

- (void)dropUpdates {
    
    self.readCallback = nil;
}

- (void)startNotifications:(CNjacob_CBCharacteristicCallback)notificationStateCallback {
    
    self.notificationStateCallback = notificationStateCallback;
    
    if ([self propertyEnabled:CNjacob_CBCharacteristicPropertyNotify]) {
        [self.service.peripheral.applePeripheral setNotifyValue:YES forCharacteristic:self.appleCharacteristic];
        
    } else {
        [self notificationNotSupportErrorCallback];
    }
}

- (void)stopNotifications:(CNjacob_CBCharacteristicCallback)notificationStateCallback {
    
    self.notificationStateCallback = notificationStateCallback;
    
    if ([self propertyEnabled:CNjacob_CBCharacteristicPropertyNotify]) {
        [self.service.peripheral.applePeripheral setNotifyValue:NO forCharacteristic:self.appleCharacteristic];
        
    } else {
        [self notificationNotSupportErrorCallback];
    }
}

- (void)writeData:(NSData *)data {
    
    if ([self propertyEnabled:CNjacob_CBCharacteristicPropertyWriteWithoutResponse]) {
        
        if ([self.service.peripheral.applePeripheral canSendWriteWithoutResponse]) {
            [self.service.peripheral.applePeripheral writeValue:data forCharacteristic:self.appleCharacteristic type:CBCharacteristicWriteWithoutResponse];
            
        } else {
            //TODO: peripheralIsReadyToSendWriteWithoutResponse
        }
        
    } else if ([self propertyEnabled:CNjacob_CBCharacteristicPropertyWrite]) {
        [self writeData:data callback:nil];
        
    } else {
        // Write not support
    }
}

- (void)writeData:(NSData *)data callback:(CNjacob_CBCharacteristicWriteDataCallback)writeCallback {
    
    // Create a queue data
    NSInteger retryTimes = self.centralManager.options.writeRetryTimes;
    
    CNjacob_CBCharacteristicWriteQueueData *queueData = [[CNjacob_CBCharacteristicWriteQueueData alloc] initWithData:data retryTimes:retryTimes callback:writeCallback];
    
    // Add data to queue
    @synchronized (self.writingQueue) {
        [self.writingQueue addObject:queueData];
    }
    
    // Start write in queue
    [self writeQueueData];
}

- (void)discoverDiscriptors:(CNjacob_CBCharacteristicCallback)discoverDescriptorCallback {
    
    self.discoverDescriptorCallback = discoverDescriptorCallback;
    
    [self.service.peripheral.applePeripheral discoverDescriptorsForCharacteristic:self.appleCharacteristic];
}

- (void)readTimeout {
    
    NSTimeInterval timeoutInterval = self.centralManager.options.readTimeoutInterval;
    
    if (timeoutInterval <= 0) {
        return ;
    }
    
    __weak typeof(self) weakSelf = self;
    self.readDelayCallback = dispatch_block_create(0, ^{
        [weakSelf handleReadTimeout];
    });
    [self.centralManager delayCallback:timeoutInterval withBlock:self.readDelayCallback];
}

- (void)handleReadTimeout {
    
    if (self.readReceived) {
        return ;
    }
    
    // Read timeout, cancel peripheral connection
//        [self.centralManager.cbCentralManager
//            cancelPeripheralConnection:self.service.peripheral.cbPeripheral];
    
    NSError *error = [self.centralManager error:@{NSLocalizedDescriptionKey: @"Read data timeout."}];
    [self didUpdateValue:error];
}

- (void)readNotSupportErrorCallback {
    
    NSError *error = [self.centralManager error:@{NSLocalizedDescriptionKey: @"Read not supported."}];
    CNJACOB_ASYNC_CALLBACK(self.readCallback,
                           self.readCallback(self, error),
                           CNjacob_CBCharacteristic,
                           self.centralManager);
}

- (void)notificationNotSupportErrorCallback {
    
    NSError *error = [self.centralManager error:@{NSLocalizedDescriptionKey: @"Notifications not supported."}];
    CNJACOB_ASYNC_CALLBACK(self.notificationStateCallback,
                           self.notificationStateCallback(self, error),
                           CNjacob_CBCharacteristic,
                           self.centralManager);
}

@end
