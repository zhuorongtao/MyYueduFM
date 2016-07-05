//
//  AnalyticsService.swift
//  MyYueduFM
//
//  Created by apple on 16/5/19.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

enum AnalyticsEventId: Int {
    case None = 0,
         Download,
         Favor
}

class AnalyticsService: BaseService {
    required init(serviceCenter: ServiceCenter) {
        super.init(serviceCenter: serviceCenter)
        MobClick.startWithAppkey("568a1c6de0f55a78440001e5", reportPolicy: BATCH, channelId: nil)
    }
    
    func sendWithEventId(eventId: AnalyticsEventId) {
        MobClick.event("\(eventId.rawValue)")
    }
}
