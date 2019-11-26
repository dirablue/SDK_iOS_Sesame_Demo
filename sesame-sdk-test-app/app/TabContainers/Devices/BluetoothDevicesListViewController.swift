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

public protocol homeDelegate: class {
    func  refleshKeyChain()
    func  goRegister(ssm : CHSesameBleInterface)

}
enum ManuItems : String {
    case register, scan
    static var allValues = [ManuItems.register, .scan]
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
            (self.tabBarController as! GeneralTabViewController).scanQR()

        case .addDevices:
            (self.tabBarController as! GeneralTabViewController).goRegisterList()
        }
        hideMoreMenu(animated: false)
    }
    private func hideMoreMenu(animated: Bool = true) {
        menuFloatView?.hide(animated: animated)
    }
    private func showMoreMenu() {
        if menuFloatView == nil {
            let y = Constants.statusBarHeight + 44
            let frame = CGRect(x: 0, y: y, width: view.bounds.width, height: view.bounds.height - y)
            menuFloatView = SessionMoreFrameFloatView(frame: frame)
            menuFloatView?.delegate = self
        }
        menuFloatView?.show(in: self.view)
    }
}

extension BluetoothDevicesListViewController{
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let rightButtonItem = UIBarButtonItem(image: UIImage.SVGImage(named: isDarkMode() ? "icons_outlined_addoutline_black":"icons_outlined_addoutline"), style: .done, target: self, action: #selector(handleRightBarButtonTapped(_:)))
        navigationItem.rightBarButtonItem = rightButtonItem





    }
}


class BluetoothDevicesListViewController: BaseViewController {

    private var menuFloatView: SessionMoreFrameFloatView?
    var devices = [CHSesameBleInterface]()
    var sesameDevicesMap: [String: CHSesameBleInterface] = [:]
    var refreshControl:UIRefreshControl = UIRefreshControl()

    @IBOutlet weak var deviceTableView: UITableView!

    override func viewWillDisappear(_ animated: Bool) {
        //        L.d("VC viewWillDisappear")
        CHBleManager.shared.disableScan()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        //        L.d("VC viewDidAppear")
        CHBleManager.shared.enableScan()
        CHBleManager.shared.delegate = self
    }
    

    @IBOutlet weak var testMode: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()

        testMode.isOn = false
        testMode.alpha = 0.1


        let  myTab  = self.tabBarController as! GeneralTabViewController
        myTab.delegateHome = self


        self.deviceTableView.delegate = self
        self.deviceTableView.dataSource = self
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.deviceTableView.addSubview(refreshControl)

        //        refleshKeyChain()

    }
    
    @objc func refresh(sender:AnyObject) {
        freshDidPress("")
    }
    
    @IBAction func freshDidPress(_ sender: Any) {
        devices.removeAll()
        sesameDevicesMap.removeAll()
        deviceTableView.reloadData()

        CHAccountManager.shared.deviceManager.flushDevices { ( result, deviceDatas) in


            //            L.d("result.success<------>",result.success)
            if let mydevices = deviceDatas, result.success == true {
                UserDefaults.init(suiteName: "group.candyhouse.widget")?.set(true, forKey: "isnNeedfreshK")

                for mydev: CHDeviceProfile in mydevices {
                    let sesame: Sesame2NOBleDevice  = Sesame2NOBleDevice(deviceProfile: mydev)
                    //                    L.d("(mydev.bleIdentity == nil)",(mydev.bleIdentity == nil))
                    self.sesameDevicesMap.updateValue(sesame, forKey: mydev.bleIdentity!.toHexString())
                }
                
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    self.reloadTable()
                }
            }else{
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                    ViewHelper.alert(result.errorCode!, result.errorDescription!, self)
                }
            }
        }
    }
    
}

extension BluetoothDevicesListViewController: CHBleManagerDelegate {
    func didDiscoverSesame(device: CHSesameBleInterface) {

        if(device.accessLevel.power() > CHDeviceAccessLevel.haveRightToAcceress){return}

        //        L.d(device.customNickname)
        DispatchQueue.main.async {
            self.sesameDevicesMap.updateValue(device, forKey: device.bleIdStr)
            self.reloadTable()
        }
    }
    func reloadTable() {
        DispatchQueue.main.async {
            self.devices.removeAll()
            self.sesameDevicesMap.forEach({
                self.devices.append($1)}
            )
            //            self.devices.sort {return $0.accessLevel.power()  < $1.accessLevel.power()}
            self.deviceTableView.reloadData()
        }
    }
}

extension BluetoothDevicesListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ssm = devices[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "SSMCell", for: indexPath) as! BluetoothDevicesCell
        cell.testBtn.isHidden = !testMode.isOn
        cell.ssm = ssm
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.vc = self
        //        L.d("AppDelegate.isFrount",AppDelegate.isFrount)

        if(ssm.gattStatus == .idle) {
            if(ssm.identifier != "fromserver"){

                //                L.d("AppDelegate.isFrount",AppDelegate.isFrount)
                if(AppDelegate.isFrount){
                    ssm.connect()
                }

//                if(ssm.customNickname == "kkk"){
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {//wait for popup
//                        self.performSegue(withIdentifier:  "setting", sender: ssm)
//                    }
//                }

            }
        }
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
                self.performSegue(withIdentifier:  "ssm2", sender: ssm)
            }
            
        }else{
            self.performSegue(withIdentifier: ssm.isRegistered ? "ssm2":"register", sender: ssm)
        }
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


                let innd =   UIImage.SVGImage(named: isDarkMode() ? "icons_outlined_addoutline_black":"icons_outlined_addoutline")
                navigationItem.backBarButtonItem?.setBackgroundImage(innd, for: .normal, barMetrics: .default)

            }
        }
    }
}


extension BluetoothDevicesListViewController:homeDelegate{
    func goRegister(ssm : CHSesameBleInterface) {
        L.d("ssm",ssm)
        self.performSegue(withIdentifier:  "register", sender: ssm)
    }

    func refleshKeyChain() {
        DispatchQueue.main.async {
            self.refreshControl.beginRefreshing()
            self.freshDidPress("")
        }
    }
}
