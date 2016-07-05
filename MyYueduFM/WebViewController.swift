//
//  WebViewController.swift
//  MyYueduFM
//
//  Created by apple on 16/5/24.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import DZNWebViewController
import Reachability
import SVProgressHUD

class WebViewController: DZNWebViewController {
    
    var viewDidDisappearBlock: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    class func controllerWithURL(url: NSURL?, didDisappear disappear: (() -> Void)?) -> WebViewController? {
        if let url = url {
            let webVC = WebViewController(URL: url)
            webVC.supportedWebNavigationTools = .All
            webVC.supportedWebActions = .DZNWebActionAll
            webVC.showLoadingProgress = true
            webVC.allowHistory = true
            webVC.hideBarsWithGestures = true
            webVC.viewDidDisappearBlock = disappear
            return webVC
        }else {
            return nil
        }
    }

    class func presentWithURL(url: NSURL?) {
        if let service = SRV(ReachabilityService) {
            if service.status == NetworkStatus.NotReachable {
                SVProgressHUD.showInfoWithStatus(service.statusString)
            }else {
                let hidden = PlayerBar.shareBar().forceHidden
                PlayerBar.shareBar().forceHidden = true
                let closure = {
                    if !hidden {
                        dispatch_async(dispatch_get_main_queue(), {
                            PlayerBar.shareBar().forceHidden = false
                        })
                    }
                }
                
                if let webVC = WebViewController.controllerWithURL(url, didDisappear: closure) {
                    UIViewController.topViewController().navigationController?.pushViewController(webVC, animated: true)
                }
            }
        }
    }
}
