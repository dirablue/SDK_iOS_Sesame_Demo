//
//  setLockVC.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/10/11.
//  Copyright © 2019 Cerberus. All rights reserved.
//


import Foundation
import UIKit
import SesameSDK
import CoreBluetooth
class setLockVC: BaseViewController  {
    @IBOutlet weak var sesameView: SesameView!
    @IBAction func setLock(_ sender: UIButton) {
        lockDegree = nowDegree
//        L.d("nowDegree",nowDegree)
//        L.d("lockDegree",lockDegree)
//        L.d("unlockDegree",unlockDegree)

        if(lockDegree == -32768  ){
            lockDegree = 0
        }
        if(unlockDegree == -32768  ){
            unlockDegree = 0
        }

        var config = CHSesameLockPositionConfiguration(lockTarget: lockDegree, unlockTarget: unlockDegree)
        _ = sesame!.configureLockPosition(configure: &config).description()
        //        sesameView.setLockV(lockDegree)

    }
    override func viewWillAppear(_ animated: Bool) {
        L.d("set angle")

           CHBleManager.shared.enableScan()
       }

       override func viewWillDisappear(_ animated: Bool) {
           CHBleManager.shared.disableScan()
       }

    @IBAction func setUnlock(_ sender: UIButton) {

        unlockDegree = nowDegree
        if(lockDegree == -32768  ){
            lockDegree = 0
        }
        if(unlockDegree == -32768  ){
            unlockDegree = 0
        }
//        L.d("nowDegree",nowDegree)
//        L.d("lockDegree",lockDegree)
//        L.d("unlockDegree",unlockDegree)
        var config = CHSesameLockPositionConfiguration(lockTarget: lockDegree, unlockTarget: unlockDegree)
       sesame!.configureLockPosition(configure: &config).description()
    }
    @IBAction func setSesame(_ sender: UIButton) {
        _ = sesame?.toggle()
    }

    var lockDegree: Int16 = 0 {
        didSet {
        }
    }

    var unlockDegree: Int16 = 0 {
        didSet {
        }
    }
    var nowDegree: Int16 = 0 {
        didSet {

        }
    }
    var gattStatus: CHBleGattStatus = CHBleGattStatus.idle {
        didSet {
        }
    }

    var sesame: CHSesameBleInterface?{
        didSet{
            sesame?.delegate = self
            sesame?.connect()
            gattStatus = sesame!.gattStatus
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "setangle".localStr
        CHBleManager.shared.delegate = self

        sesameView?.setLock(sesame!)
        guard let setting = sesame!.mechSetting else {
            return
        }
        lockDegree = Int16(setting.getLockPosition()!)
        unlockDegree = Int16(setting.getUnlockPosition()!)

        guard let status = sesame!.mechStatus else {
            return
        }
        nowDegree = Int16(status.getPosition()!)

//        L.d("nowDegree",nowDegree)
//        L.d("lockDegree",lockDegree)
//        L.d("unlockDegree",unlockDegree)


//      let  meter = TemperatureMeter(frame: CGRect(x: 40, y: 80, width: 80, height: 80))
//        meter.setPercent(percent: CGFloat(30))
//        self.view.addSubview(meter)

    }

}

extension setLockVC:CHSesameBleDeviceDelegate{
    func onBleConnectStatusChanged(device: CHSesameBleInterface, status: CBPeripheralState) {

    }

    func onBleGattStatusChanged(device: CHSesameBleInterface, status: CHBleGattStatus, error: CHSesameGattError?) {
        gattStatus = status
    }

    func onSesameLogin(device: CHSesameBleInterface, setting: CHSesameMechSettings, status: CHSesameMechStatus) {

    }

    func onBleCommandResult(device: CHSesameBleInterface, command: CHSesameCommand, returnCode: CHSesameCommandResult) {

    }

    func onMechStatusChanged(device: CHSesameBleInterface, status: CHSesameMechStatus, intention: CHSesameIntention) {

        guard let status = device.mechStatus else {
            return
        }
            nowDegree = Int16(status.getPosition()!)
            sesameView?.setLock(self.sesame!)

    }

    func onMechSettingChanged(device: CHSesameBleInterface, setting: CHSesameMechSettings) {
        guard let status = device.mechStatus else {
            return
        }
         sesameView?.setLock(self.sesame!)
    }
}

extension setLockVC: CHBleManagerDelegate {
    func didDiscoverSesame(device: CHSesameBleInterface) {
        DispatchQueue.main.async {
            if device.bleIdStr ==  self.sesame?.bleIdStr {
                self.sesame = device
            }
        }
    }
}
