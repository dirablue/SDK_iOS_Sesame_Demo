//
//  DFUProgress.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/9/11.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import SesameSDK

class TemporaryFirmwareUpdateClass: CHFirmwareUpdateInterface {
    weak var view: BaseLightViewController?
    var alertView: UIAlertController
    var abortFunc: (() -> Void)?
    var isFinished: Bool = false

    init(_ mainView: BaseLightViewController) {
        self.view = mainView
        abortFunc = nil

        alertView = UIAlertController(title: "DFU", message: "Please wait...", preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Close", style: .default, handler: self.onAbortClick))
        mainView.present(self.alertView, animated: true, completion: nil)
    }

    func onAbortClick(_ btn: UIAlertAction) {
        if isFinished == false {
            isFinished = true
            if let abortFunc = abortFunc {
                abortFunc()
            }
        }
    }

    func dfuInitialized(abort: @escaping () -> Void) {
        if isFinished {
            abort()
        } else {
            alertView.message = "dfu Init"
            abortFunc = abort
        }
    }

    func dfuStarted() {
        alertView.message = "dfu Start"
    }

    func dfuSuccessed() {
        alertView.message = "dfu Successed\n||||||||||||||||||||||||||||||||"
    }

    func dfuError(message: String) {
        alertView.message = "dfu Error"
    }

    func dfuProgressDidChange(progress: Int) {
        let prog = Double(progress) / (100.0 / 30.0)

        let left = String(repeating: "|", count: Int(prog))
        let right = String(repeating: ".", count: 30 - Int(prog))
        alertView.message = "progress \(progress)\n|\(left)>\(right)|"
    }
}
