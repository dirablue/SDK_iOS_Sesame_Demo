<p align="center" >
  <img src="https://cdn.shopify.com/s/files/1/0016/1870/6495/files/SesameSDK_iOS.png" alt="CANDY HOUSE Sesame SDK" title="SesameSDK">
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

with your app.<br>Please note, SesameSDK currently only supports ___Sesame 2___ and ___Sesame 2 mini___ which will be available in late 2019.


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
| iOS 11.4 | Bluetooth 4.0 LE | Xcode 11.2 | 


## Architecture
<p align="center" >
  <img src="https://cdn.shopify.com/s/files/1/0939/4828/files/sdk_architecture.001.png?902" alt="CANDY HOUSE Sesame SDK architecture" title="SesameSDK">
</p>

Managers:
* `CHBleManager`: Bluetooth interface
* `CHAccountManager`: Web APIs interface
* `CHDeviceManager`: Device profiles interface, each device could be Sesame II or any other products from Candy House.

Device Info:
* `CHDeviceProfile`
    * `CHDeviceModel`
    * `CHDeviceAccessLevel`

BLE Device Info:
* `CHSesameBleInterface`
    * `CHBatteryStatus`
    * `CHSesameMechStatus`
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

## Account Login Process
<p align="center" >
  <img src="https://cdn.shopify.com/s/files/1/0939/4828/files/candyhouse_login.png?899" alt="CANDY HOUSE Sesame SDK login" title="SesameSDK">
</p>
Example (Google) (https://accounts.google.com/.well-known/openid-configuration)


### CHAccountManager
`CHAccountManager` creates a Singleton to handle all Login-Related API calls. It also manages a `CHDeviceManager` which is the top manager of all Sesame devices. 

For the login process, a protocol conforming to `<CHLoginProvider>` is required. Use `setupLoginSession` to pass the protocol to AccountManager. Whenever the `CHOauthToken` in `CHLoginProvider` protocol is valid for Candy House, `CHAccountManager` will create a `Credential` to sign each API request. 

The Credentail expires in every two hours or so. Normally, Candy House SDK refreshes the `Credential` in background. To check the `Credential` is valid or not, please use `func ensureCredentials`. If `ensureCredentials` returns any error, You may have to go through Login prcoess again, to provide a valid `CHOauthToken` to Candy House.


To see how to implement the login process, please checkout this file. [link](https://github.com/CANDY-HOUSE/SDK_iOS_SSM2_DEMO/blob/master/Sesame2SDKDemo/AWSServiceClient.swift)

```swift
class CHAccountManager {
    public static let shared

    public var deviceManager: CHDeviceManager
    public var candyhouseUserId: UUID?

    public func setupLoginSession(identityProvider: CHLoginProvider)
    public func login(result: @escaping (CHAccountManager, CHApiResult) -> Void)
    public func logout()
    public func isLogin() -> Bool
    public func ensureCredentials(_ result: @escaping (CHAccountManager, CHApiResult) -> Void)
}
```

<p align="center" >
  <img src="https://cdn.shopify.com/s/files/1/0939/4828/files/candyhouse_login_diagram.png?909" alt="CANDY HOUSE Sesame SDK login" title="SesameSDK">
</p>

### CHDeviceManager
`CHDeviceManager` is under the `CHAccountManager`, where is responsible for fetching device list from server. (`func flushDevices`).

```swift
class CHDeviceManager {
    public func flushDevices(_ result: @escaping (CHDeviceManager?, CHApiResult, [CHDeviceProfile]?) -> Void)
    public func getDevices() -> [CHDeviceProfile]
    public func getDeviceByBleIdentity(_ identity: Data, withModel: CHDeviceModel) -> CHDeviceProfile?
    public func getDeviceByUUID(uuid: UUID) -> CHDeviceProfile?
}
```

### CHDeviceProfile
CHDeviceProfile contains some public-get-properties such as `bleIdentity`, `deviceId`, `model`, `accessLevel`, `deviceName` and `customName`. Those are essential parameters for users to identify each Sesame.
```swift
class CHDeviceProfile {
    public var bleIdentity: Data?
    public var deviceId: UUID
    public var model: CHDeviceModel
    public var accessLevel: CHDeviceAccessLevel
    public var deviceName: String?
    public var customName: String?
  
    public func renameDevice(name: String, completion: @escaping (CHApiResult) -> Void) throws
    public func renameNickname(name: String, completion: @escaping (CHApiResult) -> Void)
    public func unregisterDeivce(deviceId: UUID, model: CHDeviceModel, completion: @escaping (CHApiResult) -> Void)
}
```

### CHBleManager

`CHBleManager` creates and manages `Bluetooth-related` objects based on a `CBCentralManager`, which conforms to `<CBCentralManagerDelegate>`, `<CBPeripheralDelegate>`.
CHBLEManager has a delegate extension `CHBleManagerDelegate`, which gets called whenever nearby Sesame is scanned.
```swift
class CHBleManager {
    public func enableScan()
    public func disableScan()
    public func getSesame(identifier: String) -> CHSesameBleInterface?

    public protocol CHBleManagerDelegate : AnyObject {
        func didDiscoverSesame(device: CHSesameBleInterface)
    }
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
    func configureLockPosition(configure: SesameSDK.CHSesameLockPositionConfiguration) throws
    func register(nickname: String, _ callback: @escaping (CHApiResult) -> Void) throws
    func unregister() throws
    func lastSeen() -> Date
}
```

## Communications

- If you **found a bug**, _and can provide steps to reliably reproduce it_, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.
- If you believe you have identified a **security vulnerability** with SesameSDK, you should report it as soon as possible via email to developers@candyhouse.co Please do not post it to a public issue tracker.

## License
SesameSDK is owned and maintained by [CANDY HOUSE, Inc.](https://jp.candyhouse.co/) under the [MIT License](https://github.com/CANDY-HOUSE/SDK_iOS_Sesame_Demo/blob/master/LICENSE).

