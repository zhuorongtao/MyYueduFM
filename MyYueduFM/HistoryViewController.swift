//
//  HistoryViewController.swift
//  MyYueduFM
//
//  Created by apple on 16/5/30.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import MJRefresh

private struct CountPerTime {
    static var kCountPerTime = 20
}

class HistoryViewController: ArticleViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = LOC("history")
        self.emptyString = LOC("history_empty_prompt")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWithImage(UIImage(named: "icon_nav_delete.png")!, action: { 
            let alert = UIAlertView.bk_alertViewWithTitle(nil, message: LOC("history_clear_prompt")) as? UIAlertView
            alert?.bk_addButtonWithTitle(LOC("clear"), handler: { 
                SRV(ArticleService)?.deleteAllPlayed({ 
                    [weak self] in
                    self?.load()
                    self?.showWithSuccessedMessage(LOC("clear_successed"))
                })
            })
            
            alert?.bk_addButtonWithTitle(LOC("cancel"), handler: nil)
            alert?.show()
        })
        
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { 
            [weak self] in
            self?.load()
        })
        
        self.tableView.mj_header.beginRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func load() {
        SRV(ArticleService)?.listPlayed(CountPerTime.kCountPerTime, completion: { (array) in
            if let array = array {
                dispatch_async(dispatch_get_main_queue(), { 
                    self.reloadData(array)
                    self.tableView.mj_header.endRefreshing()
                    
                    if array.count >= CountPerTime.kCountPerTime {
                        self.addFooter()
                    }
                })
            }
        })
    }
    
    private func addFooter() {
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            [weak self] in
            if let weakSelf = self {
                SRV(ArticleService)?.listPlayed(weakSelf.tableData!.count + CountPerTime.kCountPerTime, completion: { (array) in
                    if let array = array {
                        dispatch_async(dispatch_get_main_queue(), { 
                            weakSelf.reloadData(array)
                            weakSelf.tableView.mj_footer.endRefreshing()
                            
                            if weakSelf.tableData!.count == array.count {
                                weakSelf.tableView.mj_footer = nil
                            }
                        })
                    }
                })
            }
        })
    }
}
