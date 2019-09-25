//
//  MyDevicesListViewController.swift
//  sesame-sdk-test-app
//
//  Created by Yiling on 2019/08/30.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import UIKit
import SesameSDK

class MyDevicesListViewController: BaseLightViewController {
    @IBOutlet weak var deviceListView: UITableView!

    var deviceList: [CHDeviceProfile] = []

    override func viewDidLoad() {
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }

        self.deviceListView.delegate = self
        self.deviceListView.dataSource = self
        self.title = "My Devices"
    }

    override func viewWillAppear(_ animated: Bool) {
        deviceList = CHAccountManager.shared.deviceManager.getDevices()
        self.deviceListView.reloadData()
    }

    @IBAction func didPressRefresh(_ sender: Any) {
        ViewHelper.showLoadingInView(view: self.view)
        self.flushDevice { (_) in
            DispatchQueue.main.async {
                ViewHelper.hideLoadingView(view: self.view)
            }
        }
    }

    public func flushDevice(_ complete: @escaping (_ apiResult: CHApiResult) -> Void) {
        CHAccountManager.shared.deviceManager.flushDevices { (_, result, devices) in
            if let devices = devices, result.success == true {
                self.deviceList = devices
                DispatchQueue.main.async {
                    self.deviceListView.reloadData()
                }
            }
            complete(result)
        }
    }
}

extension MyDevicesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.deviceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = deviceListView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }

        let device = deviceList[indexPath.row]

        cell?.textLabel?.text = device.model == CHDeviceModel.sesame2 ? "Sesame II: \(device.bleIdentity?.toHexString() ?? "") (\(device.customName ?? "-"))" : device.customName
        return cell!
    }
}

extension MyDevicesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showDeviceDetail", sender: deviceList[indexPath.row])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDeviceDetail" {
            if let controller = segue.destination as? MyDeviceViewController {
                controller.device = sender as? CHDeviceProfile
                controller.listView = self
            }
        }
    }
}
