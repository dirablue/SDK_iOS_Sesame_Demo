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
import UserNotifications

class BluetoothDevicesListViewController: BaseViewController {

    @IBOutlet weak var testMode: UISwitch!
    @IBOutlet weak var deviceTableView: UITableView!

    @IBAction func testModeChange(_ sender: Any) {
        self.deviceTableView.reloadData()
    }
    var menuFloatView: SessionMoreFrameFloatView?
    var devices = [CHSesameBleInterface]()
    var sesameDevicesMap: [String: CHSesameBleInterface] = [:]
    var refreshControl:UIRefreshControl = UIRefreshControl()

    override func viewWillDisappear(_ animated: Bool) {
        CHBleManager.shared.disableScan()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        CHBleManager.shared.enableScan()
        CHBleManager.shared.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        (self.tabBarController as! GeneralTabViewController).scanQR(){ name in
//                       L.d("測試回傳")
//                   }
        testMode.isOn = false
        testMode.alpha = 0.1

        #if DEBUG
        testMode.isHidden = false
        #else
        testMode.isHidden = true
        #endif

        (self.tabBarController as! GeneralTabViewController).delegateHome = self

        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh".localStr)
        refreshControl.addTarget(self, action: #selector(pullTorefresh), for: .valueChanged)
        self.deviceTableView.addSubview(refreshControl)
        deviceTableView.tableFooterView = UIView(frame: .zero)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            if(self.devices.count == 0){
                self.refleshKeyChain()
            }
        }
    }
    
    @objc func pullTorefresh(sender:AnyObject) {
        refleshKeyChain()
    }
    
}

extension BluetoothDevicesListViewController: CHBleManagerDelegate {
    func didDiscoverSesame(device: CHSesameBleInterface) {
        if(device.isRegistered == false){return}
        device.connect()
        DispatchQueue.main.async {
            self.sesameDevicesMap.updateValue(device, forKey: device.bleIdStr)
            self.devices.removeAll()
            self.sesameDevicesMap.forEach({
                self.devices.append($1)}
            )
            self.devices.sort(by: {return  $0.customNickname > $1.customNickname})
            self.deviceTableView.reloadData()
            if(self.devices.count == 0) {                          self.deviceTableView.setEmptyMessage("No Devices".localStr)
            }else{
                self.deviceTableView.restore()
            }
        }
    }
}

extension BluetoothDevicesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ssm = devices[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SSMCell", for: indexPath) as! BluetoothDevicesCell
        cell.testBtn.isHidden = !testMode.isOn
        cell.ssm = ssm
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.vc = self
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let ssm = devices[indexPath.row]
        if(ssm.isRegistered){
            if let setting =  ssm.mechSetting{
                if setting.isConfigured(){
                    self.performSegue(withIdentifier:  "ssm2", sender: ssm)
                }else{
                    self.performSegue(withIdentifier:  "setting", sender: ssm)
                }
            }else{
                self.performSegue(withIdentifier: ssm.isRegistered ? "ssm2":"register", sender: ssm)
            }
        }else{
            self.performSegue(withIdentifier: ssm.isRegistered ? "ssm2":"register", sender: ssm)
        }
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
        if segue.identifier == "register"{
            if let controller = segue.destination as? RegisterVC {
                let sesameDevice = sender as? CHSesameBleInterface
                controller.sesame = sesameDevice
            }
        }
        if segue.identifier == "setting"{
            if let controller = segue.destination as? setLockVC {
                let sesameDevice = sender as? CHSesameBleInterface
                controller.sesame = sesameDevice
            }
        }
        if segue.identifier == "ssm2"{
            if let controller = segue.destination as? SSM2RoomMainVC {
                let sesameDevice = sender as? CHSesameBleInterface
                controller.sesame = sesameDevice
                let leftButtonItem =  UIBarButtonItem(title: sesameDevice?.customNickname, style: .done, target: self, action: nil)
                navigationItem.backBarButtonItem = leftButtonItem
                navigationItem.backBarButtonItem?.setBackgroundImage(
                    UIImage.SVGImage(named: isDarkMode() ? "icons_outlined_addoutline_black":"icons_outlined_addoutline")
                    , for: .normal, barMetrics: .default)
            }
        }
    }
}


extension BluetoothDevicesListViewController:homeDelegate{
    func refleshRoomBackTitle(name: String) {
        DispatchQueue.main.async {
            let leftButtonItem =  UIBarButtonItem(title: name, style: .done, target: self, action: nil)
            self.navigationItem.backBarButtonItem = leftButtonItem
        }
    }

    func goRegister(ssm : CHSesameBleInterface) {
        self.performSegue(withIdentifier:  "register", sender: ssm)
    }

    func refleshKeyChain() {
        DispatchQueue.main.async {
            self.refreshControl.beginRefreshing()
            self.devices.removeAll()
            self.sesameDevicesMap.removeAll()
            self.deviceTableView.reloadData()

            CHAccountManager.shared.flushDevices { ( result) in
                L.d("列表 刷新 ")
                CHBleManager.shared.discoverALLDevices()
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    if(self.devices.count == 0) {                          self.deviceTableView.setEmptyMessage("No Devices".localStr)
                    }else{
                        self.deviceTableView.restore()
                    }
                }
            }
        }
    }

}
extension BluetoothDevicesListViewController: SessionMoreMenuViewDelegate {
    @objc private func handleRightBarButtonTapped(_ sender: Any) {
        if self.menuFloatView?.superview != nil {
            hideMoreMenu()
        } else {
            showMoreMenu()
        }
    }
    func moreMenuView(_ menu: SessionMoreMenuView, didTap item: SessionMoreItem) {
        switch item.type {
        case .addFriends:
            (self.tabBarController as! GeneralTabViewController).scanQR(){ name in
                L.d("測試回傳")
            }
        case .addDevices:
            (self.tabBarController as! GeneralTabViewController).goRegisterList()
        }
        hideMoreMenu(animated: false)
    }
    private func hideMoreMenu(animated: Bool = true) {
        menuFloatView?.hide(animated: animated)
    }
    private func showMoreMenu() {
        refleshRoomBackTitle(name: "")
        if menuFloatView == nil {
            let y = Constants.statusBarHeight + 44
            let frame = CGRect(x: 0, y: y, width: view.bounds.width, height: view.bounds.height - y)
            menuFloatView = SessionMoreFrameFloatView(frame: frame)
            menuFloatView?.delegate = self
        }
        menuFloatView?.show(in: self.view)
    }
}
public protocol homeDelegate: class {
    func  refleshKeyChain()
    func  goRegister(ssm : CHSesameBleInterface)
    func  refleshRoomBackTitle(name:String)
}
extension BluetoothDevicesListViewController{
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let rightButtonItem = UIBarButtonItem(image: UIImage.SVGImage(named: isDarkMode() ? "icons_outlined_addoutline_black":"icons_outlined_addoutline"), style: .done, target: self, action: #selector(handleRightBarButtonTapped(_:)))
        navigationItem.rightBarButtonItem = rightButtonItem
    }
}
