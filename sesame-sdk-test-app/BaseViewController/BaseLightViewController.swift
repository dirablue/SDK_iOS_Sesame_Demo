//
//  BaseLightViewController.swift
//  sesame-sdk-test-app
//
//  Created by Yiling on 2019/09/20.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UIKit

class BaseLightViewController: UIViewController {
    override func viewDidLoad() {
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }
    }

    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
}
