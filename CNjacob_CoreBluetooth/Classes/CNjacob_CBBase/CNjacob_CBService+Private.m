//
//  CNjacob_CBService+Private.m
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import "CNjacob_CBService+Private.h"

#import "CNjacob_CoreBluetoothManager+Private.h"
#import "CNjacob_CBCentralManager.h"

#import "CNjacob_CBPeripheral+Private.h"

#import "CNjacob_CBAttribute.h"
#import "CNjacob_CBCharacteristic+Private.h"

@implementation CNjacob_CBService (Private)

@dynamic appleService;
@dynamic discoveredCharacterists;
@dynamic discoveredIncludedServices;
@dynamic discoverCallback;
@dynamic peripheral;

- (instancetype)initWithService:(CBService *)service peripheral:(CNjacob_CBPeripheral *)peripheral {
    
    self = [super init];
    
    if (self) {
        self.appleService = service;
        self.peripheral = peripheral;
        self.discoveredCharacterists = [NSMutableDictionary<NSString *, CNjacob_CBCharacteristic *> dictionary];
    }
    
    return self;
}

- (void)removeAllCharacteristics {
    
    for (CNjacob_CBCharacteristic *characteristic in self.discoveredCharacterists.allValues) {
        [characteristic removeAllDescriptors];
    }
    
    [self.discoveredCharacterists removeAllObjects];
}

- (void)didDiscoverCharacteristics:(NSError *)error {
    
    CNJACOB_ASYNC_CALLBACK(self.discoverCallback,
                           self.discoverCallback(self, error),
                           CNjacob_CBService,
                           self.centralManager);
}

- (CNjacob_CBCentralManager *)centralManager {
    
    return self.peripheral.centralManager;
}

@end
