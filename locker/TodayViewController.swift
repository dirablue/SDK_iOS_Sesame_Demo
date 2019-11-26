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

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet weak var tableView: UITableView!
    var sesameDevicesMap: [String: CHSesameBleInterface] = [:]
    var devices = [CHSesameBleInterface]()
    var isFrount = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    }

    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if case .compact = activeDisplayMode {
            preferredContentSize = maxSize
        } else {
            preferredContentSize.height = CGFloat(devices.count == 0 ?440 :(devices.count+1) * 110)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        L.d("viewWillDisappear")
        isFrount = false
        CHBleManager.shared.disConnectAll()
        CHBleManager.shared.disableScan()
    }


    override func viewDidAppear(_ animated: Bool) {
        L.d("viewDidAppear",sesameDevicesMap.count)
        isFrount = true
        CHBleManager.shared.delegate = self
        //        CHBleManager.shared.enableScan()
    }
    override func viewWillAppear(_ animated: Bool) {
        L.d("viewWillAppear")

        let userDefault =  UserDefaults.init(suiteName: "group.candyhouse.widget")

        let isGoFreshK  = userDefault?.value(forKey: "isnNeedfreshK") as! Bool





        L.d("isGoFreshK",isGoFreshK)
        if(isGoFreshK){
            self.isFrount = false

            CHBleManager.shared.disableScan()
            CHAccountManager.shared.logout()
            CHAccountManager.shared.setupLoginSession(identityProvider:FakeService())
            CHAccountManager.shared.login({ (_, apiResult) in
                if apiResult.success {
                    L.d("apiResult.success",apiResult.success)
                        CHAccountManager.shared.deviceManager.flushDevices({( result, deviceDatas) in

                            if let mydevices = deviceDatas, result.success == true {
                                UserDefaults.init(suiteName: "group.candyhouse.widget")?.set(true, forKey: "isnNeedfreshK")
                                self.sesameDevicesMap.removeAll()

                                for mydev: CHDeviceProfile in mydevices {
                                    let sesame: Sesame2NOBleDevice  = Sesame2NOBleDevice(deviceProfile: mydev)
                                    self.sesameDevicesMap.updateValue(sesame, forKey: mydev.bleIdentity!.toHexString())

                                }

                                userDefault?.set(false, forKey: "isnNeedfreshK")
                                DispatchQueue.main.async {
                                    self.reloadTable()
                                }
                                CHBleManager.shared.enableScan()
                            }

                        })
                }
                self.isFrount = true

            })
        }else{
            CHBleManager.shared.enableScan()
        }

    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        L.d("widgetPerformUpdate")
        completionHandler(NCUpdateResult.newData)
    }
}

extension TodayViewController:CHBleManagerDelegate{

    func didDiscoverSesame(device: CHSesameBleInterface) {

        //        L.d("device",device.customNickname,device.gattStatus.description())

        if(!device.isRegistered){
            return
        }
        if(device.accessLevel.power() >= CHDeviceAccessLevel.haveRightToAcceress){
            return
        }
        sesameDevicesMap.updateValue(device, forKey: device.bleIdStr)
        reloadTable()
    }

    func reloadTable() {
        devices.removeAll()
        sesameDevicesMap.forEach({
            devices.append($1)
        })
        devices = devices.filter {return $0.accessLevel.power() < CHDeviceAccessLevel.haveRightToAcceress }
        devices.sort(by: {
            return  $0.customNickname > $1.customNickname
        })
        tableView.reloadData()
    }
}

public class FakeService:CHLoginProvider{
    //    public static let shared = FakeService()
    public func oauthToken() throws -> CHOauthToken {
        let userDefault =  UserDefaults.init(suiteName: "group.candyhouse.widget")
        if let token = userDefault?.value(forKey: "towidget") {
            //            L.d("我設定!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!token ",token)
            let ee = CHOauthToken("cognito-idp.us-east-1.amazonaws.com/us-east-1_K7R63YLyO",token as! String)
            return ee
        }
        return CHOauthToken("faliDomain","failToken")
    }
}
extension TodayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count + 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SSMCell", for: indexPath) as! DeviceCell
        if(indexPath.row == devices.count){
            cell.name.text = "gotoapp"
        }else{
            cell.ssm = devices[indexPath.row]
            if(isFrount){
                cell.ssm?.connect()
            }
        }
        return  cell
    }
}
extension TodayViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.row == devices.count){

            L.d(indexPath)
            let myAppUrl = URL(string: "main://recent")!
            extensionContext?.open(myAppUrl , completionHandler: { (success) in
                if (!success) {
                    // let the user know it failed
                }
            })
        }

    }
}

