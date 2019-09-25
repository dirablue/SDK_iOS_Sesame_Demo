//
//  BluetoothDevicesListViewController.swift
//  sesame-sdk-test-app
//
//  Created by Cerberus on 2019/08/05.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import CoreBluetooth
import SesameSDK
import UIKit.UIGestureRecognizerSubclass

class BluetoothDevicesListViewController: BaseLightViewController {
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
        self.title = "Scanned BLE List"
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

extension BluetoothDevicesListViewController: CHBleManagerDelegate {
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

extension BluetoothDevicesListViewController: UITableViewDataSource {
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
        if(ssm.gattStatus == .idle) {
            do {
                if ssm.accessLevel == .owner {
                    try ssm.connect()
                }
            } catch {
                print(error)
            }
        }


        return cell
    }

    //    func tableView(_ tableView: UITableView,
    //                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    //    {
    //        let closeAction = UIContextualAction(style: .normal, title:  "Close", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
    //            print("OK, marked as Closed")
    //            success(true)
    //        })
    //        closeAction.image = UIImage(named: "a")
    //        closeAction.backgroundColor = .purple
    //
    //        return UISwipeActionsConfiguration(actions: [closeAction])
    //
    //    }
    //
    //    func tableView(_ tableView: UITableView,
    //                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    //    {
    //        let modifyAction = UIContextualAction(style: .normal, title:  "Update", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
    //            print("Update action ...")
    //            success(true)
    //        })
    //        modifyAction.image = UIImage(named: "b")
    //        modifyAction.backgroundColor = .blue
    //
    //        return UISwipeActionsConfiguration(actions: [modifyAction])
    //    }
}

extension BluetoothDevicesListViewController: UITableViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDeviceDetail"{
            if let controller = segue.destination as? BluetoothSesameControlViewController {
                controller.deviceID = sender as? String
            }
        }
    }
}

class SingleTouchDownGestureRecognizer: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        CHBleManager.shared.disableScan()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        CHBleManager.shared.enableScan()
    }
}
