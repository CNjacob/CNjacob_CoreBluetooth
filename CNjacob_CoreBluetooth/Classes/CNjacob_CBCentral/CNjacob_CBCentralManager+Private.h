//
//  CNjacob_CBCentralManager+Private.h
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/3/28.
//

#import <CNjacob_CoreBluetooth/CNjacob_CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

@class CBCentralManager;

/**
 *  @Category CNjacob_CBCentralManager+Private
 */
@interface CNjacob_CBCentralManager (Private)

/**
 *  @property cbCentralManager A CBCentralManager of CoreBluetooth
 */
@property (nonatomic, strong) CBCentralManager *appleCentralManager;

@end

NS_ASSUME_NONNULL_END
