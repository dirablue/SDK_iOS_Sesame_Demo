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
    weak var view: BaseViewController?
    var alertView: UIAlertController
    var abortFunc: (() -> Void)?
    var isFinished: Bool = false
    var callBack:(_ from:String)->Void = {from in
        L.d("test 閉包")
    }

    init(_ mainView: BaseViewController , callBack :@escaping (_ from:String)->Void ) {
        self.callBack =  callBack
        self.view = mainView
        abortFunc = nil
        alertView = UIAlertController(title: "SesameOS Update".localStr, message: "Starting soon…".localStr, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Close".localStr, style: .default, handler: self.onAbortClick))

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
            alertView.message = "Initializing…".localStr
            abortFunc = abort
        }
    }

    func dfuStarted() {
        alertView.message = "Start".localStr
    }

    func dfuSuccessed() {
        alertView.message = "Succeeded".localStr
        //        alertView.dismiss(animated: true, completion: nil)
        callBack("Successed")
    }

    func dfuError(message: String) {
        alertView.message =  "Error".localStr + ":" + message 
    }

    func dfuProgressDidChange(progress: Int) {
        alertView.message = "\(progress)%"
    }
}
