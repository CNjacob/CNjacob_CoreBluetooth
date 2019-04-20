//
//  CNjacob_CBCharacteristic.h
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import "CNjacob_CBAttribute.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  @enum CNjacob_CBCharacteristicProperties
 *
 *  @discussion Characteristic properties determine how the characteristic value can be used,
 *              or how the descriptor(s) can be accessed. Can be combined.
 *              Unless otherwise specified,
 *              properties are valid for local characteristics published via
 *              @link CNjacob_CBPeripheralManager @/link.
 *
 *    @constant CNjacob_CBCharacteristicPropertyBroadcast
 *              Permits broadcasts of the characteristic value
 *              using a characteristic configuration descriptor.
 *              Not allowed for local characteristics.
 *    @constant CNjacob_CBCharacteristicPropertyRead
 *              Permits reads of the characteristic value.
 *    @constant CNjacob_CBCharacteristicPropertyWriteWithoutResponse
 *              Permits writes of the characteristic value, without a response.
 *    @constant CNjacob_CBCharacteristicPropertyWrite
 *              Permits writes of the characteristic value.
 *    @constant CNjacob_CBCharacteristicPropertyNotify
 *              Permits notifications of the characteristic value, without a response.
 *    @constant CNjacob_CBCharacteristicPropertyIndicate
 *              Permits indications of the characteristic value.
 *    @constant CNjacob_CBCharacteristicPropertyAuthenticatedSignedWrites
 *              Permits signed writes of the characteristic value
 *    @constant CNjacob_CBCharacteristicPropertyExtendedProperties
 *              If set, additional characteristic properties are defined
 *              in the characteristic extended properties descriptor.
 *              Not allowed for local characteristics.
 *    @constant CNjacob_CBCharacteristicPropertyNotifyEncryptionRequired
 *              If set, only trusted devices can enable notifications of the characteristic value.
 *    @constant CNjacob_CBCharacteristicPropertyIndicateEncryptionRequired
 *              If set, only trusted devices can enable indications of the characteristic value.
 */
typedef NS_OPTIONS(NSUInteger, CNjacob_CBCharacteristicProperties) {
    CNjacob_CBCharacteristicPropertyBroadcast                                                  = 0x01,
    CNjacob_CBCharacteristicPropertyRead                                                       = 0x02,
    CNjacob_CBCharacteristicPropertyWriteWithoutResponse                                       = 0x04,
    CNjacob_CBCharacteristicPropertyWrite                                                      = 0x08,
    CNjacob_CBCharacteristicPropertyNotify                                                     = 0x10,
    CNjacob_CBCharacteristicPropertyIndicate                                                   = 0x20,
    CNjacob_CBCharacteristicPropertyAuthenticatedSignedWrites                                  = 0x40,
    CNjacob_CBCharacteristicPropertyExtendedProperties                                         = 0x80,
    CNjacob_CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(10_9, 6_0)      = 0x100,
    CNjacob_CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(10_9, 6_0)    = 0x200
};

@class CNjacob_CBService, CNjacob_CBCharacteristic, CNjacob_CBDescriptor;

/**
 *  Write data callback
 */
typedef void (^CNjacob_CBCharacteristicWriteDataCallback) (CNjacob_CBCharacteristic *characteristic, NSData * _Nullable data, NSError * _Nullable error);

/**
 *  Characteristic common callback
 */
typedef void (^CNjacob_CBCharacteristicCallback) (CNjacob_CBCharacteristic *characteristic, NSError * _Nullable error);





/**
 *  @class CNjacob_CBCharacteristic
 */
@interface CNjacob_CBCharacteristic : CNjacob_CBAttribute

/**
 *  @property service
 *
 *  @discussion
 *      A back-pointer to the service this characteristic belongs to.
 */
@property (nonatomic, assign, readonly) CNjacob_CBService *service;

/**
 *  @property isNotifying
 */
@property (nonatomic, assign, readonly) BOOL isNotifying;

/**
 *  @property name
 */
@property (nonatomic, strong, readonly) NSString *name;

/**
 *  @property value
 */
@property (nonatomic, strong, readonly) NSData *value;

/**
 *  @property descriptors
 */
@property (nonatomic, strong, readonly) NSArray<CNjacob_CBDescriptor *> *descriptors;





/**
 *  @method propertyEnabled: check if the characteristic has specified property enabled
 */
- (BOOL)propertyEnabled:(CNjacob_CBCharacteristicProperties)property;

/**
 *  @method readData: with callback
 */
- (void)readData:(nullable CNjacob_CBCharacteristicCallback)readCallback;

/**
 *  @method receiveUpdates
 */
- (void)receiveUpdates:(nullable CNjacob_CBCharacteristicCallback)notifyCallback;

/**
 *  @method dropUpdates
 */
- (void)dropUpdates;

/**
 *  @method startNotifications: with callback
 */
- (void)startNotifications:(nullable CNjacob_CBCharacteristicCallback)notificationStateCallback;

/**
 *  @method stopNotifications: with callback
 */
- (void)stopNotifications:(nullable CNjacob_CBCharacteristicCallback)notificationStateCallback;

/**
 *  @method writeData without a callback
 */
- (void)writeData:(NSData *)data;

/**
 *  @method writeData: with a callback
 */
- (void)writeData:(NSData *)data callback:(nullable CNjacob_CBCharacteristicWriteDataCallback)writeCallback;

/**
 *  @method discoverDescriptors: with callback
 */
- (void)discoverDiscriptors:(CNjacob_CBCharacteristicCallback)discoverDescriptorCallback;

@end

NS_ASSUME_NONNULL_END
