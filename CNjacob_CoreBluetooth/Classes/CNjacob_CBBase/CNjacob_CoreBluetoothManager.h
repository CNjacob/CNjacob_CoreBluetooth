//
//  CNjacob_CoreBluetoothManager.h
//  CNjacob_CoreBluetooth
//
//  Created by jacob on 2019/4/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  @enum CNjacob_CoreBluetoothManagerState
 *
 *  @discussion Represents the current state of a CNjacob_CBCentralManager.
 *
 *  @constant CNjacob_CoreBluetoothManagerStateUnknown
 *              State unknown, update imminent.
 *  @constant CNjacob_CoreBluetoothManagerStateResetting
 *              The connection with the system service was momentarily lost, update imminent.
 *  @constant CNjacob_CoreBluetoothManagerStateUnsupported
 *              The platform doesn't support the Bluetooth Low Energy Central/Client role.
 *  @constant CNjacob_CoreBluetoothManagerStateUnauthorized
 *              The application is not authorized to use the Bluetooth Low Energy role.
 *  @constant CNjacob_CoreBluetoothManagerStatePoweredOff
 *              Bluetooth is currently powered off.
 *  @constant CNjacob_CoreBluetoothManagerStatePoweredOn
 *              Bluetooth is currently powered on and available to use.
 */
typedef NS_ENUM(NSInteger, CNjacob_CoreBluetoothManagerState) {
    CNjacob_CoreBluetoothManagerStateUnknown = 0,
    CNjacob_CoreBluetoothManagerStateResetting,
    CNjacob_CoreBluetoothManagerStateUnsupported,
    CNjacob_CoreBluetoothManagerStateUnauthorized,
    CNjacob_CoreBluetoothManagerStatePoweredOff,
    CNjacob_CoreBluetoothManagerStatePoweredOn,
};

@interface CNjacob_CoreBluetoothManager : NSObject

/**
 *  @property state
 *
 *  @seealso CNjacob_CoreBluetoothManagerState
 */
@property (nonatomic, assign, readonly) CNjacob_CoreBluetoothManagerState state;

@end

NS_ASSUME_NONNULL_END
