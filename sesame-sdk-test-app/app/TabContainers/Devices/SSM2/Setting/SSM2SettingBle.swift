//
//  SSM2SettingBle.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/11/12.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import CoreBluetooth
import SesameSDK


extension SSM2SettingVC:CHSesameBleDeviceDelegate{
    func onBleConnectStatusChanged(device: CHSesameBleInterface, status: CBPeripheralState) {
        L.d("設定頁面連線變化",status == CBPeripheralState.connected)
        refleshUI()


        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired
            _ = device.getVersionTag { (version, _) -> Void in
                                 self.version.text = version
                                 self.view.makeToast(version)
                                 L.d("設定頁面連線變化",version)
                             }
        }
        
    }

    func onBleGattStatusChanged(device: CHSesameBleInterface, status: CHBleGattStatus, error: CHSesameGattError?) {
//        refleshUI()
    }

    func onSesameLogin(device: CHSesameBleInterface, setting: CHSesameMechSettings, status: CHSesameMechStatus) {
    }

    func onBleCommandResult(device: CHSesameBleInterface, command: CHSesameCommand, returnCode: CHSesameCommandResult) {

    }

    func onMechStatusChanged(device: CHSesameBleInterface, status: CHSesameMechStatus, intention: CHSesameIntention) {
    }

    func onMechSettingChanged(device: CHSesameBleInterface, setting: CHSesameMechSettings) {
    }
}
