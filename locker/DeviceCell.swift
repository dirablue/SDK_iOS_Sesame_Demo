//
//  DeviceCell.swift
//  locker
//
//  Created by tse on 2019/10/15.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import UIKit
import SesameSDK
import CoreBluetooth


class DeviceCell: UITableViewCell {

    @IBOutlet weak var BettaryIMg: UIImageView!
    @IBOutlet weak var powerLB: UILabel!
    @IBOutlet weak var ownerNAme: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var lock: UIButton!
    @IBAction func togle(_ sender: Any) {
        _ = ssm?.toggle()
    }
    @IBOutlet weak var circle: SSMCircle!
    public var ssm:CHSesameBleInterface?{
        didSet{
            ssm?.delegate = self
            updateUI()
        }
    }

    func updateUI()  {
        if(ssm!.identifier ==  "fromserver" ){
            self.lock.setBackgroundImage(UIImage(named: "l-no"), for: .normal)
            circle? .isHidden = true
            powerLB.isHidden  = true
            BettaryIMg.isHidden = true

        }else{
            if let setting = ssm!.mechSetting{
                if(setting.isConfigured()){
                    if let islock = ssm?.mechStatus?.isInLockRange(){
                        self.lock.setBackgroundImage(UIImage(named: islock ? "img-lock":"img-unlock"), for: .normal)
                        circle? .isHidden = false
                        BettaryIMg.isHidden = false
                        powerLB.isHidden = false

                        let powPercent = batteryPrecentage(voltage: ssm!.mechStatus!.getBatteryVoltage())

                                          powerLB.text = "\(powPercent)%"
                         BettaryIMg.image = UIImage(named: powPercent < 20 ? "bt0":powPercent < 50 ? "bt50":"bt100")
                        powerLB.text = "\(powPercent)%"

                    }
                }else{
                    self.lock.setBackgroundImage(UIImage(named: "l-set"), for: .normal)
                    powerLB.isHidden  = false
                    BettaryIMg.isHidden = false
                }
            }else{
                self.lock.setBackgroundImage(UIImage(named: "l-no"), for: .normal)
                circle?.isHidden = true
                powerLB.isHidden  = true
                BettaryIMg.isHidden = true
            }
        }
        circle.setLock(ssm!)
        name.text = ssm!.customNickname
        ownerNAme.text = ssm!.ownerName
        ownerNAme.isHidden = (ssm!.customNickname == ssm!.ownerName)
        if #available(iOSApplicationExtension 13.0, *) {
            ownerNAme.textColor = UIColor.placeholderText
            powerLB.textColor = UIColor.placeholderText
        }
    }

}

extension DeviceCell:CHSesameBleDeviceDelegate{
    func onBleConnectStatusChanged(device: CHSesameBleInterface, status: CBPeripheralState) {

    }

    func onBleGattStatusChanged(device: CHSesameBleInterface, status: CHBleGattStatus, error: CHSesameGattError?) {

    }

    func onSesameLogin(device: CHSesameBleInterface, setting: CHSesameMechSettings, status: CHSesameMechStatus) {

    }

    func onBleCommandResult(device: CHSesameBleInterface, command: CHSesameCommand, returnCode: CHSesameCommandResult) {

    }

    func onMechStatusChanged(device: CHSesameBleInterface, status: CHSesameMechStatus, intention: CHSesameIntention) {
        updateUI()

    }

    func onMechSettingChanged(device: CHSesameBleInterface, setting: CHSesameMechSettings) {
        updateUI()
    }

}
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
