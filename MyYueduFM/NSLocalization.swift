//
//  NSLocalization.swift
//  MyYueduFM
//
//  Created by apple on 16/5/13.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

func LOC(__key: String) -> String {
    if let string = NSLocalization.defaultLocalization.localizedStringForKey(__key) {
        return string
    }else {
        print("获取本地化字符串失败")
        return ""
    }
}

let LocalizationBase = "Base"
let LocalizationChinese = "zh-Hans"
let LocalizationEnglish = "en"


class NSLocalization: NSObject {
    static let defaultLocalization = NSLocalization()
    
    var boundle: NSBundle?
    
    private var _localization = ""
    var localization: String {
        get {
            return _localization
        }
        set {
            self._localization = newValue
            let path = NSBundle.mainBundle().pathForResource(newValue, ofType: "lproj")
            self.boundle = NSBundle(path: path!)
        }
    }
    
    private override init() {
        super.init()
        self.setup()
    }
    
    private func setup() {
        self.localization = LocalizationBase
    }
    
    /**
     获取指定本地化的字符串
     
     - parameter key: 字符串的键值
     
     - returns: <#return value description#>
     */
    func localizedStringForKey(key: String) -> String? {
        return self.boundle?.localizedStringForKey(key, value: nil, table: nil)
    }
}
