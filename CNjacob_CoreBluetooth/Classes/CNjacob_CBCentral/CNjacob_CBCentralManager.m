//
//  CNjacob_CBCentralManager.m
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import "CNjacob_CBCentralManager.h"
#import <CoreBluetooth/CoreBluetooth.h>

#import "CNjacob_CoreBluetoothManager+Private.h"
#import "CNjacob_CBCentralManager+Private.h"
#import "CNjacob_CBCentralManagerOptions.h"

#import "CNjacob_CBPeripheral.h"
#import "CNjacob_CBPeripheral+Private.h"

@interface CNjacob_CBCentralManager () <CBCentralManagerDelegate>

@property (nonatomic, strong) dispatch_queue_t mainQueue;

@property (nonatomic, strong) dispatch_queue_t callbackQueue;

@property (nonatomic, strong) CBCentralManager *appleCentralManager;

@property (nonatomic, strong) NSMutableDictionary<NSString *, CNjacob_CBPeripheral *> *configuredConnectedPeripherals;

@property (nonatomic, strong) NSMutableDictionary<NSString *, CNjacob_CBPeripheral *> *configuredDiscoveredPeripherals;

@property (nonatomic, copy) CNjacob_CBCentralManagerCallback stateDidUpdateCallback;

@property (nonatomic, copy) CNjacob_CBCentralManagerDiscoverPeripheralCallback discoverPeripheralCallback;

@property (nonatomic, copy) CNjacob_CBCentralManagerErrorCallback timeoutCallback;

@property (nonatomic, copy) dispatch_block_t delayCallback;

/**
 *  @property isScanning, why use custom isScanning because
 *  CBCentralManager isScanning only works on ios9.0 or later
 */
@property (nonatomic, assign) BOOL isScanning;

@property (nonatomic, assign) BOOL isWaitingScanning;

@property (nonatomic, strong) NSArray<CBUUID *> *serviceUUIDs;

@end





@implementation CNjacob_CBCentralManager

+ (CNjacob_CBCentralManager *)manager {
    
    return [CNjacob_CBCentralManager new];
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        _options = [[CNjacob_CBCentralManagerOptions alloc] init];
        
        _configuredConnectedPeripherals = [NSMutableDictionary<NSString *, CNjacob_CBPeripheral *> dictionary];
        _configuredDiscoveredPeripherals = [NSMutableDictionary<NSString *, CNjacob_CBPeripheral *> dictionary];
        
        _mainQueue = [self createQueue:DISPATCH_QUEUE_SERIAL];
        _callbackQueue = [self createQueue:DISPATCH_QUEUE_SERIAL];
    }
    
    return self;
}

- (CBCentralManager *)appleCentralManager {
    
    if (!_appleCentralManager) {
        _appleCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:self.options.dispatchQueue options:self.options.managerOptions];
    }
    
    return _appleCentralManager;
}

- (CNjacob_CoreBluetoothManagerState)state {
    
    return (CNjacob_CoreBluetoothManagerState)self.appleCentralManager.state;
}

- (NSArray<CNjacob_CBPeripheral *> *)connectedPeripherals {
    
    return self.configuredConnectedPeripherals.allValues;
}

- (NSArray<CNjacob_CBPeripheral *> *)discoveredPeripherals {
    
    return self.configuredDiscoveredPeripherals.allValues;
}

- (void)stateDidUpdate:(CNjacob_CBCentralManagerCallback)stateDidUpdateCallback {
    
    self.stateDidUpdateCallback = stateDidUpdateCallback;
    if (self.state != CNjacob_CoreBluetoothManagerStateUnknown) {
        [self centralManagerStateDidUpdateCallback];
    }
}

- (void)startScanning:(CNjacob_CBCentralManagerDiscoverPeripheralCallback)discoverPeripheralCallback {
    
    [self startScanning:discoverPeripheralCallback timeoutCallback:nil];
}

- (void)startScanning:(CNjacob_CBCentralManagerDiscoverPeripheralCallback)discoverPeripheralCallback timeoutCallback:(CNjacob_CBCentralManagerErrorCallback)timeoutCallback {
    
    [self startScanningForPeripheralsWithServices:nil discoverCallback:discoverPeripheralCallback timeoutCallback:timeoutCallback];
}

- (void)startScanningForPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs discoverCallback:(CNjacob_CBCentralManagerDiscoverPeripheralCallback)discoverPeripheralCallback timeoutCallback:(CNjacob_CBCentralManagerErrorCallback)timeoutCallback {
    
    self.serviceUUIDs = serviceUUIDs;
    
    if (self.isScanning) {
        return ;
    }
    
    self.isScanning = YES;
    // Clear all discovered peripherals
    [self.configuredDiscoveredPeripherals removeAllObjects];
    [self.configuredConnectedPeripherals removeAllObjects];
    
    self.discoverPeripheralCallback = discoverPeripheralCallback;
    self.timeoutCallback = timeoutCallback;
    
    if (self.state == CNjacob_CoreBluetoothManagerStatePoweredOn) {
        [self startScan:serviceUUIDs];
    } else {
        // Will start scan after power on
        self.isWaitingScanning = YES;
    }
}

- (void)startScan:(nullable NSArray<CBUUID *> *)serviceUUIDs {
    
    NSArray<CBUUID *> *UUIDs = serviceUUIDs ?: self.options.serviceUUIDs;
    [self.appleCentralManager scanForPeripheralsWithServices:UUIDs options:self.options.scanOptions];
    
    // Timeout check
    if (self.options.scanTimeoutInterval <= 0) {
        return ;
    }
    __weak typeof(self) weakSelf = self;
    self.delayCallback = dispatch_block_create(0, ^{
        [weakSelf handleScanTimeout];
    });
    [self delayCallback:self.options.scanTimeoutInterval withBlock:self.delayCallback];
}

- (void)handleScanTimeout {
    
    if (!self.isScanning) {
        return ;
    }
    
    // Stop scanning
    [self stopScanning];
    
    // Scanning timeout callback
    NSError *error = [self error:@{NSLocalizedDescriptionKey: @"Scanning timeout."}];
    
    CNJACOB_ASYNC_CALLBACK(self.timeoutCallback,
                           self.timeoutCallback(self, error),
                           CNjacob_CBCentralManager,
                           self);
}

- (void)stopScanning {
    
    if (!self.isScanning) {
        return ;
    }
    self.isScanning = NO;
    [self.appleCentralManager stopScan];
}

- (void)disconnectAllPeripherals {
    
    for (CNjacob_CBPeripheral *peripheral in self.configuredConnectedPeripherals) {
        [peripheral disconnect];
    }
}

- (NSArray<CNjacob_CBPeripheral *> *)retrieveConnectedPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs {
    
    NSArray<CBPeripheral *> *cbPeripherals = [self.appleCentralManager retrieveConnectedPeripheralsWithServices:serviceUUIDs];
    
    if (!cbPeripherals || cbPeripherals.count <= 0) {
        return nil;
    }
    
    NSMutableArray<CNjacob_CBPeripheral *> *CNjacob_CBPeripherals = [NSMutableArray<CNjacob_CBPeripheral *> array];
    
    for (CBPeripheral *cbPeripheral in cbPeripherals) {
        
        CNjacob_CBPeripheral *jacob_CBPeripheral = [[CNjacob_CBPeripheral alloc] initWithPeripheral:cbPeripheral centralManager:self];
        [CNjacob_CBPeripherals addObject:jacob_CBPeripheral];
        
        // Add to configured peripheral
        [self addPeripheral:jacob_CBPeripheral to:self.configuredDiscoveredPeripherals];
    }
    
    return CNjacob_CBPeripherals;
}





#pragma mark - CentralManagerDelegate
/**
 *  @method centralManagerDidUpdateState:
 *
 *  The central manager whose state has changed.
 *  You should call 'scanForPeripheralsWithServices'
 *          when central.state is CBCentralManagerStatePoweredOn
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    CNjacob_CoreBluetoothManagerState state = (CNjacob_CoreBluetoothManagerState)central.state;
    // State did update callback
    [self centralManagerStateDidUpdateCallback];
    
    // Check is waiting scanning status
    if (state == CNjacob_CoreBluetoothManagerStatePoweredOn && self.isWaitingScanning) {
        self.isWaitingScanning = NO;
        [self startScan:self.serviceUUIDs];
        
    } else if (state != CNjacob_CoreBluetoothManagerStatePoweredOn) {
        // Not powered on state, stop scanning to reset is scanning state
        [self stopScanning];
    }
}

/**
 *  @method centralManager:willRestoreState:
 *            This method is invoked when the app is relaunched into the background
 *
 *  @seealso  CBCentralManagerRestoredStatePeripheralsKey;
 *  @seealso  CBCentralManagerRestoredStateScanServicesKey;
 *  @seealso  CBCentralManagerRestoredStateScanOptionsKey;
 */
- (void)centralManager:(CBCentralManager *)central
      willRestoreState:(NSDictionary<NSString *, id> *)dict {
    
    // App is relaunched into background
//    NSArray<CBPeripheral *> *peripherals =
//    [dict objectForKey:CBCentralManagerRestoredStatePeripheralsKey];
//    NSArray<CBService *> *services =
//    [dict objectForKey:CBCentralManagerRestoredStateScanServicesKey];
}

/**
 *  @method centralManager:didDiscoverPeripheral:advertisementData:RSSI:
 *
 *  Did discover peripheral callback
 *  This method is invoked after you call CBCentralManager's scanForPeripheralsWithServices
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    CNjacob_CBPeripheral *jacobPeripheral = [self.configuredDiscoveredPeripherals objectForKey:peripheral.identifier.UUIDString];
    
    if (!jacobPeripheral) {
        jacobPeripheral = [[CNjacob_CBPeripheral alloc] initWithPeripheral:peripheral
                                                 advertisementData:advertisementData
                                                              RSSI:RSSI
                                                    centralManager:self];
        // Add peripheral to discovered peripherals
        [self addPeripheral:jacobPeripheral to:self.configuredDiscoveredPeripherals];
        
    } else {
        [jacobPeripheral didReceiveAdvertising:advertisementData RSSI:RSSI];
    }
    
    // Peripheral callback
    [self discoverPeripheralCallback:jacobPeripheral];
}

/**
 *  @method centralManager:didConnectPeripheral:
 *
 *  Central did connect to peripheral callback
 *  This method is invoked afater you call CBCentralManager's connectPeripheral
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    CNjacob_CBPeripheral *CNjacob_CBPeripheral = [self.configuredDiscoveredPeripherals objectForKey:peripheral.identifier.UUIDString];
    
    if (!CNjacob_CBPeripheral) {
        return ;
    }
    
    // Add peripheral to connected peripherals if not exists in connected peripherals
    [self addPeripheral:CNjacob_CBPeripheral to:self.configuredConnectedPeripherals];
    
    // Reset connect error because error property is not nil
    //      if has failed to connect before this
    CNjacob_CBPeripheral.error = nil;
    
    // Peripheral connect callback
    [CNjacob_CBPeripheral didConnectPeripheral:CNjacob_CBPeripheral.error];
    
    // Cancel dealy callback
    [self cancelDelayCallback:self.delayCallback];
    
    // Free delay callback
    self.delayCallback = nil;
}

/**
 *  @method centralManager:didDisconnectPeripheral:error:
 *
 *  Central did disconnect from peripheral
 *  This method is invoked after you call CBCentralManager's cancelPeripheralConnection
 *      or by other reasons
 *  If this method is not invoked by CBCentralManager's cancelPeripheralConnection
 *      the cause will be detailed in the error parameters
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    // Look up peripheral in discovered peripherals instead of connected peripherals
    CNjacob_CBPeripheral *CNjacob_CBPeripheral = [self.configuredDiscoveredPeripherals objectForKey:peripheral.identifier.UUIDString];
    
    if (!CNjacob_CBPeripheral) {
        return ;
    }
    
    // Peripheral callback
    if (CNjacob_CBPeripheral.error) {
        // Peripheral connect calback
        [CNjacob_CBPeripheral didConnectPeripheral:CNjacob_CBPeripheral.error];
        
    } else {
        // Peripheral connect calback
        [CNjacob_CBPeripheral didDisconnectPeripheral:error];
    }
    
    // Remove peripheral from connected peripheral
    [self removePeripheral:CNjacob_CBPeripheral to:self.configuredConnectedPeripherals];
}

/**
 *  @method centralManager:didFailToConnectPeripheral:error
 *
 *  Central did fail to connect peripheral
 *  This method is invoked after you call CBCentralManager's connectPeripheral,
 *      but failed to complete
 *  More details see the error parameter
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    // Look up peripheral in discovered peripherals instead of connected peripherals
    CNjacob_CBPeripheral *CNjacob_CBPeripheral = [self.configuredDiscoveredPeripherals objectForKey:peripheral.identifier.UUIDString];
    
    if (!CNjacob_CBPeripheral) {
        return ;
    }
    
    // Assign connect error to peripheral
    CNjacob_CBPeripheral.error = error;
    
    // Peripheral connect calback
    [CNjacob_CBPeripheral didConnectPeripheral:error];
}





#pragma mark - public
- (void)addPeripheral:(CNjacob_CBPeripheral *)peripheral to:(NSMutableDictionary<NSString *, CNjacob_CBPeripheral *> *)mutableDisctionary {
    
    if (!peripheral || !mutableDisctionary) {
        return ;
    }
    
    [mutableDisctionary setObject:peripheral forKey:peripheral.identifier.UUIDString];
}

- (void)removePeripheral:(CNjacob_CBPeripheral *)peripheral to:(NSMutableDictionary<NSString *, CNjacob_CBPeripheral *> *)mutableDictionary {
    
    if (!peripheral || !mutableDictionary) {
        return ;
    }
    
    [mutableDictionary removeObjectForKey:peripheral.identifier.UUIDString];
}

- (void)centralManagerStateDidUpdateCallback {
    
    CNJACOB_ASYNC_CALLBACK(self.stateDidUpdateCallback,
                           self.stateDidUpdateCallback(self),
                           CNjacob_CBCentralManager,
                           self);
}

- (void)discoverPeripheralCallback:(CNjacob_CBPeripheral *)peripheral {
    
    CNJACOB_ASYNC_CALLBACK(self.discoverPeripheralCallback,
                           self.discoverPeripheralCallback(self, peripheral),
                           CNjacob_CBCentralManager,
                           self);
}

@end
