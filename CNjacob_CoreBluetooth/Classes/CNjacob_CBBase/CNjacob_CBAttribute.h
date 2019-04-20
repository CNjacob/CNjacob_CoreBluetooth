//
//  CNjacob_CBAttribute.h
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class CBUUID, CNjacob_CBCentralManager;

/**
 *  @class CNjacob_CBAttribute
 */
@interface CNjacob_CBAttribute : NSObject

/**
 *  @property UUID
 */
@property (nonatomic, strong, readonly) CBUUID *UUID;

/**
 *  @property centralManager
 */
@property (nonatomic, assign, readonly) CNjacob_CBCentralManager *centralManager;

@end

NS_ASSUME_NONNULL_END
