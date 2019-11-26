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
    var tabVC:GeneralTabViewController?
    
    @IBAction func backClick(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion:nil)
        }
    }
    //    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var deviceTableView: UITableView!
    
    var sesameDevicesMap: [String: CHSesameBleInterface] = [:]
    var devices = [CHSesameBleInterface]()
    
    
    override func viewWillAppear(_ animated: Bool) {
        CHBleManager.shared.enableScan()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        CHBleManager.shared.disableScan()
    }
    
    @IBOutlet weak var backMenuBtn: UIButton!
    override func viewDidLoad() {
        CHBleManager.shared.delegate = self
        //        backMenuBtn.setImage( UIImage.SVGImage(named: "icons_filled_close"), for: .normal)
    }
}
extension RegisterDeviceListVC: CHBleManagerDelegate {
    func didDiscoverSesame(device: CHSesameBleInterface) {
        DispatchQueue.main.async {
            self.sesameDevicesMap.updateValue(device, forKey: device.bleIdStr)
            self.reloadTable()
        }
    }
    func reloadTable() {
        DispatchQueue.main.async {
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
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ssm = devices[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SSMCellR", for: indexPath) as! RegisterCell
        
        cell.ssm = ssm
        return cell
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        CHBleManager.shared.disableScan()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate {
        }else {
            CHBleManager.shared.enableScan()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        CHBleManager.shared.enableScan()
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
