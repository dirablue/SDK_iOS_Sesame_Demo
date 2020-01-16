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


    @IBOutlet weak var modelLb: UILabel!
    @IBOutlet weak var ssi: UILabel!

    @IBOutlet weak var bluetoothImg: UIImageView!
    public var ssm:CHSesameBleInterface?{
            didSet{
                ssi.text = "\(ssm!.rssi.intValue + 100)%"
                bluetoothImg.image = UIImage.SVGImage(named: "bluetooth",fillColor: Colors.tintColor)
                modelLb.text = "\(ssm!.model.rawValue.localStr)"
            }
        }
}
