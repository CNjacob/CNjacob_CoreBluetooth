//
//  CNjacob_CoreBluetoothManager+Private.h
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import "CNjacob_CoreBluetoothManager.h"

NS_ASSUME_NONNULL_BEGIN

#define CNJACOB_ASYNC_CALLBACK(X, Y, Z, M)              \
if (X != nil) {                                         \
    __weak typeof(self) weakSelf = self;                \
    [M asyncCallback:^{                                 \
        __strong Z *self = weakSelf;                    \
        Y;                                              \
    }];                                                 \
}

#define CNJACOB_SYNC_CALLBACK(X, Y, Z, M)               \
if (X != nil) {                                         \
    __weak typeof(self) weakSelf = self;                \
    [M syncCallback:^{                                  \
        __strong Z *self = weakSelf;                    \
        Y;                                              \
    }];                                                 \
}

@interface CNjacob_CoreBluetoothManager (Private)

/**
 *  @property mainQueue
 */
@property (nonatomic, strong) dispatch_queue_t mainQueue;

/**
 *  @property callbackQueue
 */
@property (nonatomic, strong) dispatch_queue_t callbackQueue;





/**
 *  @method asyncCallback: asynchronous callback on callback queue
 *
 *  @param block block description
 */
- (void)asyncCallback:(nullable dispatch_block_t)block;

/**
 *  @method syncCallback: asynchronous callback on callback queue
 *
 *  @param block block description
 */
- (void)syncCallback:(nullable dispatch_block_t)block;

/**
 *  @method delayCallback: delay callback with a block
 *
 *  @param block block description
 */
- (void)delayCallback:(NSTimeInterval)delay withBlock:(nullable dispatch_block_t)block;

/**
 *  @method cancelDelayCallback: cancel delay callback block
 *
 *  @param block block description
 */
- (void)cancelDelayCallback:(nullable dispatch_block_t)block;

/**
 *  @method error: with custom user info
 *
 *  @param userInfo userInfo description
 *
 *  @return return value description
 */
- (NSError *)error:(NSDictionary<NSErrorUserInfoKey, id> *)userInfo;


/**
 *  @method createQueue
 *
 *  @param attribute attribute description
 *
 *  @return return value description
 */
- (dispatch_queue_t)createQueue:(nullable dispatch_queue_attr_t)attribute;

@end

NS_ASSUME_NONNULL_END
