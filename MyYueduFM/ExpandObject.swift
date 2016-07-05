//
//  NSObjectEX.swift
//  MyYueduFM
//
//  Created by apple on 16/5/16.
//  Copyright © 2016年 apple. All rights reserved.
//

import Foundation
import UIKit

class ExpandObject: NSObject {
    
    var model: AnyObject?
    
    static func objectWithModel(model: AnyObject) -> ExpandObject {
        let object = ExpandObject()
        object.model = model
        return object
    }
}
