//
//  UISwitchEX.swift
//  MyYueduFM
//
//  Created by apple on 16/5/30.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

extension UISwitch {
    convenience init(on: Bool, action: ((isOn: Bool) -> Void)?) {
        self.init()
        self.bk_addEventHandler({ (sender) in
            action?(isOn: self.on)
            }, forControlEvents: .ValueChanged)
        self.on = on
    }
    
    class func switchWithOn(on: Bool, action: ((isOn: Bool) -> Void)?) -> UISwitch {
        let sw = UISwitch()
        sw.bk_addEventHandler({ (sender) in
            action?(isOn: sw.on)
            }, forControlEvents: .ValueChanged)
        sw.on = on
        return sw
    }
}