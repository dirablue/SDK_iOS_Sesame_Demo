//
//  AccountViewController.swift
//  sesame-sdk-test-app
//
//  Created by Yiling on 2019/08/30.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import UIKit
import SesameSDK

class AccountViewController: BaseViewController {
    static var imACuteBoy: AccountViewController?

    var account: String?
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var userId: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Me"
        AccountViewController.imACuteBoy = self
    }
    override func viewDidAppear(_ animated: Bool) {
        self.reloadLoginInformation()
    }
    @IBAction func scanV(_ sender: Any) {
        L.d("test scanV")
        //        self.performSegue(withIdenti,fier: "showcamara", sender: nil)
        let tabVC = self.tabBarController as! GeneralTabViewController
        tabVC.scanQR()
    }
    func reloadLoginInformation() {
        userId.text = """
        Demo App User Name:
        \(AWSCognitoOAuthService.shared.signedInUsername ?? "Unknown")

        CANDY HOUSE User ID:
        \(CHAccountManager.shared.candyhouseUserId?.uuidString ?? "Unknown")
        """
    }

    @IBAction func didPressLogout(_ sender: Any) {
        AWSCognitoOAuthService.shared.logout()
        CHAccountManager.shared.logout()

        let tabVC = self.tabBarController as! GeneralTabViewController
        tabVC.loginV()

    }
}
