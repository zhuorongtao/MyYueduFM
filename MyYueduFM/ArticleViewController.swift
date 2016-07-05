//
//  ArticleViewController.swift
//  MyYueduFM
//
//  Created by apple on 16/5/26.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

private let kCellIdentifier = "kCellIdentifier"

class ArticleViewController: ExpandTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerNib(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: kCellIdentifier)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.closeExpand()
    }

    override func reloadData(data: [AnyObject]) {
        super.reloadData(data)
        self.isEmpty = (data.count == 0)
    }
    
    override func emptyContainer() -> UIView {
        return self.tableView
    }

}

// MARK: - ExpandTableViewControllerProtocol
extension ArticleViewController {
    override func nibForExpandCell() -> UINib? {
        if let service = SRV(ConfigService) {
            if service.config != nil {
                if service.config!.allowDownload {
                    return UINib(nibName: "ActionTableViewCell", bundle: nil)
                }else {
                    return UINib(nibName: "ActionTableViewCell-WithoutDownload", bundle: nil)
                }
            }
        }else {
            print("\(self) 无法获取ConfigService")
        }
        return nil
    }
    
    override func heightForExpandCell() -> CGFloat {
        return 60
    }
    
    override func heightForRowAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    override func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell? {
        if let model = self.tableData?[indexPath.row] as? YDSDKArticleModelEx {
            let cell = self.tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath) as? ArticleTableViewCell
            cell?.selectionStyle = .None
            cell?.model = model
            cell?.moreButton?.bk_removeEventHandlersForControlEvents(.TouchUpInside)
            cell?.moreButton?.bk_addEventHandler({ (sender) in
                
                }, forControlEvents: .TouchUpInside)
            return cell
        }
        return nil
    }
}