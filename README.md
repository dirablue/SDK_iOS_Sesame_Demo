<p align="center" >
  <img src="https://github.com/CANDY-HOUSE/SDK_iOS_Sesame_Demo/raw/master/SesameSDK_Swift.png" alt="CANDY HOUSE Sesame SDK" title="SesameSDK">
</p>


SesameSDK on iOS is a delightful Bluetooth library for your iOS app. The official Sesame app is built on this SesameSDK. By using SesameSDK, your app will have **ALL** functions and features that Sesame app has, which means, you will be able to

- Register Sesame
- Lock door
- Unlock door
- Share keys
- Read door history
- Update Sesame firmware
- Configure Sesame name
- Configure Auto-lock
- Configure angles
- Get battery status

with your app.<br>Please note, SesameSDK currently only supports ___Sesame 2___ and ___Sesame 2 mini___ which will be available in late 2020.


## Quick Start

- Download SesameSDK and try the included iPhone sample app.
- Read [Google Slides documentation](https://docs.google.com/presentation/d/1ms6W1ljdULRB0hyiKdXTzQwN9LeCVXVeEiwN1pF7_G4/edit?usp=sharing).


## Installation
Import the following frameworks

- Candyhouse.framework
- SesameSDK.framework
- AWSAPIGateway.framework
- AWSAuthCore.framework
- AWSCognitoIdentityProvider.framework
- AWSCognitoIdentityProviderASF.framework
- AWSCore.framework
- AWSMobileClient.framework

## Requirements

| Minimum iOS Target | Minimum Bluetooth Target | Minimum IDE |
|:------------------:|:------------------------:|:-----------:|
| iOS 11.4 | Bluetooth 4.0 LE | Xcode 11.3 | 


## Architecture

Managers:
* `CHBleManager`: Bluetooth interface
* `CHAccountManager`: Web APIs interface


* `CHSesameBleInterface`
    * `CHBatteryStatus`
    * `CHSesameMechStatus`
    * `CHSesameCommand`
    * `CHSesameCommandResult`
    * `CHSesameLockPositionConfiguration`


## Account Login Process
<p align="center" >
  <img src="https://cdn.shopify.com/s/files/1/0939/4828/files/candyhouse_login.png?899" alt="CANDY HOUSE Sesame SDK login" title="SesameSDK">
</p>
Example (Google) (https://accounts.google.com/.well-known/openid-configuration)


### CHAccountManager


```swift
class CHAccountManager {
    public static let shared
    public func setupLoginSession(identityProvider: CHLoginProvider)
    public func login(result: @escaping (CHAccountManager, CHApiResult) -> Void)
    public func logout()
}
```


### CHBleManager

```swift
class CHBleManager {
    public func enableScan()
    public func disableScan()
    public func getSesame(identifier: String) -> CHSesameBleInterface?
    public func discoverALLDevices() { result in 
     if case .success(let devices) = result {}
    }
    public protocol CHBleManagerDelegate : AnyObject {
        func didDiscoverSesame(device: CHSesameBleInterface)
    }
}
```

### CHSesameBleInterface


```swift
public protocol CHSesameBleInterface : AnyObject {

    var delegate: CHSesameBleDeviceDelegate?
    
    // Device Info
    var deviceId: UUID?
    var customNickname: String?
    var accessLevel: SesameSDK.CHDeviceAccessLevel?
    var model: SesameSDK.CHDeviceModel
    var deviceBleId: String
    var isRegistered: Bool
    var identifier: String
    
    // Status
    var connectStatus: CBPeripheralState?
    var deviceStatus: CHDeviceStatus
    var mechStatus: CHSesameMechStatus?
    var mechSetting: CHSesameMechSettings?
    var rssi: NSNumber
    
    // Connect / disconnect
    func connect() 
    func disconnect()

    // Bluetooth operations
    func lock() 
    func unlock() 
    func configureLockPosition(configure: SesameSDK.CHSesameLockPositionConfiguration) 
    func register(nickname: String, _ callback: @escaping (CHApiResult) -> Void) 
    func unregister() 
}
```

## Communications

- If you **found a bug**, _and can provide steps to reliably reproduce it_, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.
- If you believe you have identified a **security vulnerability** with SesameSDK, you should report it as soon as possible via email to developers@candyhouse.co Please do not post it to a public issue tracker.

## License
SesameSDK is owned and maintained by [CANDY HOUSE, Inc.](https://jp.candyhouse.co/) under the [MIT License](https://github.com/CANDY-HOUSE/SDK_iOS_Sesame_Demo/blob/master/LICENSE).

