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

    @IBOutlet weak var topHintLB: UILabel!
    @IBOutlet weak var btomHintLB: UILabel!
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
         sesame.configureLockPosition(configure: &config)
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
        sesame.configureLockPosition(configure: &config)
    }
    @IBAction func setSesame(_ sender: UIButton) {
        sesame.toggle()
    }

    var lockDegree: Int16 = 0
    var unlockDegree: Int16 = 0
    var nowDegree: Int16 = 0

//     var sesame: CHSesameBleInterface!
//        {
//        didSet{
//            sesame.delegate = self
//            sesame.connect()
////            gattStatus = sesame.gattStatus
//        }
//    }
    override func viewDidAppear(_ animated: Bool) {
        L.d("setLockVC","viewDidAppear")
           CHBleManager.shared.enableScan()
           CHBleManager.shared.delegate = self
       }
    override func viewDidLoad() {
        super.viewDidLoad()
        L.d("setLockVC","viewDidLoad")
        lockHintImg.image = UIImage.SVGImage(named: "icon_lock")
        unlockHintImg.image = UIImage.SVGImage(named: "icon_unlock")
        if let setting = sesame.mechSetting{
            if(setting.isConfigured()){
                L.d("已經設定過")
            }else{
                L.d("沒設定過")
                var config = CHSesameLockPositionConfiguration(lockTarget: 1024/4, unlockTarget: 0)
                sesame.configureLockPosition(configure: &config)
            }
        }else{
            L.d("設定讀取失敗")
        }
        btomHintLB.text = "Please completely lock/unlock Sesame, and press the buttons below to configure locked/unlocked positions respectively.".localStr
        self.title = "Configure Angles".localStr
        topHintLB.text = "Please configure Locked/Unlocked Angle.".localStr
        setlockBtn.setTitle("Set Locked Position".localStr, for: .normal)
        setunlockBtn.setTitle("Set Unlocked Position".localStr, for: .normal)
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



    }

 override   func onMechStatusChanged(device: CHSesameBleInterface, status: CHSesameMechStatus, intention: CHSesameIntention) {
          guard let status = device.mechStatus else {
              return
          }
          nowDegree = Int16(status.getPosition()!)
          sesameView?.setLock(self.sesame)
      }

    override  func onMechSettingChanged(device: CHSesameBleInterface, setting: CHSesameMechSettings) {
          view.makeToast("Completely Set".localStr)
      }
}

