//
//  SignUpViewController.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/12/7.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import SesameSDK
import AWSCognitoIdentityProvider

class ForgetPassWordVC: BaseViewController {
    var loginVC:LoginViewController? = nil

    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var nameLB: UILabel!
    @IBOutlet weak var cinfirmCodeLB: UILabel!
    @IBOutlet weak var newPasswordLB: UILabel!

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var ConfirmCodeTF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!

    @IBOutlet weak var resendMailBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!

    @IBAction func back(_ sender: Any) {
           DispatchQueue.main.async {
                    self.dismiss(animated: true, completion:nil)
                }
       }
    @IBAction func resendEmail(_ sender: Any) {

        self.view.endEditing(true)

        let user = AWSCognitoOAuthService.shared.pool.getUser(nameTF.text!.toMail())

        user.forgotPassword().continueWith{[weak self] (task: AWSTask) -> AnyObject? in
            guard self != nil else {return nil}
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                                     self?.view.makeToast((error.userInfo["message"] as? String)?.localStr)

                }  else if let result = task.result {
                    let alertController = UIAlertController(title: "Code Sent",
                                                            message: "Code sent to \(result.codeDeliveryDetails?.destination! ?? " no message")",
                        preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self?.present(alertController, animated: true, completion: nil)

                    // view group1
                    self?.ConfirmCodeTF.isHidden = false
                    self?.cinfirmCodeLB.isHidden = false
                    self?.newPasswordTF.isHidden = false
                    self?.newPasswordLB.isHidden = false
                    self?.confirmBtn.isHidden = false
                    // view group1 end
                }
            })
            return nil
        }
    }
    @IBAction func confirm(_ sender: Any) {
        self.view.endEditing(true)
        guard let confirmationCodeValue = self.ConfirmCodeTF.text, !confirmationCodeValue.isEmpty else {
            self.view.makeToast("Please enter a password of your choice.".localStr)
            return
        }
        let user = AWSCognitoOAuthService.shared.pool.getUser(nameTF.text!.toMail())

        user.confirmForgotPassword(confirmationCodeValue, password: self.newPasswordTF.text!).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    self?.view.makeToast((error.userInfo["message"] as? String)?.localStr)
                } else {
                    DispatchQueue.main.async {
                        strongSelf.loginVC?.userName.text = strongSelf.nameTF.text!.toMail()
                        strongSelf.loginVC?.password.text = strongSelf.newPasswordTF.text
                        strongSelf.dismiss(animated: true, completion:nil)
                        self?.view.makeToast("change sucess".localStr)
                    }
                    let _ = strongSelf.navigationController?.popToRootViewController(animated: true)

                }
            })
            return nil
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTF.text = loginVC?.userName.text
        newPasswordTF.text = ""
        nameTF.delegate = self
        newPasswordTF.delegate = self
        ConfirmCodeTF.delegate = self

        nameLB.text = "Email".localStr
        cinfirmCodeLB.text = "Verification".localStr
        newPasswordLB.text = "New Password".localStr

        confirmBtn.setTitle("Verification code".localStr, for: .normal)
        resendMailBtn.setTitle("Send verification code".localStr, for: .normal)

        // view group1
        ConfirmCodeTF.isHidden = true
        cinfirmCodeLB.isHidden = true
        newPasswordTF.isHidden = true
        newPasswordLB.isHidden = true
        confirmBtn.isHidden = true
        // view group1 end

    }
}
extension ForgetPassWordVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}
extension ForgetPassWordVC{
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        backBtn.setImage( UIImage.SVGImage(named:isDarkMode() ?"icons_filled_close_b" : "icons_filled_close"), for: .normal)
    }
}
