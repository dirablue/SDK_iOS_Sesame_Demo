//
//  SSM2AutoLock.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/11/12.
//  Copyright © 2019 Cerberus. All rights reserved.
//


import UIKit
import CoreBluetooth
import SesameSDK
let second = [1,2,3,4,5,6,7,8,9,10,11,12,13]

extension SSM2SettingVC:UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return second.count
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel = view as? UILabel
        if pickerLabel == nil{
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont.systemFont(ofSize: 16)
            pickerLabel?.textAlignment = .center
            pickerLabel?.text = "\(second[row])"
        }
        return pickerLabel!
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(String(row)+"-"+String(component))
        self.sesame!.enableAutolock(delay: Int(second[row])){ (delay) -> Void in
            DispatchQueue.main.async {
                self.autolockScend.text = String(delay)
            }
        }
        secondPicker.isHidden = true
    }
}
