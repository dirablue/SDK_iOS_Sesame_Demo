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
        //        updataSSMUI()
    }

    func onBleCommandResult(device: CHSesameBleInterface, command: CHSesameCommand, returnCode: CHSesameCommandResult) {

        L.d("onBleCommandResult",command.description(),returnCode.description())

        if(command == .history ){
            L.d("請求history api onBleCommandResult",command.description(),returnCode.description())

            sesame!.deviceProfile!.updateHistory{(isChange) in
//                L.d("isChange",isChange)
                self.mHistoryList = self.sesame!.deviceProfile!.getAllHistory()

                DispatchQueue.main.async {
                    self.HistoryTable.reloadData()
                    self.scrollToBottom()
                }
            }
        }
    }

    func onMechStatusChanged(device: CHSesameBleInterface, status: CHSesameMechStatus, intention: CHSesameIntention) {
        //        L.d("onMechStatusChanged")
        updataSSMUI()
    }

    func onMechSettingChanged(device: CHSesameBleInterface, setting: CHSesameMechSettings) {
        //        L.d("onMechSettingChanged")
    }
}

