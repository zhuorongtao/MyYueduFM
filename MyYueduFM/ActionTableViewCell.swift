//
//  ActionTableViewCell.swift
//  MyYueduFM
//
//  Created by apple on 16/5/23.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import YueduFMSDK
import Reachability

class ActionTableViewCell: ExpandTableViewCell {

    @IBOutlet weak var detailButton: UIVButton!
    @IBOutlet weak var downloadButton: UIVButton!
    @IBOutlet weak var favorButton: UIVButton!
    @IBOutlet weak var addButton: UIVButton!
    @IBOutlet weak var shareButton: UIVButton!
    @IBOutlet weak var deleteButton: UIVButton!
    
    private var _model: AnyObject!
    override var model: AnyObject? {
        get {
            return self._model
        }
        set {
            super.model = newValue
            self._model = newValue
            self.article().bk_removeAllBlockObservers()
            self.article().bk_addObserverForKeyPath("isFavored") {
                [weak self] (target) in
                self?.updateFavorButton()
            }
            
            SRV(ArticleService)?.update(self.article(), completion: nil)
        }
    }
    
    override func awakeFromNib() {
        if let _ = self.downloadButton {
            self.downloadButton.bk_addEventHandler({
                [weak self] (sender) in
                if let weakSelf = self {
                    weakSelf.onDownloadButtonPressed(weakSelf.downloadButton)
                }
                }, forControlEvents: .TouchUpInside)
        }
        
        if let _ = self.shareButton {
            self.shareButton.bk_addEventHandler({
                [weak self] (sender) in
                if let weakSelf = self {
                    weakSelf.onShareButtonPressed(weakSelf.shareButton)
                }
                }, forControlEvents: .TouchUpInside)
        }
        
        if let _ = self.favorButton {
            self.favorButton.bk_addEventHandler({
                [weak self] (sender) in
                if let weakSelf = self {
                    weakSelf.onFavorButtonPressed(weakSelf.favorButton)
                }
                }, forControlEvents: .TouchUpInside)
        }
        
        if let _ = self.deleteButton {
            self.deleteButton.bk_addEventHandler({
                [weak self] (sender) in
                if let weakSelf = self {
                    weakSelf.onDeleteButtonPressed(weakSelf.deleteButton)
                }
                }, forControlEvents: .TouchUpInside)
        }
        
        if let _ = self.detailButton {
            self.detailButton.bk_addEventHandler({
                [weak self] (sender) in
                if let weakSelf = self {
                    weakSelf.onDetailButtonPressed(weakSelf.detailButton)
                }
                }, forControlEvents: .TouchUpInside)
        }
        
        if let _ = self.addButton {
            self.addButton.bk_addEventHandler({
                [weak self] (sender) in
                if let weakSelf = self {
                    weakSelf.onAddButtonPressed(weakSelf.addButton)
                }
                }, forControlEvents: .TouchUpInside)
        }
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func onDownloadButtonPressed(sender: AnyObject) {
        let aModel = self.article()
        let preprocess: (error: NSError?) -> Void = {
            (error) in
            dispatch_async(dispatch_get_main_queue(), {
                if let error = error {
                    switch error.code {
                    case DownloadErrorCode.AlreadyDownloading.rawValue:
                        MessageKit.showWithFailedMessage(LOC("download_doing_prompt"))
                    case DownloadErrorCode.AlreadyDownloaded.rawValue:
                        MessageKit.showWithSuccessedMessage(LOC("download_already_prompt"))
                    default:
                        break
                    }
                }else {
                    MessageKit.showWithSuccessedMessage(LOC("download_add_prompt"))
                }
            })
        }
        
        if SRV(SettingsService)!.flowProtection && SRV(ReachabilityService)!.status == .ReachableViaWWAN {
            let alert = UIAlertView.bk_alertViewWithTitle(LOC("network_connect_prompt"), message: LOC("download_wwlan_prompt")) as? UIAlertView
            
            alert?.bk_addButtonWithTitle(LOC("continue"), handler: { 
                SRV(DownloadService)?.download(aModel, protect: false, preprocess: preprocess)
            })

            alert?.bk_addButtonWithTitle(LOC("download_in_wifi"), handler: { 
                SRV(DownloadService)?.download(aModel, protect: true, preprocess: preprocess)
            })
            
            alert?.bk_setCancelButtonWithTitle(LOC("cancel"), handler: nil)
            alert?.show()
        }else {
            SRV(DownloadService)?.download(aModel, protect: false, preprocess: preprocess)
        }
        
    }
    
    @IBAction func onFavorButtonPressed(sender: AnyObject) {
        let aModel = self.article()
        aModel.isFavored = !aModel.isFavored
        SRV(DataService)?.writeData(aModel, completion: nil)
    }
    
    @IBAction func onShareButtonPressed(sender: AnyObject) {
        let aModel = self.article()
        UIViewController.showActivityWithURL(aModel.url.url, completion: nil)
    }
    
    @IBAction func onDeleteButtonPressed(sender: AnyObject) {
    }
    
    @IBAction func onDetailButtonPressed(sender: AnyObject) {
        WebViewController.presentWithURL(self.article().url.url)
    }
    
    @IBAction func onAddButtonPressed(sender: AnyObject) {
        let aModel = self.article()
        aModel.preplayDate = NSDate()
        SRV(DataService)?.writeData(aModel, completion: nil)
        MessageKit.showWithSuccessedMessage(LOC("playlist_add_prompt"))
    }
    
    // MARK: - 本类私有方法
    private func article() -> YDSDKArticleModelEx {
        if let model = self.model as? YDSDKArticleModelEx {
            return model
        }
        return (self.model as! NSURLSessionTask).articleModel!
    }
    
    private func updateFavorButton() {
        dispatch_async(dispatch_get_main_queue()) { 
            let aModel = self.article()
            self.favorButton.setTitle(aModel.isFavored ? LOC("unfavor") : LOC("favor"), forState: .Normal)
            self.favorButton.setImage(aModel.isFavored ? UIImage(named: "icon_action_favored.png") : UIImage(named: "icon_action_favor.png"), forState: .Normal)
        }
    }
}
