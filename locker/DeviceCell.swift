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


class DeviceCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var lock: UIButton!
    @IBAction func togle(_ sender: Any) {
        ssm?.toggle()
    }
    @IBOutlet weak var circle: SSMCircle!
    public var ssm:CHSesameBleInterface?{
        didSet{
            if(ssm!.identifier ==  "fromserver" ){
                self.lock.setBackgroundImage(UIImage(named: "l-no"), for: .normal)
                circle? .isHidden = true

            }else{
                if let setting = ssm!.mechSetting{
                    if(setting.isConfigured()){
                        if let islock = ssm?.mechStatus?.isInLockRange(){
                            self.lock.setBackgroundImage(UIImage(named: islock ? "img-lock":"img-unlock"), for: .normal)
                            circle? .isHidden = false
                        }
                    }else{
                        self.lock.setBackgroundImage(UIImage(named: "l-set"), for: .normal)
                    }
                }else{
                    self.lock.setBackgroundImage(UIImage(named: "l-no"), for: .normal)
                    circle?.isHidden = true
                }
            }

            name.text = ssm!.customNickname
            circle.setLock(ssm!)
        }
    }

}
/*

 if(ssm!.connectStatus != .connected ){
 self.lockOp.setBackgroundImage(UIImage(named: "l-no"), for: .normal)
 }else{
 if let setting = ssm!.mechSetting{
 if(setting.isConfigured()){
 if let islock = ssm?.mechStatus?.isInLockRange(){
 self.lockOp.setBackgroundImage(UIImage(named: islock ? "img-lock":"img-unlock"), for: .normal)
 }
 }else{
 self.lockOp.setBackgroundImage(UIImage(named: "l-set"), for: .normal)
 }
 }else{
 self.lockOp.setBackgroundImage(UIImage(named: "l-no"), for: .normal)
 }
 }
 ssmCircle?.setLock(ssm!)
 name.text = ssm!.customNickname != "-" ? ssm!.customNickname : "\(ssm!.rssi)"
 **/
