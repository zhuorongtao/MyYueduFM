//
//  SearchViewController.swift
//  MyYueduFM
//
//  Created by apple on 16/5/27.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import MJRefresh

private struct CountPerTime {
    static var kCountPerTime = 10
}

class SearchViewController: ArticleViewController {
    
    private var searchBar: UISearchBar?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    private func setupNavigationBar() {
        self.searchBar = UISearchBar(frame: CGRectMake(0, 0, SCREEN_SIZE().width - 80, 25))
        self.searchBar?.autoresizingMask = .FlexibleWidth
        self.searchBar?.delegate         = self
        self.searchBar?.tintColor        = RGBHex("#A0A0A0")
        self.searchBar?.placeholder      = LOC("search_prompt")
        
        let button = UIButton(type: .System)
        button.frame = CGRectMake(0, 0, 40, 25)
        button.setTitle("取消", forState: .Normal)
        button.bk_addEventHandler({
            [weak self] (sender) in
            self?.navigationController?.popViewControllerAnimated(true)
            }, forControlEvents: .TouchUpInside)
        
        self.navigationItem.leftBarButtonItems = [
            UIBarButtonItem(customView: searchBar!),
            UIBarButtonItem(customView: button)
        ]
        
        self.searchBar?.becomeFirstResponder()
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.searchDidFinished()
    }
    
    private func searchDidFinished() {
        if self.searchBar!.isFirstResponder() {
            self.searchBar?.resignFirstResponder()
            
            if self.tableData?.count ?? 0 >= CountPerTime.kCountPerTime {
                self.addFooter()
            }
        }
    }
    
    private func addFooter() {
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            [weak self] in
            if let weakSelf = self, tableData = weakSelf.tableData {
                SRV(ArticleService)?.list(tableData.count + CountPerTime.kCountPerTime, filter: weakSelf.searchBar?.text, completion: { (array) in
                    if let array = array {
                        dispatch_async(dispatch_get_main_queue(), {
                            weakSelf.reloadData(array)
                            weakSelf.tableView.mj_footer.endRefreshing()
                            if tableData.count == array.count {
                                weakSelf.tableView.mj_footer = nil
                            }
                        })
                    }else {
                        weakSelf.tableView.mj_footer = nil
                    }
                })
            }
        })
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        SRV(ArticleService)?.list(20, filter: searchText, completion: { (array) in
            array != nil ? self.reloadData(array!) : self.reloadData([])
        })
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchDidFinished()
    }
}
