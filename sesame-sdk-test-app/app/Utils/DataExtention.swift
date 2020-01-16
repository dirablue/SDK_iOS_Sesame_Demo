//
//  DataExtention.swift
//  sesame-sdk
//
//  Created by tse on 2019/8/6.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import Foundation
import UIKit
extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

    var bytes: Array<UInt8> {
        return data(using: String.Encoding.utf8, allowLossyConversion: true)?.bytes ?? Array(utf8)
    }
    var localStr: String{
        return NSLocalizedString(self, comment: "")
    }
    
}


extension Array {
    init(reserveCapacity: Int) {
        self = []
        self.reserveCapacity(reserveCapacity)
    }

    var slice: ArraySlice<Element> {
        return self[self.startIndex ..< self.endIndex]
    }
}


extension Array where Element == UInt8 {
    init(hex: String) {
        self.init(reserveCapacity: hex.unicodeScalars.lazy.underestimatedCount)
        var buffer: UInt8?
        var skip = hex.hasPrefix("0x") ? 2 : 0
        for char in hex.unicodeScalars.lazy {
            guard skip == 0 else {
                skip -= 1
                continue
            }
            guard char.value >= 48 && char.value <= 102 else {
                removeAll()
                return
            }
            let v: UInt8
            let c: UInt8 = UInt8(char.value)
            switch c {
            case let c where c <= 57:
                v = c - 48
            case let c where c >= 65 && c <= 70:
                v = c - 55
            case let c where c >= 97:
                v = c - 87
            default:
                removeAll()
                return
            }
            if let b = buffer {
                append(b << 4 | v)
                buffer = nil
            } else {
                buffer = v
            }
        }
        if let b = buffer {
            append(b)
        }
    }

    func toHexString() -> String {
        return `lazy`.reduce("") {
            var s = String($1, radix: 16)
            if s.count == 1 {
                s = "0" + s
            }
            return $0 + s
        }
    }

    func toBase64() -> String? {
        return Data( self).base64EncodedString()
    }

    init(base64: String) {
        self.init()

        guard let decodedData = Data(base64Encoded: base64) else {
            return
        }

        append(contentsOf: decodedData.bytes)
    }
}


extension Data {
    init(hex: String) {
        self.init(Array<UInt8>(hex: hex))
    }

    var bytes: Array<UInt8> {
        return Array(self)
    }

    func toHexString() -> String {
        return bytes.toHexString()
    }

    private func unpackValue<T: FixedWidthInteger>() -> T {
        return self.withUnsafeBytes {
            return $0.baseAddress!.assumingMemoryBound(to: T.self).withMemoryRebound(to: T.self, capacity: 0) {
                return $0.pointee
            }
        }
    }

    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    //    func hexEncodedString(options: HexEncodingOptions = []) -> String {
    //        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
    //        return map { String(format: format, $0) }.joined()
    //    }

    var uint16: UInt16 {
        return self.unpackValue()
    }

    var uint8: UInt8 {
        return self.unpackValue()
    }

    var uint32: UInt32 {
        return self.unpackValue()
    }

    func getValue<T>(offset: Int, initialValue: T) -> T? {

        var data: T     = initialValue
        let itemSize    = MemoryLayout.size(ofValue: data)

        let maxOffset = count - itemSize
        guard Range(0...maxOffset).contains(offset) else {
            return nil
        }

        let nsdata = self as NSData

        nsdata.getBytes(&data, range: NSRange(location: offset, length: itemSize))

        return data
    }
}

extension UInt8 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt8>.size)
    }
}

extension UInt16 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt16>.size)
    }
}

extension UnicodeScalar {
    var hexNibble: UInt8 {
        let value = self.value
        if 48 <= value && value <= 57 {
            return UInt8(value - 48)
        } else if 65 <= value && value <= 70 {
            return UInt8(value - 55)
        } else if 97 <= value && value <= 102 {
            return UInt8(value - 87)
        }
        fatalError("\(self) not a legal hex nibble")
    }
}

class L {
    static func d(_ items: Any..., file: String = #file, function: String = #function,
                  line: Int = #line, tag: String = "hcia") {
        
        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let ismain  = (Thread.isMainThread)
        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "mm:ss.SSSS"
        //        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSS"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.string(from: Date())
        print(dateFormatter.string(from: Date()),"\(fileName):\(line):", items ,ismain ? "主":"副")
        #endif
    }
}
extension UInt32 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt32>.size)
    }

    var byteArrayLittleEndian: [UInt8] {
        return [
            UInt8((self & 0xFF000000) >> 24),
            UInt8((self & 0x00FF0000) >> 16),
            UInt8((self & 0x0000FF00) >> 8),
            UInt8(self & 0x000000FF)
        ]
    }
}
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
    class func rgba(red: Int, green: Int, blue: Int, alpha: CGFloat) -> UIColor{
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
}
extension URL {

    func queryItemAdded(name: String,  value: String?) -> URL? {
        return self.queryItemsAdded([URLQueryItem(name: name, value: value)])
    }

    func getQuery(name:String) -> String {
        let components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        let value = components?.queryItems?.filter({
            return $0.name == name
        })
        return value?.first?.value ?? "NOdata"

    }

    func queryItemsAdded(_ queryItems: [URLQueryItem]) -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: nil != self.baseURL) else {
            return nil
        }
        components.queryItems = queryItems + (components.queryItems ?? [])
        return components.url
    }
}
