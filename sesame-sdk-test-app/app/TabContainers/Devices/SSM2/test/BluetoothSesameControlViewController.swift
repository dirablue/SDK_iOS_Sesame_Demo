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
extension BluetoothSesameControlViewController {
    override func viewWillAppear(_ animated: Bool) {
        CHBleManager.shared.enableScan()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        CHBleManager.shared.disableScan()
        self.timer?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CHBleManager.shared.delegate = self
        isRegisted = sesame!.isRegistered
        mechStatus = sesame!.mechStatus
        mechSetting = sesame!.mechSetting
        gattStatus = sesame!.gattStatus
        
        deviceIDLB.text = "accessLevel:\(sesame!.accessLevel.rawValue)"
        bleIDLB.text = "BleId:\(sesame!.bleIdStr)"
        nicknameLB.text="customNickname:\(sesame!.customNickname)"
        shareKeyImg.image = UIImage(named: "refresh")
        
        if(self.sesame!.accessLevel == .manager  || self.sesame!.accessLevel == .owner   ){
            self.refreshUserList(self)
        }
        sesame!.connect()
    }
    
    func issueAnQRCodeKey(imgv:UIImageView , level:CHDeviceAccessLevel) {
        sesame!.issueKey(accessLevel: level, { (result, invitation) in
            if result.success {
                imgv.image = self.generateQRCode(from: invitation?.absoluteString ?? "error")!
                self.refreshUserList(self)
            } else {
                imgv.image = UIImage(named: "refresh")!
                ViewHelper.showAlertMessage(title: "Oops", message: "issue key failed: \(result.description)", actionTitle: "ok", viewController: self)
            }
        })
    }
}
class BluetoothSesameControlViewController: BaseViewController {
    var timer: Timer?
    var userList = [Operater]()
    var sesame: CHSesameBleInterface?{
        didSet{
            sesame?.delegate = self
        }
    }
    @IBOutlet weak var shareKeyImg: UIImageView!
    @IBOutlet weak var lockIntention: UILabel!
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
    @IBOutlet weak var deviceIDLB: UILabel!
    @IBOutlet weak var bleIDLB: UILabel!
    @IBOutlet weak var enableAutolockBtn: UIButton!
    @IBOutlet weak var disableAutolockBtn: UIButton!
    @IBOutlet weak var registStatusLB: UILabel!
    @IBOutlet weak var powerLB: UILabel!
    @IBOutlet weak var fwVersionLB: UILabel!
    @IBOutlet weak var autolockLB: UILabel!
    @IBOutlet weak var userTable: UITableView!

    @IBAction func lockdegree(_ sender: Any) {
        lockDegree = nowDegree
    }
    @IBAction func generateKey(_ sender: UIButton) {
        
        let title = sender.titleLabel?.text!

        if(title!.contains("manager")){
            issueAnQRCodeKey(imgv: self.shareKeyImg,level: .manager)
        }
        if(title!.contains("guest")){
            issueAnQRCodeKey(imgv: self.shareKeyImg,level: .guest)
        }
        shareKeyImg.image = UIImage(named: "loading")
        
    }

    @IBAction func refreshUserList(_ sender: Any) {
        self.sesame?.getDeviceMembers(){result ,users in
//                   L.d("新成員 ＡＰＩ result.success",result.success)
                   if result.success {
                       DispatchQueue.main.async {
                           self.userList =  users
                           self.userTable.reloadData()
                       }
                   }
               }

    }
    @objc func timerUpdate() {
        guard let status = self.mechStatus else {
            return
        }
        let times = Int(timesInput.text!)
        if(times! == 1) {
            self.timer?.invalidate()
        }
        if(status.isInLockRange()!) {
            L.d(sesame!.unlock().description())
        } else {
            L.d(sesame!.lock().description())
        }
    }
    
    @IBAction func startLock(_ sender: Any) {
        self.timer?.invalidate()

        let second =  Int(self.Interval.text!)!
        self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(second), target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
        self.timer?.fire()
    }
    
    @IBAction func stopLock(_ sender: Any) {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    @IBAction func versionTagClick(_ sender: UIButton) {
        let  err = self.sesame!.getVersionTag { (version, _) -> Void in
            DispatchQueue.main.async {
                sender.setTitle(version, for: .normal)
            }
        }
        L.d(err.description())
    }
    
    @IBAction func unlockdegree(_ sender: Any) {
        unlockDegree = nowDegree
    }
    
    @IBAction func readAutolockClick(_ sender: UIButton) {
        
        let err =  self.sesame!.getAutolockSetting { (delay) -> Void in
            self.autolockLB.text = String(delay)
        }
        L.d(err.description())
        
    }
    
    @IBAction func dufClick(_ sender: UIButton) {
        do {
            let zipData = try Data(contentsOf: Bundle.main.url(forResource: Constants.DFU_Tag, withExtension: ".zip")!)
            _ = self.sesame!.updateFirmware(zipData: zipData,
                                            delegate: TemporaryFirmwareUpdateClass(self){ succuss in
                }
            )
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
                _ = self.sesame?.enableAutolock(delay:  Int(second)!){ (delay) -> Void in
                }
                
            }
        }))
        self.present(alert, animated: true)
    }
    
    @IBAction func disableAutolock(_ sender: Any) {
        self.sesame!.disableAutolock(){ (delay) -> Void in
        }
    }
    
    @IBAction func unregisterServer(_ sender: Any) {
        self.sesame?.unregisterServer(){ result in
                  if(result.success){
                      _ = self.sesame?.unregister()
                  }else{
                      ViewHelper.alert("Error", result.errorCode!, self)
                                         ViewHelper.hideLoadingView(view: self.view)
                  }
              }
    }
    @IBAction func unregisterClick(_ sender: UIButton) {
        L.d(self.sesame!.unregister().description())
    }
    
    @IBAction func setLock(_ sender: UIButton) {
        var config = CHSesameLockPositionConfiguration(lockTarget: lockDegree, unlockTarget: unlockDegree)
        L.d(sesame!.configureLockPosition(configure: &config).description())
    }
    
    @IBAction func unlockClick(_ sender: UIButton) {
        L.d(sesame!.unlock().description())
    }
    
    @IBAction func lockClick(_ sender: UIButton) {
        L.d(sesame!.lock().description())
    }
    
    @IBAction func connectClick(_ sender: UIButton) {
        sesame!.connect()
    }
    
    @IBAction func disConnect(_ sender: Any) {
        sesame!.disconnect()
    }
    
    @IBAction func registerBtn(_ sender: Any) {
        let alert = UIAlertController(title: "sesame name", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Input your sesame name here..."
        })
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if let name = alert.textFields?.first?.text {
                
                let err  = self.sesame!.register(nickname: name, {(result) in
                    if result.success {
                        CHAccountManager.shared.flushDevices({  result in
                            if result.success == true {
                                ViewHelper.showAlertMessage(title: "flushDevices", message: "success", actionTitle: "ok", viewController: self)
                            }
                        })
                    } else {
                        ViewHelper.showAlertMessage(title: "Ooops", message: "register ssm failed:\(result.errorDescription ?? "Unknown error") code:\(result.errorCode ?? "unknown_code")", actionTitle: "OK", viewController: self)
                    }
                })
                L.d(err.description())
            }
        }))
        self.present(alert, animated: true)
    }

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
            lockCircle.setLock(self.sesame!)
            fwVersionLB.text = "\(self.sesame!.fwVersion)"
        }
    }
    
    var gattStatus: CHBleGattStatus = CHBleGattStatus.idle {
        didSet {
            DispatchQueue.main.async(execute: {
                self.gattStatusLB.text = self.gattStatus.description()
            })
        }
    }
    
    var isRegisted: Bool? {
        didSet {
            DispatchQueue.main.async {
                self.registStatusLB.text = self.isRegisted! ? "registered":"unregistered"
            }
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



extension BluetoothSesameControlViewController: CHSesameBleDeviceDelegate {
    func onMechSettingChanged(device: CHSesameBleInterface, setting: CHSesameMechSettings) {
        DispatchQueue.main.async {
            self.mechSetting = setting
        }
    }
    
    func onMechStatusChanged(device: CHSesameBleInterface, status: CHSesameMechStatus, intention: CHSesameIntention) {
        DispatchQueue.main.async {
            self.mechStatus = status
            self.lockIntention.text = intention.description
        }
    }
    
    func onSesameLogin(device: CHSesameBleInterface, setting: CHSesameMechSettings, status: CHSesameMechStatus) {
        DispatchQueue.main.async {
            self.mechSetting = setting
            self.mechStatus = status
        }
    }
    
    func onBleConnectStatusChanged(device: CHSesameBleInterface, status: CBPeripheralState) {
    }
    
    func onBleGattStatusChanged(device: CHSesameBleInterface, status: CHBleGattStatus, error: CHSesameGattError?) {
//        weak var weakSelf = self
        DispatchQueue.main.async {
            self.gattStatus = status
            if let error = error {
                ViewHelper.showAlertMessage(title: "BLE Error", message: error.description(), actionTitle: "OK", viewController: self)
            }
        }
    }
    
    func onBleCommandResult(device: CHSesameBleInterface, command: CHSesameCommand, returnCode: CHSesameCommandResult) {
        DispatchQueue.main.async {
            self.resultLB.text = "\(command.description()),\(returnCode.description())"

            L.d("\(command.description()),\(returnCode.description())")
            if command == .lock || command == .unlock && returnCode == .success {
                let times = Int(self.timesInput.text!)
                if times! > 0 {
                    self.timesInput.text = "\(times! - 1)"
                }
            }
        }
    }
}

extension BluetoothSesameControlViewController: CHBleManagerDelegate {
    func didDiscoverSesame(device: CHSesameBleInterface) {
        DispatchQueue.main.async {
            if device.bleIdStr ==  self.sesame?.bleIdStr {
                self.sesame = device
                self.isRegisted = self.sesame!.isRegistered
            }
        }
    }
}

extension BluetoothSesameControlViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = userTable.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        let user = userList[indexPath.row]
        cell?.textLabel?.text = user.roleType
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let user = userList[indexPath.row]
        if editingStyle == .delete {
            self.deleteUser(user)
        }
    }
    func deleteUser(_ user: Operater) {
        self.sesame!.revokeKey(user) { (result) in
            if result.success {
                self.refreshUserList(self)
                ViewHelper.showAlertMessage(title: "Successful", message: "You had remove this user", actionTitle: "ok", viewController: self)
            } else {
                ViewHelper.showAlertMessage(title: "Oops", message: "Revoke the user failed: \(result.errorDescription ?? "unknown error")", actionTitle: "ok", viewController: self)
            }
        }
    }
}
