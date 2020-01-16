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
    var groupHistory = [[SSMHistory]]()

    var userList = [Client]()
    var sesame: CHSesameBleInterface!

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

    func scrollToBottom(){
        DispatchQueue.main.async {
            if(self.groupHistory.count > 0 ){
                let indexPath = IndexPath(row: self.groupHistory.last!.count - 1, section: self.groupHistory.count - 1)
                self.HistoryTable.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        CHBleManager.shared.enableScan()
        CHBleManager.shared.delegate = self
        self.sesame.delegate = self
        updataSSMUI()
        DispatchQueue(label: "sesameSDK.API", qos: .default, attributes: .concurrent).async {
            self.groupHistory = self.getHistory().group(by: {$0.timestamp?.toYMD()}).map { return $0.value }
            self.groupHistory = self.groupHistory.sorted { $0.first!.timestamp!.timeIntervalSince1970 < $1.first!.timestamp!.timeIntervalSince1970 }
            DispatchQueue.main.async {
                self.HistoryTable.reloadData()
                self.scrollToBottom()
//                ViewHelper.hideLoadingView(view: self.view)
            }
        }


    }
    func getHistory() ->[SSMHistory] {

        let historyList = sesame.getHistory(){res,historys,noChange in //SSMHistory
            if(res.success){
                DispatchQueue.main.async {
                    self.groupHistory = historys.group(by: {$0.timestamp?.toYMD()}).map { return $0.value }
                    self.groupHistory = self.groupHistory.sorted { $0.first!.timestamp!.timeIntervalSince1970 < $1.first!.timestamp!.timeIntervalSince1970 }
//                    self.mHistoryList = historys
                    self.HistoryTable.reloadData()
                    self.scrollToBottom()
//                    L.d("historys.count ",historys.count )
                    if(noChange){
                        L.d("數據沒改變  停止刷新歷史")
                    }else{
                        if( self.isViewLoaded && ((self.view?.window) != nil)){
                           _ = self.getHistory()
                        }
                    }
                }
            }

        }
        return historyList
    }
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
}

