//
//  GeneralTabViewController.swift
//  sesame-sdk-test-app
//
//  Created by Yiling on 2019/08/30.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import UIKit
import SesameSDK

class GeneralTabViewController: UITabBarController {
    override func viewDidLoad() {
        let service = AWSCognitoOAuthService.shared
        let isSignin = service.isSignedIn
        if isSignin {
        }else{
            loginV()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        /*
         CH-Auth  step1
         CHAccountManager setupLoginSession
         */
        CHAccountManager.shared.setupLoginSession(identityProvider: AWSCognitoOAuthService.shared)

        /*
         CH-Auth  step2
         CHAccountManager login
         */
        CHAccountManager.shared.login({ (_, apiResult) in
            L.d("apiResult.success",apiResult.success)
            if apiResult.success {
                DispatchQueue.main.async {
                    AccountViewController.imACuteBoy?.reloadLoginInformation()
                }
                CHAccountManager.shared.deviceManager.flushDevices({(_, _, deviceDatas) in
                    L.d("Candyhouse Auth  GetList",deviceDatas?.count)
                })

            } else {
                let err = NSError(domain: apiResult.errorCode ?? "UNKNOWN_ERROR", code: 400, userInfo: ["detail": apiResult.errorDescription ?? "none"])
                print(err)
            }
        })
    }

    func loginV() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "gologin", sender: self)
        }
    }
    func scanQR()   {
        self.performSegue(withIdentifier: "qrcode", sender: nil)
    }
}
