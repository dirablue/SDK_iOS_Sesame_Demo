//
//  MeViewController.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/10/9.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import SesameSDK
import AWSAPIGateway
import Foundation
import AWSCognitoIdentityProvider

class MeViewController: BaseViewController {
    private var menuFloatView: SessionMoreFrameFloatView?
    
    
    @IBOutlet weak var changeAccountNameLb: UILabel!
    @IBOutlet weak var familyNameLB: UILabel!
    @IBOutlet weak var givenNameLb: UILabel!
    @IBOutlet weak var candyIDLB: UILabel!
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var qrImg: UIImageView!
    @IBOutlet weak var logoutBtn: UIButton!
    
    @IBAction func logOut(_ sender: UIButton) {
        let check = UIAlertAction.addAction(title: "Log Out".localStr, style: .destructive) { (action) in
            AWSCognitoOAuthService.shared.logout()
            CHAccountManager.shared.logout()
            (self.tabBarController as! GeneralTabViewController).loginV()
        }
        UIAlertController.showAlertController(style: .actionSheet, actions: [check])
    }
    @IBAction func changeAccount(_ sender: Any) {
        // Last Name = Family Name = 姓;
        // First Name = Given Name = 名
        CHTFDialogVC.show(){ lastname,firstname in
            L.d(lastname,firstname)
            var attributes = [AWSCognitoIdentityUserAttributeType]()
            let family_name = AWSCognitoIdentityUserAttributeType()
            family_name?.name = "family_name"
            family_name?.value = lastname
            attributes.append(family_name!)
            
            
            let given_name = AWSCognitoIdentityUserAttributeType()
            given_name?.name = "given_name"
            given_name?.value = firstname
            attributes.append(given_name!)

            let user =  AWSCognitoOAuthService.shared.pool.currentUser()
            let _ =  user!.update(attributes).continueWith{[weak self] (task: AWSTask) -> AnyObject? in
                guard self != nil else {return nil}
                DispatchQueue.main.async(execute: {
                    if let error = task.error as NSError? {
                        let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                                message: error.userInfo["message"] as? String,
                                                                preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alertController.addAction(okAction)
                        
                        self?.present(alertController, animated: true, completion:  nil)
                    }  else  {
                        //                            self?.view.makeToast("OK".localStr)
                        self?.setLoginName()
                    }
                })
                return nil
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setLoginName()
        (self.tabBarController as! GeneralTabViewController).delegateMe = self
        logoutBtn.setTitle("Log Out".localStr, for: .normal)
        changeAccountNameLb.text = "Edit Name".localStr
        candyIDLB.adjustsFontSizeToFitWidth = true
    }
}

extension MeViewController:MeDelegate{
    func setLoginName() {
        
        let tmpFamilyName = UserDefaults.standard.string(forKey: "family_name")
        let tmpGivenName = UserDefaults.standard.string(forKey: "given_name")

        self.givenNameLb.text = tmpGivenName
        self.familyNameLB.text = tmpFamilyName

        self.avatarImg.image = UIImage.makeLetterAvatar(withUsername: tmpGivenName)
        self.candyIDLB.text = UserDefaults.standard.string(forKey: "email")

        AWSCognitoOAuthService.shared.pool.currentUser()?.getDetails().continueWith(){ task in
            
            if let attributes = task.result?.userAttributes {
                for attribute in attributes {
                    //                    L.d("屬性 ",attribute.name!, attribute.value!)
                    if attribute.name == "family_name",let familyName = attribute.value {
                        DispatchQueue.main.async {
                            
                            UserDefaults.standard.setValue(familyName, forKey: "family_name")
                            self.familyNameLB.text = familyName

                        }
                    }
                    
                    if attribute.name == "given_name",let username = attribute.value {
                        DispatchQueue.main.async {
                            UserDefaults.standard.setValue(username, forKey: "given_name")
                            self.givenNameLb.text = username
                             self.avatarImg.image = UIImage.makeLetterAvatar(withUsername: username)
                        }
                    }
                    
                    if attribute.name == "email",let email = attribute.value {
                        DispatchQueue.main.async {
                            UserDefaults.standard.setValue(email, forKey: "email")
                            self.candyIDLB.text = email
                        }
                    }
                }
                DispatchQueue.main.async {
                    // Last Name = Family Name = 姓;
                    // First Name = Given Name = 名
                    CHAccountManager.shared.updateMyProfile(
                        first_name:"\(self.givenNameLb.text ?? "-")",
                        last_name:"\(self.familyNameLB.text ?? "-")"
                    ){ _ in}
                }
            }
            
            return nil
        }
    }
}

extension MeViewController: SessionMoreMenuViewDelegate {
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
            (self.tabBarController as! GeneralTabViewController).scanQR(){ name in
                (self.tabBarController as! GeneralTabViewController).delegateFriend?.refreshFriendPage()
                L.d("測試回傳")
            }
            
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

public protocol MeDelegate: class {
    func setLoginName()
}
extension MeViewController: UITableViewDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? MyQrVC {
            controller.familyName = familyNameLB.text
            controller.givenName = givenNameLb.text
            controller.mail = candyIDLB.text
        }
    }
}


