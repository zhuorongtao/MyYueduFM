//
//  GuideViewController.swift
//  MyYueduFM
//
//  Created by apple on 16/5/30.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import EAIntroView

class GuideViewController: UIViewController, EAIntroDelegate {
    
    var guideDidFinished: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.whiteColor()
        self.show()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func introDidFinish(introView: EAIntroView!) {
        self.guideDidFinished?()
    }

    private func show() {
        let page1 = EAIntroPage()
        page1.title   = "点击播放"
        page1.desc    = "点击图片区域, 可以播放相应的文章."
        page1.bgColor = kThemeColor
        if let path1 = NSBundle.mainBundle().pathForResource(self.adapterImageName("guide1"), ofType: "png") {
            page1.titleIconView = UIImageView(image: UIImage(contentsOfFile: path1))
        }
        
        let page2 = EAIntroPage()
        page2.title = "选时播放"
        page2.desc  = "播放栏上方会显示当前播放进度\n在播放栏上左右滑动, 可进行选时播放."
        page2.bgColor = kThemeColor
        if let path2 = NSBundle.mainBundle().pathForResource(self.adapterImageName("guide2"), ofType: "png") {
            page2.titleIconView = UIImageView(image: UIImage(contentsOfFile: path2))
        }
        
        let page3 = EAIntroPage()
        page3.title = "下载"
        page3.desc = "点击图片区域，可以暂停/恢复下载."
        page3.bgColor = kThemeColor
        if let path3 = NSBundle.mainBundle().pathForResource(self.adapterImageName("guide3"), ofType: "png") {
            page3.titleIconView = UIImageView(image: UIImage(contentsOfFile: path3))
        }
        let intro = EAIntroView(frame: self.view.bounds, andPages: [page1, page2, page3])
        intro.skipButton.alpha = 0
        intro.delegate = self
        intro.showInView(self.view, animateDuration: 0.3)
    }
    
    private func adapterImageName(name: String) -> String {
        let preName = name.stringByDeletingPathExtension
        let size = UIScreen.mainScreen().bounds.size
        if size.width >= 414 {
            return "\(preName)~5.5@2x"
        }else if size.width >= 375 {
            return "\(preName)~4.7@2x"
        }else if size.height > 480 {
            return "\(preName)~4@2x"
        }else {
            return "\(preName)~3.5@2x"
        }
        
    }
}
