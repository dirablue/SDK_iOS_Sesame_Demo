//
//  LoginViewController.swift
//  sesame-sdk-test-app
//
//  Created by Yiling on 2019/08/05.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import SesameSDK
extension LoginViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}
class LoginViewController: BaseViewController {

    @IBOutlet weak var subloginImg: UIImageView!
    @IBOutlet weak var logImg: UIImageView!
    @IBOutlet weak var testViewG: UIScrollView!
    var userisNotConfirm = false

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var nameLb: UILabel!
    @IBOutlet weak var passwordLb: UILabel!

    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!

    @IBOutlet weak var forgetpasswordBtn: UIButton!
    @IBAction func testJerming(_ sender: Any) {
        userName.text = "jerming+1@candyhouse.co"
        password.text = "111111"
        loginDidPress("")
    }

    @IBAction func testTse(_ sender: Any) {
        userName.text = "tse123321@gmail.com"
        password.text = "111111"
        loginDidPress("")
    }

    @IBAction func testtsem(_ sender: Any) {
        userName.text = "Tse@candy house.co "
        password.text = "111111"
        loginDidPress("")
    }

    @IBAction func testhci(_ sender: Any) {
        userName.text = "tse+10@candyhouse.co"
        password.text = "111111"
        loginDidPress("")
    }

    @IBAction func testpeter(_ sender: Any) {
        userName.text = "peter.su+1@candyhouse.co"
        password.text = "111111"
        loginDidPress("")
    }
    @IBAction func testChihiro(_ sender: Any) {
        userName.text = "tse+5@candyhouse.co"
        password.text = "111111"
        loginDidPress("")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
        testViewG.isHidden = false
        #else
        testViewG.isHidden = true
        #endif
        userName.delegate = self
        password.delegate = self
        logImg.image = UIImage.SVGImage(named: "loginlogo")
        subloginImg.image = UIImage.SVGImage(named: "loginsubhint")

        loginBtn.setTitle("Log In".localStr, for: .normal)
        nameLb.text = "Email".localStr
        passwordLb.text = "Password".localStr
        signupBtn.setTitle("Sign up".localStr, for: .normal)
        forgetpasswordBtn.setTitle("Forget password".localStr, for: .normal)
    }
    
    @IBAction func loginDidPress(_ sender: Any) {
        self.view.endEditing(true)
        ViewHelper.showLoadingInView(view: self.view)
        AWSCognitoOAuthService.shared.loginWithUsernamePassword(username: (userName?.text)!.toMail(), password: (password?.text)!) { (error) in
            if let error = error  {
                DispatchQueue.main.async {
                    let  message  =  error.userInfo["message"] as? String
                    self.view.makeToast((message)?.localStr)
                    if(message == "User is not confirmed."){
                        self.userisNotConfirm = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.signupBtn.sendActions(for: .touchUpInside)
                        }
                    }
                    ViewHelper.hideLoadingView(view: self.view)
                }
            } else {
                self.userisNotConfirm = false
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion:nil)
                    ViewHelper.hideLoadingView(view: self.view)
                }
            }
        }
    }
    
    @IBAction func forgetPassword(_ sender: Any) {
        self.performSegue(withIdentifier:  "forget", sender: nil)
    }
    @IBAction func didPressSignupOrForgotPassword(_ sender: Any) {
        self.performSegue(withIdentifier:  "sign", sender: nil)
    }
}
extension LoginViewController{

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? WEbRegisterVC {
            controller.loginVC = self
        }
        if let controller = segue.destination as? ForgetPassWordVC {
            controller.loginVC = self
        }
    }
}


