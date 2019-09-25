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

class BluetoothSesameControlViewController: BaseLightViewController {
    @IBOutlet weak var scannerView: QRScannerView! {
        didSet {
            scannerView.delegate = self
        }
    }
    @IBOutlet weak var lockIntention: UILabel!
    @IBOutlet weak var shareKeyImg: UIImageView!
    @IBOutlet weak var Interval: UITextField!
    @IBOutlet weak var timesInput: UITextField!
    @IBOutlet weak var versionTagBtn: UIButton!
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
    @IBOutlet weak var enableAutolockBtn: UIButton!
    @IBOutlet weak var disableAutolockBtn: UIButton!
    @IBOutlet weak var registStatusLB: UILabel!
    @IBOutlet weak var powerLB: UILabel!
    @IBOutlet weak var fwVersionLB: UILabel!
    @IBOutlet weak var autolockLB: UILabel!
    var timer: Timer?
    @IBAction func lockdegree(_ sender: Any) {
        lockDegree = nowDegree
    }
    @objc func timerUpdate() {
        guard let status = self.mechStatus else {
            return
        }
        var times = Int(timesInput.text!)
        if(times! == 1) {
            self.timer?.invalidate()
        }
        if(status.isInLockRange()!) {
            do {
                try sesame!.unlock()
            } catch {
                print(error)
            }

        } else {
            do {
                try sesame!.lock()
            } catch {
                print(error)
            }
        }

    }
    @IBAction func startLock(_ sender: Any) {

        let sss =  Int(self.Interval.text!)!
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(sss), target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
        self.timer?.fire()

    }
    @IBAction func stopLock(_ sender: Any) {
        self.timer?.invalidate()
        self.timer = nil
    }

    @IBAction func versionTagClick(_ sender: UIButton) {
        do {
            try self.sesame!.getVersionTag { (version, _) -> Void in
                sender.setTitle(version, for: .normal)
            }
        } catch {
            print(error)
        }
    }
    @IBAction func unlockdegree(_ sender: Any) {
        unlockDegree = nowDegree
    }

    @IBAction func readAutolockClick(_ sender: UIButton) {
        do {
            try  self.sesame!.getAutolockSetting { (delay) -> Void in
                print("delay", delay)
                self.autolockLB.text = String(delay)
            }
        } catch {
            print(error)
        }
    }
    @IBAction func dufClick(_ sender: UIButton) {
        do {
            if let filePath = Bundle.main.url(forResource: "sesame2_firmware", withExtension: ".zip") {
                let zipData = try Data(contentsOf: filePath)
                try self.sesame!.updateFirmware(zipData: zipData, delegate: TemporaryFirmwareUpdateClass(self))
            } else {
                ViewHelper.alert("Error", "Can not open firmware file", self)
            }
        } catch {
            ViewHelper.alert("Error", "Update Error: \(error)", self)
        }
    }
    @IBAction func enableAutolock(_ sender: Any) {
        let alert = UIAlertController(title: "Autolock", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input your delay second here..."
            textField.keyboardType = .numberPad
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if let second = alert.textFields?.first?.text {
                print("second", second)
                do {
                    try self.sesame!.enableAutolock(delay: Int(second)!)
                } catch {
                    print(error)
                }
            }
        }))
        self.present(alert, animated: true)
    }
    @IBAction func disableAutolock(_ sender: Any) {
        do {
            try  self.sesame!.disableAutolock()
        } catch {
            print(error)
        }
    }

    @IBAction func unregisterClick(_ sender: UIButton) {
        do {
            guard let sesame = self.sesame,
                  let bleId = sesame.bleId else {
                print("Incomplete data, ignore unregister")
                return
            }
            try sesame.unregister()
            let deviceProfile = CHAccountManager.shared.deviceManager.getDeviceByBleIdentity(bleId, withModel: sesame.model)
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
            //            let angleSetting = CHSesameLockPositionConfiguration(lockTarget: lockDegree, unlockTarget: unlockDegree)
            try sesame?.configureLockPosition(configure: CHSesameLockPositionConfiguration(lockTarget: lockDegree, unlockTarget: unlockDegree))
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
                                        self.deviceName = "register ok! id:\(self.sesame!.bleId?.toHexString().prefix(8) ?? "UNKNOWN")   name:\(name)"
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
            lockstatusLB.text = status.isInLockRange()! ? "locked" : status.isInUnlockRange()! ? "unlocked" : "moved"
            let  batteryStatus: CHBatteryStatus = status.getBatteryStatus()!
            powerLB.text = "battery:\(batteryStatus.description()),\(status.getBatteryVoltage())"
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
            lockCircle.setLockValue(angle2degree(angle: self.lockDegree), angle2degree(angle: self.unlockDegree))
            // print("\(self.sesame!.fwVersion)")
            fwVersionLB.text = "\(self.sesame!.fwVersion)"
            // self.versionTagBtn.sendActions(for: .touchUpInside)

        }
    }

    var gattStatus: CHBleGattStatus = CHBleGattStatus.idle {
        didSet {
            DispatchQueue.main.async(execute: {
                self.gattStatusLB.text = self.gattStatus.description()
            })
        }
    }

    var deviceName: String? {
        didSet {
            if sesame!.deviceId == nil {
                deviceIDLB.text = "-"
            } else {
                deviceIDLB.text = "deviceId:\(sesame!.deviceId!)"
            }
            bleIDLB.text = "deviceBleId:\(sesame?.bleId?.toHexString().prefix(8) ?? "UNKNOWN")"
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
    func angle2degree(angle: Int16) -> Float {

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


}
extension BluetoothSesameControlViewController {
    override func viewWillAppear(_ animated: Bool) {
        CHBleManager.shared.enableScan()
        if !scannerView.isRunning {
            scannerView.startScanning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        CHBleManager.shared.disableScan()
        if !scannerView.isRunning {
            scannerView.stopScanning()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        CHBleManager.shared.delegate = self
        if let sesame = CHBleManager.shared.getSesame(identifier: deviceID!) {
            sesame.delegate = self
            self.sesame = sesame
            deviceName = "deviceBleId:\(sesame.bleId?.toHexString().prefix(8) ?? "UNKNOWN")"
            isRegisted = sesame.isRegistered
            mechStatus = sesame.mechStatus
            mechSetting = sesame.mechSetting
            gattStatus = sesame.gattStatus
        }


        let image = generateQRCode(from: "I am share key")

        shareKeyImg.image = image
    }
}

extension BluetoothSesameControlViewController: CHSesameBleDeviceDelegate {
    func onMechSettingChanged(device: CHSesameBleInterface, setting: CHSesameMechSettings) {
        mechSetting = setting
    }

    func onMechStatusChanged(device: CHSesameBleInterface, status: CHSesameMechStatus, intention: CHSesameIntention) {
        mechStatus = status
        lockIntention.text = intention.description
    }

    func onSesameLogin(device: CHSesameBleInterface, setting: CHSesameMechSettings, status: CHSesameMechStatus) {
        mechSetting = setting
        mechStatus = status
    }

    func onBleConnectStatusChanged(device: CHSesameBleInterface, status: CBPeripheralState) {
    }

    func onBleGattStatusChanged(device: CHSesameBleInterface, status: CHBleGattStatus, error: CHSesameGattError?) {
        weak var weakSelf = self
        gattStatus = status
        if let error = error {
            ViewHelper.showAlertMessage(title: "BLE Error", message: error.description(), actionTitle: "OK", viewController: weakSelf!)
        }
    }

    func onBleCommandResult(device: CHSesameBleInterface, command: CHSesameCommand, returnCode: CHSesameCommandResult) {
        resultLB.text = "\(command.description()),\(returnCode.description())"
        if((command == .lock   || command == .unlock)  &&  returnCode == .success) {
            let times = Int(timesInput.text!)
            if(times! > 0) {
                timesInput.text = "\(times!-1)"
            }
        }
    }
}

extension BluetoothSesameControlViewController: CHBleManagerDelegate {
    func didDiscoverSesame(device: CHSesameBleInterface) {
        isRegisted = self.sesame!.isRegistered
    }
}

extension BluetoothSesameControlViewController: QRScannerViewDelegate {
    func qrScanningDidStop() {
        print("qrScanningDidStop")
    }

    func qrScanningDidFail() {
        print("qrScanningDidFail")
    }

    func qrScanningSucceededWithCode(_ str: String?) {
        ViewHelper.alert("QR Code Scan Result:", "\(str ?? "unknown")", self)
    }
}
