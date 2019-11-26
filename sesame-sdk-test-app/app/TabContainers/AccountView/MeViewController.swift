//
//  MeViewController.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/10/9.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import SesameSDK

public protocol MeDelegate: class {
    func  setLoginName()
}

class MeViewController: BaseViewController {
    private var menuFloatView: SessionMoreFrameFloatView?
    private func showMoreMenu() {
        if menuFloatView == nil {
            let y = Constants.statusBarHeight + 44
            let frame = CGRect(x: 0, y: y, width: view.bounds.width, height: view.bounds.height - y)
            menuFloatView = SessionMoreFrameFloatView(frame: frame)
            menuFloatView?.delegate = self
        }
        menuFloatView?.show(in: self.view)
    }
    
    private func hideMoreMenu(animated: Bool = true) {
        menuFloatView?.hide(animated: animated)
    }
    
    @IBOutlet weak var accountNameLB: UILabel!

    @IBOutlet weak var avatarImg: UIImageView!

    @IBOutlet weak var qrImg: UIImageView!

    @IBOutlet weak var candyIDLB: UILabel!

    @IBAction func logOut(_ sender: UIButton) {
        AWSCognitoOAuthService.shared.logout()
        CHAccountManager.shared.logout()
        (self.tabBarController as! GeneralTabViewController).loginV()
        UserDefaults.init(suiteName: "group.candyhouse.widget")?.set(true, forKey: "widgetlogout")

    }

    @IBOutlet weak var logoutBtn: UIButton!

    override func viewDidAppear(_ animated: Bool) {
        setLoginName()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.tabBarController as! GeneralTabViewController).delegateMe = self

        logoutBtn.setTitle("logout".localStr, for: .normal)


    }

}

extension MeViewController:MeDelegate{
    func setLoginName() {
        let name = AWSCognitoOAuthService.shared.signedInUsername ?? "-"
        let id = CHAccountManager.shared.candyhouseUserId?.uuidString ?? "-"

        accountNameLB.text = name
        candyIDLB.text = id
        avatarImg.image = UIImage.makeLetterAvatar(withUsername: name)
    }
}

extension MeViewController: SessionMoreMenuViewDelegate {
    @objc private func handleRightBarButtonTapped(_ sender: Any) {
        if self.menuFloatView?.superview != nil {
            hideMoreMenu()
        } else {
            showMoreMenu()
        }
    }

    func moreMenuView(_ menu: SessionMoreMenuView, didTap item: SessionMoreItem) {
        switch item.type {
        case .addFriends:
            (self.tabBarController as! GeneralTabViewController).scanQR()

        case .addDevices:
            (self.tabBarController as! GeneralTabViewController).goRegisterList()
        }
        hideMoreMenu(animated: false)
    }
}
extension MeViewController{
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let rightButtonItem = UIBarButtonItem(image: UIImage.SVGImage(named: isDarkMode() ? "icons_outlined_addoutline_black":"icons_outlined_addoutline"), style: .done, target: self, action: #selector(handleRightBarButtonTapped(_:)))
        navigationItem.rightBarButtonItem = rightButtonItem


        qrImg.image = UIImage.SVGImage(named: isDarkMode() ? "icons_outlined_qr-code_b":"icons_outlined_qr-code")

    }
}
