//
//  UIViewController+MessageKit.swift
//  MyYueduFM
//
//  Created by apple on 16/5/13.
//  Copyright © 2016年 apple. All rights reserved.
//

import Foundation
import UIKit
import Synchronized

class MessageView: UIView {
    
    @IBOutlet weak var messageLabel: UILabel!
}

extension UIViewController {
    
    private struct AssociatedKey {
        static var MessageViewIdentifier = "messageView"
    }
    
    var messageView: MessageView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.MessageViewIdentifier) as? MessageView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.MessageViewIdentifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func showWithSuccessedMessage(message: String) {
        if let view = MessageView.viewWithNibName("SuccessedMessageView") as? MessageView {
            view.messageLabel.text = message
            view.left = 0
            view.width = self.view.width
            self.messageView?.removeFromSuperview()
            self.messageView = view
            self.view.addSubview(view)
            self.showMessageView(view)
        }else {
            print("SuccessedMessageView为空")
        }
    }
    
    func showWithFailedMessage(message: String) {
        if let view = MessageView.viewWithNibName("FailedMessageView") as? MessageView {
            view.messageLabel.text = message
            view.width = self.view.width
            self.messageView?.removeFromSuperview()
            self.view.addSubview(view)
            self.showMessageView(view)
        }else {
            print("FailedMessageView为空")
        }
    }
    
    private func showMessageView(view: MessageView) {
//        synchronized(self) { 
            view.top -= view.height
            UIView.animateWithDuration(0.3, animations: { 
                view.top = 0
                }, completion: { (finished) in
                    UIView.animateWithDuration(0.3, delay: 2.0, options: .CurveEaseOut, animations: {
                            view.top -= view.height
                        }, completion: nil)
            })
//        }
    }
}