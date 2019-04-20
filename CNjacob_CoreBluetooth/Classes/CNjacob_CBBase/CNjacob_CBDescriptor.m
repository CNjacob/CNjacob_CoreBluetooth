//
//  CNjacob_CBDescriptor.m
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import "CNjacob_CBDescriptor.h"
#import <CoreBluetooth/CoreBluetooth.h>

#import "CNjacob_CBPeripheral+Private.h"

#import "CNjacob_CBService+Private.h"
#import "CNjacob_CBCharacteristic+Private.h"
#import "CNjacob_CBDescriptor+Private.h"

@interface CNjacob_CBDescriptor () {
    CBUUID *_UUID;
}

@property (nonatomic, copy) CNjacob_CBDescriptorDataCallback readCallback;

@property (nonatomic, copy) CNjacob_CBDescriptorDataCallback writeCallback;

@property (nonatomic, strong) CBDescriptor *appleDescriptor;

@property (nonatomic, assign) CNjacob_CBCharacteristic *characteristic;

@end





@implementation CNjacob_CBDescriptor

- (CNjacob_CBCharacteristic *)characteristic {
    
    return _characteristic;
}

- (CBUUID *)UUID {
    
    if (!_UUID) {
        _UUID = _appleDescriptor.UUID;
    }
    
    return _UUID;
}

- (void)readData:(CNjacob_CBDescriptorDataCallback)readCallback {
    
    self.readCallback = readCallback;
    [self.characteristic.service.peripheral.applePeripheral readValueForDescriptor:self.appleDescriptor];
}

- (void)writeData:(NSData *)data callback:(CNjacob_CBDescriptorDataCallback)writeCallback {
    
    self.writeCallback = writeCallback;
    [self.characteristic.service.peripheral.applePeripheral writeValue:data forDescriptor:self.appleDescriptor];
}

@end
