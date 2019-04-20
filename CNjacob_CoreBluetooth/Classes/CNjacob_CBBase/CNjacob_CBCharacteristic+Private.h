//
//  CNjacob_CBCharacteristic+Private.h
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import "CNjacob_CBCharacteristic.h"

NS_ASSUME_NONNULL_BEGIN

@class CBCharacteristic;

/**
 *  @class
 */
@interface CNjacob_CBCharacteristicWriteQueueData : NSObject

/**
 *  @property data
 */
@property (nonatomic, strong, readonly) NSData *data;

/**
 *  @property retryTimes
 */
@property (nonatomic, assign, readonly) NSInteger retryTimes;

/**
 *  @property writeCallback
 */
@property (nonatomic, copy, readonly) CNjacob_CBCharacteristicWriteDataCallback writeCallback;





/**
 *  @method initWithData:retryTimes:callback
 */
- (instancetype)initWithData:(NSData *)data retryTimes:(NSInteger)retryTimes callback:(CNjacob_CBCharacteristicWriteDataCallback)writeCallback;

@end





/**
 *  @Category CNjacob_CBCharacteristic+Private
 */
@interface CNjacob_CBCharacteristic (Private)

/**
 *  @property cbCharacteristic A CBCharacteristic object
 */
@property (nonatomic, strong) CBCharacteristic *appleCharacteristic;

/**
 *  @property discoveredDescriptors
 */
@property (nonatomic, strong)
NSMutableDictionary<NSString *, CNjacob_CBDescriptor *> *discoveredDescriptors;

/**
 *  @property readCallback
 */
@property (nonatomic, copy) CNjacob_CBCharacteristicCallback readCallback;

/**
 *  @property readDelayCallback
 */
@property (nonatomic, copy, nullable) dispatch_block_t readDelayCallback;

/**
 *  @property writeDelayCallback
 */
@property (nonatomic, copy, nullable) dispatch_block_t writeDelayCallback;

/**
 *  @property notificationCallback
 */
@property (nonatomic, copy) CNjacob_CBCharacteristicCallback notificationStateCallback;

/**
 *  @property descriptorCallback
 */
@property (nonatomic, copy) CNjacob_CBCharacteristicCallback discoverDescriptorCallback;

/**
 *  @property writingQueue, A list to keep writing data if callback specified
 */
@property (nonatomic, strong) NSMutableArray<CNjacob_CBCharacteristicWriteQueueData *> *writingQueue;

/**
 *  @property readReceived
 */
@property (nonatomic, assign) BOOL readReceived;

/**
 *  @property writeReceived
 */
@property (nonatomic, assign) BOOL writeReceived;

/**
 *  @property service
 *
 *  @discussion
 *      A back-pointer to the service this characteristic belongs to.
 */
@property (nonatomic, assign, readwrite) CNjacob_CBService *service;





/**
 *  @method initWithCharacteristic:service
 *
 *  @param characteristic A CBCharacteristic object
 *  @param service A CNjacob_CBService object
 */
- (instancetype)initWithCharacteristic:(CBCharacteristic *)characteristic service:(CNjacob_CBService *)service;

/**
 *  @method removeAllDescriptors
 */
- (void)removeAllDescriptors;

/**
 *  @method didUpdateValue:
 */
- (void)didUpdateValue:(nullable NSError *)error;

/**
 *  @method didWriteValue:
 */
- (void)didWriteValue:(nullable NSError *)error;

/**
 *  @method didUpdateNotificationState:
 */
- (void)didUpdateNotificationState:(nullable NSError *)error;

/**
 *  @method didDiscoverDescriptors
 */
- (void)didDiscoverDescriptors:(nullable NSError *)error;

/**
 *  @method writeQueueData
 */
- (void)writeQueueData;

@end

NS_ASSUME_NONNULL_END
