//
//  SSM2RoomMainVC.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/10/14.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import SesameSDK
import CoreBluetooth
class SSM2RoomMainVC:BaseViewController {

    @IBOutlet weak var sesameCircle: SesameCircle!

//    let Interval = 30
    var userList = [Client]()
    var sesame: CHSesameBleInterface?
    @IBOutlet weak var Locker: UIButton!
    @IBOutlet weak var nameLB: UILabel!
    @IBAction func settingClick(_ sender: Any) {
        self.performSegue(withIdentifier:  "setting", sender: sesame!)
    }
    @IBAction func lockBtn(_ sender: UIButton) {
        _ = sesame!.toggle().description()
    }
    @IBOutlet weak var HistoryTable: UITableView!

    var mHistoryList = [DeviceHistoryEntity]()
//    var cycleTimer: Timer?
    @objc func timerUpdate() {
//        sesame?.deviceProfile?.updateHistory{(isChange)->Bool in
//            if(self.mHistoryList.count > 0   &&  !isChange){
//                return false
//            }
//            let  historyList  = self.sesame!.deviceProfile!.getAllHistory()
//
//            DispatchQueue.main.async {
//                self.mHistoryList = historyList
//                self.HistoryTable.reloadData()
//                self.scrollToBottom()
//            }
//            return false
//        }
    }
    func scrollToBottom(){
        DispatchQueue.main.async {
            if(self.mHistoryList.count > 0 ){
                let indexPath = IndexPath(row: self.mHistoryList.count-1, section: 0)
                self.HistoryTable.scrollToRow(at: indexPath, at: .bottom, animated: true)//crash
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
//        cycleTimer?.invalidate()
    }

    override func viewDidAppear(_ animated: Bool) {
        CHBleManager.shared.enableScan()
        CHBleManager.shared.delegate = self
        self.sesame!.delegate = self

//        cycleTimer =  Timer.scheduledTimer(timeInterval: TimeInterval(Int(Interval)), target: self, selector: #selector(timerUpdate), userInfo: nil, repeats: true)
//        cycleTimer?.fire()
        updataSSMUI()

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let  historyList  = self.sesame!.deviceProfile!.getAllHistory()
        self.mHistoryList = historyList
        self.HistoryTable.reloadData()
        self.scrollToBottom()


//        let leftButtonItem = UIBarButtonItem(title: "＜ \(self.sesame!.customNickname)", style: .done, target: self
//            , action: #selector(handleLeftBarButtonTapped(_:)))
//        navigationItem.leftBarButtonItem = leftButtonItem


        sesameCircle.setLock(sesame!)
    }
}
extension SSM2RoomMainVC{
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let rightButtonItem = UIBarButtonItem(image: UIImage.SVGImage(named: isDarkMode() ? "icons_filled_more_b":"icons_filled_more"), style: .done, target: self, action: #selector(handleRightBarButtonTapped(_:)))
            navigationItem.rightBarButtonItem = rightButtonItem

//        navigationItem.backBarButtonItem = rightButtonItem
    }
}

extension SSM2RoomMainVC {
    @objc private func handleRightBarButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier:  "setting", sender: sesame!)
    }
    @objc private func handleLeftBarButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
extension SSM2RoomMainVC:CHBleManagerDelegate{
    func didDiscoverSesame(device: CHSesameBleInterface) {
        if device.bleIdStr ==  self.sesame?.bleIdStr {
            self.sesame = device
            self.sesame?.delegate = self
            self.sesame!.connect()
        }
    }

    func updataSSMUI()  {
        if(sesame?.identifier ==  "fromserver" ){
                   self.Locker.setBackgroundImage(UIImage(named: "l-no"), for: .normal)
                   sesameCircle? .isHidden = true
               }else{
                   if let setting = sesame?.mechSetting{
                       if(setting.isConfigured()){
                           if let islock = sesame?.mechStatus?.isInLockRange(){
                               self.Locker.setBackgroundImage(UIImage(named: islock ? "img-lock":"img-unlock"), for: .normal)
                               sesameCircle? .isHidden = false
                           }
                       }else{
                           self.Locker.setBackgroundImage(UIImage(named: "l-set"), for: .normal)
                       }
                   }else{
                       self.Locker.setBackgroundImage(UIImage(named: "l-no"), for: .normal)
                       sesameCircle? .isHidden = true
                   }
                   sesameCircle?.setLock(sesame!)
               }
    }
}
