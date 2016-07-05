//
//  FavorActionTableViewCell.swift
//  MyYueduFM
//
//  Created by apple on 16/5/29.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class FavorActionTableViewCell: ActionTableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func onFavorButtonPressed(sender: AnyObject) {
        super.onFavorButtonPressed(sender)
        self.expandTableViewController?.deleteCellWithModel(self.model!)
    }
    
}
