//
//  PlayerBar.swift
//  MyYueduFM
//
//  Created by apple on 16/5/20.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class PlayerBar: UIView {
    
    private var actionCell: PlayBarActionTableViewCell?
    private var streamerService: StreamerService?
    private var processBar: UIView?
    private static var point = CGPointZero
    
    private var _progress: CGFloat!
    var progress: CGFloat {
        get {
            if let processBar = self.processBar {
                return processBar.width / self.width
            }else {
                return 0
            }
        }
        set {
            _progress = fmax(0, newValue)
            _progress = fmin(_progress, 1)
            processBar?.width = self.width * _progress
        }
    }
    
    private struct OnceTemp {
        static var onceToken: dispatch_once_t = 0
        static var bar: PlayerBar?
    }
    
    class func shareBar() -> PlayerBar {
        
        
        dispatch_once(&OnceTemp.onceToken) {
            
            
            OnceTemp.bar = PlayerBar.viewWithNibName("PlayerBar") as? PlayerBar
        }
        
        
        return OnceTemp.bar!
    }
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var speakerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var durationLabel: UILabel?
    
    private var _playing: Bool!
    var playing: Bool {
        get {
            return _playing
        }
        set {
            self._playing = newValue
            self.playButton.selected = newValue
        }
    }
    
    private var visiable: Bool = false
    
    private var container: UIView?
    
    private var _forceHidden = false
    var forceHidden: Bool {
        get {
            return _forceHidden
        }
        set {
            if _forceHidden == newValue {
                return
            }
            _forceHidden = newValue
            
            UIView.animateWithDuration(0.3) { 
                self.actionCell?.top = self.height
            }
            
            if newValue {
                UIView.animateWithDuration(0.3, animations: { 
                    self.top = self.container?.height ?? 0
                })
            }else {
                self.top = self.container?.height ?? 0
                UIView.animateWithDuration(0.3, animations: { 
                    self.top -= self.height
                })
            }
        }
    }
    
    private var timer: NSTimer?
    /// 是否在加速
    private var seeking = false
    
    override func awakeFromNib() {
        let line = UIView(frame: CGRectMake(0, 0, self.width, 1))
        line.autoresizingMask = .FlexibleWidth
        line.backgroundColor = RGB(224, G: 224, B: 224)
        self.addSubview(line)
        
        if let config = SRV(ConfigService)?.config where config.allowDownload {
            self.actionCell = PlayBarActionTableViewCell.viewWithNibName("PlayBarActionTableViewCell") as? PlayBarActionTableViewCell
        }else {
            actionCell = PlayBarActionTableViewCell.viewWithNibName("PlayBarActionTableViewCell-WithoutDownload") as? PlayBarActionTableViewCell
        }
        
        actionCell?.width  = self.width
        actionCell?.height = self.height
        actionCell?.top    = self.height
        actionCell?.autoresizingMask = .FlexibleWidth
        actionCell?.hideButton.bk_addEventHandler({
            [weak self] (sender) in
            if let weakSelf = self {
                UIView.animateWithDuration(0.3, animations: { 
                    weakSelf.actionCell?.top = weakSelf.height
                })
            }
            }, forControlEvents: .TouchUpInside)
        self.addSubview(self.actionCell!)
        
        self.actionButton.bk_addEventHandler({ (sender) in
            let model = SRV(ArticleService)?.activeArticleModel
            WebViewController.presentWithURL(model?.url.url)
            }, forControlEvents: .TouchUpInside)
        
        self.playButton.bk_addEventHandler({
            [weak self] (sender) in
            if let weakSelf = self {
                let model = SRV(ArticleService)?.activeArticleModel
                if let service = weakSelf.streamerService {
                    if service.isPlaying {
                        weakSelf.streamerService?.pause()
                    }else {
                        weakSelf.streamerService?.play(model)
                    }
                }
            }
            }, forControlEvents: .TouchUpInside)
        
        self.nextButton.bk_addEventHandler({
            [weak self] (sender) in
            self?.streamerService?.next()
            }, forControlEvents: .TouchUpInside)
        
        self.moreButton.bk_addEventHandler({
            [weak self] (sender) in
            let model = SRV(ArticleService)?.activeArticleModel
            self?.actionCell?.model = model
            UIView.animateWithDuration(0.3, animations: { 
                self?.actionCell?.top = 0
            })
            }, forControlEvents: .TouchUpInside)
        
        self.streamerService = SRV(StreamerService)
        
        processBar = UIView(frame: CGRectMake(0, 0, 0, 2))
        processBar?.backgroundColor = kThemeColor
        self.progress = 0
        self.addSubview(self.processBar!)
        
        self.imageView.image = UIImage.imageWithColor(kThemeColor)
        
        SRV(ArticleService)?.bk_addObserverForKeyPath("activeArticleModel", task: { (target) in
            dispatch_async(dispatch_get_main_queue(), { 
                [weak self] in
                if let weakSelf = self {
                    weakSelf.showIfNeed()
                    
                    if let model = SRV(ArticleService)?.activeArticleModel {
                        weakSelf.imageView.sd_setImageWithURL(model.pictureURL.url, placeholderImage: UIImage.imageWithColor(kThemeColor))
                        weakSelf.titleLabel.text    = model.title
                        weakSelf.authorLabel.text   = model.author
                        weakSelf.speakerLabel.text  = model.speaker
                        weakSelf.durationLabel?.text = String.stringWithSeconds(model.duration)
                        
                        UIView.animateWithDuration(0.3, animations: { 
                            weakSelf.actionCell?.top = weakSelf.height
                        })
                    }
                }
            })
        })
        
        self.streamerService?.bk_addObserverForKeyPath("isPlaying", task: { (target) in
            dispatch_async(dispatch_get_main_queue(), { 
                [weak self] in
                if let weakSelf = self {
                    if let service = weakSelf.streamerService {
                        weakSelf.playing = service.isPlaying
                        weakSelf.progress = CGFloat(service.duration > 0 ? service.currentTime / service.duration : 0)
                    }
                }
            })
        })
        
        self.timer = NSTimer.bk_scheduledTimerWithTimeInterval(1, block: {
            [weak self] (timer) in
            if let weakSelf = self {
                if let service = weakSelf.streamerService {
                    if service.isPlaying && !weakSelf.seeking && service.duration > 0 {
                        weakSelf.progress = CGFloat(service.currentTime / service.duration)
                    }
                }
            }
            }, repeats: true)
        
        let gesture = UILongPressGestureRecognizer.bk_recognizerWithHandler { (sender, state, location) in
            if let service = self.streamerService {
                if !service.isPlaying {
                    return
                }
                
                switch state {
                    case .Began:
                        PlayerBar.point = location
                        self.seeking = true
                    case .Changed:
                        fallthrough
                    case .Ended:
                        let x = location.x - PlayerBar.point.x
                        self.progress += x / self.width
                    default:
                        break
                }
                
                if state == .Ended {
                    if let service = SRV(StreamerService) {
                        service.currentTime = service.duration * NSTimeInterval(self.progress)
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * __uint64_t(1.0))), dispatch_get_main_queue(), {
                            self.seeking = false
                        })
                    }
                }
                
                PlayerBar.point = location
            }
        } as? UILongPressGestureRecognizer
        
        gesture?.numberOfTouchesRequired = 1
        gesture?.minimumPressDuration = 0.2
        gesture?.allowableMovement = 200
        self.addGestureRecognizer(gesture!)
    }
   
    // MARK: - 本类共有方法
    class func setContainer(container: UIView) {
        let bar = PlayerBar.shareBar()
        bar.container = container
        bar.showIfNeed()
    }
    
    class func show() {
        PlayerBar.shareBar().forceHidden = false
    }
    
    class func hide() {
        PlayerBar.shareBar().forceHidden = true
    }
    
    // MARK: - 本类私有方法
    private func showIfNeed() {
        if !self.forceHidden && !self.visiable && SRV(ArticleService)?.activeArticleModel != nil && self.container != nil {
            self.width = self.container?.width ?? 0
            self.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
            self.removeFromSuperview()
            self.container?.addSubview(self)
            self.top = self.container?.height ?? 0
            UIView.animateWithDuration(0.3, animations: { 
                self.top -= self.height
            })

            self.visiable = true
        }
    }
}
