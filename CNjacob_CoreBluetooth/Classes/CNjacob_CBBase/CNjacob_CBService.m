//
//  CNjacob_CBService.m
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import "CNjacob_CBService.h"
#import <CoreBluetooth/CoreBluetooth.h>

#import "CNjacob_CBPeripheral+Private.h"

@interface CNjacob_CBService () {
    CBUUID *_UUID;
}

@property (nonatomic, strong) CBService *appleService;

@property (nonatomic, strong) NSMutableDictionary<NSString *, CNjacob_CBCharacteristic *> *discoveredCharacterists;

@property (nonatomic, strong) NSMutableDictionary<NSString *, CNjacob_CBService *> *discoveredIncludedServices;

@property (nonatomic, assign) CNjacob_CBPeripheral *peripheral;

@property (nonatomic, copy) CNjacob_CBServiceDiscoverCharacteristicCallback discoverCallback;

@end





@implementation CNjacob_CBService

- (CNjacob_CBPeripheral *)peripheral {
    
    return _peripheral;
}

- (CBUUID *)UUID {
    
    if (!_UUID) {
        _UUID = _appleService.UUID;
    }
    
    return _UUID;
}

- (BOOL)isPrimary {
    
    return self.appleService.isPrimary;
}

- (NSString*)name {
    
    return @"Unknown";
}

- (NSArray<CNjacob_CBCharacteristic *> *)characteristics {
    
    return self.discoveredCharacterists.allValues;
}

- (NSArray<CNjacob_CBService *> *)includedServices {
    
    return self.discoveredIncludedServices.allValues;
}

- (void)discoverCharacteristics:(CNjacob_CBServiceDiscoverCharacteristicCallback)discoverCallback {
    
    [self discoverCharacteristics:nil callback:discoverCallback];
}

- (void)discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs callback:(CNjacob_CBServiceDiscoverCharacteristicCallback)discoverCallback {
    
    self.discoverCallback = discoverCallback;
    [self.peripheral.applePeripheral discoverCharacteristics:characteristicUUIDs forService:self.appleService];
}

- (CNjacob_CBCharacteristic *)characteristicWithUUID:(NSString *)UUID {
    
    return [self.discoveredCharacterists objectForKey:UUID];
}

@end
