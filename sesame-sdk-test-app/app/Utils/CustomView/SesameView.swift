//
//  SesameView.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/10/11.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation

import UIKit.UIGestureRecognizerSubclass
import SesameSDK
class SesameView: UIControl {
    private (set) var value: Float = 0

    var minimumValue: Float = 0
    var maximumValue: Float = 360

    private let renderer = KnobRenderer()


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        L.d("init aDecoder")

        commonInit()
    }

    private func commonInit() {
        L.d("init commonInit")

        //        backgroundColor = .black

        //        layer.addSublayer(renderer.trackLayer)
        //        layer.addSublayer(renderer.gradientLayer)

        //        layer.addSublayer(renderer.lockLayer)
        layer.addSublayer(renderer.centerBigLayer)
        layer.addSublayer(renderer.lockImgLyer)
        layer.addSublayer(renderer.unlockImgLyer)

        renderer.updateBounds(bounds)

    }

    func setLock(_ ssm:CHSesameBleInterface)  {
        guard let status = ssm.mechStatus else {
            return
        }
        let  nowDegree = Int16(status.getPosition()!)
        renderer.setPointerAngle(CGFloat(angle2degree(angle: nowDegree)))

        guard let setting = ssm.mechSetting else {
            return
        }
        let  lockDegree = Int16(setting.getLockPosition()!)
        let  unlockDegree = Int16(setting.getUnlockPosition()!)

        renderer.updateLockImg(CGFloat(angle2degree(angle: lockDegree)))
        renderer.updateunLockImg(CGFloat(angle2degree(angle: unlockDegree)))
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

    var lockPointerLength: CGFloat = 50

    let trackLayer = CAShapeLayer()
    let lockLayer = CAShapeLayer()
    let centerBigLayer = CALayer()
    let lockImgLyer = CALayer()
    let unlockImgLyer = CALayer()
    let gradientLayer = CAGradientLayer()


    init() {
        L.d("KnobRenderer init")
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor(rgb: 0x28aeb1).cgColor
        lockLayer.fillColor = UIColor.clear.cgColor
        lockLayer.strokeColor = UIColor(rgb: 0x28aeb1).cgColor
        trackLayer.lineWidth = 20
        gradientLayer.colors = [UIColor.blue.cgColor,UIColor.red.cgColor]
    }

    func updateBounds(_ bounds: CGRect) {

        trackLayer.bounds = bounds
        trackLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)

        lockLayer.bounds = bounds
        lockLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)

        centerBigLayer.bounds = bounds
        centerBigLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)

        lockImgLyer.bounds = bounds
        lockImgLyer.position = CGPoint(x: bounds.midX, y: bounds.midY)

        unlockImgLyer.bounds = bounds
        unlockImgLyer.position = CGPoint(x: bounds.midX, y: bounds.midY)

        //        gradient.bounds = bounds
        //        gradient.position = CGPoint(x: bounds.midX, y: bounds.midY)
        gradientLayer.frame = bounds
        //        gradientLayer.apply(angle: 45.0)
        //        gradientLayer.mask = trackLayer

        updateTrackLayerPath()
        updatePointerLayerPath()
        updateCentLock()
    }

    func updateLockImg(_ newPointerAngle: CGFloat) {

        let qqqq = CGFloat(Double.pi*2)  / CGFloat(360) * newPointerAngle
        let bounds = lockLayer.bounds
        let myImage = UIImage(named: "img-lock")?.cgImage

        let ss = sin(qqqq)
        let aa = cos(qqqq)

        let  imageW = bounds.width/10
        let  redius = bounds.width/2

        lockImgLyer.frame = CGRect(
            x: bounds.midX - imageW/2 + redius * CGFloat(aa) ,
            y: bounds.midY - imageW/2 + redius * CGFloat(ss),
            width: imageW,
            height: imageW)
        lockImgLyer.contents = myImage

    }
    func updateunLockImg(_ newPointerAngle: CGFloat) {

        let qqqq = CGFloat(Double.pi*2)  / CGFloat(360) * newPointerAngle
        let bounds = lockLayer.bounds
        let myImage = UIImage(named: "img-unlock")?.cgImage

        let ss = sin(qqqq)
        let aa = cos(qqqq)

        let  imageW = bounds.width/10
        let  redius = bounds.width/2

        unlockImgLyer.frame = CGRect(
            x: bounds.midX - imageW/2 + redius * CGFloat(aa) ,
            y: bounds.midY - imageW/2 + redius * CGFloat(ss),
            width: imageW,
            height: imageW)
        unlockImgLyer.contents = myImage


        //        gradientLayer.frame = bounds
        //        gradientLayer.startPoint = CGPoint(x: 0, y:lockImgLyer.frame.midY)
        //        gradientLayer.endPoint = CGPoint(x: 0,y:unlockImgLyer.frame.midY)

        L.d("gradientLayer.startPoint",gradientLayer.startPoint)
        L.d("gradientLayer.endPoint",gradientLayer.endPoint)
        gradientLayer.frame = CGRect(
            x: unlockImgLyer.frame.midX ,
            y: unlockImgLyer.frame.midY,
            width: trackLayer.frame.width,
            height: lockImgLyer.frame.midY - unlockImgLyer.frame.midY )

        gradientLayer.mask = trackLayer

    }

    private func updateCentLock() {
        let bounds = centerBigLayer.bounds
        let myImage = UIImage(named: "img-knob")?.cgImage



        let  widthRatial = CGFloat(5)/6
        let partialInd =  CGFloat(1)/2 - CGFloat(widthRatial)/2

        //        L.d("partialInd:\(partialInd), widthRatial:\(widthRatial)" )
        centerBigLayer.frame = CGRect(x:bounds.width * CGFloat(partialInd), y: bounds.width * CGFloat(partialInd), width: bounds.width * CGFloat(widthRatial), height: bounds.width * CGFloat(widthRatial))
        //         centerBigLayer.frame = CGRect(x:0, y: 0, width: bounds.width , height: bounds.width )
        centerBigLayer.contents = myImage

    }
    private func updatePointerLayerPath() {
        let bounds = lockLayer.bounds
        let pointerLock = UIBezierPath()
        pointerLock.move(to: CGPoint(x: bounds.width  - CGFloat(lockPointerLength) , y: bounds.midY))
        pointerLock.addLine(to: CGPoint(x: bounds.width, y: bounds.midY))
        lockLayer.path = pointerLock.cgPath
        lockLayer.lineWidth = 1
        lockLayer.path = pointerLock.cgPath

    }
    func setPointerAngle(_ newPointerAngle: CGFloat) {


        let ss = CGFloat(Double.pi*2)  / CGFloat(360) * newPointerAngle
        let ww = CGFloat(Double.pi*2)  / CGFloat(360) * newPointerAngle   + CGFloat(Double.pi/2)

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        lockLayer.transform = CATransform3DMakeRotation(ss, 0, 0, 1)
        centerBigLayer.transform = CATransform3DMakeRotation(ww, 0, 0, 1)

        CATransaction.commit()
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
//extension CAGradientLayer {
//    func apply(angle : Double) {
//        let x: Double! = angle / 360.0
//        let a = pow(sinf(Float(2.0 * Double.pi * ((x + 0.75) / 2.0))),2.0);
//        let b = pow(sinf(Float(2*Double.pi*((x+0.0)/2))),2);
//
//        let c = pow(sinf(Float(2*Double.pi*((x+0.25)/2))),2);
//        let d = pow(sinf(Float(2*Double.pi*((x+0.5)/2))),2);
//
//        startPoint = CGPoint(x: CGFloat(a),y:CGFloat(b))
//        endPoint = CGPoint(x: CGFloat(c),y: CGFloat(d))
//    }
//}
