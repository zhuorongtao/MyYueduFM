//
//  SettingsService.swift
//  MyYueduFM
//
//  Created by apple on 16/5/19.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class SettingsService: BaseService {
    private var _flowProtection: Bool!
    var flowProtection: Bool { //流量保护
        get {
            return _flowProtection
        }
        set {
            _flowProtection = newValue
            USER_SET_CONFIG("flowProtection", value: newValue)
        }
    }
    
    var autoCloseTimes: [Int]? //分钟
    
    var autoCloseTimer: NSTimer?
    
    private var _autoCloseLevel: Int!
    var autoCloseLevel: Int {
        get {
            return _autoCloseLevel
        }
        set {
            _autoCloseLevel = newValue
            self.autoCloseRestTime = autoCloseTimes![newValue] * 60
            
            self.autoCloseTimer?.invalidate()
            if self.autoCloseRestTime != 0 {
                self.autoCloseTimer = NSTimer.bk_scheduledTimerWithTimeInterval(1.0, block: {
                        [weak self] (timer) in
                        self?.autoCloseRestTime -= 1
                        if self?.autoCloseRestTime <= 0 {
                            self?.autoCloseLevel = 0
                            SRV(StreamerService)?.pause()
                        }
                    }, repeats: true)
            }
        }
    }
    
    dynamic var autoCloseRestTime: Int = 0 //秒
    
    override class func level() -> ServiceLevel {
        return .Highest
    }
    
    required init(serviceCenter: ServiceCenter) {
        super.init(serviceCenter: serviceCenter)
        flowProtection = true
        self.setup()
    }
    
    func setup() {
        //流量
        let value = USER_CONFIG("flowProtection")
        flowProtection = value != nil ? (value as! Bool) : true
        //自动关闭
        autoCloseTimes = [0, 10, 20, 30, 60, 120]
        //应用启动
        self.autoCloseLevel = 0
    }
}
