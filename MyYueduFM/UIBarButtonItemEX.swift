//
//  UIBarButtonItemEX.swift
//  MyYueduFM
//
//  Created by apple on 16/5/27.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

extension UIBarButtonItem {
    class func itemWithImage(image: UIImage, action: (() -> Void)?) -> UIBarButtonItem {
        let button = UIButton(frame: CGRectMake(0, 0, 32, 32))
        button.setImage(image, forState: .Normal)
        button.bk_addEventHandler({ (sender) in
            action?()
            }, forControlEvents: .TouchUpInside)
        return UIBarButtonItem(customView: button)
    }
}