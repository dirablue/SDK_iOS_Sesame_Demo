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
extension RegisterDeviceListVC:CHBleManagerDelegate{
    func didDiscoverSesame(device: CHSesameBleInterface) {
        if(device.isRegistered){
            return
        }
        
        
        //        L.d("UI device",device)
        
        DispatchQueue.main.async {
            self.sesameDevicesMap.updateValue(device, forKey: device.identifier)
            self.devices.removeAll()
            self.sesameDevicesMap.forEach({
                if(($1.rssi.intValue + 130) > 70){
                    self.devices.append($1)}
                }
            )
            self.devices = self.devices.sorted(by: {$0.rssi.intValue > $1.rssi.intValue})
            self.deviceTableView.reloadData()
        }
    }
}
class RegisterDeviceListVC: CHBaseVC  {
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
    override func viewDidDisappear(_ animated: Bool) {
//        L.d("註冊列表","viewDidDisappear <===")
    }
    override func viewWillDisappear(_ animated: Bool) {
        L.d("註冊列表","viewWillDisappear <=== 綁定主頁面")
        tabVC?.delegateHome?.bindManager()
    }
    override func viewWillAppear(_ animated: Bool) {
//        L.d("註冊列表","viewWillAppear ===>")
    }
    
    override func viewDidLoad() {
        L.d("註冊列表","viewDidLoad ===>")
        CHBleManager.shared.delegate = self
        deviceTableView.tableFooterView = UIView(frame: .zero)
    }
    
    
    
}

extension RegisterDeviceListVC{
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        backMenuBtn.setImage( UIImage.SVGImage(named:isDarkMode() ?"icons_filled_close_b" : "icons_filled_close"), for: .normal)
        
    }
}
extension RegisterCell:CHSesameBleDeviceDelegate{
    func onBleDeviceStatusChanged(device: CHSesameBleInterface, status: CHDeviceStatus) {
        //        L.d("UI註冊狀態",device.deviceStatus.description())
        if(status == .readytoRegister){
            DispatchQueue.main.async {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HHmm"
                let timetag  = dateFormatter.string(from: Date()) // 2017年8月12日
                let nameTag = "Sesame".localStr
                //                if(device.model == .sesame2){todo gateway nameTag
                //                    nameTag = "Sesame".localStr
                //                }
                L.d("調用點位Ａ")
                device.register(nickname:"\(nameTag)\(timetag)", {(result) in
                    if result.success {
                        L.d("ＵＩ收到註冊成功")
                        var config = CHSesameLockPositionConfiguration(lockTarget: 1024/4, unlockTarget: 0)
                        device.configureLockPosition(configure: &config)
                        DispatchQueue.main.async {

                            self.registerVC?.dismiss(animated: false, completion: nil)
                            self.registerVC?.tabVC?.delegateHome?.refleshKeyChain()
                            self.registerVC?.navigationController?.popViewController(animated: true)
                        }
                    }
                    DispatchQueue.main.async {
                        ViewHelper.hideLoadingView(view: self.registerVC?.view)
                    }
                })
                
            }
        }
    }
    func onBleConnectStatusChanged(device: CHSesameBleInterface, status: CBPeripheralState) {
        L.d("UI藍芽狀態",status,status.rawValue)
        if(status == CBPeripheralState.disconnected){
            ViewHelper.hideLoadingView(view: self.registerVC?.view)
            
            self.modelLb.superview?.makeToast("\("New Sesame".localStr) \("Error".localStr)")
        }
    }
}
extension RegisterDeviceListVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(devices.count == 0){
            tableView.setEmptyMessage("No New Devices".localStr)
        }else{
            tableView.restore()
        }
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ssm = devices[indexPath.row]
        ssm.connect()
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SSMCellR", for: indexPath) as! RegisterCell
        
        cell.ssm = ssm
        cell.registerVC = self
        cell.ssi.textColor =  (indexPath.row == 0) ?  Colors.tintColor: UIColor.gray
        //        ssm.delegate = cell
        
        return cell
    }
    
}

extension RegisterDeviceListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ssm = devices[indexPath.row]
        self.tabVC?.selectedIndex = 0
        
        if(ssm.deviceStatus == .readytoRegister){
            foregister(ssm)
            L.d("BBBBBB")
        }else{
            L.d("🐯💊",ssm.deviceStatus.description())
            ssm.delegate = tableView.cellForRow(at: indexPath) as! CHSesameBleDeviceDelegate
        }
        
        
        ViewHelper.showLoadingInView(view: self.view)
    }
    func foregister(_ ssm:CHSesameBleInterface){
        DispatchQueue.main.async {
            L.d("調用點位Ｂ")
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HHmm"
            let timetag  = dateFormatter.string(from: Date()) // 2017年8月12日
            let nameTag = "Sesame".localStr
            
            ssm.register(nickname:"\(nameTag)\(timetag)", {(result) in
                if result.success {
                    L.d("ＵＩ收到註冊成功")
                    var config = CHSesameLockPositionConfiguration(lockTarget: 1024/4, unlockTarget: 0)
                    ssm.configureLockPosition(configure: &config)
                    DispatchQueue.main.async {
                        
                        self.dismiss(animated: false, completion: nil)
                        self.tabVC?.delegateHome?.refleshKeyChain()
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                DispatchQueue.main.async {
                    ViewHelper.hideLoadingView(view: self.view)
                }
            })
            
        }
        
    }
}
