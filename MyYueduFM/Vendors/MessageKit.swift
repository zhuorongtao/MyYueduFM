//
//  MessageKit.swift
//  MyYueduFM
//
//  Created by apple on 16/5/13.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import RESideMenu

class MessageKit: NSObject {
    
    class func topViewController() -> UIViewController? {
        var vc = UIApplication.sharedApplication().delegate!.window??.rootViewController
        while true {
            if vc!.isKindOfClass(UINavigationController.self) {
                vc = (vc as? UINavigationController)?.topViewController
                continue
            }else if vc!.isKindOfClass(RESideMenu.self) {
                vc = (vc as? RESideMenu)?.contentViewController
                continue
            }
            break
        }
        return vc
    }
    
    class func showWithSuccessedMessage(message: String) {
        self.topViewController()?.showWithSuccessedMessage(message)
    }
    
    class func showWithFailedMessage(message: String) {
        self.topViewController()?.showWithFailedMessage(message)
    }
}
