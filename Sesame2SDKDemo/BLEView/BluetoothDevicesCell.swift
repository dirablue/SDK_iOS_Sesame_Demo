//
//  BluetoothDevicesCell.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/8/30.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import UIKit

class BluetoothDevicesCell: UITableViewCell {
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var connectStatusLB: UILabel!
    @IBOutlet weak var ownerLB: UILabel!
    @IBOutlet weak var registerStatus: UILabel!
    @IBOutlet weak var rssiValue: UILabel!
}
