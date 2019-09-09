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

class LoginViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        password.isSecureTextEntry = true
    }

    override func viewWillAppear(_ animated: Bool) {
        if AWSCognitoOAuthService.shared.isSignedIn {
            if CHAccountManager.shared.isLogin() {
                AWSCognitoOAuthService.shared.continueLoginSession()
                self.loginView.isHidden = true
                loadMenuView()
            } else {
                AWSCognitoOAuthService.shared.loginCandyhouseWithCurrentLoginSession(callback: {(apiResult) in
                    if apiResult.success {
                        self.loadMenuView()
                        self.loginView.isHidden = true
                    }
                })
            }
        }
    }

    func loadMenuView() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "enterTabBarController", sender: self)
            ViewHelper.hideLoadingView(view: self.view)
        }
    }

    @IBAction func loginDidPress(_ sender: Any) {
        weak var weakSelf = self
        ViewHelper.showLoadingInView(view: self.view)
        AWSCognitoOAuthService.shared.login(username: (email?.text)!, password: (password?.text)!) { (error) in
            if error == nil {
                weakSelf?.loadMenuView()
            } else {
                let userInfo = (error! as NSError).userInfo
                DispatchQueue.main.async {
                    ViewHelper.hideLoadingView(view: weakSelf!.view)
                    ViewHelper.showAlertMessage(title: "Ooops", message: String(format: "login failed with error: %@, userInfo: %@", error!.localizedDescription, userInfo), actionTitle: "OK", viewController: weakSelf!)
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
