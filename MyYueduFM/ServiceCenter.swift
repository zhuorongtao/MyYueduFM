//
//  ServiceCenter.swift
//  MyYueduFM
//
//  Created by apple on 16/5/12.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import Synchronized

//func serviceCompare(obj1: AnyObject, obj2: AnyObject, context: UnsafeMutablePointer<Void>) -> Int {
//    return NSComparisonResult.OrderedSame.rawValue
//}

//let __serviceCenter = ServiceCenter.defaultCenter

func SRV<T: BaseService>(__servicename: T.Type) -> T? {
    return ServiceCenter.defaultCenter.accessService(__servicename) as? T
}

class ServiceCenter: NSObject {
    static let defaultCenter = ServiceCenter()
    
    var version: String?
    private var _serviceArray: [AnyObject] = []
    
    private override init() {
        super.init()
    }
    
    // MARK: - 本类共有方法
    func setup() {
        var classes = BaseService.class_getSubclasses(BaseService)
        
        //优先级排序 大 -> 小
        classes.sortInPlace({
            ($0 as? BaseService.Type)?.level().rawValue > ($1 as? BaseService.Type)?.level().rawValue
        })
        
        synchronized(self) { 
//            if let classes = classes {
                for cls in classes {
                    let service = (cls as! BaseService.Type).init(serviceCenter: self)
                    print("\(service.classForCoder)")
                    self._serviceArray.append(service)
                }
//            }
        }
    }
    
    func teardown() {
        synchronized(self) { 
            for service in _serviceArray {
                if let service = service as? BaseService {
                    service.stop()
                }
            }
            
            _serviceArray.removeAll()
        }
    }
    
    /**
     获取服务
     
     - parameter clazz: <#clazz description#>
     
     - returns: <#return value description#>
     */
    func accessService(clazz: AnyClass) -> AnyObject? {
        return synchronized(self) { () -> AnyObject? in
            for service in _serviceArray {
//                if let service = service as? BaseService.Type {
//                    if (service.self).isKindOfClass(clazz) {
//                        
//                        return service.init(serviceCenter: self)
//                    }
//                }
                
                if service.isKindOfClass(clazz) {
                    return service
                }
            }
        print("servie nil")
            return nil
        }
    }
    
    /**
     启动服务, 用于启动所有的service服务
     */
    func startAllServices() {
        for service in _serviceArray {
            if let service = service as? BaseService {
                service.start()
            }
        }
    }
    
    /**
     关闭服务, 用于关闭所有的service服务
     */
    func stopAllServices() {
        for service in _serviceArray {
            if let service = service as? BaseService {
                service.stop()
            }
        }
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        var isHandle = false
        for service in _serviceArray {
            if let service = service as? BaseService.Type {
//                if service.application(application, handleOpenURL: url) {
//                    isHandle = true
//                }
                if accessService(service)!.application(application, handleOpenURL: url) {
                    isHandle = true
                }
            }
        }
        return isHandle
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject) -> Bool {
        var isHandle = false
        for service in _serviceArray {
            if let service = service as? BaseService.Type {
//                if service.application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation) {
//                    isHandle = true
//                }
                if accessService(service)!.application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation) {
                    isHandle = true
                }
            }
        }
        return isHandle
    }
    
    // MARK: - 本类私有方法
    
}
