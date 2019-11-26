//
//  LoginViewController.swift
//  sesame-sdk-test-app
//
//  Created by Yiling on 2019/08/05.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import UIKit
import SesameSDK

class LoginViewController: BaseViewController {
    
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var passwordLb: UILabel!
    @IBAction func testJerming(_ sender: Any) {
    }
    
    @IBAction func testTse(_ sender: Any) {
    }
    
    @IBAction func testYuria(_ sender: Any) {
    }
    
    @IBAction func testhci(_ sender: Any) {
    }
    
    @IBAction func testpeter(_ sender: Any) {
    }
    @IBAction func testChihiro(_ sender: Any) {
    }
    
    @IBOutlet weak var signBtn: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.setTitle("login".localStr, for: .normal)
        nameLb.text = "name".localStr
        passwordLb.text = "password".localStr
        signBtn.text = "signup".localStr
        password.isSecureTextEntry = true
    }
    
    @IBAction func loginDidPress(_ sender: Any) {
        weak var weakSelf = self
        ViewHelper.showLoadingInView(view: self.view)
        AWSCognitoOAuthService.shared.loginWithUsernamePassword(username: (userName?.text)!, password: (password?.text)!) { (error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion:nil)
                    ViewHelper.hideLoadingView(view: self.view)
                }
            } else {
                let userInfo = (error! as NSError).userInfo
                DispatchQueue.main.async {
                    ViewHelper.hideLoadingView(view: weakSelf!.view)
                    ViewHelper.showAlertMessage(title: "Ooops", message: "login failed with error: \(error!.localizedDescription) userInfo:\(userInfo)", actionTitle: "OK", viewController: weakSelf!)
                }
            }
        }
    }
    
    @IBAction func didPressSignupOrForgotPassword(_ sender: Any) {
        self.performSegue(withIdentifier:  "sign", sender: nil)
    }
}


