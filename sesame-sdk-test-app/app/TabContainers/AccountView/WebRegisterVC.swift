//
//  WebRegisterVC.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/11/25.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit
import SesameSDK
import WebKit
extension WEbRegisterVC{
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        back.setImage( UIImage.SVGImage(named:isDarkMode() ?"icons_filled_close_b" : "icons_filled_close"), for: .normal)
    }
}
class WEbRegisterVC: BaseViewController , WKNavigationDelegate, WKUIDelegate{
    var backButton: UIButton!
    var forwadButton: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBAction func back(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion:nil)
        }
    }
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var webContain: WKWebView!
//    override func loadView() {
//        let webConfiguration = WKWebViewConfiguration()
//        webContain = WKWebView(frame: .zero, configuration: webConfiguration)
//
//        webContain.uiDelegate = self
//        webContain.navigationDelegate = self
//        view = webContain
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
        L.d("viewDidLoad")
        let myURL = URL(string:"https://sesame-demo.auth.us-east-1.amazoncognito.com/login?client_id=16f93kesuhp9p41kgp1tselpot&response_type=code&redirect_uri=https://candyhouse.co/&state=STATE&scope=openid")
        let myRequest = URLRequest(url: myURL!)

        webContain.frame = view.frame
        webContain.navigationDelegate = self
        webContain.uiDelegate = self
        webContain.allowsBackForwardNavigationGestures = true

        webContain.load(myRequest)
        let webConfiguration = WKWebViewConfiguration()
        webContain = WKWebView(frame: .zero, configuration: webConfiguration)
        view.addSubview(webContain)
        createWebControlParts()

    }
    private func createWebControlParts() {

        let buttonSize = CGSize(width:40,height:40)
        let offseetUnderBottom:CGFloat = 60
        let yPos = (UIScreen.main.bounds.height - offseetUnderBottom)
        let buttonPadding:CGFloat = 10

        let backButtonPos = CGPoint(x:buttonPadding, y:yPos)
        let forwardButtonPos = CGPoint(x:(buttonPadding + buttonSize.width + buttonPadding), y:yPos)

        backButton = UIButton(frame: CGRect(origin: backButtonPos, size: buttonSize))
        forwadButton = UIButton(frame: CGRect(origin:forwardButtonPos, size:buttonSize))

        backButton.setTitle("<", for: .normal)
        backButton.setTitle("< ", for: .highlighted)
        backButton.setTitleColor(.white, for: .normal)
        backButton.layer.backgroundColor = UIColor.black.cgColor
        backButton.layer.opacity = 0.6
        backButton.layer.cornerRadius = 5.0
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        backButton.isHidden = true
        view.addSubview(backButton)

        forwadButton.setTitle(">", for: .normal)
        forwadButton.setTitle(" >", for: .highlighted)
        forwadButton.setTitleColor(.white, for: .normal)
        forwadButton.layer.backgroundColor = UIColor.black.cgColor
        forwadButton.layer.opacity = 0.6
        forwadButton.layer.cornerRadius = 5.0
        forwadButton.addTarget(self, action: #selector(goForward), for: .touchUpInside)
        forwadButton.isHidden = true
        view.addSubview(forwadButton)

    }

    @objc private func goBack() {
        webContain.goBack()
    }

    @objc private func goForward() {
        webContain.goForward()
    }

}


