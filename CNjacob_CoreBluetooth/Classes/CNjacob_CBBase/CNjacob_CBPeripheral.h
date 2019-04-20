//
//  CNjacob_CBPeripheral.h
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  @enum CNjacob_CBPeripheralState
 *
 *  @discussion Represents the current state of a CNjacob_CBPeripheral.
 *
 *  @constant CNjacob_CBPeripheralStateDisconnected       State disconnected, update imminent.
 *  @constant CNjacob_CBPeripheralStateConnecting         State connecting.
 *  @constant CNjacob_CBPeripheralStateConnected          State connected.
 *  @constant CNjacob_CBPeripheralStateDisconnecting      State disconnecting.
 */
typedef NS_ENUM(NSInteger, CNjacob_CBPeripheralState) {
    CNjacob_CBPeripheralStateDisconnected = 0,
    CNjacob_CBPeripheralStateConnecting,
    CNjacob_CBPeripheralStateConnected,
    CNjacob_CBPeripheralStateDisconnecting NS_AVAILABLE(10_13, 9_0),
};

@class CBUUID, CNjacob_CBService, CNjacob_CBPeripheral;

/**
 *  Peripheral connect callback
 *
 *  @discussion A common peripheral callback
 */
typedef void (^CNjacob_CBPeripheralCallback) (CNjacob_CBPeripheral *peripheral, NSError * _Nullable error);





/**
 *  @class CNjacob_CBPeripheral
 */
@interface CNjacob_CBPeripheral : NSObject

/**
 *  @property services
 */
@property (nonatomic, strong, readonly) NSArray<CNjacob_CBService *> *services;

/**
 *  @property identifier NSUUID
 */
@property (nonatomic, strong, readonly) NSUUID *identifier;

/**
 *  @property name
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 *  @property state
 */
@property (nonatomic, assign, readonly) CNjacob_CBPeripheralState state;

/**
 *  @property advertisementData
 */
@property (atomic, strong, readonly) NSDictionary<NSString *, id> *advertisementData;

/**
 *  @property error Connect error etc.
 */
@property (nonatomic, strong, nullable) NSError *error;





/**
 *  @method connect: Connect callback
 *
 *  @param connectCallback Connect callback handler
 */
- (void)connect:(nullable CNjacob_CBPeripheralCallback)connectCallback;

/**
 *  @method connect: connect peripheral with callback and options
 *
 *  @param connectOptions connect options
 *  @param connectCallback Connect callback handler
 *  @seealso CBConnectPeripheralOptionNotifyOnConnectionKey
 *  @seealso CBConnectPeripheralOptionNotifyOnDisconnectionKey
 *  @seealso CBConnectPeripheralOptionNotifyOnNotificationKey
 */
- (void)connect:(nullable NSDictionary<NSString *, id> *)connectOptions callback:(nullable CNjacob_CBPeripheralCallback)connectCallback;

/**
 *  @method disconnect
 */
- (void)disconnect;

/**
 *  @method disconnect: with disconnect callback
 */
- (void)disconnect:(nullable CNjacob_CBPeripheralCallback)disconnectCallback;

/**
 *  @method receiveDisconnect
 */
- (void)receiveDisconnect:(nullable CNjacob_CBPeripheralCallback)receiveDisconnectCallback;

/**
 *  @method dropDisconnect
 */
- (void)dropDisconnect;

/**
 *  @method receiveAdvertising
 */
- (void)receiveAdvertising:(CNjacob_CBPeripheralCallback)receiveAdvertisingCallback;

/**
 *  @method dropAdvertising
 */
- (void)dropAdvertising;

/**
 *  @method readRSSI
 */
- (void)readRSSI:(nullable CNjacob_CBPeripheralCallback)readRSSICallback;

/**
 *  @method dropRSSIUpdates
 */
- (void)dropRSSIUpdates;

/**
 *  @method discoverServices: with callback
 *
 *  @param discoverCallback discover callback
 */
- (void)discoverServices:(nullable CNjacob_CBPeripheralCallback)discoverCallback;

/**
 *  @method discoverServices: with services UUIDs
 *
 *  @param serviceUUIDs service uuids to be discovered
 *  @param discoverCallback discover callback
 */
- (void)discoverServices:(nullable NSArray<CBUUID *> *)serviceUUIDs callback:(nullable CNjacob_CBPeripheralCallback)discoverCallback;

/**
 *  @method discoverServicesAndCharacteristics
 *
 *  @param discoverCallback discover callback
 */
- (void)discoverServicesAndCharacteristics:(nullable CNjacob_CBPeripheralCallback)discoverCallback;

/**
 *  @method discoverServices:andCharacteristics
 *
 *  @param serviceUUIDs     serviceUUIDs to be discovered
 *  @param characteristicUUIDs  characteristics to be discovered
 *  @param discoverCallback discover callback
 */
- (void)discoverServices:(nullable NSArray<CBUUID *> *)serviceUUIDs andCharacteristics:(nullable NSArray<CBUUID *> *)characteristicUUIDs callback:(nullable CNjacob_CBPeripheralCallback)discoverCallback;

@end

NS_ASSUME_NONNULL_END
