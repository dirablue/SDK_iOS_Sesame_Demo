//
//  CHTFDialogVC.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2020/1/9.
//  Copyright © 2020 Cerberus. All rights reserved.
//

import Foundation
import UIKit
class CHTFDialogVC: UIViewController {
    var callBack:(_ first:String,_ second:String)->Void = {f,s in
              L.d("test 閉包")
          }

    var sss = ""
    @IBOutlet weak var titleLB: UILabel!
    @IBOutlet weak var firstTF: UITextField!
    @IBOutlet weak var secondTF: UITextField!

    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var okBtn: UIButton!

    @IBAction func cancleClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func okClick(_ sender: Any) {
        if let first = firstTF.text ,let second = secondTF.text{

            if(first == ""){
                return
            }
            if(second == ""){
                return
            }
            self.callBack(first,second)
            self.dismiss(animated: true, completion: nil)
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLB.text = "Edit Name".localStr
        cancelBtn.setTitle("Cancel".localStr, for: .normal)
        okBtn.setTitle("Ok".localStr, for: .normal)
        firstTF.placeholder = "Last Name".localStr
        secondTF.placeholder = "First Name".localStr

    }
    static func show(callBack:@escaping (_ first:String,_ second:String)->Void){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "alert") as! CHTFDialogVC

//        myAlert.sss = "wewewe"
        myAlert.callBack = callBack

        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        UIApplication.shared.delegate?.window??.rootViewController?.present(myAlert, animated: true, completion: nil)
    }


}
