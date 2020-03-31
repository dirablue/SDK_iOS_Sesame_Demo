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
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    var callBack:(_ first:String,_ second:String)->Void = {f,s in
              L.d("test 閉包")
          }

    @IBOutlet weak var secondHintLB: UILabel!
    @IBOutlet weak var tophintLB: UILabel!
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
        titleLB.font = .boldSystemFont(ofSize: UIFont.labelFontSize)

        titleLB.text = "Edit Name".localStr
        cancelBtn.setTitle("Cancel".localStr, for: .normal)
        okBtn.setTitle("OK".localStr, for: .normal)
        tophintLB.text = "Last Name".localStr
        secondHintLB.text = "First Name".localStr


        let tmpFamilyName = UserDefaults.standard.string(forKey: "family_name")
        let tmpGivenName = UserDefaults.standard.string(forKey: "given_name")

        firstTF.text = tmpFamilyName
        secondTF.text = tmpGivenName

        okBtn.titleLabel?.font = .boldSystemFont(ofSize: UIFont.labelFontSize)
        cancelBtn.titleLabel?.font = .boldSystemFont(ofSize: UIFont.labelFontSize)


    }
    static func show(callBack:@escaping (_ first:String,_ second:String)->Void){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "alert") as! CHTFDialogVC

        myAlert.callBack = callBack

        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        UIApplication.shared.delegate?.window??.rootViewController?.present(myAlert, animated: true, completion: nil)
    }


}
