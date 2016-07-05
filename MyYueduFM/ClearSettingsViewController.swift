//
//  ClearSettingsViewController.swift
//  MyYueduFM
//
//  Created by apple on 16/5/30.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD

class ClearSettingsViewController: SettingsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = LOC("settings_clean_space")
        
        let rows1: [[String: Any]] = [
            [
                "title": LOC("settings_clean_picture_space"),
                "detail": String.stringWithFileSize(Double(SDImageCache.sharedImageCache().getSize())),
                "accessoryType": UITableViewCellAccessoryType.DisclosureIndicator,
                "action": {
                    (cell: UITableViewCell) in
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { 
                        SDImageCache.sharedImageCache().clearDiskOnCompletion({ 
                            dispatch_async(dispatch_get_main_queue(), { 
                                cell.detailTextLabel?.text = String.stringWithFileSize(Double(SDImageCache.sharedImageCache().getSize()))
                                SVProgressHUD.showSuccessWithStatus(LOC("settings_clean_successed"))
                            })
                        })
                    })
                }
            ]
        ]
        let section1: [String: Any] = [
            "footer": LOC("settings_clean_picture_space"),
            "rows": rows1
        ]
        
        let rows2: [[String: Any]] = [
            [
                "title": LOC("settings_clean_downloaded_space"),
                "detail": String.stringWithFileSize(Double(SRV(DownloadService)?.cacheSize() ?? 0)),
                "accessoryType": UITableViewCellAccessoryType.DisclosureIndicator,
                "action": {
                    (cell: UITableViewCell) in
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { 
                        SRV(ArticleService)?.deleteAllDownloaded({ 
                            dispatch_async(dispatch_get_main_queue(), { 
                                cell.detailTextLabel?.text = String.stringWithFileSize(Double(SRV(DownloadService)?.cacheSize() ?? 0))
                                SVProgressHUD.showSuccessWithStatus(LOC("settings_clean_successed"))
                            })
                        })
                    })
                }
            ]
        ]
        let section2: [String: Any] = [
            "footer": LOC("settings_clean_downloaded_space_prompt"),
            "rows": rows2
        ]
        
        
        self.tableData = [section1, section2]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
