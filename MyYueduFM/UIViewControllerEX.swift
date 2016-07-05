//
//  UIViewControllerEX.swift
//  MyYueduFM
//
//  Created by apple on 16/5/24.
//  Copyright © 2016年 apple. All rights reserved.
//

import Foundation
import UIKit
import DZNWebViewController
import RESideMenu

extension UIViewController {
    class func topViewController() -> UIViewController {
        var vc = UIApplication.sharedApplication().delegate?.window??.rootViewController
        while true {
            if vc!.isKindOfClass(UINavigationController.self) {
                vc = (vc as! UINavigationController).topViewController
                continue
            }else if vc!.isKindOfClass(RESideMenu.self) {
                vc = (vc as! RESideMenu).contentViewController
                continue
            }
            break
        }
        return vc!
    }
    
    class func showActivityWithURL(url: NSURL?, completion: (() -> Void)?) {
        self.topViewController().showActivityWithURL(url, completion: completion)
    }
    
    func showActivityWithURL(url: NSURL?, completion: (() -> Void)?) {
        if let url = url {
            let activityItems = [url]
            let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            activityVC.excludedActivityTypes = [
                UIActivityTypePrint,
                UIActivityTypeAssignToContact,
                UIActivityTypeSaveToCameraRoll,
                UIActivityTypeAddToReadingList,
                UIActivityTypePostToFlickr,
                UIActivityTypePostToVimeo
            ]
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
}