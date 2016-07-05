//
//  StreamerService.swift
//  MyYueduFM
//
//  Created by apple on 16/5/13.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import AVFoundation

import DOUAudioStreamer
import BlocksKit
import SVProgressHUD
import SDWebImage
import Reachability

import MediaPlayer

class StreamerService: BaseService {
    
    private var _imageView: UIImageView
    dynamic var isPlaying = false
    var playingModel: YDSDKArticleModelEx?
    private var _streamer: DOUAudioStreamer?
    
    private var updateDate: NSDate
    
    private var _nowPlayingInfo: [String: AnyObject]!
    private var nowPlayingInfo: [String: AnyObject] {
        get {
            return _nowPlayingInfo
        }
        set {
            _nowPlayingInfo = newValue
            
            //防止频繁更新而导致程序奔溃
            if (NSDate.timeIntervalSinceReferenceDate() - self.updateDate.timeIntervalSinceReferenceDate) > 0.1 {
                MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = newValue
                self.updateDate = NSDate()
            }
        }
    }
    
    var currentTime: NSTimeInterval {
        get {
            return self.playingModel != nil ? self._streamer!.currentTime : 0
        }
        set {
            self._streamer?.currentTime = newValue
            var info = self.nowPlayingInfo
            info[MPMediaItemPropertyPlaybackDuration] = _streamer!.duration
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = newValue
            self.nowPlayingInfo = info
        }
    }
    
    var duration: NSTimeInterval {
        return self.playingModel != nil ? _streamer!.duration : 0
    }
    
    required init(serviceCenter: ServiceCenter) {
        self._imageView = UIImageView()
        self.updateDate = NSDate()
        super.init(serviceCenter: serviceCenter)
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
            try session.setActive(true)
        }catch let error {
            print("后台播放出错: \(error)")
        }
        
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        
    }
    
    deinit {
        print("\(self.classForCoder)已销毁")
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
    }
    
    override func start() {
        self.isPlaying = false
    }
    
    func play(model: YDSDKArticleModelEx?) {
        if model == nil {
            return
        }
        
        if model!.audioURL != self.playingModel?.audioURL {
            self.playingModel = model
            SRV(ArticleService)?.activeArticleModel = model
            model?.playedDate = NSDate()
            SRV(DataService)?.writeData(model!, completion: nil)
            
            _streamer?.bk_removeAllBlockObservers()
            _streamer?.stop()
            _streamer = DOUAudioStreamer(audioFile: SRV(DownloadService)?.playableURLForModel(self.playingModel)?.audioFileURL())
            _streamer?.bk_addObserverForKeyPath("duration", task: { (target) in
                self.updateNowPlayingPlayback()
            })
            
            _streamer?.bk_addObserverForKeyPath("status", task: { (target) in
                if self._streamer?.status == .Finished {
                    self.isPlaying = false
                    self.playingModel?.preplayDate = NSDate(timeIntervalSince1970: 0)
                    if let playingModel = self.playingModel {
                        SRV(DataService)?.writeData(playingModel, completion: nil)
                    }
                    self.next()
                    self.playingModel = nil
                }else if self._streamer?.status == .Paused {
                    self.isPlaying = false
                }
            })
            
            let info = [
                MPMediaItemPropertyTitle: model!.title,
                MPMediaItemPropertyAlbumTitle: model!.author,
                MPMediaItemPropertyArtist: model!.speaker,
                MPNowPlayingInfoPropertyPlaybackRate: 1
            ]
            
            self.nowPlayingInfo = info as! [String : AnyObject]
            
            self._imageView.sd_setImageWithURL(model?.pictureURL.url, completed: { (image, error, cacheType, imageURL) in
                if image != nil {
                    self.nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image)
                }
            })
        }
        
        //在线资源需要验证网路连接情况
        if !_streamer!.url.fileURL {
            if SRV(ReachabilityService)?.status == .NotReachable {
                dispatch_async(dispatch_get_main_queue(), {
                    if let statusString = SRV(ReachabilityService)?.statusString {
                        SVProgressHUD.showInfoWithStatus(statusString)
                    }
                })
                self.isPlaying = false
            }else if SRV(ReachabilityService)!.status == NetworkStatus.ReachableViaWWAN && SRV(SettingsService)!.flowProtection {
                dispatch_async(dispatch_get_main_queue(), {
                    if let statusString = SRV(ReachabilityService)?.statusString {
                        SVProgressHUD.showInfoWithStatus(statusString) 
                    }
                })
                
                _streamer?.play()
                self.isPlaying = true
            }else {
                _streamer?.play()
                self.isPlaying = true
            }
        }else {
            _streamer?.play()
            self.isPlaying = true
        }
    }
    
    func next() {
        SRV(ArticleService)?.nextPreplay(playingModel, completion: { (nextModel) in
            if nextModel != nil {
                if let _ = self.playingModel {
                    self.playingModel?.preplayDate = NSDate(timeIntervalSince1970: 0)
                    SRV(DataService)?.writeData(self.playingModel!, completion: nil)
                }
                self.play(nextModel)
            }else {
                dispatch_async(dispatch_get_main_queue(), {
                    SVProgressHUD.showInfoWithStatus(LOC("playlist_none_prompt"))
                })
            }
        })
    }
    
    func pause() {
        _streamer?.pause()
        self.isPlaying = false
    }
    
    func resume() {
        self.play(self.playingModel)
        self.updateNowPlayingPlayback()
    }
    
    func remoteControlReceivedWithEvent(event: UIEvent?) {
        if let event = event {
            switch event.subtype {
            case .RemoteControlPlay:
                self.resume()
            case .RemoteControlPause:
                self.pause()
            case .RemoteControlNextTrack:
                self.next()
            default:
                break
            }
        }
    }
    
    // MARK: - 本类私有方法
    private func updateNowPlayingPlayback() {
        var info = self.nowPlayingInfo
        info[MPMediaItemPropertyPlaybackDuration] = _streamer!.duration
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = _streamer!.currentTime
        self.nowPlayingInfo = info
    }
    
}
