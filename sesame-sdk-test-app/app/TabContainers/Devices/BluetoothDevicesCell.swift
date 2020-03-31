//
//  BluetoothDevicesCell.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/8/30.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import UIKit
import SesameSDK
import CoreBluetooth

extension BluetoothDevicesCell:CHSesameBleDeviceDelegate{
    func onBleDeviceStatusChanged(device: CHSesameBleInterface, status: CHDeviceStatus) {
        updateUI()
    }
}
class BluetoothDevicesCell: UITableViewCell {

    func updateUI()  {
        ssmCircle?.setLock(ssm!)
        self.lockOp.setBackgroundImage(UIImage(named: namessmUIParcer(uiState: ssm!.deviceStatus)), for: .normal)
        let powPercent = batteryPrecentage(voltage: ssm!.mechStatus?.getBatteryVoltage() ?? 0)

//        L.d("powPercent",powPercent)
        powerLB.text = "\(powPercent)%"
        powerLB.isHidden  = (ssm!.deviceStatus.loginStatus() == .unlogin)
        batteryIMG.isHidden = (ssm!.deviceStatus.loginStatus() == .unlogin)
        ssmCircle.isHidden = (ssm!.deviceStatus.loginStatus() == .unlogin)

        batteryIMG.image = UIImage(named: powPercent < 20 ? "bt0":powPercent < 50 ? "bt50":"bt100")

}

    @IBAction func test(_ sender: UIButton) {
        vc?.performSegue(withIdentifier:  "toDeviceDetail", sender: ssm)
    }
    public var vc:UIViewController?


    @IBOutlet weak var batteryIMG: UIImageView!
    @IBOutlet weak var powerLB: UILabel!

    @IBOutlet weak var ssmCircle: SesameCircle!
    @IBOutlet weak var testBtn: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var ownerNAmeLB: UILabel!
    @IBOutlet weak var lockOp: UIButton!
    public var ssm:CHSesameBleInterface?{
        didSet{
//            L.d("列表綁定ＳＳＭ",ssm?.customNickname)
            ssm?.delegate = self
            updateUI()
            name.text = ssm!.customNickname
            ownerNAmeLB.text = ssm!.ownerName
            ownerNAmeLB.isHidden = (ssm!.customNickname == ssm!.ownerName)
        }
    }

    @IBAction func togleLock(_ sender: UIButton) {
         ssm!.toggle()
    }
}

func batteryPrecentage(voltage:Float) -> Int {
//    L.d("🔋voltage",voltage)
       let blocks:[Float] = [6.0,5.8,5.7,5.6,5.4,5.2,5.1,5.0,4.8,4.6]
       let mapping:[Float] = [100.0,50.0,40.0,32.0,21.0,13.0,10.0,7.0,3.0,0.0]
       if voltage >= blocks[0] {
           return Int((voltage-blocks[0])*200/blocks[0] + 100)
       }
       if voltage <= blocks[blocks.count-1] {
           return Int(mapping[mapping.count-1])
       }

       for i in 0..<blocks.count-1 {
           let upper: CFloat = blocks[i]
           let lower: CFloat = blocks[i+1]
           if voltage <= upper && voltage > lower {
               let value: CFloat = (voltage-lower)/(upper-lower)
               let max = mapping[i]
               let min = mapping[i+1]
               return Int((max-min)*value+min)
           }
       }
       return 0
   }


func namessmUIParcer(uiState:CHDeviceStatus) -> String {
    switch uiState {

    case .reset:
        return "l-no"
    case .noSignal:
        return "l-no"
    case .receiveBle:
        return "receiveBle"//!號圖
    case .connecting:
        return "receiveBle"

    case .waitgatt:
        return "waitgatt"

    case .logining:
        return "logining"

    case .readytoRegister:
        return "logining"
    case .locked:
        return "img-lock"

    case .unlocked:
        return "img-unlock"

    case .moved:
        return "img-unlock"

    case .nosetting:
        return "l-set"
    }
}
