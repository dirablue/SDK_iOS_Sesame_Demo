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
import AWSAPIGateway

class GeneralTabViewController: UITabBarController {
    public weak var delegateHome: homeDelegate?
    public weak var delegateMe: MeDelegate?
    public weak var delegateFriend: FriendDelegate?
    override func viewWillAppear(_ animated: Bool) {
        checkLogin()
    }

    func checkLogin()  {
        let service = AWSCognitoOAuthService.shared

//        L.d("進入主要ＡＰＰ","是否登入",service.isSignedIn,AWSCognitoOAuthService.shared.pool.currentUser()?.username)
        if service.isSignedIn {
            L.d("*** CHAccountManager.shared.setupLoginSession")
            CHAccountManager.shared.setupLoginSession(identityProvider: AWSCognitoOAuthService.shared)

        }else{
            loginV()
        }
        let sss = DispatchQueue(label: "history", qos: .background, attributes: .concurrent)
        sss.async() {
//            L.d("🔥", "UI主動調用拿到token ==>")
            let token =  AWSCognitoOAuthService.shared.oauthToken()
//            L.d("🔥", "UI調用結果 <==",token.token.count)
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
//        checkLogin()
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
        if let controller = segue.destination as? LoginViewController {
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
