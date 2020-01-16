//
//  ScanView.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2020/1/6.
//  Copyright © 2020 Cerberus. All rights reserved.
//

import UIKit
public class ScanView: UIView {

    /// 扫描动画图片
    lazy var scanAnimationImage = UIImage()

    /// 扫描样式
    public lazy var scanAnimationStyle = ScanAnimationStyle.default

    /// 边角位置，默认与边框线同中心点
    public lazy var cornerLocation = CornerLocation.default

    /// 边框线颜色，默认白色
    public lazy var borderColor = UIColor.white

    /// 边框线宽度，默认0.2
    public lazy var borderLineWidth:CGFloat = 0.2

    /// 边角颜色，默认红色
    public lazy var cornerColor = Colors.tintColor

    /// 边角宽度，默认2.0
    public lazy var cornerWidth:CGFloat = 2.0

    /// 扫描区周边颜色的 alpha 值，默认 0.6
    public lazy var backgroundAlpha:CGFloat = 0.6


    /// 扫描区的宽度跟屏幕宽度的比
    public lazy var scanBorderWidthRadio:CGFloat = 0.6

    /// 扫描区的宽度
    lazy var scanBorderWidth = scanBorderWidthRadio * screenWidth

    lazy var scanBorderHeight = scanBorderWidth

    /// 扫描区的x值
    lazy var scanBorderX = 0.5 * (1 - scanBorderWidthRadio) * screenWidth

    /// 扫描区的y值
    lazy var scanBorderY = 0.4 * (screenHeight - scanBorderWidth)

    lazy var contentView = UIView(frame: CGRect(x: scanBorderX, y: scanBorderY, width: scanBorderWidth, height:scanBorderHeight))

    // 提示文字
    public lazy var tips = ""

    override public init(frame: CGRect) {

        super.init(frame: frame)

        backgroundColor = .clear

    }
    required init?(coder aDecoder: NSCoder) {
          super.init(coder: aDecoder)
      }
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }


    override public func draw(_ rect: CGRect) {

        super.draw(rect)

        drawScan(rect)

        var rect:CGRect?

        let imageView = UIImageView(image: scanAnimationImage.changeColor(cornerColor))

        if scanAnimationStyle == .default {
            rect = CGRect(x: 0 , y: -(12 + 20), width: scanBorderWidth , height: 12)

        }else{
            rect = CGRect(x: 0, y: -(scanBorderHeight + 20), width: scanBorderWidth, height:scanBorderHeight)
        }

        contentView.backgroundColor = .clear

        contentView.clipsToBounds = true

        addSubview(contentView)

        ScanAnimation.shared.startWith(rect!, contentView, imageView: imageView)

        setupTips()

    }

}

class ScanAnimation:NSObject{

    static let shared:ScanAnimation = {

        let instance = ScanAnimation()

        return instance
    }()

    lazy var animationImageView = UIImageView()

    var displayLink:CADisplayLink?

    var tempFrame:CGRect?

    var contentHeight:CGFloat?

    func startWith(_ rect:CGRect, _ parentView:UIView, imageView:UIImageView) {

        tempFrame = rect

        imageView.frame = tempFrame ?? CGRect.zero

        animationImageView = imageView

        contentHeight = parentView.bounds.height

        parentView.addSubview(imageView)

        setupDisplayLink()

    }


    @objc func animation() {

        if animationImageView.frame.maxY > contentHeight! + 20 {
            animationImageView.frame = tempFrame ?? CGRect.zero
        }

        animationImageView.transform = CGAffineTransform(translationX: 0, y: 2).concatenating(animationImageView.transform)

    }


    func setupDisplayLink() {

        displayLink = CADisplayLink(target: self, selector: #selector(animation))

        displayLink?.add(to: .current, forMode: .common)

        displayLink?.isPaused = true

    }


    func startAnimation() {

        displayLink?.isPaused = false

    }


    func stopAnimation() {

        displayLink?.invalidate()

        displayLink = nil

    }

}


// MARK: - CustomMethod
extension ScanView{


    func setupTips() {

        if tips == "" {
            return
        }

        let tipsLbl = UILabel.init()

        tipsLbl.text = tips

        tipsLbl.textColor = .white

        tipsLbl.textAlignment = .center

        tipsLbl.font = UIFont.systemFont(ofSize: 13)

        addSubview(tipsLbl)

        tipsLbl.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([tipsLbl.centerXAnchor.constraint(equalTo: self.centerXAnchor),tipsLbl.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 20),tipsLbl.widthAnchor.constraint(equalToConstant: screenWidth),tipsLbl.heightAnchor.constraint(equalToConstant: 14)])

    }


    func startAnimation() {

        ScanAnimation.shared.startAnimation()

    }

    func stopAnimation() {
        ScanAnimation.shared.stopAnimation()
    }


    func drawScan(_ rect: CGRect) {

        UIColor.black.withAlphaComponent(backgroundAlpha).setFill()

        UIRectFill(rect)

        let context = UIGraphicsGetCurrentContext()

        context?.setBlendMode(.destinationOut)

        let bezierPath = UIBezierPath(rect: CGRect(x: scanBorderX + 0.5 * borderLineWidth, y: scanBorderY + 0.5 * borderLineWidth, width: scanBorderWidth - borderLineWidth, height: scanBorderHeight - borderLineWidth))

        bezierPath.fill()

        // 执行混合模式
        context?.setBlendMode(.normal)

        /// 边框设置
        let borderPath = UIBezierPath(rect: CGRect(x: scanBorderX, y: scanBorderY, width: scanBorderWidth, height: scanBorderHeight))

        borderPath.lineCapStyle = .butt

        borderPath.lineWidth = borderLineWidth

        borderColor.set()

        borderPath.stroke()

        //角标长度
        let cornerLenght:CGFloat = 20

        let insideExcess = 0.5 * (cornerWidth - borderLineWidth)

        let outsideExcess = 0.5 * (cornerWidth + borderLineWidth)

        /// 左上角角标
        let leftTopPath = UIBezierPath()

        leftTopPath.lineWidth = cornerWidth

        cornerColor.set()

        if cornerLocation == .inside {

            leftTopPath.move(to: CGPoint(x: scanBorderX + insideExcess, y: scanBorderY + cornerLenght + insideExcess))

            leftTopPath.addLine(to: CGPoint(x: scanBorderX + insideExcess, y: scanBorderY + insideExcess))

            leftTopPath.addLine(to: CGPoint(x: scanBorderX + cornerLenght + insideExcess, y: scanBorderY + insideExcess))

        }else if cornerLocation == .outside{

            leftTopPath.move(to: CGPoint(x: scanBorderX - outsideExcess, y: scanBorderY + cornerLenght - outsideExcess))

            leftTopPath.addLine(to: CGPoint(x: scanBorderX - outsideExcess, y: scanBorderY - outsideExcess))

            leftTopPath.addLine(to: CGPoint(x: scanBorderX + cornerLenght - outsideExcess, y: scanBorderY - outsideExcess))

        }else{

            leftTopPath.move(to: CGPoint(x: scanBorderX, y: scanBorderY + cornerLenght))

            leftTopPath.addLine(to: CGPoint(x: scanBorderX, y: scanBorderY))

            leftTopPath.addLine(to: CGPoint(x: scanBorderX + cornerLenght, y: scanBorderY))

        }

        leftTopPath.stroke()

        /// 左下角角标
        let leftBottomPath = UIBezierPath()

        leftBottomPath.lineWidth = cornerWidth

        cornerColor.set()

        if cornerLocation == .inside {

            leftBottomPath.move(to: CGPoint(x: scanBorderX + cornerLenght + insideExcess, y: scanBorderY + scanBorderHeight - insideExcess))

            leftBottomPath.addLine(to: CGPoint(x: scanBorderX + insideExcess, y: scanBorderY + scanBorderHeight - insideExcess))

            leftBottomPath.addLine(to: CGPoint(x: scanBorderX +  insideExcess, y: scanBorderY + scanBorderHeight - cornerLenght - insideExcess))

        }else if cornerLocation == .outside{

            leftBottomPath.move(to: CGPoint(x: scanBorderX + cornerLenght - outsideExcess, y: scanBorderY + scanBorderHeight + outsideExcess))

            leftBottomPath.addLine(to: CGPoint(x: scanBorderX - outsideExcess, y: scanBorderY + scanBorderHeight + outsideExcess))

            leftBottomPath.addLine(to: CGPoint(x: scanBorderX - outsideExcess, y: scanBorderY + scanBorderHeight - cornerLenght + outsideExcess))

        }else{

            leftBottomPath.move(to: CGPoint(x: scanBorderX + cornerLenght, y: scanBorderY + scanBorderHeight))

            leftBottomPath.addLine(to: CGPoint(x: scanBorderX, y: scanBorderY + scanBorderHeight))

            leftBottomPath.addLine(to: CGPoint(x: scanBorderX, y: scanBorderY + scanBorderHeight - cornerLenght))

        }

        leftBottomPath.stroke()

        /// 右上角小图标
        let rightTopPath = UIBezierPath()

        rightTopPath.lineWidth = cornerWidth

        cornerColor.set()

        if cornerLocation == .inside {

            rightTopPath.move(to: CGPoint(x: scanBorderX + scanBorderWidth - cornerLenght - insideExcess, y: scanBorderY + insideExcess))

            rightTopPath.addLine(to: CGPoint(x: scanBorderX + scanBorderWidth - insideExcess, y: scanBorderY + insideExcess))

            rightTopPath.addLine(to: CGPoint(x: scanBorderX + scanBorderWidth - insideExcess, y: scanBorderY + cornerLenght + insideExcess))

        } else if cornerLocation == .outside {

            rightTopPath.move(to: CGPoint(x: scanBorderX + scanBorderWidth - cornerLenght + outsideExcess, y: scanBorderY - outsideExcess))

            rightTopPath.addLine(to: CGPoint(x: scanBorderX + scanBorderWidth + outsideExcess, y: scanBorderY - outsideExcess))

            rightTopPath.addLine(to: CGPoint(x: scanBorderX + scanBorderWidth + outsideExcess, y: scanBorderY + cornerLenght - outsideExcess))

        } else {

            rightTopPath.move(to: CGPoint(x: scanBorderX + scanBorderWidth - cornerLenght, y: scanBorderY))

            rightTopPath.addLine(to: CGPoint(x: scanBorderX + scanBorderWidth, y: scanBorderY))

            rightTopPath.addLine(to: CGPoint(x: scanBorderX + scanBorderWidth, y: scanBorderY + cornerLenght))

        }

        rightTopPath.stroke()

        /// 右下角小图标
        let rightBottomPath = UIBezierPath()

        rightBottomPath.lineWidth = cornerWidth

        cornerColor.set()

        if cornerLocation == .inside {

            rightBottomPath.move(to: CGPoint(x: scanBorderX + scanBorderWidth - insideExcess, y: scanBorderY + scanBorderHeight - cornerLenght - insideExcess))

            rightBottomPath.addLine(to: CGPoint(x: scanBorderX + scanBorderWidth - insideExcess, y: scanBorderY + scanBorderHeight - insideExcess))

            rightBottomPath.addLine(to: CGPoint(x: scanBorderX + scanBorderWidth - cornerLenght - insideExcess, y: scanBorderY + scanBorderHeight - insideExcess))

        } else if cornerLocation == .outside {

            rightBottomPath.move(to: CGPoint(x: scanBorderX + scanBorderWidth + outsideExcess, y: scanBorderY + scanBorderHeight - cornerLenght + outsideExcess))

            rightBottomPath.addLine(to: CGPoint(x: scanBorderX + scanBorderWidth + outsideExcess, y: scanBorderY + scanBorderHeight + outsideExcess))

            rightBottomPath.addLine(to: CGPoint(x: scanBorderX + scanBorderWidth - cornerLenght + outsideExcess, y: scanBorderY + scanBorderHeight + outsideExcess))

        } else {

            rightBottomPath.move(to: CGPoint(x: scanBorderX + scanBorderWidth, y: scanBorderY + scanBorderHeight - cornerLenght))

            rightBottomPath.addLine(to: CGPoint(x: scanBorderX + scanBorderWidth, y: scanBorderY + scanBorderHeight))

            rightBottomPath.addLine(to: CGPoint(x: scanBorderX + scanBorderWidth - cornerLenght, y: scanBorderY + scanBorderHeight))

        }

        rightBottomPath.stroke()


    }

}
public enum ScanAnimationStyle {
    case `default`
    case grid
}
public enum CornerLocation {
    case `default`
    case inside
    case outside
}
extension UIImage{

    public func changeColor(_ color : UIColor) -> UIImage{

        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)

        color.setFill()

        let bounds = CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height)

        UIRectFill(bounds)

        self.draw(in: bounds, blendMode: CGBlendMode.destinationIn, alpha: 1.0)

        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let image = tintedImage else {
            return UIImage()
        }

        return image
    }
//    func generateQRCode(from string: String) -> UIImage? {
//        let data = string.data(using: String.Encoding.ascii)
//
//        if let filter = CIFilter(name: "CIQRCodeGenerator") {
//            filter.setValue(data, forKey: "inputMessage")
//            let transform = CGAffineTransform(scaleX: 3, y: 3)
//
//            if let output = filter.outputImage?.transformed(by: transform) {
//                return UIImage(ciImage: output)
//            }
//        }
//        return nil
//    }

    public class func generateQRCode(_ text: String,_ fillImage:UIImage? = nil, _ color:UIColor? = nil) -> UIImage? {

        guard let data = text.data(using: .utf8) else {
            return nil
        }

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")

            // value = @"L/M/Q/H"
            filter.setValue("H", forKey: "inputCorrectionLevel")

            guard let outPutImage = filter.outputImage else {
                return nil
            }

//            let colorFilter = CIFilter(name: "CIFalseColor", parameters: ["inputImage":outPutImage,"inputColor0":CIColor(cgColor: color?.cgColor ?? UIColor.black.cgColor),"inputColor1":CIColor(cgColor: UIColor.clear.cgColor)])
//
//            guard let newOutPutImage = colorFilter?.outputImage else {
//                return nil
//            }

            let scale = screenWidth/outPutImage.extent.width

            let transform = CGAffineTransform(scaleX: scale, y: scale)

            let output = outPutImage.transformed(by: transform)

            let QRCodeImage = UIImage(ciImage: output)

            guard let fillImage = fillImage else {
                return QRCodeImage
            }

            let imageSize = QRCodeImage.size

            UIGraphicsBeginImageContext(imageSize)

            QRCodeImage.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))

            let fillRect = CGRect(x: (screenWidth - screenWidth/5)/2, y: (screenWidth - screenWidth/5)/2, width: screenWidth/5, height: screenWidth/5)

            fillImage.draw(in: fillRect)

            guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return QRCodeImage }

            UIGraphicsEndImageContext()

            return newImage

        }

        return nil

    }


    public class func generateCode128(_ text:String, _ size:CGSize,_ color:UIColor? = nil ) -> UIImage?
    {
        guard let data = text.data(using: .utf8) else {
            return nil
        }

        if let filter = CIFilter(name: "CICode128BarcodeGenerator") {

            filter.setDefaults()

            filter.setValue(data, forKey: "inputMessage")

            guard let outPutImage = filter.outputImage else {
                return nil
            }

            let colorFilter = CIFilter(name: "CIFalseColor", parameters: ["inputImage":outPutImage,"inputColor0":CIColor(cgColor: color?.cgColor ?? UIColor.black.cgColor),"inputColor1":CIColor(cgColor: UIColor.clear.cgColor)])

            guard let newOutPutImage = colorFilter?.outputImage else {
                return nil
            }

            let scaleX:CGFloat = size.width/newOutPutImage.extent.width

            let scaleY:CGFloat = size.height/newOutPutImage.extent.height

            let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)

            let output = newOutPutImage.transformed(by: transform)

            let barCodeImage = UIImage(ciImage: output)

            return barCodeImage

        }

        return nil
    }

}

let screenWidth = UIScreen.main.bounds.width

let screenHeight = UIScreen.main.bounds.height

let statusHeight = UIApplication.shared.statusBarFrame.height


