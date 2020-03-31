//
//  CHBaseViewController.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/9/11.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import AVFoundation
import SesameSDK
import CoreBluetooth


class BaseViewController: UIViewController {
    
    func onBleConnectStatusChanged(device: CHSesameBleInterface, status: CBPeripheralState){}
    
    func onBleDeviceStatusChanged(device: CHSesameBleInterface, status: CHDeviceStatus){}
    
    func onBleCommandResult(device: CHSesameBleInterface, command: SSM2ItemCode, returnCode: SSM2CmdResultCode){}
    func onMechStatusChanged(device: CHSesameBleInterface, status: CHSesameMechStatus, intention: CHSesameIntention){}
    func onMechSettingChanged(device: CHSesameBleInterface, setting: CHSesameMechSettings){}
    
    
    
    var soundPlayer: AVAudioPlayer?
    
    static var ssm: CHSesameBleInterface!
    
    var sesame: CHSesameBleInterface!{
        didSet{
            BaseViewController.ssm = sesame
        }
    }
    func didDiscoverSesame(device: CHSesameBleInterface) {
        if device.bleIdStr ==  self.sesame?.bleIdStr {
            self.sesame = device
            device.delegate = self
            self.sesame.connect()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        L.d("BASE 中心綁定 Cache",BaseViewController.ssm.bleIdStr)
          if(BaseViewController.ssm != nil){
              sesame = BaseViewController.ssm
          }
        L.d("BASE 中心綁定 sesame",sesame.bleIdStr)

          self.sesame.delegate = self
          CHBleManager.shared.delegate = self
      }
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    func isDarkMode() -> Bool{
        if #available(iOS 12.0, *) {
            let isDark = traitCollection.userInterfaceStyle == .dark ? true : false
            return isDark
        }
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        traitCollectionDidChange(nil)
        let navigationBar = navigationController?.navigationBar
        navigationBar?.shadowImage = UIImage()
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "bee", withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            soundPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            guard let player = soundPlayer else { return }
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func cameraEnable() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if (authStatus == .authorized) {
            //                L.d("掃描已經授權")
        }
        else if (authStatus == .denied) {
            L.d("掃描denied")
            let okAction = UIAlertAction(title:"setting", style: UIAlertAction.Style.default) {
                UIAlertAction in
                let url = URL(string: UIApplication.openSettingsURLString)
                if let url = url, UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url, options: [:],
                                                  completionHandler: {
                                                    (success) in
                        })
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion:nil)
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                UIAlertAction in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion:nil)
                }
            }
            let alert = UIAlertController(title: title, message: "camara privacy", preferredStyle: .alert)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
            
        else if (authStatus == .restricted) {
            L.d("掃描restricted")
        }
        else if (authStatus == .notDetermined) {
            L.d("掃描未決定授權")
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (statusFirst) in
                //                if statusFirst {
                //                } else {
                //                }
            })
        }
    }
}

extension BaseViewController:CHSesameBleDeviceDelegate{
    
}
extension BaseViewController:CHBleManagerDelegate{
    
}
