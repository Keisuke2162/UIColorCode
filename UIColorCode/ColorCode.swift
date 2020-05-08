//
//  ColorCode.swift
//  UIColorCode
//
//  Created by 植田圭祐 on 2020/05/09.
//  Copyright © 2020 Keisuke Ueda. All rights reserved.
//

import UIKit

extension UIColor {
    
    var floatValues: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r:CGFloat = -1, g:CGFloat = -1, b:CGFloat = -1, a:CGFloat = -1
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return (r, g, b, a)
    }
    
    var intValues: (red: Int, green: Int, blue: Int, alpha: Int) {
        let f = self.floatValues
        return (
            UIColor.intByCGFloat(v: f.red),
            UIColor.intByCGFloat(v: f.green),
            UIColor.intByCGFloat(v: f.blue),
            UIColor.intByCGFloat(v: f.alpha)
        )
    }
}

extension UIColor {
    
    private static let maxHex = 0xFFFFFFFF
    private static let minHex = 0x0
    
    private static let prefix = "#"
    
    private class func substring(string: String, location: Int, length: Int? = nil) -> String {
        let strlen = string.count
        var len = length ?? strlen
        if location + len > strlen {
            len = strlen - location
        }
        return (string as NSString).substring(with: NSMakeRange(location, len))
    }
    
    private class func intByCGFloat(v: CGFloat) -> Int {
        return Int(round(v * 255.0))
    }
    
    private class func hexStringByCGFloat(v: CGFloat) -> String {
        let n = self.intByCGFloat(v: v)
        return NSString(format: "%02X", n) as String
    }
}

extension UIColor {
    
    convenience init(rgb: Int) {
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >>  8) / 255.0
        let b = CGFloat( rgb & 0x0000FF       ) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    var rgb: Int {
        let i = self.intValues
        return (i.red * 0x010000) + (i.green * 0x000100) + i.blue
    }
    
    var rgbString: String {
        var r:CGFloat = -1, g:CGFloat = -1, b:CGFloat = -1, a:CGFloat = -1
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        var ret = ""
        ret += UIColor.hexStringByCGFloat(v: r)
        ret += UIColor.hexStringByCGFloat(v: g)
        ret += UIColor.hexStringByCGFloat(v: b)
        return ret
    }
}

extension UIColor {
    
    convenience init(rgba: Int) {
        let r = CGFloat((rgba & 0xFF000000) >> 24) / 255.0
        let g = CGFloat((rgba & 0x00FF0000) >> 16) / 255.0
        let b = CGFloat((rgba & 0x0000FF00) >>  8) / 255.0
        let a = CGFloat( rgba & 0x000000FF       ) / 255.0
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    var rgba: Int {
        let i = self.intValues
        return (i.red * 0x01000000) + (i.green * 0x00010000) + (i.blue *  0x00000100) + i.alpha
    }
    
    var rgbaString: String {
        var r:CGFloat = -1, g:CGFloat = -1, b:CGFloat = -1, a:CGFloat = -1
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        var ret = ""
        ret += UIColor.hexStringByCGFloat(v: r)
        ret += UIColor.hexStringByCGFloat(v: g)
        ret += UIColor.hexStringByCGFloat(v: b)
        ret += UIColor.hexStringByCGFloat(v: a)
        return ret
    }
}

extension UIColor {
    
    convenience init(colorCode: String) {
        self.init(rgba: UIColor.colorCodeToHex(colorCode: colorCode))
    }
    
    class func colorCodeToHex(colorCode: String) -> Int {
        var colorCode = colorCode
        if colorCode.hasPrefix(self.prefix) {
            colorCode = self.substring(string: colorCode, location: 1)
        }
        
        switch colorCode.count {
        case 8: // e.g. 35D24CFF
            break
        case 6: // e.g. 35D24C
            colorCode += "FF"
        case 4: // e.g. 35DF
            let r = self.substring(string: colorCode, location:0, length: 1)
            let g = self.substring(string: colorCode, location:1, length: 1)
            let b = self.substring(string: colorCode, location:2, length: 1)
            let a = self.substring(string: colorCode, location:3, length: 1)
            colorCode = "\(r)\(r)\(g)\(g)\(b)\(b)\(a)\(a)"
        case 3: // e.g. 35D
            let r = self.substring(string: colorCode, location:0, length: 1)
            let g = self.substring(string: colorCode, location:1, length: 1)
            let b = self.substring(string: colorCode, location:2, length: 1)
            colorCode = "\(r)\(r)\(g)\(g)\(b)\(b)FF"
        default: return self.minHex
        }
        
        if (colorCode as NSString).rangeOfCharacter(from: CharacterSet(charactersIn: "^[a-fA-F0-9]+$"), options: .regularExpression).location == NSNotFound {
            return self.minHex
        }
        
        
        var ret: UInt32 = 0
        Scanner(string: colorCode).scanHexInt32(&ret)
        return Int(ret)
    }
    
    class func hexToColorCode(hex: Int, withPrefix prefix: Bool = true) -> String {
        var hex = hex
        if hex > self.maxHex {
            hex = self.maxHex
        }
        
        let r = CGFloat((hex & 0xFF000000) >> 24) / 255.0
        let g = CGFloat((hex & 0x00FF0000) >> 16) / 255.0
        let b = CGFloat((hex & 0x0000FF00) >>  8) / 255.0
        let a = CGFloat( hex & 0x000000FF       ) / 255.0
        
        var ret = ""
        ret += self.hexStringByCGFloat(v: r)
        ret += self.hexStringByCGFloat(v: g)
        ret += self.hexStringByCGFloat(v: b)
        ret += self.hexStringByCGFloat(v: a)
        if prefix {
            ret = self.prefix + ret
        }
        return ret
    }
}

