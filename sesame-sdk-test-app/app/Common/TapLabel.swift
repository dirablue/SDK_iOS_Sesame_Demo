//
//  TapLabel.swift
//  sesame-sdk-test-app
//
//  Created by gaku on 4/9/20.
//  Copyright © 2020 CandyHouse. All rights reserved.
//

import Foundation
import UIKit

class TapLabel: UILabel {
 
    var expandTouchArea: UIEdgeInsets = .zero
    private var handler: (() -> ())?
 
    override func awakeFromNib() {
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapLabel(sender:))))
    }
 
//    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
//        var rect = bounds
//        rect.origin.x -= self.expandMargin.left
//        rect.origin.y -= self.expandMargin.top
//        rect.size.width += self.expandMargin.left + self.expandMargin.right
//        rect.size.height += self.expandMargin.top + self.expandMargin.bottom
//        return rect.contains(point)
//    }
 
    @objc private func tapLabel(sender: UITapGestureRecognizer) {
        self.handler?()
    }
 
    func tapLabelHandler(completion: @escaping (() -> ())) {
        self.handler = completion
    }
 
}

