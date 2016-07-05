//
//  ConfigService.swift
//  MyYueduFM
//
//  Created by apple on 16/5/13.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import YueduFMSDK

class ConfigService: BaseService {
        
    var config: YDSDKConfigModelEx?
    var isConfiged: Bool = false
    private var blockArray: NSMutableArray
    
    override class func level() -> ServiceLevel {
        return .High
    }
    
    required init(serviceCenter: ServiceCenter) {
        self.blockArray = NSMutableArray()
        super.init(serviceCenter: serviceCenter)
        
        self.dataManger()?.registerClass(YDSDKConfigModelEx.classForCoder(), complete: nil)
        self.checkout(nil)
    }
    
    /**
     请求配置, 获取权限
     
     - parameter completion: <#completion description#>
     */
    func fetch(completion: ((error: NSError?) -> Void)?) {
        let req = YDSDKConfigRequest()
        self.netManger().request(req) { (request, error) in
            if error == nil {
                let model = YDSDKConfigModelEx.objectFromSuperObject(req.model) as? YDSDKConfigModelEx
                model?.updateDate = NSDate()
                self.dataManger()?.writeObject(model, complete: { (successed, result) in
                    self.checkout({ (successed) in
                        completion?(error: error)
                    })
                })
            }else {
                completion?(error: error)
            }
        }
        
    }
    
    private func checkout(completion: ((successed: Bool) -> Void)?) {
        self.dataManger()?.read(YDSDKConfigModelEx.classForCoder(), condition: nil, complete: { (successed, result) in
            if let result = result as? [YDSDKConfigModelEx] {
                self.netManger().config = successed ? result.first : nil
                self.config = successed ? result.first : nil
                self.isConfiged = true
                completion?(successed: successed)
            }else {
                print("YDSDKConfigModelEx查询结果出错")
            }
        })
    }
    
}
