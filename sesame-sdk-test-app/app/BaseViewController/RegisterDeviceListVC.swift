//
//  RegisterDeviceList.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/11/9.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import SesameSDK

class RegisterDeviceListVC: BaseViewController  {
    var sesameDevicesMap: [String: CHSesameBleInterface] = [:]

    var tabVC:GeneralTabViewController?
    @IBOutlet weak var backMenuBtn: UIButton!

    @IBOutlet weak var deviceTableView: UITableView!

    @IBAction func backClick(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion:nil)
        }
    }

    var devices = [CHSesameBleInterface]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        CHBleManager.shared.enableScan(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        CHBleManager.shared.disableScan()
    }
    
    override func viewDidLoad() {
        CHBleManager.shared.delegate = self
        deviceTableView.tableFooterView = UIView(frame: .zero)
    }
}
extension RegisterDeviceListVC: CHBleManagerDelegate {
    func didDiscoverSesame(device: CHSesameBleInterface) {
        DispatchQueue.main.async {
            self.sesameDevicesMap.updateValue(device, forKey: device.bleIdStr)
            self.devices.removeAll()
                     self.sesameDevicesMap.forEach({//todo crash
                         self.devices.append($1)}
                     )
                     self.devices = self.devices.filter {return !$0.isRegistered  }
                     self.deviceTableView.reloadData()
        }
    }

}
extension RegisterDeviceListVC{
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        backMenuBtn.setImage( UIImage.SVGImage(named:isDarkMode() ?"icons_filled_close_b" : "icons_filled_close"), for: .normal)
        
    }
}
extension RegisterDeviceListVC: UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(devices.count == 0){
            tableView.setEmptyMessage("No Scanable Devices".localStr)
        }else{
            tableView.restore()
        }
        return devices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ssm = devices[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SSMCellR", for: indexPath) as! RegisterCell
        
        cell.ssm = ssm
        return cell
    }
    

}

extension RegisterDeviceListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ssm = devices[indexPath.row]
        DispatchQueue.main.async {
            self.tabVC?.selectedIndex = 0
            self.tabVC?.goRegisterPage(ssm: ssm)
            self.dismiss(animated: true, completion:nil)
        }
    }
}
