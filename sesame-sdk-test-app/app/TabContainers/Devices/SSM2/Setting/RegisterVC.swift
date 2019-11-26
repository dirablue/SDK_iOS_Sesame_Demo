//
//  RegisterVC.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/10/10.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import UIKit
import SesameSDK
import CoreBluetooth
class RegisterVC: BaseViewController  {
    override func viewDidAppear(_ animated: Bool) {
        L.d("viewDidAppear")
        CHBleManager.shared.enableScan()
        CHBleManager.shared.delegate = self

    }

    override func viewWillDisappear(_ animated: Bool) {
        L.d("viewWillDisappear")
        CHBleManager.shared.disableScan()
    }
    var sesame: CHSesameBleInterface?{
        didSet{
            sesame?.delegate = self
            sesame?.connect()
        }
    }
    @IBOutlet weak var deviceName: UITextField!
    override func viewDidLoad() {
//        CHBleManager.shared.delegate = self

        deviceName.delegate = self
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tapGesAction(_:)))
        tapGes.addTarget(self, action: #selector(tapGesAction))
        self.view.addGestureRecognizer(tapGes)
    }
    @objc func tapGesAction(_ tapGes : UITapGestureRecognizer){
        self.view.endEditing(true)
    }
}

extension RegisterVC:CHSesameBleDeviceDelegate{
    func onBleConnectStatusChanged(device: CHSesameBleInterface, status: CBPeripheralState) {
        //        L.d("status",status.rawValue)
        deviceName.isHidden = (status != .connected)
        //        status == .connected
    }
    
    func onBleGattStatusChanged(device: CHSesameBleInterface, status: CHBleGattStatus, error: CHSesameGattError?) {
        
    }
    
    func onSesameLogin(device: CHSesameBleInterface, setting: CHSesameMechSettings, status: CHSesameMechStatus) {
        
    }
    
    func onBleCommandResult(device: CHSesameBleInterface, command: CHSesameCommand, returnCode: CHSesameCommandResult) {
        
    }
    
    func onMechStatusChanged(device: CHSesameBleInterface, status: CHSesameMechStatus, intention: CHSesameIntention) {
        
    }
    
    func onMechSettingChanged(device: CHSesameBleInterface, setting: CHSesameMechSettings) {
        
    }
    
}
extension RegisterVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        weak var weakSelf = self
        _ = self.sesame!.register(nickname: deviceName.text!, {(result) in
            L.d("result.success",result.success)
            if result.success {
                DispatchQueue.main.async {
                    self.dismiss(animated: false, completion: nil)

                    let tb =  self.tabBarController as! GeneralTabViewController
                    tb.deviceReflesh()
                    self.navigationController?.popViewController(animated: true)
                    self.performSegue(withIdentifier:  "setting", sender: self.sesame)
                }
            }else{
                DispatchQueue.main.async {

                    let okAction = UIAlertAction(title:"ok", style: UIAlertAction.Style.default) {
                        UIAlertAction in
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }

                    let alert = UIAlertController(title: "Error", message: result.errorCode!, preferredStyle: .alert)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }

            }
        })
        self.view.endEditing(true)
        ViewHelper.showLoadingInView(view: self.view)
        return true
    }
}

extension RegisterVC: CHBleManagerDelegate {
    func didDiscoverSesame(device: CHSesameBleInterface) {
        DispatchQueue.main.async {
            if device.bleIdStr ==  self.sesame?.bleIdStr {
                L.d("RegisterVC")
                self.sesame = device
            }
        }
    }
}
extension RegisterVC: UITableViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setting"{
            if let controller = segue.destination as? setLockVC {
                let sesameDevice = sender as? CHSesameBleInterface
                controller.sesame = sesameDevice
            }
        }
    }
}
