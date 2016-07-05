//
//  AboutViewController.swift
//  MyYueduFM
//
//  Created by apple on 16/5/31.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class AboutViewController: BaseViewController, UIWebViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = LOC("settings_about")
        
        if let URLString = NSBundle.mainBundle().pathForResource("about", ofType: "html") {
            do {
                try self.webView.loadHTMLString(String(contentsOfFile: URLString, encoding: NSUTF8StringEncoding), baseURL: nil)
                self.webView.delegate = self
            }catch {
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
