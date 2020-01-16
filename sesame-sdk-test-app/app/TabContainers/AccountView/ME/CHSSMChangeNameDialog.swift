//
//  CHSSMChangeNameDialog.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2020/1/13.
//  Copyright © 2020 Cerberus. All rights reserved.
//

import Foundation

import Foundation
import UIKit
class CHSSMChangeNameDialog: UIViewController {
    var callBack:(_ first:String)->Void = {f in
              L.d("test 閉包")
          }

    @IBOutlet weak var titleLB: UILabel!
    var sss = ""

    @IBOutlet weak var nameTF: UITextField!

    @IBOutlet weak var cancelBTN: UIButton!
    @IBOutlet weak var okBTN: UIButton!

    @IBAction func onOKCLick(_ sender: Any) {
                if let first = nameTF.text {

                    if(first == ""){
                        return
                    }

                    self.callBack(first)
                    self.dismiss(animated: true, completion: nil)
                }
    }


    @IBAction func cancleClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLB.text = "Change Sesame Name".localStr
        cancelBTN.setTitle("Cancel".localStr, for: .normal)
        okBTN.setTitle("Ok".localStr, for: .normal)
//        nameTF.placeholder = "Last Name".localStr
//        secondTF.placeholder = "First Name".localStr

    }
    static func show(callBack:@escaping (_ first:String)->Void){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "ssmalert") as! CHSSMChangeNameDialog

        myAlert.callBack = callBack

        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        UIApplication.shared.delegate?.window??.rootViewController?.present(myAlert, animated: true, completion: nil)
    }


}
