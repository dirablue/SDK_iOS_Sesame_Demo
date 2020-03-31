//
//  SSM2SettingVC.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/10/14.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import CoreBluetooth
import SesameSDK

class SSM2SettingVC: BaseViewController {
    var memberList = [Operater]()
//    var sesame: CHSesameBleInterface!{
//        didSet{
//            sesame?.delegate = self
//        }
//    }
    @IBOutlet weak var memberCollectionView: UICollectionView!

    @IBOutlet weak var arrowImg: UIImageView!
    @IBOutlet weak var auleftHintLB: UILabel!
    @IBOutlet weak var auRightHintLB: UILabel!
    @IBOutlet weak var changenameLb: UILabel!
    @IBOutlet weak var angleLb: UILabel!
    @IBOutlet weak var dfuLB: UILabel!
    @IBOutlet weak var autolockLb: UILabel!
    @IBOutlet weak var unsesameBtn: UIButton!
    @IBOutlet weak var autolockSwitch: UISwitch!
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var autolockScend: UILabel!
    @IBOutlet weak var secondPicker: UIPickerView!
    @IBAction func AutolockSwitch(_ sender: UISwitch) {
        sender.isOn ?
            self.sesame.enableAutolock(delay: Int(2)){ (delay) -> Void in
                DispatchQueue.main.async {
                    self.autolockScend.text = String(delay)
                }
            }:
            self.sesame.disableAutolock(){ (delay) -> Void in
                DispatchQueue.main.async {
                    
                    self.autolockScend.text = String(delay)
                }
        }
        secondPicker.isHidden = !sender.isOn
        autolockScend.isHidden = !sender.isOn
        auleftHintLB.isHidden = !sender.isOn
        auRightHintLB.isHidden = !sender.isOn
    }
    @IBAction func defClick(_ sender: Any) {
        let check = UIAlertAction.addAction(title: "SesameOS Update".localStr, style: .destructive) { (action) in
            do {
                if let filePath = Bundle.main.url(forResource: nil, withExtension: ".zip") {
                    let zipData = try Data(contentsOf: filePath)
                    _ = self.sesame.updateFirmware(zipData: zipData, delegate: TemporaryFirmwareUpdateClass(self){ succuss in
                    })
                }
            } catch {
                ViewHelper.alert("Error", "Update Error: \(error)", self)
            }
        }
        UIAlertController.showAlertController(sender as! UIView,style: .actionSheet, actions: [check])
    }
    
    @IBAction func autolockSecond(_ sender: Any) {

        if( self.autolockScend.text == "0"){
            secondPicker.isHidden  =   true
            return
        }
        secondPicker.isHidden = !secondPicker.isHidden
    }
    @IBAction func unRegister(_ sender: UIButton) {
        let check = UIAlertAction.addAction(title: "Delete this Sesame".localStr, style: .destructive) { (action) in
            ViewHelper.showLoadingInView(view: self.view)
            self.sesame.unregisterServer(){ result in
                DispatchQueue.main.async {
                    ViewHelper.hideLoadingView(view: self.view)
                }
                if(result.success){
                    _ = self.sesame.unregister()
                    DispatchQueue.main.async {
                        let tb =  self.tabBarController as! GeneralTabViewController
                        self.navigationController?.popToRootViewController(animated: true)
                        //todo kill this delay
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.2) {
                            tb.delegateHome?.refleshKeyChain()
                        }
                    }
                }
            }
        }
        UIAlertController.showAlertController(sender,style: .actionSheet, actions: [check])
    }
    
    @IBAction func angleSet(_ sender: UIButton) {
        self.performSegue(withIdentifier: "angle", sender: sesame)
    }
    @IBAction func changeName(_ sender: UIButton) {

        CHSSMChangeNameDialog.show(self.sesame.customNickname){ name in
            if name == "" {
                self.view.makeToast("Enter Sesame name".localStr)
                return
            }
            self.sesame.renameDevice(name:name){result in
                L.d(result.success)
                if(result.success){
                    DispatchQueue.main.async {
                        (self.tabBarController as! GeneralTabViewController).delegateHome?.refleshKeyChain()
                        (self.tabBarController as! GeneralTabViewController).delegateHome?.refleshRoomBackTitle(name: name)
                        self.title = name
                    }
                }
            }
        }


    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        autolockSwitch.isOn = false
        self.sesame.getDeviceMembers(){result ,users in
            if result.success {

                DispatchQueue.main.async {
                    self.memberList =  users.sorted(by: {$0.roleType! > $1.roleType!})
                    self.memberCollectionView.reloadData()
                }
            }
        }
        CHBleManager.shared.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = sesame.customNickname
        L.d("詳細設定頁面")
        self.autolockScend.isHidden = true
        self.auleftHintLB.isHidden = true
        self.auRightHintLB.isHidden = true
        changenameLb.text = "Change Sesame Name".localStr
        angleLb.text = "Configure Angles".localStr
        dfuLB.text = "SesameOS Update".localStr
        autolockLb.text = "autolock".localStr
        unsesameBtn.setTitle("Delete this Sesame".localStr, for: .normal)
        auleftHintLB.text = "After".localStr
        auRightHintLB.text = "sec".localStr
        arrowImg.image = UIImage.SVGImage(named: "arrow")

        let flowLayout = memberCollectionView?.collectionViewLayout as? AlignedCollectionViewFlowLayout
        flowLayout?.horizontalAlignment = .justified
        
        secondPicker.isHidden = true
        self.sesame.getAutolockSetting { (delay) -> Void in
            self.autolockScend.text = String(delay)
            self.autolockSwitch.isOn = (Int(delay) > 0)
            self.autolockScend.isHidden = !self.autolockSwitch.isOn
            self.auleftHintLB.isHidden = !self.autolockSwitch.isOn
            self.auRightHintLB.isHidden = !self.autolockSwitch.isOn
        }
        self.sesame.getVersionTag { (version, _) -> Void in
            self.version.text = version
        }

        refleshUI()
    }
    func refleshUI()  {
        autolockSwitch.isEnabled = (sesame.deviceStatus.loginStatus() == .login)
    }

   override func onBleConnectStatusChanged(device: CHSesameBleInterface, status: CBPeripheralState) {
         //        L.d("設定頁面連線變化",status == CBPeripheralState.connected)
         refleshUI()
         DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired
             _ = device.getVersionTag { (version, _) -> Void in
                 self.version.text = version
                 self.view.makeToast(version)
             }
         }
     }
}

extension SSM2SettingVC{
//    func didDiscoverSesame(device: CHSesameBleInterface) {
//        if device.bleIdStr ==  self.sesame?.bleIdStr {
//            self.sesame = device
//            device.delegate = self
//
//            self.sesame.connect()
//        }
//    }
}
