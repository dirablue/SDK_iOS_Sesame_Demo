//
//  SSM2RoomBle.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/10/17.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import UIKit
import SesameSDK
import CoreBluetooth

extension SSM2RoomMainVC:CHSesameBleDeviceDelegate{
    func onBleConnectStatusChanged(device: CHSesameBleInterface, status: CBPeripheralState) {
        //        L.d("onBleConnectStatusChanged")
        //        updataSSMUI()
    }

    func onBleGattStatusChanged(device: CHSesameBleInterface, status: CHBleGattStatus, error: CHSesameGattError?) {
        //        L.d("onBleGattStatusChanged")
        updataSSMUI()

    }

    func onSesameLogin(device: CHSesameBleInterface, setting: CHSesameMechSettings, status: CHSesameMechStatus) {
        //        L.d("onSesameLogin")
    }

    func onBleCommandResult(device: CHSesameBleInterface, command: CHSesameCommand, returnCode: CHSesameCommandResult) {

//        L.d("onBleCommandResult",command.description(),returnCode.description())

        if(command == .history ){
//            L.d("請求history api onBleCommandResult",command.description(),returnCode.description())
           _ =  getHistory()
//          _ = sesame.getHistory(){res,historys,noChange in //SSMHistory
//                DispatchQueue.main.async {
//                    self.mHistoryList = historys
//                    self.HistoryTable.reloadData()
//                    self.scrollToBottom()
//                }
//            }
        }
    }



    func onMechStatusChanged(device: CHSesameBleInterface, status: CHSesameMechStatus, intention: CHSesameIntention) {
        updataSSMUI()
    }

    func onMechSettingChanged(device: CHSesameBleInterface, setting: CHSesameMechSettings) {
    }
}

extension SSM2RoomMainVC:CHBleManagerDelegate{
    func didDiscoverSesame(device: CHSesameBleInterface) {
        if device.bleIdStr ==  self.sesame?.bleIdStr {
            self.sesame = device
            self.sesame.delegate = self
            self.sesame.connect()
        }
    }

    func updataSSMUI()  {
        if(sesame.identifier ==  "fromserver" ){
            self.Locker.setBackgroundImage(UIImage(named: "l-no"), for: .normal)
            sesameCircle?.isHidden = true
        }else{
            if let setting = sesame.mechSetting{
                if(setting.isConfigured()){
                    if let islock = sesame.mechStatus?.isInLockRange(){
                        self.Locker.setBackgroundImage(UIImage(named: islock ? "img-lock":"img-unlock"), for: .normal)
                        sesameCircle?.isHidden = false
                    }
                }else{
                    self.Locker.setBackgroundImage(UIImage(named: "l-set"), for: .normal)
                }
            }else{
                self.Locker.setBackgroundImage(UIImage(named: "l-no"), for: .normal)
                sesameCircle?.isHidden = true
            }
            sesameCircle?.setLock(sesame)
        }
    }
}
extension SSM2RoomMainVC{
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let rightButtonItem = UIBarButtonItem(image: UIImage.SVGImage(named: isDarkMode() ? "icons_filled_more_b":"icons_filled_more"), style: .done, target: self, action: #selector(handleRightBarButtonTapped(_:)))
        navigationItem.rightBarButtonItem = rightButtonItem
    }
}

extension SSM2RoomMainVC {
    @objc private func handleRightBarButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier:  "setting", sender: sesame)
    }
    @objc private func handleLeftBarButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
