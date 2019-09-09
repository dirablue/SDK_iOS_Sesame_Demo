//
//  MyDeviceViewController.swift
//  sesame-sdk-test-app
//
//  Created by Yiling on 2019/08/30.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import UIKit
import SesameSDK

class MyDeviceViewController: UIViewController {
    var device: CHDeviceProfile?
    var listView: MyDevicesListViewController?

    @IBOutlet weak var detailLabel: UILabel!

    override func viewDidLoad() {
        detailLabel.text = "Device ID: \(device!.deviceId.uuidString)\nCustomName: \(device!.customName ?? "")\nDevice Model: \(device!.model.rawValue)\nBluetooth Identity: \(device!.bleIdentity?.toHexString() ?? "")\nAccess Level: \(device!.accessLevel.rawValue)\n"
        detailLabel.sizeToFit()
        detailLabel.numberOfLines = 0
    }

    @IBAction func unregisterDidPress(_ sender: Any) {
        weak var weakSelf = self
        ViewHelper.showLoadingInView(view: self.view)
        device?.unregisterDeivce(deviceId: device!.deviceId, model: device!.model, completion: { (result) in
            ViewHelper.hideLoadingView(view: weakSelf?.view)
            if result.success {
                self.listView?.flushDevice { (_) in
                    weakSelf?.presentingViewController?.dismiss(animated: true, completion: nil)
                }
            } else {
                ViewHelper.showAlertMessage(title: "Error", message: "unregister failed: \(result.errorDescription ?? "unknown reason")", actionTitle: "ok", viewController: weakSelf!)
            }
        })
    }
}
