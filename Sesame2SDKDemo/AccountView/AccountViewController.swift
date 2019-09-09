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

class AccountViewController: UIViewController {
    var account: String?
    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var userId: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Account"
        userId.text = "User Name: \n\(AWSCognitoOAuthService.shared.signedInUsername ?? "Unknown")\n\nCandy House UserId:\n\(CHAccountManager.shared.candyhouseUserId?.uuidString ?? "Unknown")"
    }

    @IBAction func didPressLogout(_ sender: Any) {
        AWSCognitoOAuthService.shared.logout()
    }
}
