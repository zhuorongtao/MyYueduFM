//
//  UIColorEX.swift
//  MyYueduFM
//
//  Created by apple on 16/5/26.
//  Copyright © 2016年 apple. All rights reserved.
//
import UIKit

extension UIColor {
    class func colorWithHexString(hex: String) -> UIColor {
        //去掉前后空格换行符
        var cStr = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        if cStr.characters.count < 6 {
            return UIColor.whiteColor()
        }
        
        if cStr.hasPrefix("0X") {
            if let range = cStr.rangeOfString("0X") {
                cStr = cStr.substringFromIndex(range.endIndex)
            }
        }else if cStr.hasPrefix("#") {
            if let range = cStr.rangeOfString("#") {
                cStr = cStr.substringFromIndex(range.startIndex.advancedBy(1))
            }
        }
        
        if cStr.characters.count != 6 {
            return UIColor.whiteColor()
        }
        
        // Separate into r, g, b substrings
        let cStrStartIndex = cStr.startIndex
        let rStr = cStr.substringWithRange(cStrStartIndex..<cStrStartIndex.advancedBy(2))
        let gStr = cStr.substringWithRange(cStrStartIndex.advancedBy(2)..<cStrStartIndex.advancedBy(4))
        let bStr = cStr.substringWithRange(cStrStartIndex.advancedBy(4)..<cStrStartIndex.advancedBy(6))
        
        var r: CUnsignedInt = 0
        var g: CUnsignedInt = 0
        var b: CUnsignedInt = 0
        
        NSScanner(string: rStr).scanHexInt(&r)
        NSScanner(string: gStr).scanHexInt(&g)
        NSScanner(string: bStr).scanHexInt(&b)
        
        return UIColor(red: CGFloat(Float(r) / 255.0), green: CGFloat(Float(g) / 255.0), blue: CGFloat(Float(b) / 255.0), alpha: 1)
    }
    
    class var colors: [UIColor] {
        return [
            RGBHex("#A0F4B2"),
            RGBHex("#9FF2F4"),
            RGBHex("#A5CAF7"),
            RGBHex("#A3B2F6"),
            RGBHex("#EEE2AA"),
            RGBHex("#DECC85"),
            RGBHex("#BEC3C7"),
            RGBHex("#F4C600"),
            RGBHex("#EA7E00"),
            RGBHex("#B8BC00"),
            RGBHex("#75C5D6"),
            RGBHex("#306056")
        ]
    }
    
}