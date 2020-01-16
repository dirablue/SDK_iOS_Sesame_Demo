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
        _ =  AWSCognitoOAuthService.shared.oauthToken()
        let isCandyLoging = CHAccountManager.shared.isLogin()
        //todo factor this is login not account login
        if isCandyLoging == false {
            ViewHelper.showLoadingInView(view: self.view)
            CHAccountManager.shared.loginBackgroundPreparation({ (_, apiResult) in
                L.d("apiResult.success",apiResult.success)

                if apiResult.success {
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                        self.delegateMe?.setLoginName()
                        self.delegateFriend?.refreshFriendPage()
                        self.delegateHome?.refleshKeyChain()
                    }
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
        self.tabBar.items?[0].title = "Sesame".localStr
        self.tabBar.items?[1].title = "Contacts".localStr
        self.tabBar.items?[2].title = "Me".localStr

        self.tabBar.items?[0].image = UIImage.SVGImage(named:"keychain_original")
        self.tabBar.items?[0].selectedImage = UIImage.SVGImage(named:"keychain_tint")
        self.tabBar.items?[1].image = UIImage.SVGImage(named:"icons_outlined_contacts",fillColor: UIColor.gray)
        self.tabBar.items?[1].selectedImage = UIImage.SVGImage(named:"icons_filled_contacts",fillColor: Colors.tintColor)
        self.tabBar.items?[2].image = UIImage.SVGImage(named:"icons_outlined_me",fillColor: UIColor.gray)
        self.tabBar.items?[2].selectedImage = UIImage.SVGImage(named:"icons_filled_official-accounts",fillColor: Colors.tintColor)

        self.tabBar.shadowImage = UIImage()
        self.tabBar.backgroundImage = UIImage()
        self.tabBar.layer.borderWidth = 0
        self.tabBar.clipsToBounds = true

        let service = AWSCognitoOAuthService.shared
        if service.isSignedIn {
        }else{
            loginV()
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let controller = segue.destination as? ScanViewController {
            let parr = sender as! Array<Any>
            let tabVC = sender as? GeneralTabViewController
            controller.tabVC = tabVC
            controller.from = (parr[0] as! String)
            controller.callBack = parr[1] as! (_ from:String)->Void
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
    func scanQR(from:String = "no",_ callBack:@escaping (_ from:String)->Void)   {
        self.performSegue(withIdentifier: "qrcode", sender: [from,callBack])
    }
    func goRegisterList()   {
        self.performSegue(withIdentifier: "register", sender: self)
    }
    func goRegisterPage(ssm: CHSesameBleInterface)   {
        L.d(goRegisterPage)
        delegateHome?.goRegister(ssm: ssm)
    }

}
