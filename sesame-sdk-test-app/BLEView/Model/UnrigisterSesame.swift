//
//  UnrigisterSesame.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/9/30.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import SesameSDK
import CoreBluetooth

public class mySesame: NSObject, CHSesameBleInterface {
    

    public func issueKey(accessLevel: CHDeviceAccessLevel, deviceNickname: String, _ completion: @escaping (CHApiResult, String?) -> Void) {
    }

    public func issueKey(accessLevel: CHDeviceAccessLevel, _ completion: @escaping (CHApiResult, String?) -> Void) {
    }

    public func revokeKey(_ member: CHDeviceMember, _ completion: @escaping (CHApiResult) -> Void) {
    }

    public func updateMechStatus() -> CHBleError {
        return CHBleError.bleNotReady
    }

    public func updateFirmware(zipData: Data, delegate: CHFirmwareUpdateInterface) -> CHBleError {
        return CHBleError.bleNotReady
    }

    public func register(nickname: String, _ callback: @escaping (CHApiResult) -> Void) -> CHBleError {
        return CHBleError.bleNotReady
    }

    public func getVersionTag(completion: @escaping (String, Int32) -> Void) -> CHBleError {
        return CHBleError.bleNotReady
    }

    public func configureLockPosition(configure: inout CHSesameLockPositionConfiguration) -> CHBleError {
        return CHBleError.bleNotReady
    }

    public func getAutolockSetting(completion: @escaping (Int) -> Void) -> CHBleError {
        return CHBleError.bleNotReady
    }

    public func enableAutolock(delay: Int) -> CHBleError {
        return CHBleError.bleNotReady
    }

    public func disableAutolock() -> CHBleError {
        return CHBleError.bleNotReady
    }

    public func unregister() -> CHBleError {
        return CHBleError.bleNotReady
    }

    public var deviceProfile: CHDeviceProfile?

    public init( deviceProfile: CHDeviceProfile?) {
        self.deviceProfile = deviceProfile
        self.gattStatus = CHBleGattStatus.idle
        super.init()
    }

    public var delegate: CHSesameBleDeviceDelegate?

    public var deviceId: UUID? {
        return deviceProfile?.deviceId
    }

    public var customNickname: String? {
        return deviceProfile?.customName
    }

    public var bleId: Data? {
        return  deviceProfile?.bleIdentity
    }
    public var bleIdStr: String{
        return (deviceProfile?.bleIdentity?.toHexString())!
    }

    public var debugId: String = ""

    public var identifier: String {
        return "fromserver"
    }

    public var rssi: NSNumber = 0.0

    public var accessLevel: CHDeviceAccessLevel {
        return deviceProfile!.accessLevel
    }

    public var model: CHDeviceModel {
        return CHDeviceModel.sesame2
    }

    public var isRegistered: Bool {
        return true
    }

    public var gattStatus: CHBleGattStatus

    public var connectStatus: CBPeripheralState?

    public var fwVersion: UInt8 = 0

    public var mechStatus: CHSesameMechStatus?

    public var mechSetting: CHSesameMechSettings?

    public func lastSeen() -> Date {
        return  Date()
    }

    public func connect() {
        L.d("fack c")
    }

    public func disconnect() {

    }

    public func register(nickname: String, _ callback: @escaping (CHApiResult) -> Void) throws {

    }

    public func updateMechStatus() throws {

    }

    public func lock() -> CHBleError {
        return CHBleError.bleNotReady
    }

    public func unlock() -> CHBleError {
        return CHBleError.bleNotReady
    }

    public func updateFirmware(zipData: Data, delegate: CHFirmwareUpdateInterface) throws {

    }

    public func issueKey(accessLevel: CHDeviceAccessLevel, _ completion: @escaping (CHApiResult, String?) -> Void)  -> CHBleError {
        return CHBleError.bleNotReady

    }

}
