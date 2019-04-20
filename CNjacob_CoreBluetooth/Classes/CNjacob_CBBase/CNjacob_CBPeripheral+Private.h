//
//  CNjacob_CBPeripheral+Private.h
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import "CNjacob_CBPeripheral.h"
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@class CNjacob_CBCentralManager, CNjacob_CBService;

/**
 *  @Category CNjacob_CBPeripheral+Private
 */
@interface CNjacob_CBPeripheral (Private) <CBPeripheralDelegate>

@property (nonatomic, strong) CBPeripheral *applePeripheral;

@property (nonatomic, copy) CNjacob_CBPeripheralCallback connectCallback;

@property (nonatomic, copy, nullable) dispatch_block_t delayCallback;

@property (nonatomic, copy) CNjacob_CBPeripheralCallback disconnectCallback;

@property (nonatomic, copy) CNjacob_CBPeripheralCallback receiveDisconnectCallback;

@property (nonatomic, copy) CNjacob_CBPeripheralCallback receiveAdvertisingCallback;

@property (nonatomic, copy) CNjacob_CBPeripheralCallback discoverCallback;

@property (nonatomic, assign) NSInteger connectionSequenceNumber;

@property (nonatomic, strong) NSMutableDictionary<NSString *, CNjacob_CBService *> *discoveredServices;

@property (nonatomic, strong) NSDictionary<NSString *, id> *advertisementData;

@property (atomic, strong) NSNumber *RSSI;

/**
 *  @property connectRetryTimes if connect failed or timeout how many times it will retry
 */
@property (atomic, assign) NSInteger connectRetryTimes;

@property (nonatomic, strong) NSDictionary<NSString *,id> *connectOptions;

@property (nonatomic, assign) CNjacob_CBCentralManager *centralManager;





/**
 *  @method initWithPeripheral Initialize a CNjacob_CBPeripheral with a CBPeripheral object
 *
 *  @param peripheral Core Bluetooth Peripheral
 *  @param centralManager Access to central manager
 */
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
                    centralManager:(CNjacob_CBCentralManager *)centralManager;

/**
 *  @method initWithPeripheral Initialize a CNjacob_CBPeripheral with a CBPeripheral object, etc
 *
 *  @param peripheral Core Bluetooth Peripheral
 *  @param advertisementData Advertisement data
 *  @param RSSI RSSI number
 *  @param centralManager Access to central manager
 */
- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral
                 advertisementData:(nullable NSDictionary<NSString *,id> *)advertisementData
                              RSSI:(nullable NSNumber *)RSSI
                    centralManager:(CNjacob_CBCentralManager *)centralManager;

/**
 *  @method didConnectPeripheral
 */
- (void)didConnectPeripheral:(nullable NSError *)error;

/**
 *  @method didDisconnectPeripheral
 */
- (void)didDisconnectPeripheral:(nullable NSError *)error;

/**
 *  @method didReceiveAdvertising
 */
- (void)didReceiveAdvertising:(nullable NSDictionary<NSString *,id> *)advertisementData
                         RSSI:(NSNumber *)RSSI;

@end

NS_ASSUME_NONNULL_END
