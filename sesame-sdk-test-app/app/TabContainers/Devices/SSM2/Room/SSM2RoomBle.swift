//
//  SSM2RoomBle.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/10/17.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import UIKit
import SesameSDK
import CoreBluetooth



extension SSM2RoomMainVC{

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        let rightButtonItem = UIBarButtonItem(image: UIImage.SVGImage(named: isDarkMode() ? "icons_filled_more_b":"icons_filled_more"), style: .done, target: self, action: #selector(handleRightBarButtonTapped(_:)))
        navigationItem.rightBarButtonItem = rightButtonItem
    }
}

extension SSM2RoomMainVC {
    @objc private func handleRightBarButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier:  "setting", sender: sesame)
    }
    @objc private func handleLeftBarButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
