/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit.UIGestureRecognizerSubclass

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
class Knob: UIControl {

    /** Contains the minimum value of the receiver. */
    let justAngle = 200
    var minimumValue: Float = 0

    /** Contains the maximum value of the receiver. */
    var maximumValue: Float = 360

    /** Contains the receiver’s current value. */
    private (set) var value: Float = 0
    private (set) var lockValue: Float = 0
    private (set) var unlockValue: Float = 0

    /** Sets the receiver’s current value, allowing you to animate the change visually. */
    func setValue(_ newValue: Float, animated: Bool = false) {
        value = min(maximumValue, max(minimumValue, newValue))
        lockValue = min(maximumValue, max(minimumValue, 30))
        unlockValue = min(maximumValue, max(minimumValue, 90))

        let angleRange = endAngle - startAngle
        let valueRange = maximumValue - minimumValue

        let angleValue = CGFloat(value - minimumValue) / CGFloat(valueRange) * angleRange + startAngle

        renderer.setPointerAngle(angleValue, animated: animated )
    }
    func setLockValue(_ lockV: Float, _ unlockV: Float) {

        lockValue = min(maximumValue, max(minimumValue, lockV))
        unlockValue = min(maximumValue, max(minimumValue, unlockV))

        let angleRange = endAngle - startAngle
        let valueRange = maximumValue - minimumValue

        let angleLockValue = CGFloat(lockValue - minimumValue) / CGFloat(valueRange) * angleRange + startAngle
        let angleUnlockValue = CGFloat(unlockValue - minimumValue) / CGFloat(valueRange) * angleRange + startAngle

        renderer.setPointerLockSetting(lock: angleLockValue, unlock: angleUnlockValue)
    }

    /** Contains a Boolean value indicating whether changes
     in the sliders value generate continuous update events. */
    var isContinuous = true

    private let renderer = KnobRenderer()

    /** Specifies the width in points of the knob control track. Defaults to 2 */
    var lineWidth: CGFloat {
        get { return renderer.lineWidth }
        set { renderer.lineWidth = newValue }
    }

    /** Specifies the angle of the start of the knob control track. Defaults to -11π/8 */
    var startAngle: CGFloat {
        get { return renderer.startAngle }
        set { renderer.startAngle = newValue }
    }

    /** Specifies the end angle of the knob control track. Defaults to 3π/8 */
    var endAngle: CGFloat {
        get { return renderer.endAngle }
        set { renderer.endAngle = newValue }
    }

    /** Specifies the length in points of the pointer on the knob. Defaults to 6 */
    var pointerLength: CGFloat {
        get { return renderer.pointerLength }
        set { renderer.pointerLength = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        renderer.updateBounds(bounds)
        renderer.color = tintColor
        renderer.setPointerAngle(renderer.startAngle)
        renderer.setPointerLockSetting( lock: renderer.startAngle, unlock: renderer.startAngle)


        layer.addSublayer(renderer.trackLayer)
        layer.addSublayer(renderer.pointerLayer)
        layer.addSublayer(renderer.lockLayer)
        layer.addSublayer(renderer.unlockLayer)

    }

}

private class KnobRenderer {
     let  JA: CGFloat  = 0

    var color: UIColor = .blue {
        didSet {
            trackLayer.strokeColor = UIColor(rgb: 0x28aeb1).cgColor
            pointerLayer.strokeColor = UIColor(rgb: 0xfce15e).cgColor
            lockLayer.strokeColor = UIColor(rgb: 0xcc4a44).cgColor
            unlockLayer.strokeColor = UIColor(rgb: 0x28aeb1).cgColor

        }
    }

    var lineWidth: CGFloat = 2 {
        didSet {
            trackLayer.lineWidth = lineWidth
            pointerLayer.lineWidth = lineWidth
            lockLayer.lineWidth = lineWidth
            unlockLayer.lineWidth = lineWidth

            updateTrackLayerPath()
            updatePointerLayerPath()
        }
    }

    var startAngle: CGFloat = CGFloat(-Double.pi) * 2 {
        didSet {
            updateTrackLayerPath()
        }
    }

    var endAngle: CGFloat = CGFloat(Double.pi) * 0 {
        didSet {
            updateTrackLayerPath()
        }
    }

    var pointerLength: CGFloat = 10 {
        didSet {
            updateTrackLayerPath()
            updatePointerLayerPath()
        }
    }
    var lockPointerLength: CGFloat = 3 {
        didSet {
            updateTrackLayerPath()
            updatePointerLayerPath()
        }
    }

    private (set) var pointerAngle: CGFloat = CGFloat(-Double.pi) * 11 / 8

    func setPointerAngle(_ newPointerAngle: CGFloat, animated: Bool = false) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        pointerLayer.transform = CATransform3DMakeRotation(newPointerAngle+JA, 0, 0, 1)


        if animated {
            let midAngleValue = (max(newPointerAngle, pointerAngle) - min(newPointerAngle, pointerAngle)) / 2 + min(newPointerAngle, pointerAngle)
            let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            animation.values = [pointerAngle, midAngleValue, newPointerAngle]
            animation.keyTimes = [0.0, 0.5, 1.0]
            animation.timingFunctions = [CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)]
            pointerLayer.add(animation, forKey: nil)
        }

        pointerLayer.transform = CATransform3DMakeRotation(newPointerAngle+JA, 0, 0, 1)
        CATransaction.commit()
        pointerAngle = newPointerAngle
    }

    func setPointerLockSetting(lock: CGFloat, unlock: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        lockLayer.transform = CATransform3DMakeRotation(lock+JA, 0, 0, 1)
        unlockLayer.transform = CATransform3DMakeRotation(unlock+JA, 0, 0, 1)
        CATransaction.commit()
    }

    let trackLayer = CAShapeLayer()
    let lockLayer = CAShapeLayer()
    let unlockLayer = CAShapeLayer()
    let pointerLayer = CAShapeLayer()

    init() {
        trackLayer.fillColor = UIColor.clear.cgColor
        pointerLayer.fillColor = UIColor.clear.cgColor
        lockLayer.fillColor = UIColor.clear.cgColor
        unlockLayer.fillColor = UIColor.clear.cgColor

    }

    private func updateTrackLayerPath() {
        let bounds = trackLayer.bounds
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let offset = max(pointerLength, lineWidth  / 2)
        let radius = min(bounds.width, bounds.height) / 2 - offset

        let ring = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        trackLayer.path = ring.cgPath
    }

    private func updatePointerLayerPath() {
        let bounds = trackLayer.bounds

        let pointer = UIBezierPath()
        pointer.move(to: CGPoint(x: bounds.width - CGFloat(pointerLength) - CGFloat(lineWidth) / 2, y: bounds.midY))
        pointer.addLine(to: CGPoint(x: bounds.width, y: bounds.midY))
        pointerLayer.path = pointer.cgPath


        let pointerLock = UIBezierPath()
        pointerLock.move(to: CGPoint(x: bounds.width - CGFloat(lockPointerLength) - CGFloat(lineWidth) / 2, y: bounds.midY))
        pointerLock.addLine(to: CGPoint(x: bounds.width, y: bounds.midY))
        lockLayer.path = pointerLock.cgPath


        let pointerUnlock = UIBezierPath()
        pointerUnlock.move(to: CGPoint(x: bounds.width - CGFloat(lockPointerLength) - CGFloat(lineWidth) / 2, y: bounds.midY))
        pointerUnlock.addLine(to: CGPoint(x: bounds.width, y: bounds.midY))
        unlockLayer.path = pointerLock.cgPath

    }

    func updateBounds(_ bounds: CGRect) {
        trackLayer.bounds = bounds
        trackLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        updateTrackLayerPath()

        pointerLayer.bounds = trackLayer.bounds
        pointerLayer.position = trackLayer.position

        lockLayer.bounds = trackLayer.bounds
        lockLayer.position = trackLayer.position

        unlockLayer.bounds = trackLayer.bounds
        unlockLayer.position = trackLayer.position

        updatePointerLayerPath()
    }
}

private class RotationGestureRecognizer: UIPanGestureRecognizer {
    private(set) var touchAngle: CGFloat = 0

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        updateAngle(with: touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        updateAngle(with: touches)
    }

    private func updateAngle(with touches: Set<UITouch>) {
        guard
            let touch = touches.first,
            let view = view
            else {
                return
        }
        let touchPoint = touch.location(in: view)
        touchAngle = angle(for: touchPoint, in: view)
    }

    private func angle(for point: CGPoint, in view: UIView) -> CGFloat {
        let centerOffset = CGPoint(x: point.x - view.bounds.midX, y: point.y - view.bounds.midY)
        return atan2(centerOffset.y, centerOffset.x)
    }

    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)

        maximumNumberOfTouches = 1
        minimumNumberOfTouches = 1
    }

}
