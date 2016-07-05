//
//  NetService.swift
//  MyYueduFM
//
//  Created by apple on 16/5/13.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import YueduFMSDK

class NetService: BaseService {
    
    
    
    required init(serviceCenter: ServiceCenter) {
        super.init(serviceCenter: serviceCenter)
    }
    
    override class func level() -> ServiceLevel {
        return .Highest
    }
}

extension BaseService {
    func netManger() -> YDSDKManager {
        return YDSDKManager.defaultManager()
    }
}