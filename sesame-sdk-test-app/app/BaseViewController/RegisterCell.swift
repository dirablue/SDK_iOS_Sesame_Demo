//
//  RegisterCell.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/11/18.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import UIKit
import SesameSDK
import CoreBluetooth

class RegisterCell: UITableViewCell {


    @IBOutlet weak var ssi: UILabel!

     public var ssm:CHSesameBleInterface?{
            didSet{
    //            L.d(ssm?.customNickname, ssm?.identifier)


                ssi.text = "\(ssm!.rssi) -\(ssm!.model.rawValue.localStr)"//todo 多語言 devices
            }
        }
}
