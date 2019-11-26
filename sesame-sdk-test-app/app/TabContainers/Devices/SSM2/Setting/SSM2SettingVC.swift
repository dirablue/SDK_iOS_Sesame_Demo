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
    var memberList = [Client]()

    @IBOutlet weak var angleLb: UILabel!
    @IBOutlet weak var dfuLB: UILabel!
    @IBOutlet weak var autolockLb: UILabel!
    @IBOutlet weak var unsesameBtn: UIButton!

    @IBOutlet weak var autolockSwitch: UISwitch!
    @IBOutlet weak var version: UILabel!
    @IBOutlet weak var autolockScend: UILabel!
    @IBOutlet weak var secondPicker: UIPickerView!
    @IBAction func AutolockSwitch(_ sender: UISwitch) {
        _ = sender.isOn ?
            self.sesame!.enableAutolock(delay: Int(2)){ (delay) -> Void in
                DispatchQueue.main.async {
                    self.autolockScend.text = String(delay)
                }
            }.description():
            self.sesame!.disableAutolock(){ (delay) -> Void in
                DispatchQueue.main.async {

                    self.autolockScend.text = String(delay)
                }
            }.description()
        secondPicker.isHidden = !sender.isOn
    }
    @IBAction func defClick(_ sender: Any) {
        do {
            if let filePath = Bundle.main.url(forResource: "sesame2_firmware", withExtension: ".zip") {
                let zipData = try Data(contentsOf: filePath)
                self.sesame!.updateFirmware(zipData: zipData, delegate: TemporaryFirmwareUpdateClass(self)).description()
            } else {
                ViewHelper.alert("Error", "Can not open firmware file", self)
            }
        } catch {
            ViewHelper.alert("Error", "Update Error: \(error)", self)
        }
    }

    @IBAction func autolockSecond(_ sender: Any) {
        if( self.autolockScend.text == "0"){
            secondPicker.isHidden  =   true
            return
        }
        secondPicker.isHidden = !secondPicker.isHidden
    }
    @IBAction func unRegister(_ sender: UIButton) {
        ViewHelper.showLoadingInView(view: self.view)
        
        if let deviceProfile = self.sesame!.deviceProfile {
            deviceProfile.unregisterDeivce() { (result) in
                DispatchQueue.main.async {

                    if(result.success){
                        self.sesame?.deviceProfile?.deleteAllHistory()
                        self.sesame?.unregister()
                        let tb =  self.tabBarController as! GeneralTabViewController
                        tb.deviceReflesh()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }else{
                        ViewHelper.alert("Error", result.errorCode!, self)
                        ViewHelper.hideLoadingView(view: self.view)
                    }
                }
            }

        }
    }
    var sesame: CHSesameBleInterface?{
        didSet{
            sesame?.delegate = self
        }
    }
    @IBAction func angleSet(_ sender: UIButton) {
        self.performSegue(withIdentifier: "angle", sender: sesame!)
    }


    @IBOutlet weak var memberCollectionView: UICollectionView!
    override func viewWillAppear(_ animated: Bool) {
        CHAccountManager.shared.deviceManager.getDeviceMembers(self.sesame!) { (_, result, users) in
            if result.success {
                if let users = users {
                    DispatchQueue.main.async {
                        self.memberList =  users
                        self.memberCollectionView.reloadData()
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = sesame?.customNickname


        angleLb.text = "setangle".localStr
        dfuLB.text = "dfu".localStr
        autolockLb.text = "autolock".localStr
        unsesameBtn.setTitle("unsesame".localStr, for: .normal)

        let flowLayout = memberCollectionView?.collectionViewLayout as? AlignedCollectionViewFlowLayout
        flowLayout?.horizontalAlignment = .justified

        secondPicker.isHidden = true
        _ =  self.sesame!.getAutolockSetting { (delay) -> Void in
            DispatchQueue.main.async {

                self.autolockScend.text = String(delay)
                self.autolockSwitch.isOn = (Int(delay) > 0)
                let _ = self.sesame!.getVersionTag { (version, _) -> Void in
                    self.version.text = version
                }
            }
        }
    }
}






