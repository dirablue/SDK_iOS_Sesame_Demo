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
extension SSM2RoomMainVC{
    func updataSSMUI()  {
        L.d("歷史ＳＳＭ狀態", sesame.deviceStatus.description())
        sesameCircle?.setLock(sesame)

        self.Locker.setBackgroundImage(UIImage(named: namessmUIParcer(uiState: sesame!.deviceStatus)), for: .normal)
    }
}

class SSM2RoomMainVC:BaseViewController {
    var groupHistory = [[SSMHistory]]()
    var mHistory = [SSMHistory]()
    var userList = [Client]()

    @IBOutlet weak var HistoryTable: UITableView!
    @IBOutlet weak var sesameCircle: SesameCircle!
    @IBOutlet weak var Locker: UIButton!
    @IBOutlet weak var nameLB: UILabel!
    @IBAction func settingClick(_ sender: Any) {
        self.performSegue(withIdentifier:  "setting", sender: sesame!)
    }
    @IBAction func lockBtn(_ sender: UIButton) {
        _ = sesame.toggle()
    }

    func moveToBottom(_ scroll:Bool = false){
        DispatchQueue.main.async {
            self.HistoryTable.reloadData()
            if(self.groupHistory.count > 0 ){
                let indexPath = IndexPath(row: self.groupHistory.last!.count - 1, section: self.groupHistory.count - 1)
                self.HistoryTable.scrollToRow(at: indexPath, at: .bottom, animated: scroll)
            }
        }
    }
    override func onBleDeviceStatusChanged(device: CHSesameBleInterface, status: CHDeviceStatus) {
        sesame = device
        updataSSMUI()
    }


    override func onBleCommandResult(device: CHSesameBleInterface, command: SSM2ItemCode, returnCode: SSM2CmdResultCode){
        if(command == .history ){
            _ =  getHistory()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        CHBleManager.shared.delegate = self
        updataSSMUI()
        self.hisGroupAndSort(self.getHistory())
        DispatchQueue(label: "sesameSDK.API", qos: .default, attributes: .concurrent).async {
            self.moveToBottom()
        }

    }
    func  hisGroupAndSort(_ historys:[SSMHistory])  {
        self.groupHistory = historys.group(by: {$0.timestamp?.toYMD()}).map { return $0.value }
        self.groupHistory = self.groupHistory.sorted { $0.first!.timestamp!.timeIntervalSince1970 < $1.first!.timestamp!.timeIntervalSince1970 }
    }
    func getHistory() ->[SSMHistory] {

        let historyList = sesame.getHistory(){res,historys,noChange in //SSMHistory
            if(res.success){
                DispatchQueue.main.async {
//                    L.d("網路historyList",self.groupHistory.count,historys.count)

                    self.hisGroupAndSort(historys)
                    self.moveToBottom(true)

                    if(noChange){
                        //                        L.d("數據沒改變  停止刷新歷史")
                    }else{
                        if( self.isViewLoaded && ((self.view?.window) != nil)){
                            _ = self.getHistory()
                        }
                    }
                }
            }

        }
        self.mHistory = historyList
        return historyList
    }
}

