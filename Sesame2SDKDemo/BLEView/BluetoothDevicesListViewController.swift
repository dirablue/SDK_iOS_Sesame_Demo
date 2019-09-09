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

class BluetoothDevicesListViewController: UIViewController {
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

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    }
}

extension BluetoothDevicesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ssm = devices[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SSMCell", for: indexPath) as! BluetoothDevicesCell

        cell.title.text = "BleID: \(ssm.deviceBleId.prefix(8))"
        cell.registerStatus.text = "\(ssm.isRegistered ? "Registered" : "Unregistered")"
        cell.registerStatus.textColor = ssm.isRegistered ? UIColor.lightGray : UIColor.red
        cell.rssiValue.text = "rssi: \(ssm.rssi)"
        cell.nameLB.text = ssm.customNickname

        if let accessLevel = ssm.accessLevel {
            cell.ownerLB.text = accessLevel.rawValue
        } else {
            cell.ownerLB.text = ""
        }

        switch ssm.gattStatus {
        case .idle:
            cell.connectStatusLB.text = "disconnected"
            do {
                if ssm.accessLevel == .owner {
                    try ssm.connect()
                }
            } catch {
                print(error)
            }
        case .connecting:
            cell.connectStatusLB.text = "connecting"
        case .connected:
            cell.connectStatusLB.text = "connected"
        case .established:
            cell.connectStatusLB.text = "established"
        case .busy:
            cell.connectStatusLB.text = "busy"
        case .error:
            cell.connectStatusLB.text = "error"
        }

        return cell
    }
}

extension BluetoothDevicesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toDeviceDetail", sender: deviceNameID[indexPath.row])
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDeviceDetail"{
            if let controller = segue.destination as? BluetoothSesameControlViewController {
                controller.deviceID = sender as? String
            }
        }
    }
}
