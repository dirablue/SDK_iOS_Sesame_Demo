//
//  ScanViewController.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/9/27.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import SesameSDK
import AVFoundation
extension ScanViewController{
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        back.setImage( UIImage.SVGImage(named:isDarkMode() ?"icons_filled_close_b" : "icons_filled_close"), for: .normal)
    }
}
class ScanViewController: BaseViewController {
    var player: AVAudioPlayer?

    var tabVC:GeneralTabViewController?
    @IBOutlet weak var scannerView: QRScannerView! {
        didSet {
            scannerView.delegate = self
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if !scannerView.isRunning {
            scannerView.startScanning()
        }
        cameraEnable()
    }

    @IBOutlet weak var rightItem: UIBarButtonItem!
    override func viewWillDisappear(_ animated: Bool) {
        if !scannerView.isRunning {
            scannerView.stopScanning()
        }
    }

    @IBAction func backClick(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion:nil)
        }
    }
    @IBOutlet weak var back: UIButton!
    override func viewDidLoad() {
        //        back.setImage( UIImage.SVGImage(named: "icons_filled_close"), for: .normal)
    }

    func playSound() {
        guard let url = Bundle.main.url(forResource: "bee", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }

    func cameraEnable() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if (authStatus == .authorized) {
            L.d("authorized")
        }
        else if (authStatus == .denied) {
            L.d("denied")
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
            L.d("restricted")
        }
        else if (authStatus == .notDetermined) {
            L.d("notDetermined")
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (statusFirst) in
                if statusFirst {
                } else {
                }
            })
        }

    }
}

extension ScanViewController: QRScannerViewDelegate {
    func qrScanningDidStop() {
        L.d("qrScanningDidStop")
    }

    func qrScanningDidFail() {
        L.d("qrScanningDidFail")
    }

    func qrScanningSucceededWithCode(_ QRCode: String?) {
        playSound()
        CHAccountManager.shared.receiveQRCode(qrcode:QRCode ?? "error"){ (result,event) in
            switch event{
            case .getKeyFromOwner:
                if(result){
                    self.dismiss(animated: true, completion:nil)
                }
            case .addFriendFromACcount:
                if(result){
                    self.tabVC?.selectedIndex = 1
                    self.tabVC?.refreshFriendPage()
                    self.dismiss(animated: true, completion:nil)
                }
            }
        }
    }
}
