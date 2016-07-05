//
//  DataService.swift
//  MyYueduFM
//
//  Created by apple on 16/5/13.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class DataService: BaseService {
        
    var manager: PPSqliteORMManager?
    
    required init(serviceCenter: ServiceCenter) {
        super.init(serviceCenter: serviceCenter)
        manager = PPSqliteORMManager(DBFilename: "db.sqlite")
    }
    
    override class func level() -> ServiceLevel {
        return .Highest
    }
    
    func writeData(data: YDSDKArticleModelEx, completion: (() -> Void)?) {
        self.manager?.writeObject(data, complete: { (successed, result) in
            completion?()
        })
    }
    
    func writeDataFromArray(array: [AnyObject], completion: (() -> Void)?) {
        self.manager?.writeObjects(array, complete: { (successed, result) in
            completion?()
        })
    }
}

extension BaseService {
    func dataManger() -> PPSqliteORMManager? {
        return SRV(DataService)?.manager
    }
}
