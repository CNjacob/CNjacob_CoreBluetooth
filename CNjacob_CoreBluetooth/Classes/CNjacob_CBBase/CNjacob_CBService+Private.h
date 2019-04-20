//
//  CNjacob_CBService+Private.h
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import "CNjacob_CBService.h"

NS_ASSUME_NONNULL_BEGIN

@class CBService, CNjacob_CBCentralManager;

/**
 *  @Category CNjacob_CBService+Private
 */
@interface CNjacob_CBService (Private)

/**
 *  @property service A CBService object
 */
@property (nonatomic, strong) CBService *appleService;

/**
 *  @property characteristics
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, CNjacob_CBCharacteristic *> *discoveredCharacterists;

/**
 *  @property discoveredIncludedServices
 */
@property (nonatomic, strong) NSMutableDictionary<NSString *, CNjacob_CBService *> *discoveredIncludedServices;

/**
 *  @property peripheral
 *
 *  @discussion
 *      A back-pointer to the peripheral this service belongs to.
 */
@property (nonatomic, assign, readwrite) CNjacob_CBPeripheral *peripheral;

/**
 *  @property Did discover characteristics callback
 */
@property (nonatomic, copy) CNjacob_CBServiceDiscoverCharacteristicCallback discoverCallback;





/**
 *  @method initWithService:
 *
 *  @param service CBService object
 *  @param peripheral CNjacob_CBPeripheral object
 */
- (instancetype)initWithService:(CBService *)service peripheral:(CNjacob_CBPeripheral *)peripheral;

/**
 *  @method removeAllCharacteristics
 */
- (void)removeAllCharacteristics;

/**
 *  @method didDiscoverCharacteristics
 */
- (void)didDiscoverCharacteristics:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
