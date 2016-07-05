//
//  UIVButton.swift
//  MyYueduFM
//
//  Created by apple on 16/5/20.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class UIVButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentHorizontalAlignment = .Left
        self.contentVerticalAlignment   = .Top
        
        let imageHeight = self.imageView?.height ?? 0
        let imageWidth  = self.imageView?.width ?? 0

        let titleHeight = self.titleLabel?.height ?? 0
        let titleWidth  = self.titleLabel?.width ?? 0
        
        self.imageEdgeInsets = UIEdgeInsetsMake((self.height - imageHeight - titleHeight) / 2, (self.width - imageWidth) / 2 , 0, 0)
        self.titleEdgeInsets = UIEdgeInsetsMake((self.height - imageHeight - titleHeight) / 2 + imageHeight, (self.width - titleWidth) / 2 - imageWidth, 0, 0)
    }

}
