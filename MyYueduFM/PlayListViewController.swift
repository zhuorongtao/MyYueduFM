//
//  PlayListViewController.swift
//  MyYueduFM
//
//  Created by apple on 16/5/28.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import MJRefresh

private struct CountPerTime {
    static var kCountPerTime = 20
}

class PlayListViewController: ArticleViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = LOC("menu_playlist")
        self.emptyString = LOC("playlist_empty_prompt")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWithImage(UIImage(named: "icon_nav_delete.png")!, action: { 
            let alert = UIAlertView.bk_alertViewWithTitle(nil, message: LOC("playlist_clear_prompt")) as? UIAlertView
            alert?.bk_addButtonWithTitle("clear", handler: { 
                [weak self] in
                SRV(ArticleService)?.deleteAllPreplay({ 
                    self?.load()
                    self?.showWithSuccessedMessage("clear_successed")
                })
            })
            
            alert?.bk_addButtonWithTitle("cancel", handler: nil)
            alert?.show()
        })
        
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            [weak self] in
            self?.load()
        })
        
        self.load()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func nibForExpandCell() -> UINib? {
        if let config = SRV(ConfigService)?.config {
            if config.allowDownload {
                return UINib(nibName: "PlayListActionTableViewCell", bundle: nil)
            }else {
                return UINib(nibName: "PlayListActionTableViewCell-WithoutDownload", bundle: nil)
            }
        }
        return nil
    }
    
    private func load() {
        SRV(ArticleService)?.listPreplay(CountPerTime.kCountPerTime, completion: { (array) in
            dispatch_async(dispatch_get_main_queue(), { 
                if let array = array {
                    self.reloadData(array)
                    self.tableView.mj_header.endRefreshing()
                    if array.count >= CountPerTime.kCountPerTime {
                        self.addFooter()
                    }
                }
            })
        })
    }

    private func addFooter() {
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            [unowned self] in
            if let tableData = self.tableData {
                SRV(ArticleService)?.listPreplay(tableData.count + CountPerTime.kCountPerTime, completion: { (array) in
                    dispatch_async(dispatch_get_main_queue(), {
                        if let array = array {
                            self.reloadData(array)
                            self.tableView.mj_footer.endRefreshing()
                            
                            if let tableData = self.tableData where tableData.count == array.count {
                                self.tableView.mj_footer = nil
                            }
                        }
                    })
                })
            }
        })
    }
}
