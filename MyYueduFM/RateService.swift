//
//  RateService.swift
//  MyYueduFM
//
//  Created by apple on 16/5/19.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import iRate

class RateService: BaseService {
    required init(serviceCenter: ServiceCenter) {
        super.init(serviceCenter: serviceCenter)
        iRate.sharedInstance().applicationBundleID = NSBundle.mainBundle().bundleIdentifier
        iRate.sharedInstance().promptForNewVersionIfUserRated = true
    }
}
