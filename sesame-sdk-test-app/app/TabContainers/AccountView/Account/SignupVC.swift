//
//  WebRegisterVC.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/11/25.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import SesameSDK
import WebKit
import AWSCognitoIdentityProvider

class WEbRegisterVC: CHBaseVC , WKNavigationDelegate, WKUIDelegate{

    var loginVC:LoginViewController? = nil
    @IBAction func back(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion:nil)
        }
    }

    @IBAction func signup(_ sender: Any) {
        self.view.endEditing(true)

        var attributes = [AWSCognitoIdentityUserAttributeType]()
        let emailAttr = AWSCognitoIdentityUserAttributeType()
        emailAttr?.name = "email"
        emailAttr?.value = emailTF.text!.toMail()
        attributes.append(emailAttr!)

        let given_name = AWSCognitoIdentityUserAttributeType()
        given_name?.name = "given_name"
        given_name?.value = givenNameTF.text
        attributes.append(given_name!)

        let family_name = AWSCognitoIdentityUserAttributeType()
        family_name?.name = "family_name"
        family_name?.value = userTF.text
        attributes.append(family_name!)

        AWSCognitoOAuthService.shared.pool.signUp(emailTF.text!.toMail(), password: passwordTF.text!, userAttributes: attributes, validationData: nil).continueWith {[weak self] (task) -> Any? in
            guard self != nil else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError?{
//                    L.d("message",error.code,(error.userInfo["message"] as? String))
                    self?.view.makeToast((error.userInfo["message"] as? String)?.localStr)
//                    L.d("task.result",task.result)
                } else if let result = task.result  {

                    if(result.user.confirmedStatus  == .confirmed){
                        self?.view.makeToast("confirmed")
                    }
                    if(result.user.confirmedStatus  == .unconfirmed){
                        self?.view.makeToast("unconfirmed")
                    }
//                    if(result.user.confirmedStatus  == .unknown){
//                        L.d("unknown")
//                        self?.view.makeToast("unknown")
//                    }
                    L.d("result.user.confirmedStatus",result.user.confirmedStatus.rawValue)
                    if (result.user.confirmedStatus != AWSCognitoIdentityUserStatus.confirmed) {
                        L.d("result.user.confirmedStatus AAAAA",result.user.confirmedStatus)
                        //                            guard let _ = self else { return nil }
                        DispatchQueue.main.async(execute: {
                            if let error = task.error as NSError? {
                                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                                        message: error.userInfo["message"] as? String,
                                                                        preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                                alertController.addAction(okAction)

                                self?.present(alertController, animated: true, completion:  nil)
                            } else if let result = task.result {

                                //view group 1
                                self?.userTF.isEnabled = false
                                self?.givenNameTF.isEnabled = false
                                self?.passwordTF.isEnabled = false
                                self?.emailTF.isEnabled = false
                                self?.signupBtn.isEnabled = false
                                self?.signupBtn.backgroundColor = UIColor.lightGray
                                self?.signupBtn.alpha = 0.6
                                //end view group 1

                                //view group 2
                                self?.cinfirmTF.isHidden = false // todo test
                                self?.confirmCodeLB.isHidden = false
                                self?.confirmBtn.isHidden = false
                                self?.resendEmailBtn.isHidden = false
                                //end view group 2

                                let alertController = UIAlertController(title: "Code Sent",
                                                                        message: "Code sent to \(result.codeDeliveryDetails?.destination! ?? " no message")",
                                    preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                                alertController.addAction(okAction)
                                self?.present(alertController, animated: true, completion: nil)
                            }
                        })

                    } else {
                        L.d("result.user.confirmedStatus BBBBB",result.user.confirmedStatus)
                    }
                }

            })
            return nil
        }
    }



    @IBAction func confirmuser(_ sender: Any) {

        let user = AWSCognitoOAuthService.shared.pool.getUser(emailTF.text!.toMail())
        user.confirmSignUp(self.cinfirmTF.text!, forceAliasCreation: true).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    self?.view.makeToast((error.userInfo["message"] as? String)?.localStr)
                } else {
                    let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                    DispatchQueue.main.async {
                        strongSelf.loginVC?.userName.text = strongSelf.emailTF.text!.toMail()
                        strongSelf.loginVC?.password.text = strongSelf.passwordTF.text
                        strongSelf.dismiss(animated: true, completion:nil)
                    }

                }
            })


            return nil
        }
    }
    @IBAction func reSendEmail(_ sender: Any) {
        let user = AWSCognitoOAuthService.shared.pool.getUser(emailTF.text!.toMail())
        user.resendConfirmationCode().continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let _ = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {

                    self?.view.makeToast((error.userInfo["message"] as? String)?.localStr)


                } else if let result = task.result {
                    let alertController = UIAlertController(title: "Code Sent",
                                                            message: "Code resent to \(result.codeDeliveryDetails?.destination! ?? " no message")",
                        preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self?.present(alertController, animated: true, completion: nil)
                }
            })
            return nil
        }
    }
    @IBOutlet weak var usernameLb: UILabel!
    @IBOutlet weak var passwordLB: UILabel!
    @IBOutlet weak var mailLB: UILabel!
    @IBOutlet weak var userTF: UITextField!
    @IBOutlet weak var givenNameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var cinfirmTF: UITextField!
    @IBOutlet weak var confirmCodeLB: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var givenNameLB: UILabel!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var resendEmailBtn: UIButton!

    @objc private func handleRightBarButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
    }
    @objc private func okTapped(_ sender: Any) {
        self.view.endEditing(true)
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        L.d("viewDidLoad")

        userTF.delegate = self
        givenNameTF.delegate = self
        passwordTF.delegate = self
        emailTF.delegate = self
        cinfirmTF.delegate = self
        // Last Name = Family Name = 姓;
        // First Name = Given Name = 名
        mailLB.text = "Email".localStr
        usernameLb.text = "Last Name".localStr
        givenNameLB.text = "First Name".localStr
        passwordLB.text = "Password".localStr
        confirmCodeLB.text = "Verification code".localStr
        signupBtn.setTitle("Sign up".localStr, for: .normal)
        confirmBtn.setTitle("Verification code".localStr, for: .normal)
        resendEmailBtn.setTitle("Re-send verification code".localStr, for: .normal)

        emailTF.text = loginVC?.userName.text
        passwordTF.text = loginVC?.password.text

        if(loginVC!.userisNotConfirm){
            //view group 1
            givenNameTF.isHidden = true
            userTF.isHidden = true
            signupBtn.isHidden = true
            usernameLb.isHidden = true
            givenNameLB.isHidden = true
            passwordTF.isHidden = true
            passwordLB.isHidden = true
            //end view group 1
            reSendEmail("")

        }else{
            //view group 2
            cinfirmTF.isHidden = true
            confirmCodeLB.isHidden = true
            confirmBtn.isHidden = true
            resendEmailBtn.isHidden = true
            //end view group 2
        }
        loginVC!.userisNotConfirm = false

    }
}


extension WEbRegisterVC:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}

extension WEbRegisterVC{
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        backBtn.setImage( UIImage.SVGImage(named:isDarkMode() ?"icons_filled_close_b" : "icons_filled_close"), for: .normal)
    }
}
