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
//        L.d("viewWillDisappear")
        CHBleManager.shared.disConnectAll()
        CHBleManager.shared.disableScan()

    }

    override func viewDidAppear(_ animated: Bool) {
//        L.d("viewDidAppear",sesameDevicesMap.count)
        self.sesameDevicesMap.removeAll()
        self.devices.removeAll()
        self.tableView.reloadData()
        CHBleManager.shared.delegate = self
        CHBleManager.shared.enableScan()
    }
    override func viewWillAppear(_ animated: Bool) {
        CHSetting.shared.setAppGroup(appGrroup: CHAppGroupWidget)
        CHAccountManager.shared.setupLoginSession(identityProvider:FakeService())
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
}

extension TodayViewController:CHBleManagerDelegate{
    func didDiscoverSesame(device: CHSesameBleInterface) {
        if(!device.isRegistered){
            return
        }
        device.connect()
        DispatchQueue.main.async {
            self.sesameDevicesMap.updateValue(device, forKey: device.bleIdStr)
            self.devices.removeAll()
            self.sesameDevicesMap.forEach({
                self.devices.append($1)
            })
            self.devices.sort(by: {
                return  $0.customNickname > $1.customNickname
            })
            self.tableView.reloadData()
        }
    }
}

public class FakeService:CHLoginProvider{
    public func oauthToken() throws -> CHOauthToken {
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
