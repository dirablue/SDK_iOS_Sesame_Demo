//
//  ScanViewController.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/9/27.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import SesameSDK


class ScanViewController: BaseViewController {
    @IBOutlet weak var scannerView: QRScannerView! {
        didSet {
            scannerView.delegate = self
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if !scannerView.isRunning {
            scannerView.startScanning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if !scannerView.isRunning {
            scannerView.stopScanning()
        }
    }
    override func viewDidLoad() {
        L.d("viewDidLoad")
    }
    @IBAction func back(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion:nil)
        }
    }
}

extension ScanViewController: QRScannerViewDelegate {
    func qrScanningDidStop() {
        print("qrScanningDidStop")
    }

    func qrScanningDidFail() {
        print("qrScanningDidFail")
    }

    func qrScanningSucceededWithCode(_ str: String?) {
        // block too short random qrcode
        if str != nil && str!.count > 40 {
            CHAccountManager.shared.deviceManager.applyDeviceInvitation(invitation: str!) { (result) in
                L.d("result.success",result.success)
                if result.success {
                    ViewHelper.showAlertMessage(title: "Successful", message: "You had received a new key", actionTitle: "ok", viewController: self)
                } else {
                    ViewHelper.showAlertMessage(title: "Ooops", message: "Get key failed: \(result.errorDescription ?? "unknown error")", actionTitle: "ok", viewController: self)
                }

            }
        }
    }
}
