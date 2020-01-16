//
//  setLockVC.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/10/11.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import SesameSDK
import CoreBluetooth

class setLockVC: BaseViewController  {

    @IBOutlet weak var lockHintImg: UIImageView!

    @IBOutlet weak var unlockHintImg: UIImageView!


    @IBOutlet weak var setlockBtn: UIButton!
    @IBOutlet weak var setunlockBtn: UIButton!
    @IBOutlet weak var sesameView: SesameView!
    @IBAction func setLock(_ sender: UIButton) {
        lockDegree = nowDegree
        if(lockDegree == -32768){
            lockDegree = 0
        }
        if(unlockDegree == -32768){
            unlockDegree = 0
        }
        var config = CHSesameLockPositionConfiguration(lockTarget: lockDegree, unlockTarget: unlockDegree)
        if(abs(lockDegree - unlockDegree) < 50){
            view.makeToast("Too Close".localStr)
            return
        }
        _ = sesame.configureLockPosition(configure: &config)
    }


    override func viewWillDisappear(_ animated: Bool) {
        L.d("setLockVC","viewWillDisappear")
//        CHBleManager.shared.disableScan()
    }

    @IBAction func setUnlock(_ sender: UIButton) {
        unlockDegree = nowDegree
        if(lockDegree == -32768){
            lockDegree = 0
        }
        if(unlockDegree == -32768){
            unlockDegree = 0
        }

        var config = CHSesameLockPositionConfiguration(lockTarget: lockDegree, unlockTarget: unlockDegree)
        if(abs(lockDegree - unlockDegree) < 50){
            view.makeToast("Too Close".localStr)
                   return
               }
        _ = sesame.configureLockPosition(configure: &config)
    }
    @IBAction func setSesame(_ sender: UIButton) {
        _ = sesame.toggle()
    }

    var lockDegree: Int16 = 0
    var unlockDegree: Int16 = 0
    var nowDegree: Int16 = 0
    var gattStatus: CHBleGattStatus = CHBleGattStatus.idle
    var sesame: CHSesameBleInterface!{
        didSet{
            sesame.delegate = self
            sesame.connect()
            gattStatus = sesame.gattStatus
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        L.d("setLockVC","viewDidAppear")

           CHBleManager.shared.enableScan(true)
           CHBleManager.shared.delegate = self
       }
    override func viewDidLoad() {
        super.viewDidLoad()
        L.d("setLockVC","viewDidLoad")
        if let setting = sesame.mechSetting{
            if(setting.isConfigured()){
                L.d("已經設定過")
            }else{
                L.d("沒設定過")
                var config = CHSesameLockPositionConfiguration(lockTarget: 1024/4, unlockTarget: 0)
                _ = sesame.configureLockPosition(configure: &config)
            }
        }else{
            L.d("設定讀取失敗")
        }
        self.title = "Configure Angles".localStr
        setlockBtn.setTitle("Set Lock Position".localStr, for: .normal)
        setunlockBtn.setTitle("Set Unlock Position".localStr, for: .normal)
        sesameView?.setLock(sesame)
        guard let setting = sesame.mechSetting else {
            return
        }
        lockDegree = Int16(setting.getLockPosition()!)
        unlockDegree = Int16(setting.getUnlockPosition()!)

        guard let status = sesame.mechStatus else {
            return
        }
        nowDegree = Int16(status.getPosition()!)

        lockHintImg.image = UIImage.SVGImage(named: "icon_lock")
        unlockHintImg.image = UIImage.SVGImage(named: "icon_unlock")







    }
}

extension setLockVC:CHSesameBleDeviceDelegate{
    func onBleConnectStatusChanged(device: CHSesameBleInterface, status: CBPeripheralState) {
    }

    func onBleGattStatusChanged(device: CHSesameBleInterface, status: CHBleGattStatus, error: CHSesameGattError?) {gattStatus = status}

    func onSesameLogin(device: CHSesameBleInterface, setting: CHSesameMechSettings, status: CHSesameMechStatus) {}

    func onBleCommandResult(device: CHSesameBleInterface, command: CHSesameCommand, returnCode: CHSesameCommandResult) {}

    func onMechStatusChanged(device: CHSesameBleInterface, status: CHSesameMechStatus, intention: CHSesameIntention) {
        guard let status = device.mechStatus else {
            return
        }
        nowDegree = Int16(status.getPosition()!)
        sesameView?.setLock(self.sesame)
    }

    func onMechSettingChanged(device: CHSesameBleInterface, setting: CHSesameMechSettings) {
        view.makeToast("Set Complete".localStr)
    }
}

extension setLockVC:CHBleManagerDelegate{
    func didDiscoverSesame(device: CHSesameBleInterface) {
//        L.d("BleID",device.bleIdStr,"新<===>舊",self.sesame.bleIdStr)
//        L.d("BleID",device.identifier,"新<===>舊",self.sesame.identifier)
        if device.identifier ==  self.sesame.identifier {
//            L.d("設定頁面重心連線!!!!!!!!!!!")
            self.sesame = device
        }
    }
}
