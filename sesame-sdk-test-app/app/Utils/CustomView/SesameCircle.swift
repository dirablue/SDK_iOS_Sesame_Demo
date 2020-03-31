//
//  SesameCircle.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/11/13.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation

import SesameSDK
class SesameCircle: UIControl {
    private (set) var value: Float = 0

    var minimumValue: Float = 0
    var maximumValue: Float = 360

    private let renderer = KnobRenderer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        layer.addSublayer(renderer.trackLayer)
        layer.addSublayer(renderer.unlockImgLyer)
        renderer.updateBounds(bounds)
    }

    func setLock(_ ssm:CHSesameBleInterface)  {
        self.isHidden  = (ssm.deviceStatus.loginStatus() == .unlogin )

        guard let status = ssm.mechStatus else {
            return
        }
        let  nowDegree = Int16(status.getPosition()!)

        let isinLockrange = status.isInLockRange() ?? false

        renderer.updateunLockImg(CGFloat(angle2degree(angle: nowDegree)), isInLockrange: isinLockrange)


    }

    func angle2degree(angle: Int16) -> Float {

        var degree = Float(angle % 1024)
        degree = degree * 360 / 1024
        if degree > 0 {
            degree = 360 - degree
        } else {
            degree = abs(degree)
        }
        return degree
    }
}


private class KnobRenderer {

    let trackLayer = CAShapeLayer()
    let unlockImgLyer = CAShapeLayer()


    init() {
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor.clear.cgColor
    }

    func updateBounds(_ bounds: CGRect) {

        trackLayer.bounds = bounds
        trackLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)

        unlockImgLyer.bounds = trackLayer.bounds
        unlockImgLyer.position = trackLayer.position

        updateTrackLayerPath()

    }


    func updateunLockImg(_ newPointerAngle: CGFloat,isInLockrange:Bool) {

        let qqqq = CGFloat(Double.pi*2)  / CGFloat(360) * newPointerAngle
        let bounds = trackLayer.bounds

        let ss = sin(qqqq)
        let aa = cos(qqqq)

        let  imageW = bounds.width/10
        let  redius = bounds.width/2


        unlockImgLyer.frame = CGRect(
            x: bounds.midX - imageW/2 + redius * CGFloat(aa),
            y: bounds.midY - imageW/2 + redius * CGFloat(ss),
            width: imageW,
            height: imageW)


        unlockImgLyer.strokeColor = isInLockrange ? UIColor(rgb: 0xcc4a44).cgColor:UIColor(rgb: 0x28aeb1).cgColor
        unlockImgLyer.fillColor = isInLockrange ? UIColor(rgb: 0xcc4a44).cgColor:UIColor(rgb: 0x28aeb1).cgColor


        let bounds_ = unlockImgLyer.bounds
        let center_ = CGPoint(x: bounds_.midX, y: bounds_.midY)
        let radius_ = imageW/4
        let ring_ = UIBezierPath(arcCenter: center_, radius: radius_,
                                startAngle: 0,
                                endAngle: CGFloat(Double.pi) * 2, clockwise: true)

        unlockImgLyer.path = ring_.cgPath

    }

    private func updateTrackLayerPath() {
        let bounds = trackLayer.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2
        let ring = UIBezierPath(arcCenter: center, radius: radius,
                                startAngle: 0,
                                endAngle: CGFloat(Double.pi) * 2, clockwise: true)


        trackLayer.path = ring.cgPath
    }

}
