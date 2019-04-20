//
//  CNjacob_CBCentralManager.h
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import "CNjacob_CoreBluetoothManager.h"

NS_ASSUME_NONNULL_BEGIN

@class CBCentralManager, CBUUID, CNjacob_CBCentralManager, CNjacob_CBCentralManagerOptions, CNjacob_CBPeripheral;

//  CNjacob_CBCentralManager common callback
typedef void (^CNjacob_CBCentralManagerCallback) (CNjacob_CBCentralManager *centralManager);

//  CNjacob_CBCentralManager error callback
typedef void (^CNjacob_CBCentralManagerErrorCallback) (CNjacob_CBCentralManager *centralManager,
                                               NSError * _Nullable error);

//  CNjacob_CBCentralManager discover peripheral callback
typedef void (^CNjacob_CBCentralManagerDiscoverPeripheralCallback) (CNjacob_CBCentralManager *centralManager,
                                                            CNjacob_CBPeripheral *peripheral);





@interface CNjacob_CBCentralManager : CNjacob_CoreBluetoothManager

/**
 *  @property options An optional dictionary specifying options for the manager.
 *
 *  @discussion CNjacobCentral manager options, see 'CNjacob_CBCentralManagerOptions' for details
 */
@property (nonatomic, strong, readonly) CNjacob_CBCentralManagerOptions *options;

/**
 *  @property connectedPeripherals A collect of connected peripherals
 */
@property (nonatomic, strong, readonly) NSArray *connectedPeripherals;

/**
 *  @property discoveredPeripherals A collect of discovered peripherals
 */
@property (nonatomic, strong, readonly) NSArray *discoveredPeripherals;





/**
 *  Creates and returns a 'CNjacobCenteralManager' object
 */
+ (CNjacob_CBCentralManager *)manager;

/**
 *  @method stateDidUpdate:
 *
 *  @param stateDidUpdateCallback Callback after CNjacob_CBCentralManager state did update
 */
- (void)stateDidUpdate:(CNjacob_CBCentralManagerCallback)stateDidUpdateCallback;

/**
 *  @method startScanning: with callback
 *
 *  @param discoverPeripheralCallback discover callback
 */
- (void)startScanning:(nullable CNjacob_CBCentralManagerDiscoverPeripheralCallback)discoverPeripheralCallback;

/**
 *  @method startScanning: with callback
 *
 *  @param discoverPeripheralCallback discover callback
 *  @param timeoutCallback scan timeout callback
 *          @see CNjacob_CBCentralManagerOptions's scanTimeoutInterval
 */
- (void)startScanning:(nullable CNjacob_CBCentralManagerDiscoverPeripheralCallback)discoverPeripheralCallback timeoutCallback:(nullable CNjacob_CBCentralManagerErrorCallback)timeoutCallback;

/**
 *  @method startScanningForPeripheralsWithServices:discoverCallback
 *
 *  @param serviceUUIDs services to be discovered
 *  @param discoverPeripheralCallback discover peripheral callback
 *  @param timeoutCallback scan timeout callback
 *          @see CNjacob_CBCentralManagerOptions's scanTimeoutInterval
 */
- (void)startScanningForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs discoverCallback:(nullable CNjacob_CBCentralManagerDiscoverPeripheralCallback)discoverPeripheralCallback timeoutCallback:(nullable CNjacob_CBCentralManagerErrorCallback)timeoutCallback;

/**
 *  @method stopScanning
 */
- (void)stopScanning;

/**
 *  @method disconnectAllPeripherals
 */
- (void)disconnectAllPeripherals;

/**
 *  @method retrieveConnectedPeripheralsWithServices:
 */
- (NSArray<CNjacob_CBPeripheral *> *)retrieveConnectedPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs;

@end

NS_ASSUME_NONNULL_END
