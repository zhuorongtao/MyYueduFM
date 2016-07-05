//
//  BaseService.swift
//  MyYueduFM
//
//  Created by apple on 16/5/12.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

enum ServiceLevel: Int {
    case Low = 0,
         Middle,
         High,
         Highest
}

class BaseService: NSObject {

    var serviceCenter: ServiceCenter
    
    required init(serviceCenter: ServiceCenter) {
        self.serviceCenter = serviceCenter
        super.init()
    }
    
    // MARK: - 本类共有方法
    class func level() -> ServiceLevel {
        return .Low
    }
    
     private struct Constance {
        static var mySubclasses: [AnyClass]?
        static var onceToken: dispatch_once_t = 0
        static var numOfClasses: UInt32 = 0
    }

    //FIXME: 如果出错, 可以参考https://gist.github.com/bnickel/410a1bdc02f12fbd9b5e和https://github.com/neonichu/xctester/blob/master/code/RuntimeExtensions.swift
    /**
     找出BaseService的所有子类
     
     - returns: <#return value description#>
     */
    class func allSubclasses() -> [AnyClass]? {
        dispatch_once(&Constance.onceToken) {
            let myClass = self.self
            Constance.mySubclasses = []
            var numOfClasses: UInt32 = 0
            let classes = objc_copyClassList(&numOfClasses)
            for ci in 0..<numOfClasses{
                var superClass: AnyClass? = classes[Int(ci)]
                repeat {
                    superClass = class_getSuperclass(superClass)
                } while (superClass != nil && superClass != myClass)//将不是本类的子类过滤掉
                
                if superClass != nil {
                    Constance.mySubclasses?.append(classes[Int(ci)]!)
                }
//                if classes.memory != nil {
//                    free(&classes.memory)
//                }
            }
        }
        return Constance.mySubclasses
    }
    
    
    class func class_getSubclasses(parentClass: AnyClass) -> [AnyClass] {
        var numClasses = objc_getClassList(nil, 0)
        
        let classes = AutoreleasingUnsafeMutablePointer<AnyClass?>(malloc(Int(sizeof(AnyClass) * Int(numClasses))))
        numClasses = objc_getClassList(classes, numClasses)
        
        var result = [AnyClass]()
        
        for i in 0..<numClasses {
            var superClass: AnyClass! = classes[Int(i)] as AnyClass!
            
            repeat {
                superClass = class_getSuperclass(superClass)
            } while (superClass != nil && NSStringFromClass(parentClass) != NSStringFromClass(superClass))
            
            if (superClass != nil) {
                result.append(classes[Int(i)]!)
            }
        }
        
        return result
    }
    
    /**
     启动服务
     */
    func start() {
        //启动服务, 子类实现
    }
    
    /**
     停止服务
     */
    func stop() {
        //停止服务, 子类实现
    }
    
    deinit {
        print("\(self.classForCoder)已销毁")
    }
    
    /**
     不带参数app跳转
     
     - parameter application: application description
     - parameter url:         url description
     
     - returns: return value description
     */
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        //app跳转
        return false
    }
    
    /**
     带参数的app跳转for微信
     
     - parameter application:       <#application description#>
     - parameter url:               <#url description#>
     - parameter sourceApplication: <#sourceApplication description#>
     - parameter annotation:        <#annotation description#>
     
     - returns: <#return value description#>
     */
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject) -> Bool {
        //app跳转带参数, 子类实现
        return false
    }
    
    // MARK: - 本类私有方法
}
