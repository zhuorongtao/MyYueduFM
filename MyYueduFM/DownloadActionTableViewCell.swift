//
//  DownloadActionTableViewCell.swift
//  MyYueduFM
//
//  Created by apple on 16/5/29.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import YueduFMSDK

class DownloadActionTableViewCell: ActionTableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func onDeleteButtonPressed(sender: AnyObject) {
        if let model = self.model as? YDSDKArticleModelEx {
            SRV(ArticleService)?.deleteDownloaded(model, completion: { (successed) in
                if successed {
                    self.expandTableViewController?.deleteCellWithModel(model)
                }
            })
        }else if let model = self.model as? NSURLSessionTask {
            
            SRV(DownloadService)?.deleteTask(model)
            self.expandTableViewController?.deleteCellWithModel(model)
        }
        
        
    }
    
}
