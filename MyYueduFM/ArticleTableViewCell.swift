//
//  ArticleTableViewCell.swift
//  MyYueduFM
//
//  Created by apple on 16/5/26.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import TTTAttributedLabelVodafone

class ArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var detailLabel: TTTAttributedLabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var rhythmView: RhythmView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var speakerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton?
    
    private var streamerService: StreamerService?
    
    private var _playing: Bool = false
    var playing: Bool {
        get {
            return self._playing
        }
        set {
            self._playing = newValue
            if newValue {
                if let _ = self.rhythmView {
                    self.rhythmView.startAnimating()
                }
            }else {
                if let _ = self.rhythmView {
                    self.rhythmView.stopAnimating()
                }
            }
        }
    }
    
    private var _model: YDSDKArticleModelEx!
    var model: YDSDKArticleModelEx {
        get {
            return _model
        }
        set {
            self.bk_removeAllBlockObservers()
            self._model = newValue

            self.pictureView.sd_setImageWithURL(newValue.pictureURL.url, placeholderImage: UIImage.imageWithColor(UIColor.colors[Int(newValue.aid % Int32(UIColor.colors.count))]))
            self.titleLabel.text    = newValue.title
            self.authorLabel.text   = newValue.author
            self.speakerLabel.text  = newValue.speaker
            self.durationLabel.text = String.stringWithSeconds(newValue.duration)
            self.detailLabel.text   = newValue.abstract
            self.playing            = self.isMyPlaying()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.pictureView.layer.cornerRadius = 3
        self.pictureView.clipsToBounds = true
        
        self.streamerService = SRV(StreamerService)
        self.detailLabel.verticalAlignment = .Top
        self.detailLabel.lineSpacing = 2
        
        self.playButton.bk_addEventHandler({
            [weak self](sender) in
            if let weakSelf = self {
                SRV(DataService)?.writeData(weakSelf.model, completion: nil)
                weakSelf.streamerService?.play(weakSelf.model)
            }
            }, forControlEvents: .TouchUpInside)
        
        self.addObserver()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    deinit {
        self.bk_removeAllBlockObservers()
    }
    
    // MARK: - 本类私有方法
    private func isMyPlaying() -> Bool {
        if let service = self.streamerService, playingModel = service.playingModel {
            return service.isPlaying && playingModel.aid == self.model.aid
        }
        return false
    }
    
    private func addObserver() {
        self.streamerService?.bk_addObserverForKeyPath("isPlaying", task: {
            [weak self] (target) in
            if let weakSelf = self {
                if weakSelf.isMyPlaying() {
                    weakSelf.playing = true
                }else {
                    weakSelf.playing = false
                }
            }
        })
    }
    
}
