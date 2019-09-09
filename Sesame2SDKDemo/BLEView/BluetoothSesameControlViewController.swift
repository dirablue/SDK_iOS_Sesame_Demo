//
//  BluetoothSesameControlViewController.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/8/6.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import SesameSDK
import CoreBluetooth

class BluetoothSesameControlViewController: UIViewController {
    @IBOutlet weak var lockCircle: Knob!
    @IBOutlet weak var gattStatusLB: UILabel!
    @IBOutlet weak var unlockSetBtn: UIButton!
    @IBOutlet weak var lockSetBtn: UIButton!
    @IBOutlet weak var resultLB: UILabel!
    @IBOutlet weak var angleLB: UILabel!
    @IBOutlet weak var lockstatusLB: UILabel!
    @IBOutlet weak var nicknameLB: UILabel!
    @IBOutlet weak var identifierIDLB: UILabel!
    @IBOutlet weak var deviceIDLB: UILabel!
    @IBOutlet weak var bleIDLB: UILabel!

    @IBOutlet weak var registStatusLB: UILabel!
    @IBOutlet weak var powerLB: UILabel!

    @IBAction func lockdegree(_ sender: Any) {
        lockDegree = nowDegree
    }

    @IBAction func unlockdegree(_ sender: Any) {
        unlockDegree = nowDegree
    }

    @IBAction func unregisterClick(_ sender: UIButton) {
        do {
            try self.sesame!.unregister({ (_) in })
            // unregister from server
            let deviceProfile = CHAccountManager.shared.deviceManager.getDeviceByBleIdentity(Data(hex: self.sesame!.deviceBleId), withModel: self.sesame!.model)
            if let deviceProfile = deviceProfile {
                deviceProfile.unregisterDeivce(deviceId: deviceProfile.deviceId, model: deviceProfile.model) { (result) in
                    CHLogger.debug("unregister result:\(result.success), \(result.errorDescription ?? "unknown")")
                    print("unregister result:\(result.success), \(result.errorDescription ?? "unknown")")
                    print("flushDevices~")

                    if result.success {
                        CHAccountManager.shared.deviceManager.flushDevices({ (_, result, _) in
                            if result.success == true {
                                print("flushDevices ok")
                            }
                        })
                    }
                }
            }
        } catch {
            print(error)
        }
    }

    @IBAction func setLock(_ sender: UIButton) {
        do {
            let angleSetting = CHSesameLockPositionConfiguration(lockTarget: lockDegree, unlockTarget: unlockDegree)
            try sesame?.configureLockPosition(configure: angleSetting)
        } catch {
            print(error)
        }
    }

    @IBAction func unlockClick(_ sender: UIButton) {
        do {
            try sesame!.unlock()
        } catch {
            print(error)
        }
    }

    @IBAction func lockClick(_ sender: UIButton) {
        do {
            try sesame!.lock()
        } catch {
            print(error)
        }
    }

    @IBAction func connectClick(_ sender: UIButton) {
        do {
            try sesame!.connect()
        } catch {
            print(error)
        }
    }

    @IBAction func disConnect(_ sender: Any) {
        sesame!.disconnect()
    }

    @IBAction func registerBtn(_ sender: Any) {
        weak var weakSelf = self
        let alert = UIAlertController(title: "sesame name", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input your sesame name here..."
        })

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if let name = alert.textFields?.first?.text {
                do {
                    try self.sesame!.register(nickname: name, {(result) in
                        if result.success {
                            CHAccountManager.shared.deviceManager.flushDevices({ (_, result, _) in
                                if result.success == true {
                                    DispatchQueue.main.async {
                                        self.deviceName = "register ok! id:\(self.sesame!.deviceBleId)   name:\(name)"
                                    }
                                }
                            })
                        } else {
                            ViewHelper.showAlertMessage(title: "Ooops", message: "register ssm failed:\(result.errorDescription ?? "Unknown error") code:\(result.errorCode ?? "unknown_code")", actionTitle: "OK", viewController: weakSelf!)
                        }
                    })
                } catch {
                    ViewHelper.showAlertMessage(title: "Ooops", message: "register ssm failed:\(error.localizedDescription)", actionTitle: "OK", viewController: weakSelf!)
                    print(error)
                }
            }
        }))

        self.present(alert, animated: true)
    }

    var sesame: CHSesameBleInterface?
    var deviceID: String?

    var mechStatus: CHSesameMechStatus? {
        didSet {
            guard let status = mechStatus else {
                return
            }
            nowDegree = Int16(status.getPosition()!)
            lockstatusLB.text = status.isInLockRange()! ? "locked" : "unlocked"
            let  batteryStatus: CHBatteryStatus = status.getBatteryStatus()!

            switch batteryStatus {
            case .healthy:
                powerLB.text = "battery:healthy"
            case .low:
                powerLB.text = "battery:low"
            case .criticalLow:
                powerLB.text = "battery:criticalLow"
            case .inoperable:
                powerLB.text = "battery:inoperable"
            }
        }
    }

    var mechSetting: CHSesameMechSettings? {
        didSet {
            guard let setting = mechSetting else {
                return
            }

            lockDegree = Int16(setting.getLockPosition()!)
            unlockDegree = Int16(setting.getUnlockPosition()!)
            lockSetBtn.setTitle("\(setting.getLockPosition()!)", for: .normal)
            unlockSetBtn.setTitle("\(setting.getUnlockPosition()!)", for: .normal)

            lockCircle.setLockValue(angle2degree(angle: self.lockDegree),angle2degree(angle: self.unlockDegree))
        }
    }

    var gattStatus: CHBleGattStatus = CHBleGattStatus.idle {
        didSet {
            switch gattStatus {
            case .idle:
                gattStatusLB.text = "idle"
            case .connecting:
                gattStatusLB.text = "connecting"
            case .connected:
                gattStatusLB.text = "connected"
            case .established:
                gattStatusLB.text = "established"
            case .error:
                gattStatusLB.text = "error"
            case .busy:
                gattStatusLB.text = "busy"
            }
        }
    }

    var deviceName: String? {
        didSet {
            if sesame!.deviceId == nil {
                deviceIDLB.text = "-"
            } else {
                deviceIDLB.text = "deviceId:\(sesame!.deviceId!)"
            }
            bleIDLB.text = "deviceBleId:\(sesame?.deviceBleId ?? "-")"
            identifierIDLB.text = "IdentifierID:\(deviceID ?? "-")"
            nicknameLB.text="customNickname:\(sesame?.customNickname ?? "-")"
        }
    }

    var isRegisted: Bool? {
        didSet {
            registStatusLB.text = isRegisted! ? "registered":"unregistered"
        }
    }

    var nowDegree: Int16 = 0 {
        didSet {
            angleLB.text = "angle:\(nowDegree)"
            lockCircle.setValue(angle2degree(angle: nowDegree))
        }
    }
    func angle2degree(angle:Int16) -> Float {

        var degree = Float(angle % 1024)
        degree = degree * 360 / 1024
        if degree > 0 {
            degree = 360 - degree
        } else {
            degree = abs(degree)
        }
        return degree
    }

    var lockDegree: Int16 = 0 {
        didSet {
            lockSetBtn.setTitle(String(lockDegree), for: .normal)
        }
    }

    var unlockDegree: Int16 = 0 {
        didSet {
            unlockSetBtn.setTitle(String(unlockDegree), for: .normal)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        CHBleManager.shared.enableScan()
    }

    override func viewWillDisappear(_ animated: Bool) {
        CHBleManager.shared.disableScan()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        CHBleManager.shared.delegate = self

        if let sesame = CHBleManager.shared.getSesame(identifier: deviceID!) {
            sesame.delegate = self

            self.sesame = sesame
            deviceName = "deviceBleId:\(sesame.deviceBleId)"
            isRegisted = sesame.isRegistered
            mechStatus = sesame.mechStatus
            mechSetting = sesame.mechSetting
            gattStatus = sesame.gattStatus
        }
    }
}

extension BluetoothSesameControlViewController: CHSesameBleDeviceDelegate {
    func onMechSettingChanged(device: CHSesameBleInterface, setting: CHSesameMechSettings) {
        mechSetting = setting
    }

    func onMechStatusChanged(device: CHSesameBleInterface, status: CHSesameMechStatus) {
        mechStatus = status
    }

    func onSesameLogin(device: CHSesameBleInterface, setting: CHSesameMechSettings, status: CHSesameMechStatus) {

        mechSetting = setting
        mechStatus = status
    }

    func onBleConnectStatusChanged(device: CHSesameBleInterface, status: CBPeripheralState) {
    }

    func onBleGattStatusChanged(device: CHSesameBleInterface, status: CHBleGattStatus, error: CHSesameGattError?) {
        gattStatus = status
        if let error = error {
            switch error {
            case .bleError(let error):
                print("ble error: ble error, \(error.localizedDescription)")
            case .incompleteKey:
                print("ble error: incompleteKey")
            case .encryptionError:
                print("ble error: encryption error")
            case .wrongStatus(let message):
                print("ble error: wrong status, \(message)")
            case .runtimeError(let error):
                print("ble error: runtime error, \(error.localizedDescription)")
            }
        }
    }

    func onBleCommandResult(device: CHSesameBleInterface, command: CHSesameCommand, returnCode: CHSesameCommandResult) {
        resultLB.text = "\(command.toString()),\(returnCode.toString())"
    }
}

extension BluetoothSesameControlViewController: CHBleManagerDelegate {
    func didDiscoverSesame(device: CHSesameBleInterface) {
        //        L.d("didDiscoverSesame")
        isRegisted = self.sesame!.isRegistered
    }
}

extension CHSesameCommand {
    fileprivate func toString() -> String {
        switch self {
        case .lock:
            return "lock"
        case .unlock:
            return "unlock"
        case .autolock:
            return "autolock"
        case .configureMech:
            return "configureMech"
        case .unknown:
            return "unknown"
        case .registration:
            return "registration"
        }
    }
}

extension CHSesameCommandResult {
    fileprivate func toString() -> String {
        switch self {
        case .success:
            return "success"
        case .paramError:
            return "paramError"
        case .notSupported:
            return "notSupported"
        case .storageFail:
            return "storageFail"
        case .unknown:
            return "unknown"
        }
    }
}
