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
    func onBleConnectStatusChanged(device: CHSesameBleInterface, status: CBPeripheralState) {

    }

    func onBleGattStatusChanged(device: CHSesameBleInterface, status: CHBleGattStatus, error: CHSesameGattError?) {
        updateUI()

    }

    func onSesameLogin(device: CHSesameBleInterface, setting: CHSesameMechSettings, status: CHSesameMechStatus) {

    }

    func onBleCommandResult(device: CHSesameBleInterface, command: CHSesameCommand, returnCode: CHSesameCommandResult) {

    }

    func onMechStatusChanged(device: CHSesameBleInterface, status: CHSesameMechStatus, intention: CHSesameIntention) {
        
        updateUI()
    }

    func onMechSettingChanged(device: CHSesameBleInterface, setting: CHSesameMechSettings) {
        
    }


}
class BluetoothDevicesCell: UITableViewCell {



    func batteryPrecentage(voltage:Float) -> Int {
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

    func updateUI()  {
        if(ssm!.identifier ==  "fromserver" ){
            self.lockOp.setBackgroundImage(UIImage(named: "l-no"), for: .normal)
            ssmCircle? .isHidden = true
            powerLB.isHidden  = true
            batteryIMG.isHidden = true
        }else{
            if let setting = ssm!.mechSetting{
                if(setting.isConfigured()){
                    if let islock = ssm?.mechStatus?.isInLockRange(){
                        self.lockOp.setBackgroundImage(UIImage(named: islock ? "img-lock":"img-unlock"), for: .normal)
                        ssmCircle? .isHidden = false
                    }
                }else{
                    self.lockOp.setBackgroundImage(UIImage(named: "l-set"), for: .normal)
                }
                let powPercent = batteryPrecentage(voltage: ssm!.mechStatus!.getBatteryVoltage())
                powerLB.text = "\(powPercent)%"
                powerLB.isHidden  = false
                batteryIMG.isHidden = false
                batteryIMG.image = UIImage(named: powPercent < 20 ? "bt0":powPercent < 50 ? "bt50":"bt100")

            }else{
                self.lockOp.setBackgroundImage(UIImage(named: "l-no"), for: .normal)
                ssmCircle? .isHidden = true
                powerLB.isHidden  = true
                batteryIMG.isHidden = true

            }
            ssmCircle?.setLock(ssm!)

        }
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
            ssm?.delegate = self
            updateUI()
            name.text = ssm!.customNickname
            ownerNAmeLB.text = ssm!.ownerName
            ownerNAmeLB.isHidden = (ssm!.customNickname == ssm!.ownerName)

        }
    }

    @IBAction func togleLock(_ sender: UIButton) {
        _ = ssm!.toggle().description()
    }
}
