//
//  UIImageEX.swift
//  MyYueduFM
//
//  Created by apple on 16/5/26.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

extension UIImage {
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 2, 2)
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return theImage.resizableImageWithCapInsets(UIEdgeInsetsZero, resizingMode: .Stretch)        
    }
}