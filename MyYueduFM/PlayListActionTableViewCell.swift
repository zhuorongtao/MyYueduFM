//
//  PlayListActionTableViewCell.swift
//  MyYueduFM
//
//  Created by apple on 16/5/28.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class PlayListActionTableViewCell: ActionTableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction override func onDeleteButtonPressed(sender: AnyObject) {
        if let aModel = self.model as? YDSDKArticleModelEx{
            aModel.preplayDate = NSDate(timeIntervalSince1970: 0)
            SRV(DataService)?.writeData(aModel, completion: nil)
            self.expandTableViewController?.deleteCellWithModel(self.model!)
        }
    }
}
