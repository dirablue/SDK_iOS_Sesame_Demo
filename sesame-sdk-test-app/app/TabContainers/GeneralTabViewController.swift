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
    public weak var delegateHome: homeDelegate?
    public weak var delegateMe: MeDelegate?
    public weak var delegateFriend: FriendDelegate?


    override func viewWillAppear(_ animated: Bool) {

        CHAccountManager.shared.setupLoginSession(identityProvider: AWSCognitoOAuthService.shared)
        do {
            try AWSCognitoOAuthService.shared.oauthToken()
        } catch  {
            L.d("error",error)
        }

        if CHAccountManager.shared.isLogin() == false {
            UserDefaults.init(suiteName: "group.candyhouse.widget")?.set(true, forKey: "isnNeedfreshK")

            ViewHelper.showLoadingInView(view: self.view)

            CHAccountManager.shared.login({ (_, apiResult) in
                L.d("apiResult.success",apiResult.success)
                if apiResult.success {
                    if let username = AWSCognitoOAuthService.shared.signedInUsername{
                        CHAccountManager.shared.updateMyProfile(name: username){ isS in
                            CHAccountManager.shared.getMyProfile(){ profile in
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.delegateMe?.setLoginName()
                        L.d("刷新點位Ａ")
                        self.delegateHome?.refleshKeyChain()
                    }

                } else {
                    L.d("apiResult.errorCode",apiResult.errorCode)
                }
                DispatchQueue.main.async {

                    ViewHelper.hideLoadingView(view: self.view)
                }
            })
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = Colors.tintColor

        self.tabBar.items?[0].title = "Device List".localStr
        self.tabBar.items?[1].title = "Friends".localStr
        self.tabBar.items?[2].title = "me".localStr


        let service = AWSCognitoOAuthService.shared
        if service.isSignedIn {
        }else{
            loginV()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ScanViewController {
            let tabVC = sender as? GeneralTabViewController
            controller.tabVC = tabVC
        }
        if let controller = segue.destination as? RegisterDeviceListVC {
            let tabVC = sender as? GeneralTabViewController
            controller.tabVC = tabVC
        }
    }

    func loginV() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "gologin", sender: self)
        }
    }
    func scanQR()   {
        self.performSegue(withIdentifier: "qrcode", sender: self)
    }
    func goRegisterList()   {
        self.performSegue(withIdentifier: "register", sender: self)
    }
    func goRegisterPage(ssm: CHSesameBleInterface)   {
        L.d(goRegisterPage)
        delegateHome?.goRegister(ssm: ssm)
    }

    func deviceReflesh() {
        delegateHome?.refleshKeyChain()
    }

    func refreshFriendPage() {
        DispatchQueue.main.async {
            self.delegateFriend?.refreshFriendPage()
        }
    }
}
enum HomeTab: String {
    case chats
    case contacts
    case discover
    case me

    var selectedImage: UIImage? {
        get {
            let name = "icons_filled_\(rawValue)"
            return UIImage.SVGImage(named: name, fillColor: Colors.tintColor)
        }
    }

    var image: UIImage? {
        get {
            let name = "icons_outlined_\(rawValue)"
            return UIImage.SVGImage(named: name, fillColor: UIColor.black)
        }
    }
}
