//
//  YueduFM+Define.swift
//  MyYueduFM
//
//  Created by apple on 16/5/12.
//  Copyright © 2016年 apple. All rights reserved.
//

import Foundation
import UIKit

func RGBA(R: CGFloat, G: CGFloat, B: CGFloat, A: CGFloat) -> UIColor {
    return UIColor(red: R / 255.0, green: G / 255.0, blue: B / 255.0, alpha: A)
}

func RGB(R: CGFloat, G: CGFloat, B: CGFloat) -> UIColor {
    return RGBA(R, G: G, B: B, A: 1)
}

func RGBHex(RGB: String) -> UIColor {
    return UIColor.colorWithHexString(RGB)
}

/// 主题颜色
let kThemeColor = RGB(0, G: 189, B: 238)

func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: String) -> Bool {
    return (UIDevice.currentDevice().systemVersion as NSString).compare(version, options: .NumericSearch) != .OrderedAscending
}

func USER_SET_CONFIG(key: String, value: AnyObject) {
    NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
}

func USER_CONFIG(key: String) -> AnyObject? {
    return NSUserDefaults.standardUserDefaults().objectForKey(key)
}

func SCREEN_SIZE() -> CGSize {
    return UIScreen.mainScreen().bounds.size
}