//
//  CNjacob_CBService.h
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import "CNjacob_CBAttribute.h"

NS_ASSUME_NONNULL_BEGIN

@class CBUUID, CNjacob_CBPeripheral, CNjacob_CBCharacteristic, CNjacob_CBService;

/**
 *  Discover characteristics callback
 */
typedef void (^CNjacob_CBServiceDiscoverCharacteristicCallback) (CNjacob_CBService *service, NSError * _Nullable error);





/**
 *  @class CNjacob_CBService
 */
@interface CNjacob_CBService : CNjacob_CBAttribute

/**
 *  @property peripheral
 *
 *  @discussion
 *      A back-pointer to the peripheral this service belongs to.
 */
@property (nonatomic, assign, readonly) CNjacob_CBPeripheral *peripheral;

/**
 *  @property characterists A collect of CNjacob_CBCharacteristic
 */
@property (nonatomic, strong, readonly) NSArray<CNjacob_CBCharacteristic *> *characteristics;

/**
 *  @property includedServices
 *      A list of included CBServices that have so far been discovered in this service.
 */
@property (nonatomic, strong, readonly) NSArray<CNjacob_CBService *> *includedServices;

/**
 *  @property isPrimary
 */
@property (nonatomic, assign, readonly) BOOL isPrimary;

/**
 *  @property name
 */
@property (nonatomic, strong, readonly) NSString *name;





/**
 *  @method discoverCharacterists with callback
 *
 *  @param discoverCallback Discover callback
 */
- (void)discoverCharacteristics:(CNjacob_CBServiceDiscoverCharacteristicCallback)discoverCallback;

/**
 *  @method discoverCharacterists with callback
 *
 *  @param characteristicUUIDs Characteristics to be discovered
 *  @param discoverCallback Discover callback
 */
- (void)discoverCharacteristics:(nullable NSArray<CBUUID *> *)characteristicUUIDs callback:(nullable CNjacob_CBServiceDiscoverCharacteristicCallback)discoverCallback;

/**
 *  @method characteristicWithUUID:
 *
 *  @param UUID characteristicUUID to be searched
 *  @return CNjacob_CBCharacteristic
 */
- (CNjacob_CBCharacteristic *)characteristicWithUUID:(NSString *)UUID;

@end

NS_ASSUME_NONNULL_END
