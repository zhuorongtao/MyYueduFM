//
//  ChannelService.swift
//  MyYueduFM
//
//  Created by apple on 16/5/19.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import YueduFMSDK

/// 频道服务
class ChannelService: BaseService {
    
    dynamic var channels: [YDSDKChannelModel]?
    
    required init(serviceCenter: ServiceCenter) {
        super.init(serviceCenter: serviceCenter)
        self.dataManger()?.registerClass(YDSDKChannelModel.self, complete: nil)
        self.checkout(nil)
    }
    
    override func start() {
        
        if let channels = self.channels {
            if channels.count == 0 {
                self.fetch(nil)
            }
        }else {
            self.fetch(nil)
        }
    }
    
    func fetch(completion: ((error: NSError?) -> Void)?) {
        SRV(ConfigService)?.fetch({ (error) in//先配置, 再获取数据
            let req = YDSDKChannelListRequest()
            self.netManger().request(req) { (request, error) in
                if error == nil {
                    self.dataManger()?.writeObjects(req.modelArray, complete: { (successed, result) in
                        self.checkout({ (successed) in
                            completion?(error: nil)
                        })
                    })
                }else {
                    completion?(error: nil)
                }
            }
        })
    }
    
    // MARK: - 本类私有方法
    private func checkout(completion: ((successed: Bool) -> Void)?) {
        self.dataManger()?.read(YDSDKChannelModel.classForCoder(), condition: nil, complete: { (successed, result) in
            self.channels = successed ? (result as? [YDSDKChannelModel]) : nil
            completion?(successed: successed)
        })
    }
}
