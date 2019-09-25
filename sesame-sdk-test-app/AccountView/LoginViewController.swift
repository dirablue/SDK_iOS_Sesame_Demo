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

class LoginViewController: BaseLightViewController {
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        password.isSecureTextEntry = true
    }

    override func viewWillAppear(_ animated: Bool) {
        let service = AWSCognitoOAuthService.shared

        /*
         CH-Auth  step1
         CHAccountManager setupLoginSession
         */
        CHAccountManager.shared.setupLoginSession(identityProvider: AWSCognitoOAuthService.shared)
        if service.isSignedIn {
            loadMenuView()
            if !CHAccountManager.shared.isLogin() {
                print("SesameSDK is not login yet")
            }
        }
    }

    func loadMenuView() {
        DispatchQueue.main.async {
            L.d("Login Finish")
            self.performSegue(withIdentifier: "enterTabBarController", sender: self)
            ViewHelper.hideLoadingView(view: self.view)
        }
    }

    @IBAction func loginDidPress(_ sender: Any) {
        weak var weakSelf = self
        ViewHelper.showLoadingInView(view: self.view)
        AWSCognitoOAuthService.shared.loginWithUsernamePassword(username: (userName?.text)!, password: (password?.text)!) { (error) in
            if error == nil {
                /*
                 CH-Auth  step2
                 CHAccountManager login
                 */
                CHAccountManager.shared.login({ (_, apiResult) in
                    if apiResult.success {
                        L.d("Candyhourse Auth  OK!!!!!")
                        CHAccountManager.shared.deviceManager.flushDevices({(_, _, _) in
                            L.d("Candyhourse Auth  GetList")
                        })
                    } else {
                        let err = NSError(domain: apiResult.errorCode ?? "UNKNOWN_ERROR", code: 400, userInfo: ["detail": apiResult.errorDescription ?? "none"])
                        print(err)
                    }
                })
                self.loadMenuView()
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
