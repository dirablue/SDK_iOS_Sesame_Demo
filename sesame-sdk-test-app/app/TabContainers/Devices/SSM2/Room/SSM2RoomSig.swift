//
//  SSM2RoomSig.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/10/17.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import SesameSDK

extension SSM2RoomMainVC{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setting"{
            if let controller = segue.destination as? SSM2SettingVC {
//                let sesameDevice = sender as? CHSesameBleInterface
                controller.sesame = sesame
            }
        }
    }
}

