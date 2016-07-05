//
//  UIViewEX.swift
//  MyYueduFM
//
//  Created by apple on 16/5/13.
//  Copyright © 2016年 apple. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    class func viewWithNibName(nibName: String?) -> AnyObject? {
        if nibName == "" || nibName == nil {
            return nil
        }
        
        let array = NSBundle.mainBundle().loadNibNamed(nibName!, owner: self, options: nil)
        return array.first
    }
    
    var left: CGFloat {
        get {
            return self.frame.origin.x
        }
        set {
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    var top: CGFloat {
        get {
            return self.frame.origin.y
        }
        set {
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
    
    
    var width: CGFloat {
        get {
            return self.frame.size.width
        }
        set {
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    var height: CGFloat {
        get {
            return self.frame.size.height
        }
        set {
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
    var bottom: CGFloat {
        get {
            return self.frame.size.height + self.frame.origin.y
        }
        set {
            var frame = self.frame
            frame.size.height = newValue - self.frame.origin.y
            self.frame = frame
        }
    }
    
    var right: CGFloat {
        get {
            return self.frame.size.width + self.frame.origin.x
        }
        set {
            var frame = self.frame
            frame.size.width = newValue - self.frame.origin.x
            self.frame = frame
        }
    }
    
}
