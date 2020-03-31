//
//  TodayViewController.swift
//  locker
//
//  Created by tse on 2019/10/15.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import NotificationCenter
import SesameSDK
let CHAppGroupWidget = "group.candyhouse.widget"
//let CHAppGroupWidget = "group.apaman.widget" // the same as widget

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var tableView: UITableView!
    var sesameDevicesMap: [String: CHSesameBleInterface] = [:]
    var devices = [CHSesameBleInterface]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if case .compact = activeDisplayMode {
            preferredContentSize = maxSize
        } else {
            preferredContentSize.height = CGFloat((devices.count) * 110)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        L.d("離開widget")
        CHBleManager.shared.disableScan()
        CHBleManager.shared.disConnectAll()
    }
    override func viewWillAppear(_ animated: Bool) {
        L.d("viewWillAppear")

        CHSetting.shared.setAppGroup(appGrroup: CHAppGroupWidget)
        CHAccountManager.shared.setupLoginSession(identityProvider:FakeService())

        CHBleManager.shared.delegate = self
           CHBleManager.shared.enableScan()
           L.d("viewDidAppear")
           self.loadLocalDevices()
    }
    override func viewDidAppear(_ animated: Bool) {

    }


    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        L.d("widgetPerformUpdate")
        completionHandler(NCUpdateResult.newData)
    }
}

extension TodayViewController:CHBleManagerDelegate{
    func didDiscoverSesame(device: CHSesameBleInterface) {
        if(!device.isRegistered){
            return
        }
        device.connect()
        self.sesameDevicesMap.updateValue(device, forKey: device.bleIdStr)
        notifyTable()
        //        loadLocalDevices()
    }


    func loadLocalDevices()  {
        DispatchQueue.main.async {

            CHBleManager.shared.discoverALLDevices(){ result in
                if case .success(let devices) = result {
                    self.devices += devices
                    self.devices.forEach({
                        self.sesameDevicesMap.updateValue($0, forKey: $0.bleIdStr)
                    })
                    //                      L.d("列表本地刷新",self.devices.count)
                }
                self.notifyTable()
            }
        }
    }
    func notifyTable()  {
        DispatchQueue.main.async {
            self.devices.removeAll()
            self.sesameDevicesMap.forEach({
                self.devices.append($1)}
            )
            self.devices.sort(by: {return  $0.customNickname > $1.customNickname})
            self.tableView.reloadData()
        }
    }
}

public class FakeService:CHLoginProvider{
    public func oauthToken()  -> CHOauthToken {
        let userDefault =  UserDefaults.init(suiteName: CHAppGroupWidget)
        if let token = userDefault?.value(forKey: "towidget") {
            let ee = CHOauthToken(identityProviderCognito,token as! String)
            return ee
        }
        return CHOauthToken("faliDomain","failToken")
    }
}

extension TodayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SSMCell", for: indexPath) as! DeviceCell
        cell.ssm = devices[indexPath.row]
        return  cell
    }
}
