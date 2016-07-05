//
//  ReachabilityService.swift
//  MyYueduFM
//
//  Created by apple on 16/5/16.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import Reachability
import SVProgressHUD

class ReachabilityService: BaseService {
    
    private struct onceTemp {
        static var instance: ReachabilityService?
        static var once: dispatch_once_t = 0
    }
    
    class func defaultService() -> ReachabilityService {
        dispatch_once(&onceTemp.once) { 
            onceTemp.instance = ReachabilityService(serviceCenter: ServiceCenter.defaultCenter)
        }
        return onceTemp.instance!
    }
    
    dynamic var status: NetworkStatus
    var statusString: String {
        get {
            switch self.status {
            case .NotReachable:
                return LOC("network_none_prompt")
            case .ReachableViaWiFi:
                return LOC("network_wifi_prompt")
            case .ReachableViaWWAN:
                return LOC("network_wwlan_prompt")
            }
        }
    }
    
    private var _reach: Reachability?
    
    override class func level() -> ServiceLevel {
        return .Highest
    }
    
//    static let shareInstance: ReachabilityService = ReachabilityService(serviceCenter: ServiceCenter.defaultCenter)
    
    required init(serviceCenter: ServiceCenter) {
        _reach = Reachability.reachabilityForInternetConnection()
        _reach?.startNotifier()
        self.status = (_reach?.currentReachabilityStatus())!
        
        super.init(serviceCenter: serviceCenter)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ReachabilityService.reachabilityChangedNotification(_:)), name: kReachabilityChangedNotification, object: nil)
    }
    
    func reachabilityChangedNotification(notification: NSNotification) {
        let reach = notification.object as? Reachability
        self.status = reach!.currentReachabilityStatus()
        
        dispatch_async(dispatch_get_main_queue()) { 
            SVProgressHUD.showInfoWithStatus(self.statusString)
        }
    }
    
}
