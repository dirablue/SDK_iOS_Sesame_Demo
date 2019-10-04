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

class BluetoothDevicesListViewController: BaseViewController {

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
    @IBAction func scan(_ sender: Any) {
        L.d("test scanV")
        let tabVC = self.tabBarController as! GeneralTabViewController
        tabVC.scanQR()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Device List"
        self.deviceTableView.delegate = self
        self.deviceTableView.dataSource = self
        self.deviceTableView.allowsSelection = true
        tabBarItem.selectedImage = tabBarItem.selectedImage?.withRenderingMode(.alwaysOriginal)

        let gesture = SingleTouchDownGestureRecognizer(target: self, action: nil)
        self.deviceTableView.addGestureRecognizer(gesture)

        let tabGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        self.deviceTableView.addGestureRecognizer(tabGesture)

        let  mydevices = CHAccountManager.shared.deviceManager.getDevices()
            for mydev in  mydevices
            {
                L.d("🔵🔴⚫️⚪️", mydev.bleIdentity?.toHexString(), mydev.customName, mydev.accessLevel.rawValue, mydev.deviceId)
                let sesame: mySesame  = mySesame(deviceProfile: mydev)
                if(mydev.bleIdentity == nil) {

                } else {
                    let  inde = self.sesameDevicesMap.index(forKey: mydev.bleIdentity!.toHexString())
                    if(inde == nil){
                        self.sesameDevicesMap.updateValue(sesame, forKey: mydev.bleIdentity!.toHexString())
                    }
                }
            }
            deviceTableView.reloadData()
    }

    @objc func tapGesture(_ sender: UITapGestureRecognizer) {
        let touch =   sender.location(in: self.deviceTableView)
        if let indexPath = self.deviceTableView.indexPathForRow(at: touch) {
            self.performSegue(withIdentifier: "toDeviceDetail", sender: devices[indexPath.row])
        }
    }

    @IBAction func freshDidPress(_ sender: Any) {
        devices.removeAll()
        sesameDevicesMap.removeAll()
        deviceTableView.reloadData()

        CHAccountManager.shared.deviceManager.flushDevices { (_, result, deviceDatas) in

            L.d("result.success",result.success,"deviceDatas",deviceDatas?.count)
            if let mydevices = deviceDatas, result.success == true {
                for mydev: CHDeviceProfile in mydevices {
                    L.d("🔵🔴⚫️⚪️", mydev.bleIdentity?.toHexString(), mydev.customName, mydev.accessLevel.rawValue, mydev.deviceId)
                    let sesame: mySesame  = mySesame(deviceProfile: mydev)
                    if(mydev.bleIdentity == nil) {

                    } else {
                        let  inde = self.sesameDevicesMap.index(forKey: mydev.bleIdentity!.toHexString())
                        if(inde == nil){
                            self.sesameDevicesMap.updateValue(sesame, forKey: mydev.bleIdentity!.toHexString())
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.reloadTable()
                }
            }
        }
    }
    func reloadTable() {
        devices.removeAll()
        for (_, value) in sesameDevicesMap {
            devices.append(value)
        }
        devices.sort { (a, b) -> Bool in
            return a.accessLevel.power()  < b.accessLevel.power()
        }
        deviceTableView.reloadData()
    }
}

extension BluetoothDevicesListViewController: CHBleManagerDelegate {
    func didDiscoverSesame(device: CHSesameBleInterface) {
        sesameDevicesMap.updateValue(device, forKey: device.bleIdStr)
        reloadTable()
    }
}

extension BluetoothDevicesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ssm = devices[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SSMCell", for: indexPath) as! BluetoothDevicesCell

        cell.title.text = "BleID: \(ssm.bleIdStr)"
        cell.registerStatus.text = "\(ssm.isRegistered ? "Registered" : "Unregistered")"
        cell.registerStatus.textColor = ssm.isRegistered ? UIColor.lightGray : UIColor.red
        cell.rssiValue.text = "rssi: \(ssm.rssi)"
        cell.nameLB.text = ssm.customNickname
        cell.ownerLB.text =  ssm.accessLevel.rawValue
        cell.connectStatusLB.text = ssm.gattStatus.description()

        if(ssm.accessLevel == .owner || ssm.accessLevel == .manager || ssm.accessLevel == .guest){
            cell.backgroundColor = UIColor(rgb: 0xEEEEEE)
        }else{
            cell.backgroundColor = UIColor.white
        }

        if(ssm.gattStatus == .established) {
            ssm.disconnect()
        }
        //        if(ssm.gattStatus == .idle) {
        //            if ssm.accessLevel == .owner || ssm.accessLevel ==  .manager || ssm.accessLevel ==  .guest {
        //                if(ssm.identifier != "fromserver"){
        //                    ssm.connect(),
        //                }
        //            }
        //        }
        return cell
    }

}

extension BluetoothDevicesListViewController: UITableViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDeviceDetail"{
            if let controller = segue.destination as? BluetoothSesameControlViewController {
                let sesameDevice = sender as? CHSesameBleInterface
                controller.sesame = sesameDevice
            }
        }
    }
}

class SingleTouchDownGestureRecognizer: UIGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
//        CHBleManager.shared.disableScan()
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
//        CHBleManager.shared.enableScan()
    }
}


