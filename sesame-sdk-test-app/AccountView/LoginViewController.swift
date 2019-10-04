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
    @IBOutlet weak var loginView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //        password.isSecureTextEntry = true
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
        if let url = URL(string: "https://sesame-demo.auth.us-east-1.amazoncognito.com/login?client_id=16f93kesuhp9p41kgp1tselpot&response_type=code&redirect_uri=https://candyhouse.co/&state=STATE&scope=openid") {
            UIApplication.shared.open(url)
        }
    }
}


