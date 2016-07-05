//
//  DownloadViewController.swift
//  MyYueduFM
//
//  Created by apple on 16/5/28.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import MJRefresh
import YueduFMSDK

private struct DownloadViewTemp {
    static var kCountPerTime = 20
    static let kDownloadCellIdentifier = "kDownloadCellIdentifier"
}

enum DownloadType: Int {
    case Done = 0,
         Doing
}

class DownloadViewController: ArticleViewController {
    
    var segmentedControl: UISegmentedControl?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationBar()
        self.emptyString = LOC("download_empty_prompt")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWithImage(UIImage(named: "icon_nav_delete.png")!, action: { 
            [weak self] in
            if let weakSelf = self {
                if weakSelf.isDownloadTypeDone() {
                    let alert = UIAlertView.bk_alertViewWithTitle(nil, message: LOC("download_clear_prompt")) as? UIAlertView
                    alert?.bk_addButtonWithTitle(LOC("clear"), handler: {
                        SRV(ArticleService)?.deleteAllDownloaded({
                            self?.load()
                            self?.showWithSuccessedMessage(LOC("clear_successed"))
                        })
                    })
                    alert?.bk_addButtonWithTitle(LOC("cancel"), handler: nil)
                    alert?.show()
                }else {
                    let alert = UIAlertView.bk_alertViewWithTitle(nil, message: LOC("download_clear_prompt")) as? UIAlertView
                    alert?.bk_addButtonWithTitle(LOC("clear"), handler: { 
                        SRV(DownloadService)?.deleteAllTask({ 
                            [weak self] in
                            self?.load()
                            self?.showWithSuccessedMessage(LOC("clear_successed"))
                        })
                    })
                    alert?.bk_addButtonWithTitle(LOC("cancel"), handler: nil)
                    alert?.show()
                }
            }
        })
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DownloadViewController.downloadSeriviceDidChangedNotification(_:)), name: DownloadSeriviceDidChangedNotification, object: nil)
        
        self.tableView.registerNib(UINib(nibName: "DownloadTableViewCell", bundle: nil), forCellReuseIdentifier: DownloadViewTemp.kDownloadCellIdentifier)
        
        SRV(DownloadService)?.state({ (downloading) in
            self.segmentedControl?.selectedSegmentIndex = downloading ? DownloadType.Doing.rawValue : DownloadType.Done.rawValue
            self.load()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func nibForExpandCell() -> UINib? {
        return UINib(nibName: "DownloadActionTableViewCell", bundle: nil)
    }
    
    override func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell? {
        if let _ = self.tableData?.first as? YDSDKArticleModel where self.isDownloadTypeDone() {
            return super.cellForRowAtIndexPath(indexPath)
        }else {
            if let task = self.tableData?[indexPath.row] as? NSURLSessionTask {
                let cell = self.tableView.dequeueReusableCellWithIdentifier(DownloadViewTemp.kDownloadCellIdentifier, forIndexPath: indexPath) as? DownloadTableViewCell
                cell?.selectionStyle = .None
                cell?.task = task
                return cell
            }
        }
        
        return nil
    }

    // MARK: selector
    func downloadSeriviceDidChangedNotification(notification: NSNotification)  {
        self.load()
    }
    
    private func setupNavigationBar() {
        self.segmentedControl = UISegmentedControl(items: [LOC("download_done"), LOC("download_doing")])
        segmentedControl?.bk_addEventHandler({
            [weak self] (sender) in
            self?.load()
            }, forControlEvents: .ValueChanged)
        segmentedControl?.selectedSegmentIndex = 0
        self.navigationItem.titleView = self.segmentedControl
    }
    
    private func isDownloadTypeDone() -> Bool {
        return segmentedControl!.selectedSegmentIndex == DownloadType.Done.rawValue
    }
    
    private func load() {
        if self.isDownloadTypeDone() {
            SRV(ArticleService)?.listDownloaded(DownloadViewTemp.kCountPerTime, completion: { (array) in
                dispatch_async(dispatch_get_main_queue(), { 
                    if let array = array {
                        self.reloadData(array)
                        if let _ = self.tableView.mj_header {
                            self.tableView.mj_header.endRefreshing()
                        }
                        
                        if array.count >= DownloadViewTemp.kCountPerTime {
                            self.addFooter()
                        }
                    }
                })
            })
        }else {
            SRV(DownloadService)?.list({ (tasks) in
                if let tasks = tasks {
                    self.reloadData(tasks)
                }
            })
        }
    }
    
    private func addFooter() {
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { 
            [weak self] in
            if let weakSelf = self {
                if weakSelf.isDownloadTypeDone() {
                    SRV(ArticleService)?.listDownloaded(weakSelf.tableData!.count + DownloadViewTemp.kCountPerTime, completion: { (array) in
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
            }
        })
    }
    
}
