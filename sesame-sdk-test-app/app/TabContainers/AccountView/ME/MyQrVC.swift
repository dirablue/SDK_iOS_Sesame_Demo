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

    @IBOutlet weak var hintLB: UILabel!
    @IBOutlet weak var headImg: UIImageView!
    @IBOutlet weak var familyNameLB: UILabel!
    @IBOutlet weak var givenNameLb: UILabel!
    @IBOutlet weak var mailLB: UILabel!
    @IBOutlet weak var qrImg: UIImageView!

    var familyName:String?
    var givenName:String?
    var mail:String?

    override func viewDidLoad() {
        super.viewDidLoad()

        familyNameLB.text  = familyName
        givenNameLb.text  = givenName
        mailLB.text  = mail
        mailLB.adjustsFontSizeToFitWidth = true
        hintLB.text = "Scan this QR code to add me on your contact".localStr
        headImg.image = UIImage.makeLetterAvatar(withUsername: self.givenName ?? "")

        DispatchQueue.main.async {
            ViewHelper.showLoadingInView(view: self.view)
        }
        CHAccountManager.shared.getInvitation(){ invitation in
            DispatchQueue.main.async {
                ViewHelper.hideLoadingView(view: self.view)
            }
            DispatchQueue.main.async {
                L.d("invitation.absoluteString",invitation.absoluteString)
                self.qrImg.image = UIImage.generateQRCode(invitation.absoluteString, UIImage.makeLetterAvatar(withUsername: self.givenName ?? ""), .black)
            }
        }
    }
}
