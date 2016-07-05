//
//  StringEX.swift
//  MyYueduFM
//
//  Created by apple on 16/5/16.
//  Copyright © 2016年 apple. All rights reserved.
//

import Foundation
import UIKit

extension String {
    var url: NSURL? {
        return NSURL(string: self)
    }
    
    var fileURL: NSURL {
        return NSURL(fileURLWithPath: self)
    }
    
    var stringByDeletingPathExtension: String {
        return (self as NSString).stringByDeletingPathExtension
    }
    
    static func stringWithFileSize(size: Double) -> String {
        var i = 0
        var tempLength = 0.0
        let formatString = ["%.0lfB", "%.1lfKB", "%.1lfMB", ".2lfGB", "%.2lfTB"]
        tempLength = size
        while tempLength >= 1024 && i < 4 {
            tempLength /= 1024.0
            i += 1
        }
        return String(format: formatString[i], tempLength)
    }
    
    static func stringWithSeconds(seconds: Int32) -> String {
        var tempSeconds = seconds
        
        if tempSeconds < 0 {
            tempSeconds = 0
        }
        
        let s = tempSeconds % 60 //秒数
        let min = tempSeconds / 60
        let m = min % 60
        let h = min / 60 //小时
        
        var str: String = ""
        if h > 0 {
            str = String(format: "%d:%02d:%02d", arguments: [h, m, s])
        }else {
            str = String(format: "%d:%02d", arguments: [m, s])
        }
        
        return str
        
    }
    
    static func fullStringWithSeconds(seconds: Int) -> String {
        var secondsTemp = seconds
        
        if seconds < 0 {
            secondsTemp = 0
        }
        
        let s = secondsTemp % 60
        let min = secondsTemp / 60
        let m = min % 60
        let h = min / 60
        
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
    
}