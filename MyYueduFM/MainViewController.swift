//
//  MainViewController.swift
//  MyYueduFM
//
//  Created by apple on 16/5/27.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import MJRefresh
import REMenu

private struct CountPerTime {
    static var kCountPerTime = 20
}

class MainViewController: ArticleViewController {
    
    private var selectMenuIndex = 0
    
    private var menu: REMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = LOC("main")
        self.emptyString = LOC("main_empty_prompt")
        
        self.setupNavigationBar()
        
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            
            [weak self] in
                        
            self?.refreshing()
            
        })

//        self.refreshing()
        self.tableView.mj_header.beginRefreshing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        menu?.close()
    }

    // MARK: - 本类私有方法
    private func setupNavigationBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.itemWithImage(UIImage(named: "icon_nav_menu.png")!, action: { 
            [weak self] in
            self?.presentLeftMenuViewController(nil)
        })
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.itemWithImage(UIImage(named: "icon_nav_search.png")!, action: {
            [weak self] in
            let searchVC = SearchViewController(nibName: "SearchViewController", bundle: nil)
            self?.navigationController?.pushViewController(searchVC, animated: true)
            
        })
    }
    
    private func loadCurrentChannelData(completion: (() -> Void)?) {
        SRV(ArticleService)?.list(CountPerTime.kCountPerTime, channel: Int(self.currentChannel()), completion: { (array) in
            dispatch_async(dispatch_get_main_queue(), { 
                [weak self] in
                if let array = array as? [AnyObject] {
                    if let weakSelf = self {
                        weakSelf.reloadData(array)
                        weakSelf.tableView.mj_header.endRefreshing()
                        if array.count >= CountPerTime.kCountPerTime {
                            self?.addFooter()
                        }
                        completion?()
                    }
                }
            })
        })
    }
    
    private func currentChannel() -> Int32 {
        //不支持多频道
        return 0
        
        if let array = SRV(ChannelService)?.channels {
            if array.count <= self.selectMenuIndex {
                return 1
            }else {
                return array[self.selectMenuIndex].aid
            }
        }
        
    }
    
    private func addFooter() {
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            [weak self] in
            if let weakSelf = self, tableData = weakSelf.tableData {
                SRV(ArticleService)?.list(tableData.count + CountPerTime.kCountPerTime, channel: Int(weakSelf.currentChannel()), completion: { (array) in
                    dispatch_async(dispatch_get_main_queue(), { 
                        if let array = array as? [AnyObject] {
                            self?.reloadData(array)
                            self?.tableView.mj_footer.endRefreshing()
                            
                            if self?.tableData?.count ?? 0 == array.count {
                                self?.tableView.mj_footer = nil
                            }
                        }
                    })
                })
            }
        })
    }
    
    private func refreshing() {
        SRV(ArticleService)?.latestLocalArticle({ (model) in
            let lastModel = model
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                SRV(ArticleService)?.fetchLatest({ (error) in
                    self.loadCurrentChannelData({
                        dispatch_async(dispatch_get_main_queue(), {
                            if let nowModel = self.tableData?.first as? YDSDKArticleModelEx {
                                if error != nil {
                                    self.showWithFailedMessage(LOC("main_update_failed_prompt"))
                                }else {
                                    if lastModel == nil || lastModel!.aid != nowModel.aid {
                                        self.showWithSuccessedMessage(LOC("main_update_newer_prompt"))
                                    }else {
                                        self.showWithSuccessedMessage(LOC("main_update_none_prompt"))
                                    }
                                }
                            }else {
                                self.showWithSuccessedMessage(LOC("main_update_none_prompt"))
                            }
                        })
                    })
                })
            })
        })
    }
    
    //没有使用
    private func setupMenu() {
        self.menu = REMenu()
        self.menu?.shadowColor                = UIColor.blackColor()
        self.menu?.shadowOffset               = CGSizeMake(0, 3)
        self.menu?.shadowOpacity              = 0.2
        self.menu?.shadowRadius               = 10.0
        self.menu?.backgroundColor            = UIColor.whiteColor()
        self.menu?.textColor                  = kThemeColor
        self.menu?.textShadowColor            = UIColor.clearColor()
        self.menu?.textOffset                 = CGSizeZero
        self.menu?.textShadowOffset           = CGSizeZero
        self.menu?.highlightedTextColor       = UIColor.whiteColor()
        self.menu?.highlightedTextShadowColor = UIColor.clearColor()
        self.menu?.highlightedBackgroundColor = RGBHex("#E0E0E0")
        self.menu?.highlightedSeparatorColor  = RGBHex("#E0E0E0")
        self.menu?.font                       = UIFont.systemFontOfSize(14)
        self.menu?.separatorColor             = RGBHex("#E0E0E0")
        self.menu?.separatorHeight            = 0.5
        self.menu?.separatorOffset            = CGSizeMake(15, 0)
        self.menu?.borderWidth                = 0
        self.menu?.itemHeight                 = 40
        
        menu?.bk_addObserverForKeyPath("isOpen", task: {
            [unowned self] (target) in
            let button = self.navigationItem.titleView as? UIButton
            if self.menu!.isOpen {
                button?.setImage(UIImage(named: "icon_up_arrow"), forState: .Normal)
                button?.setImage(UIImage(named: "icon_up_arrow_h"), forState: .Highlighted)
            }else {
                button?.setImage(UIImage(named: "icon_down_arrow"), forState: .Normal)
                button?.setImage(UIImage(named: "icon_down_arrow_h"), forState: .Highlighted)
            }
        })
        
        self.reloadMenu()
        
        SRV(ChannelService)?.bk_addObserverForKeyPath("channels", task: { (target) in
            dispatch_async(dispatch_get_main_queue(), { 
                [unowned self] in
                self.reloadMenu()
            })
        })
    }
    
    private func reloadMenu() {
        var array: [REMenuItem] = []
        SRV(ChannelService)?.channels?.forEach({ (obj) in
            let channel = obj
            let item = REMenuItem(title: channel.name, image: nil, highlightedImage: nil, action: { (item) in
                if let button = self.navigationItem.titleView as? UIButton {
                    button.setTitle(item.title, forState: .Normal)
                    self.selectMenuIndex = (self.menu!.items as NSArray).indexOfObject(item)
                    self.loadCurrentChannelData(nil)
                }
            })
            
            array.append(item)
        })
        
        self.menu?.items = array
    }
    
}
