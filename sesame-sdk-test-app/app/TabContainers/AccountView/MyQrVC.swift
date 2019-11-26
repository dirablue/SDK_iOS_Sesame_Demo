//
//  MyQrVc.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/11/11.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import SesameSDK

class MyQrVC: BaseViewController {
    @IBOutlet weak var qrImg: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = AWSCognitoOAuthService.shared.signedInUsername ?? "-"

        self.title = name
        CHAccountManager.shared.getInvitation(){ invitation in
            DispatchQueue.main.async {
                self.qrImg.image = self.generateQRCode(from: invitation.absoluteString)
            }
        }
    }
}
