//
//  CNjacob_CBPeripheral+Private.m
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import "CNjacob_CBPeripheral+Private.h"

#import "CNjacob_CoreBluetoothManager+Private.h"
#import "CNjacob_CBCentralManager.h"
#import "CNjacob_CBCentralManagerOptions.h"

@implementation CNjacob_CBPeripheral (Private)

@dynamic connectCallback;
@dynamic delayCallback;
@dynamic disconnectCallback;
@dynamic receiveDisconnectCallback;
@dynamic receiveAdvertisingCallback;
@dynamic discoverCallback;
@dynamic applePeripheral;
@dynamic connectionSequenceNumber;
@dynamic advertisementData;
@dynamic discoveredServices;
@dynamic RSSI;
@dynamic connectRetryTimes;
@dynamic connectOptions;
@dynamic centralManager;

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral centralManager:(nonnull CNjacob_CBCentralManager *)centralManager {
    
    return [self initWithPeripheral:peripheral advertisementData:nil RSSI:nil centralManager:centralManager];
}

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI centralManager:(nonnull CNjacob_CBCentralManager *)centralManager {
    
    self = [super init];
    if (self) {
        self.centralManager = centralManager;
        self.discoveredServices = [NSMutableDictionary<NSString *, CNjacob_CBService *> dictionary];
        self.applePeripheral = peripheral;
        self.applePeripheral.delegate = self;
        self.advertisementData = advertisementData;
        self.RSSI = RSSI;
        self.connectRetryTimes = self.centralManager.options.connectRetryTimes;
    }
    return self;
}

- (void)didConnectPeripheral:(NSError *)error {
    // Reset connection sequence number
    self.connectionSequenceNumber = 0;
    
    if (error
        && self.centralManager.options.autoReconnectAfterDisconnect
        && self.connectRetryTimes > 0) {
        
        // Decrease retry times and try to reconnect
        self.connectRetryTimes --;
        [self connect:self.connectOptions callback:self.connectCallback];
        
    } else {
        // Connect callback
        CNJACOB_ASYNC_CALLBACK(self.connectCallback,
                               self.connectCallback(self, error),
                               CNjacob_CBPeripheral,
                               self.centralManager);
        // Cancel delay callback
        [self.centralManager cancelDelayCallback:self.delayCallback];
        
        // Free delay callback
        self.delayCallback = nil;
    }
}

- (void)didDisconnectPeripheral:(NSError *)error {
    
    self.connectRetryTimes = self.centralManager.options.connectRetryTimes;
    
    // Disconnect callback
    if (self.disconnectCallback) {
        CNJACOB_ASYNC_CALLBACK(self.disconnectCallback,
                               self.disconnectCallback(self, error),
                               CNjacob_CBPeripheral,
                               self.centralManager);
        
    } else if (self.receiveDisconnectCallback) {
        // Receive disconnect callback
        CNJACOB_ASYNC_CALLBACK(self.receiveDisconnectCallback,
                               self.receiveDisconnectCallback(self, error),
                               CNjacob_CBPeripheral,
                               self.centralManager)
    }
}

- (void)didReceiveAdvertising:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    self.advertisementData = advertisementData;
    self.RSSI = RSSI;
    // Here has a bug, because didDiscoverPeripheral using async callback,
    //      so this may happens before you call receiveAdvertising
    CNJACOB_ASYNC_CALLBACK(self.receiveAdvertisingCallback,
                           self.receiveAdvertisingCallback(self, nil),
                           CNjacob_CBPeripheral,
                           self.centralManager);
}

@end
