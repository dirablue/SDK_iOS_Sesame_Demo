//
//  BLEDeviceListVC.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/9/11.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import CoreBluetooth
import SesameSDK
import UIKit.UIGestureRecognizerSubclass

class DeviceTestListVC: BaseLightViewController {
    var deviceNameID = [String]()
    var devices = [CHSesameBleInterface]()
    var sesameDevicesMap: [String: CHSesameBleInterface] = [:]
    @IBOutlet weak var deviceTableView: UITableView!
    override func viewWillAppear(_ animated: Bool) {
        CHBleManager.shared.enableScan()
    }

    override func viewWillDisappear(_ animated: Bool) {
        CHBleManager.shared.disableScan()
    }

    override func viewDidAppear(_ animated: Bool) {
        CHBleManager.shared.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Test"
        self.deviceTableView.delegate = self
        self.deviceTableView.dataSource = self
        self.deviceTableView.allowsSelection = true
        tabBarItem.selectedImage = tabBarItem.selectedImage?.withRenderingMode(.alwaysOriginal)

        let gesture = SingleTouchDownGestureRecognizer(target: self, action: nil)
        self.deviceTableView.addGestureRecognizer(gesture)

        let tabGesture = UITapGestureRecognizer(target: self, action: Selector("tapGesture:"))
        self.deviceTableView.addGestureRecognizer(tabGesture)

    }

    @objc func tapGesture(_ sender: UITapGestureRecognizer) {
        let touch =   sender.location(in: self.deviceTableView)
        if let indexPath = self.deviceTableView.indexPathForRow(at: touch) {
            self.performSegue(withIdentifier: "toDeviceDetail", sender: deviceNameID[indexPath.row])
        }
    }

    @IBAction func freshDidPress(_ sender: Any) {
        devices.removeAll()
        deviceNameID.removeAll()
        sesameDevicesMap.removeAll()
        deviceTableView.reloadData()
    }
}

extension DeviceTestListVC: CHBleManagerDelegate {
    func didDiscoverSesame(device: CHSesameBleInterface) {
        deviceNameID.removeAll()
        devices.removeAll()
        sesameDevicesMap.updateValue(device, forKey: device.identifier)

        for (key, value) in sesameDevicesMap {
            devices.append(value)
            deviceNameID.append(key)
        }

        deviceTableView.reloadData()

    }
}

extension DeviceTestListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ssm = devices[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SSMCell", for: indexPath) as! BluetoothDevicesCell
        cell.title.text = "BleID: \(ssm.bleId?.toHexString().prefix(8) ?? "UNKNOWN")"
        cell.registerStatus.text = "\(ssm.isRegistered ? "Registered" : "Unregistered")"
        cell.registerStatus.textColor = ssm.isRegistered ? UIColor.lightGray : UIColor.red
        cell.rssiValue.text = "rssi: \(ssm.rssi)"
        cell.nameLB.text = ssm.customNickname

        if let accessLevel = ssm.accessLevel {
            cell.ownerLB.text = accessLevel.rawValue
        } else {
            cell.ownerLB.text = ""
        }

        cell.connectStatusLB.text = ssm.gattStatus.description()

//        if ssm.accessLevel == .owner {
//            let rssi = abs(Int(truncating: ssm.rssi))
//            if( 50 > rssi ){
//                self.performSegue(withIdentifier: "toDeviceDetail", sender: deviceNameID[indexPath.row])
//            }
//        }

        return cell
    }


}

extension DeviceTestListVC: UITableViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDeviceDetail"{
            if let controller = segue.destination as? BluetoothAutoTestViewController {
                controller.deviceID = sender as? String
            }
        }
    }
}
