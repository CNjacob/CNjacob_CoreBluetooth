//
//  CNjacob_CBDescriptor+Private.h
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import "CNjacob_CBDescriptor.h"

NS_ASSUME_NONNULL_BEGIN

@class CBDescriptor, CNjacob_CBCharacteristic, CNjacob_CBCentralManager;

/**
 *  @Category CNjacob_CBDescriptor+Private
 */
@interface CNjacob_CBDescriptor (Private)

/**
 *  @property characteristic
 *
 *  @discussion
 *      A back-pointer to the characteristic this descriptor belongs to.
 */
@property (nonatomic, assign, readwrite) CNjacob_CBCharacteristic *characteristic;

/**
 *  @property cbDescriptor
 */
@property (nonatomic, strong) CBDescriptor *appleDescriptor;

/**
 *  @property readCallback
 */
@property (nonatomic, copy) CNjacob_CBDescriptorDataCallback readCallback;

/**
 *  @property writeCallback
 */
@property (nonatomic, copy) CNjacob_CBDescriptorDataCallback writeCallback;





/**
 *  @method initWithDescriptor:characteristic
 *
 *  @param descriptor A CBDescriptor object
 *  @param characteristic A CNjacob_CBCharacteristic object
 */
- (instancetype)initWithDescriptor:(CBDescriptor *)descriptor characteristic:(CNjacob_CBCharacteristic *)characteristic;

/**
 *  @method didUpdateValue:
 */
- (void)didUpdateValue:(nullable NSError *)error;

/**
 *  @method didWriteValue:
 */
- (void)didWriteValue:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
