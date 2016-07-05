//
//  DownloadTableViewCell.swift
//  MyYueduFM
//
//  Created by apple on 16/5/29.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class DownloadTableViewCell: ArticleTableViewCell {

    @IBOutlet weak var progressView: EVCircularProgressView!
    
    private var _task: NSURLSessionTask?
    var task: NSURLSessionTask? {
        get {
            return self._task
        }
        set {
            self.task?.bk_removeAllBlockObservers()
            self._task = newValue
            
            self.model = newValue!.articleModel!
            self.updateProgress()
            self.task?.bk_removeAllBlockObservers()
            self.task?.bk_addObserverForKeyPath("countOfBytesReceived") { (target) in
                dispatch_async(dispatch_get_main_queue(), { 
                    [weak self] in
                    if let weakSelf = self {
                        let bytesReceived = Float(weakSelf
                            .task!.countOfBytesReceived)
                        let bytesExpectedToReceive = Float(weakSelf.task!.countOfBytesExpectedToReceive)
                        let progress = bytesReceived / bytesExpectedToReceive
                        
                        weakSelf.progressView.progress = progress
                    }

                })
            }
            
            self.progressView.bk_removeEventHandlersForControlEvents(.TouchUpInside)
            self.progressView.bk_addEventHandler({
                [weak self] (sender) in
                self?.toggleTask()
                }, forControlEvents: .TouchUpInside)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.playButton.bk_removeEventHandlersForControlEvents(.TouchUpInside)
        self.playButton.bk_addEventHandler({
            [weak self] (sender) in
            self?.toggleTask()
            }, forControlEvents: .TouchUpInside)
        
        self.progressView.progressTintColor = UIColor.whiteColor()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    private func updateProgress() {
        if self.task?.state == .Running {
            let bytesReceived = Float(self.task!.countOfBytesReceived)
            let bytesExpectedToReceive = Float(self.task!.countOfBytesExpectedToReceive)
            let progress = bytesReceived / bytesExpectedToReceive
            
            self.progressView.progress = progress
        }else {
            self.progressView.progress = 0.0
        }
    }
    
    private func toggleTask() {
        if self.task?.state == .Running {
            self.task?.suspend()
        }else {
            self.task?.resume()
        }
        
        self.updateProgress()
    }

}
