<p align="center" >
  <img src="https://cdn.shopify.com/s/files/1/0016/1870/6495/files/SesameSDK_iOS.png" alt="CANDY HOUSE Sesame SDK" title="SesameSDK">
</p>


SesameSDK on iOS is a delightful Bluetooth library for your iOS app. The official Sesame app is built on this SesameSDK. By using SesameSDK, your app will have `ALL` functions and features that Sesame app has, which means, you will be able to `Register Sesame`/`Lock door`/`Unlock door`/`Share keys`/`Read door history`/`Update Sesame firmware`/`Configure Sesame name`/`Configure Auto-lock`/`Configure angles`/`Get battery status` with your app.<br>Please note, SesameSDK currently only supports ___Sesame 2___ and ___Sesame 2 mini___ which will be available in late 2019.


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
- PromiseKit.framework

## Requirements

| Minimum iOS Target | Minimum Bluetooth Target | Minimum IDE |
|:------------------:|:------------------------:|:-----------:|
| iOS 11.4 | Bluetooth 4.0 LE | Xcode 11.0 | 


## Architecture

Managers:
* `CHBleManager`: Bluetooth interface
* `CHAccountManager`: Web APIs interface
* `CHDeviceManager`: Device profiles interface

Device Info:
* `CHDeviceProfile`
    * `CHLockStatus`
    * `CHBatteryStatus`
    * `CHDeviceModel`
    * `CHDeviceAccessLevel`

BLE Device Info:
* `CHSesameBleInterface`
    * `CHBleGattStatus`
    * `CHSesameCommand`
    * `CHSesameCommandResult`
    * `CHSesameLockPositionConfiguration`

Debug:
* `CHLogger`
* `CHLogLevel`
* `CHApiResult`
* `CHBleError`: `resourceBusy`, `bleNotReady`, `deviceBusy`, `alreadyRegistered`, `noRegistered`
* `CHSesameGattError`: `incompleteKey`, `encryptionError`, `wrongStatus`, `runtimeError`, `bleError`
* `CHAccountError`: `notLogin`, `permissionDeny`, `masterUserKeyNotExist`

## Example Operation Flow

1. Log in
1. Connect to the Sesame
1. Register the Sesame
1. Set a locked angle
1. Set an unlocked angle
1. Try Lock command
1. Try Unlock command

### CHAccountManager
`CHAccountManager` creates a Singleton to handle all Login-Related API calls. It also manages a `CHDeviceManager` which is the top manager of all Sesame devices. 

For the login process, a protocol conforming to `<CHLoginProvider>` is required. Whenever the `CHOauthToken` in `CHLoginProvider` protocol is valid for Candy House, `CHAccountManager` will create a `Credential` to sign each API request. 

The Credentail expires in every two hours or so. Normally, Candy House SDK refreshes the `Credential` in background. To check the `Credential` is valid or not, please use `func ensureCredentials`. If `ensureCredentials` returns any error, You may have to go through Login prcoess again, to provide a valid `CHOauthToken` to Candy House.

To see how to implement the login process, please checkout this file. [link](https://github.com/CANDY-HOUSE/SDK_iOS_SSM2_DEMO/blob/master/Sesame2SDKDemo/AWSServiceClient.swift)

```swift
    public static let shared = CHAccountManager()
    public var deviceManager: CHDeviceManager!
    public var candyhouseUserId: UUID?
    public func continueLoginSession(identityProvider: CHLoginProvider)
    public func login(identityProvider: CHLoginProvider, result: @escaping (SesameSDK.CHAccountManager, SesameSDK.CHApiResult) -> Void)
    public func logout()
    public func isLogin() -> Bool
    public func ensureCredentials(_ result: @escaping (SesameSDK.CHAccountManager, SesameSDK.CHApiResult) -> Void)

```
### CHDeviceManager
`CHDeviceManager` is under the `CHAccountManager`, where is responsible for fetching device list from server. (`func flushDevices`).

```swift
    public func flushDevices(_ result: @escaping (SesameSDK.CHDeviceManager?, SesameSDK.CHApiResult, [SesameSDK.CHDeviceProfile]?) -> Void)
    public func getDevices() -> [SesameSDK.CHDeviceProfile]
    public func getDeviceByBleIdentity(_ identity: Data, withModel: SesameSDK.CHDeviceModel) -> SesameSDK.CHDeviceProfile?
    public func getDeviceByUUID(uuid: UUID) -> SesameSDK.CHDeviceProfile?
```

### CHDeviceProfile
CHDeviceProfile contains some public-get-properties such as `bleIdentity`, `deviceId`, `model`, `accessLevel`, `deviceName` and `customName`. Those are essential parameters for users to identify each Sesame.
```swift
    public var bleIdentity: Data?
    public var deviceId: UUID
    public var model: SesameSDK.CHDeviceModel
    public var accessLevel: SesameSDK.CHDeviceAccessLevel
    public var deviceName: String?
    public var customName: String?
    public func renameDevice(name: String, completion: @escaping (SesameSDK.CHApiResult) -> Void) throws
    public func renameNickname(name: String, completion: @escaping (SesameSDK.CHApiResult) -> Void)
    public func unregisterDeivce(deviceId: UUID, model: SesameSDK.CHDeviceModel, completion: @escaping (SesameSDK.CHApiResult) -> Void)
```

### CHBleManager

`CHBleManager` creates and manages `Bluetooth-related` objects based on a `CBCentralManager`, which conforms to `<CBCentralManagerDelegate>`, `<CBPeripheralDelegate>`.
CHBLEManager has a delegate extension `CHBleManagerDelegate`, which gets called whenever nearby Sesame is scanned.
```swift
    public func enableScan()
    public func disableScan()
    public func getSesame(identifier: String) -> CHSesameBleInterface?

    public protocol CHBleManagerDelegate : AnyObject {
        func didDiscoverSesame(device: CHSesameBleInterface)
    }

```

### CHSesameBleInterface
Each Bluetooth object under the CHBleManager follows the interface `CHSesameBleInterface`. Users can identify the bluetooth device by its deviceId or deviceBleId, and also check if the Sesame had been registered or not (`isRegistered`) and so on.

`connectStatus` follows the `CBPeripheralState`, it returns CBBLE connection status, such as `disconnected`, `connecting`, `connected` or `disconnecting`. However, Candy House also provides its own connection status `CHBleGattStatus` for developers to debug. only when `CHBleGattStatus` is equal to `established` can the user do further ble operations such as lock or unlock.

After the connection is fully established, the Sesame Mechanical status will be revealed (`CHSesameMechStatus`), which allows users to grab the update-to-date Sesame battery voltage or the angle of thumb turn.

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
    var gattDealStatus: SesameSDK.CHBleGattStatus?
    var mechStatus: CHSesameMechStatus?
    var mechSetting: CHSesameMechSettings?
    var rssi: NSNumber
    
    // Connect / disconnect
    func connect() throws
    func disconnect()

    // Bluetooth operations
    func lock() throws
    func unlock() throws
    func getMechStatus() throws
    func configureLockPosition(configure: SesameSDK.CHSesameLockPositionConfiguration) throws
    func register(nickname: String, _ callback: @escaping (SesameSDK.CHApiResult) -> Void) throws
    func unregister(_ callback: @escaping (SesameSDK.CHApiResult) -> Void) throws
    func lastSeen() -> Date
}
```

## Communications

- If you **found a bug**, _and can provide steps to reliably reproduce it_, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.
- If you believe you have identified a **security vulnerability** with SesameSDK, you should report it as soon as possible via email to developers@candyhouse.co Please do not post it to a public issue tracker.

## License
SesameSDK is owned and maintained by [CANDY HOUSE, Inc.](https://jp.candyhouse.co/) under a [MIT-like License](https://github.com/CANDY-HOUSE/SDK_iOS_Sesame_Demo/blob/master/LICENSE).

