//
//  CNjacob_CBDescriptor.h
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import "CNjacob_CBAttribute.h"

NS_ASSUME_NONNULL_BEGIN

@class CNjacob_CBCharacteristic, CNjacob_CBDescriptor;

typedef void (^CNjacob_CBDescriptorDataCallback) (CNjacob_CBDescriptor *descriptor, NSError * _Nullable error);





/**
 *  @class CNjacob_CBDescriptor
 */
@interface CNjacob_CBDescriptor : CNjacob_CBAttribute

/**
 *  @property characteristic
 *
 *  @discussion
 *      A back-pointer to the characteristic this descriptor belongs to.
 */
@property (nonatomic, assign, readonly) CNjacob_CBCharacteristic *characteristic;

/**
 *  @property stringValue
 */
@property (nonatomic, strong, readonly) NSString *stringValue;

/**
 *  @property numberValue
 */
@property (nonatomic, strong, readonly) NSNumber *numberValue;

/**
 *  @property dataValue
 */
@property (nonatomic, strong, readonly) NSData *dataValue;

/**
 *  @property typeStringValue
 */
@property (nonatomic, strong, readonly) NSString *typeStringValue;





/**
 *  @method readData: with callback
 */
- (void)readData:(CNjacob_CBDescriptorDataCallback)readCallback;

/**
 *  @method writeData: with callback
 */
- (void)writeData:(NSData *)data callback:(CNjacob_CBDescriptorDataCallback)writeCallback;

@end

NS_ASSUME_NONNULL_END
