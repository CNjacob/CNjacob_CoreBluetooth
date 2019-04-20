//
//  CNjacob_CBCentralManagerOptions.m
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import "CNjacob_CBCentralManagerOptions.h"

@implementation CNjacob_CBCentralManagerOptions

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        _scanTimeoutInterval = 0;
        _connectTimeoutInterval = 5;
        _readTimeoutInterval = 5;
        _writeTimeoutInterval = 5;
        _writeRetryTimes = 3;
        _connectRetryTimes = 3;
        _autoReconnectAfterDisconnect = NO;
        _autoRewriteAfterFailure = NO;
    }
    
    return self;
}

@end
