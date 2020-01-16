//
//  ScanViewController.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/9/27.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import SesameSDK
import AVFoundation

class ScanViewController: BaseViewController {
    @IBOutlet weak var hintLb: UILabel!
    var tabVC:GeneralTabViewController?
    var from:String?
    var callBack:(_ from:String)->Void = {from in
        L.d("test 閉包")
    }

    @IBOutlet weak var scannerView: QRScannerView! {
        didSet {
            scannerView.delegate = self
        }
    }
    @IBOutlet weak var scanViewSp: ScanView!

    @IBOutlet weak var back: UIButton!

    override func viewWillDisappear(_ animated: Bool) {
        if !scannerView.isRunning {
            scannerView.stopScanning()
        }
    }

    @IBAction func backClick(_ sender: Any) {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion:nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        if !scannerView.isRunning {
            scannerView.startScanning()
        }
        cameraEnable()
    }
    override func viewDidLoad() {
        L.d("掃碼畫面加載")
        scanViewSp.scanAnimationImage = UIImage(named: "ScanLine")!
        hintLb.text = "Scan the QR code".localStr

    }
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scanViewSp.startAnimation()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scanViewSp.stopAnimation()
    }

}

extension ScanViewController: QRScannerViewDelegate {
    func qrScanningDidStop() {
    }

    func qrScanningDidFail() {
        L.d("qrScanningDidFail")
    }

    func qrScanningSucceededWithCode(_ QRCode: String?) {
        playSound()
        CHAccountManager.shared.receiveQRCode(qrcode:QRCode ?? "error"){ (result,event,param) in
            switch event{
            case .getKeyFromOwner:
                if(result){
                    self.dismiss(animated: true, completion:nil)
                }
            case .addFriendFromACcount:
                if(result){
                    L.d("掃描成功 addFriendFromACcount")
                    self.tabVC?.selectedIndex = 1
                    self.tabVC?.delegateFriend?.refreshFriendPage()
//                    if(self.from == "addSesame"){
                    self.callBack(param)
//                    }
                    self.dismiss(animated: true, completion:nil)

                }
            }
        }
    }
}
extension ScanViewController{
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
//        back.setImage( UIImage.SVGImage(named:isDarkMode() ?"icons_filled_close_b" : "icons_filled_close"), for: .normal)
        back.setImage( UIImage.SVGImage(named: "icons_filled_close_b"), for: .normal)
    }
}
