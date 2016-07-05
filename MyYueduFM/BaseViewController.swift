//
//  BaseViewController.swift
//  MyYueduFM
//
//  Created by apple on 16/5/13.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    private var _isEmpty: Bool!
    var isEmpty: Bool {
        get {
            return _isEmpty
        }
        set {
            _isEmpty = newValue
            dispatch_async(dispatch_get_main_queue()) { 
                self.emptyView?.hidden = !newValue
            }
        }
    }
    
    private var emptyView: UILabel?
    
    private var _emptyString: String = ""
    var emptyString: String {
        get {
            return _emptyString
        }
        set {
            _emptyString = newValue
            self.emptyView?.text = newValue
        }
    }
    
    private var _title: String?
    override var title: String? {
        get {
            return _title
        }
        set {
            _title = newValue
            super.title = newValue
            
            let label = UILabel()
            label.text = newValue
            label.font = UIFont.systemFontOfSize(17)
            label.textColor = UIColor.whiteColor()
            label.sizeToFit()
            self.navigationItem.titleView = label
        }
    }
    
    private var dragging: Bool   = false
    private var scrollY: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()
        self.setupEmptyView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        SRV(StreamerService)?.isPlaying = (SRV(StreamerService)?.isPlaying)!
    }
    
    private func setupEmptyView() {
        let container                    = self.emptyContainer()
        self.emptyView                   = UILabel(frame: CGRectMake(0, 0, container.width, 20))
        self.emptyView?.center           = CGPointMake(container.width / 2, (container.height - 120) / 2)
        self.emptyView?.textColor        = UIColor.lightGrayColor()
        self.emptyView?.textAlignment    = .Center
        self.emptyView?.text             = self.emptyString
        self.emptyView?.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
        self.emptyView?.font             = UIFont.systemFontOfSize(15)
        self.isEmpty                     = false
        container.addSubview(self.emptyView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func emptyContainer() -> UIView {
        return self.view
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.dragging = true
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.dragging = false
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        self.dragging = false
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let diffY = self.scrollY - scrollView.contentOffset.y
        
        //手指上滑时 scrollView.contentOffset.y大于0
        self.scrollY = scrollView.contentOffset.y
        if !self.dragging || scrollView.contentOffset.y < -70 {
            return
        }
        
        if diffY > 0 { //上滑(手指下滑)
            PlayerBar.show()
        }else if diffY < 0 {
            PlayerBar.hide()
        }
    }
    
    deinit {
        print("\(self.classForCoder)已销毁")
    }
}
