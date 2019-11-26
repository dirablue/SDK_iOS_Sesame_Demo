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

class BluetoothDevicesCell: UITableViewCell {
    @IBAction func test(_ sender: UIButton) {
        vc?.performSegue(withIdentifier:  "toDeviceDetail", sender: ssm)
    }

    @IBOutlet weak var ssmCircle: SesameCircle!
    @IBOutlet weak var testBtn: UIButton!
    public var vc:UIViewController?
//    @IBOutlet weak var circle: SesameView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var lockOp: UIButton!
    public var ssm:CHSesameBleInterface?{
        didSet{
//            L.d(ssm?.customNickname, ssm?.identifier)

            if(ssm!.identifier ==  "fromserver" ){
                self.lockOp.setBackgroundImage(UIImage(named: "l-no"), for: .normal)
                ssmCircle? .isHidden = true
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
                }else{
                    self.lockOp.setBackgroundImage(UIImage(named: "l-no"), for: .normal)
                    ssmCircle? .isHidden = true
                }
                ssmCircle?.setLock(ssm!)

            }
            name.text = ssm!.customNickname
        }
    }

    @IBAction func togleLock(_ sender: UIButton) {
        _ = ssm!.toggle().description()
    }
}
