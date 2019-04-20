//
//  CNjacob_CBDescriptor+Private.m
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import "CNjacob_CBDescriptor+Private.h"

#import "CNjacob_CoreBluetoothManager+Private.h"
#import "CNjacob_CBCentralManager.h"

#import "CNjacob_CBAttribute.h"
#import "CNjacob_CBCharacteristic+Private.h"

@implementation CNjacob_CBDescriptor (Private)

@dynamic characteristic;
@dynamic appleDescriptor;
@dynamic readCallback;
@dynamic writeCallback;

- (instancetype)initWithDescriptor:(CBDescriptor *)descriptor characteristic:(CNjacob_CBCharacteristic *)characteristic {
    
    self = [super init];
    
    if (self) {
        self.characteristic = characteristic;
        self.appleDescriptor = descriptor;
    }
    
    return self;
}

- (void)didUpdateValue:(NSError *)error {
    
    CNJACOB_ASYNC_CALLBACK(self.readCallback,
                           self.readCallback(self, error),
                           CNjacob_CBDescriptor,
                           self.centralManager);
}

- (void)didWriteValue:(NSError *)error {
    
    CNJACOB_ASYNC_CALLBACK(self.writeCallback,
                           self.writeCallback(self, error),
                           CNjacob_CBDescriptor,
                           self.centralManager);
}

- (CNjacob_CBCentralManager *)centralManager {
    
    return self.characteristic.centralManager;
}

@end
