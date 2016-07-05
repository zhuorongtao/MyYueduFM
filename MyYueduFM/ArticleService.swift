//
//  ArticleService.swift
//  MyYueduFM
//
//  Created by apple on 16/5/13.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import YueduFMSDK

/// 文章的服务
class ArticleService: BaseService {
    dynamic var activeArticleModel: YDSDKArticleModelEx?
    
    override class func level() -> ServiceLevel {
        return .Middle
    }
    
    override func start() {
        self.autoFetch(nil)
        self.updateActiveArticleModel()
    }
    
    required init(serviceCenter: ServiceCenter) {
        super.init(serviceCenter: serviceCenter)
        self.dataManger()?.registerClass(YDSDKArticleModelEx.classForCoder(), complete: nil)
    }
    
    // MARK: - 本类公有方法
    func fetchLatest(completion: ((error: NSError?) -> Void)?) {
        self.dataManger()?.count(YDSDKArticleModelEx.self, condition: nil, complete: { (successed, result) in
            if let result = result as? NSNumber {
                let none = successed && (result.intValue == 0)
                self.fetch(0, completion: { (array, error) in
                    if error == nil {
                        if self.activeArticleModel == nil {
                            self.activeArticleModel = YDSDKArticleModelEx.objectFromSuperObject(array!.firstObject) as? YDSDKArticleModelEx
                        }
                        
                        //为了防止第一次数据不够，多加载一次
                        if none {
                            self.autoFetch({ 
                                completion?(error: error)
                            })
                        }else {
                            self.autoFetch(nil)
                            completion?(error: error)
                        }
                    }else {
                        completion?(error: error)
                    }
                })
            }
        })
    }
    
    // MARK; - 最近本地文章
    func latestLocalArticle(completion: ((model: YDSDKArticleModelEx?) -> Void)?) {
        self.dataManger()?.read(YDSDKArticleModelEx.self, condition: "state=\(YDSDKModelState.Normal.rawValue) ORDER BY aid DESC LIMIT 0,1", complete: { (successed, result) in
            completion?(model: successed ? (result as? [YDSDKArticleModelEx])?.first : nil)
        })
    }
    
    // MARK: - 列表
    func list(count: Int, channel: Int, completion: ((array: NSArray?) -> Void)?) {
        self.checkout(count, channel: channel, completion: completion)
    }
    
    // MARK: - 搜索
    func list(count: Int, filter: String?, completion: ((array: [AnyObject]?) -> Void)?) {
        if filter == nil || filter!.characters.count == 0 {
            completion?(array: nil)
        }else {
            self.dataManger()?.read(YDSDKArticleModelEx.self, condition: "title LIKE '%%\(filter!)%%' OR author LIKE '%%\(filter!)%%' OR speaker LIKE '%%\(filter!)%%'  LIMIT 0, \(count)", complete: { (successed, result) in
                completion?(array: successed ? (result as? [AnyObject]) : nil)
            })
        }
    }
    
    // MARK: - 我的列表
    func listPreplay(count: Int, completion: ((array: [AnyObject]?) -> Void)?) {
        self.dataManger()?.read(YDSDKArticleModelEx.self, condition: "preplayDate > 0 ORDER BY preplayDate LIMIT 0, \(count)", complete: { (successed, result) in
            completion?(array: successed ? (result as? [AnyObject]) : nil)
        })
    }
    
    func nextPreplay(model: YDSDKArticleModelEx?, completion: ((nextModel: YDSDKArticleModelEx?) -> Void)?) {
        self.dataManger()?.read(YDSDKArticleModelEx.self, condition: "preplayDate > \(Float(model?.preplayDate.timeIntervalSince1970 ?? 0)) ORDER BY preplayDate LIMIT 0, 1", complete: { (successed, result) in
            completion?(nextModel: successed ? (result as? [YDSDKArticleModelEx])?.first : nil)
        })
    }
    
    func deleteAllPreplay(completion: (() -> Void)?) {
        self.dataManger()?.read(YDSDKArticleModelEx.self, condition: "preplayDate>0", complete: { (successed, result) in
            if successed {
                var array = [AnyObject]()
                (result as? NSArray)?.enumerateObjectsUsingBlock({ (obj, index, stop) in
                    if let model = obj as? YDSDKArticleModelEx {
                        model.preplayDate = NSDate(timeIntervalSince1970: 0)
                        array.append(model)
                    }
                })
                
                self.dataManger()?.writeObjects(array, complete: { (successed, result) in
                    completion?()
                })
            }else {
                completion?()
            }
        })
    }
    
    // MARK: - 最近播放
    func listPlayed(count: Int, completion: ((array: [AnyObject]?) -> Void)?) {
        self.dataManger()?.read(YDSDKArticleModelEx.self, condition: "playedDate > 0 ORDER BY playedDate DESC LIMIT 0, \(count)", complete: { (successed, result) in
            completion?(array: successed ? (result as? [AnyObject]) : nil)
        })
    }
    
    func deleteAllPlayed(completion: (() -> Void)?) {
        self.dataManger()?.read(YDSDKArticleModelEx.self, condition: "playedDate>0", complete: { (successed, result) in
            if successed {
                var array = [AnyObject]()
                (result as? NSArray)?.enumerateObjectsUsingBlock({ (obj, index, stop) in
                    if let model = obj as? YDSDKArticleModelEx {
                        model.playedDate = NSDate(timeIntervalSince1970: 0)
                        array.append(model)
                    }
                })
                self.dataManger()?.writeObjects(array, complete: { (successed, result) in
                    completion?()
                })
            }else {
                completion?()
            }
        })
    }
    
    // MARK: - 下载
    func listAllDownloading(completion: ((array: [AnyObject]?) -> Void)?) {
        self.dataManger()?.read(YDSDKArticleModelEx.self, condition: "downloadState=\(DownloadState.Doing.rawValue) ORDER BY downloadDate DESC", complete: { (successed, result) in
            completion?(array: successed ? (result as? [AnyObject]) : nil)
        })
    }
    
    func listDownloaded(count: Int, completion: ((array: [AnyObject]?) -> Void)?) {
        self.dataManger()?.read(YDSDKArticleModelEx.self, condition: "downloadState=\(DownloadState.Successed.rawValue) ORDER BY downloadDate DESC LIMIT 0, \(count)", complete: { (successed, result) in
            completion?(array: successed ? (result as? [AnyObject]) : nil)
        })
    }
    
    func deleteDownloaded(model: YDSDKArticleModelEx, completion: ((successed: Bool) -> Void)?) {
        model.downloadState = .Normal
        do {
            try NSFileManager.defaultManager().removeItemAtPath(model.downloadURLString!)
        }catch {
        }
        
        self.dataManger()?.writeObject(model, complete: { (successed, result) in
            completion?(successed: successed)
        })
    }
    
    func deleteAllDownloaded(completion: (() -> Void)?) {
        self.dataManger()?.read(YDSDKArticleModelEx.self, condition: "downloadState=\(DownloadState.Successed.rawValue)", complete: { (successed, result) in
            if successed {
                var array: [YDSDKArticleModelEx] = []
                (result as? NSArray)?.enumerateObjectsUsingBlock({ (obj, index, stop) in
                    if let model = obj as? YDSDKArticleModelEx {
                        model.downloadState = .Normal
                        array.append(model)
                    }
                })
                
                self.dataManger()?.writeObjects(array, complete: { (successed, result) in
                    completion?()
                })
            }else {
                
                completion?()
            }
            
            SRV(DownloadService)?.deleteAllDownloadedFiles()
        })
    }
    
    func modelForAudioURLString(URLString: String, completion: ((model: YDSDKArticleModelEx?) -> Void)?) {
        self.dataManger()?.read(YDSDKArticleModelEx.self, condition: "audioURL='\(URLString)' LIMIT 0, 1", complete: { (successed, result) in
            completion?(model: successed ? (result as? [YDSDKArticleModelEx])?.first : nil)
        })
    }
    
    // MARK: - 收藏
    func listFavored(count: Int, completion: ((array: [AnyObject]?) -> Void)?) {
        self.dataManger()?.read(YDSDKArticleModelEx.self, condition: "isFavored=1 ORDER BY aid DESC LIMIT 0, \(count)", complete: { (successed, result) in
            completion?(array: successed ? (result as? [AnyObject]) : nil)
        })
    }
    
    func deleteAllFavored(completion: (() -> Void)?) {
        self.dataManger()?.read(YDSDKArticleModelEx.self, condition: "isFavored=1", complete: { (successed, result) in
            if successed {
                var array = [AnyObject]()
                (result as? NSArray)?.enumerateObjectsUsingBlock({ (obj, index, stop) in
                    if let model = obj as? YDSDKArticleModelEx {
                        model.isFavored = false
                        array.append(model)
                    }
                })
                
                self.dataManger()?.writeObjects(array, complete: { (successed, result) in
                    completion?()
                })
            }else {
                completion?()
            }
        })
    }
    
    func update(model: YDSDKArticleModelEx, completion: ((newModel: YDSDKArticleModelEx) -> Void)?) {
        self.dataManger()?.read(YDSDKArticleModelEx.self, condition: "aid=\(model.aid)", complete: { (successed, result) in
            let newModel = successed ? (result as? [AnyObject])?.first : nil
            if let newModel = newModel as? YDSDKArticleModelEx {
                model.updateForObject(newModel)
                completion?(newModel: model)
            }else {
        
            }
        })
    }
    
    // MARK: - 本类私有方法
    private func fetch(articleId: Int32, completion: ((array: NSArray?, error: NSError?) -> Void)?) {
        SRV(ConfigService)?.fetch({ (error) in
            let req = YDSDKArticleListRequest() //请求文章
            req.articleId = articleId
            self.netManger().request(req, completion: { (request, error) in
                if error == nil {
                    let cursorModel = YDSDKArticleModel()
                    cursorModel.aid = articleId
                    var data = req.modelArray
                    self.dataManger()?.deleteObject(cursorModel, complete: { (successed, result) in
                        let writeBlock = {
                            (array: [AnyObject]) in
                            self.dataManger()?.writeObjects(array, complete: { (successed, result) in
                                completion?(array: array, error: nil)
                            })
                        }
                        if req.next != 0 {
                            let nextModel = YDSDKArticleModelEx()
                            nextModel.aid = req.next
                            nextModel.state = .Incomplete
                            self.dataManger()?.isExist(nextModel, complete: { (successed, result) in
                                if !successed {
                                    data.append(nextModel)
                                }
                                writeBlock(data)
                            })
                        }else {
                            
                            writeBlock(data)
                        }
                    })
                }else {
                    
                    completion?(array: nil, error: error)
                }
            })
        })
    }
    
    private func autoFetch(completion: (() -> Void)?) {
        self.dataManger()?.read(YDSDKArticleModelEx.classForCoder(), condition: "state=\(YDSDKModelState.Incomplete.rawValue) ORDER BY aid DESC LIMIT 0,1", complete: { (successed, result) in
            if let result = result as? NSArray {
                if successed && (result.count > 0) {
                    let model = result.firstObject
                    if let obj = model as? YDSDKArticleModelEx {
                        self.fetch(obj.aid, completion: { (array, error) in
                            completion?()
                            self.autoFetch(nil)
                        })
                    }
                }else {
                    completion?()
                }
            }else {
                completion?()
            }
        })
    }
    
    private func checkout(count: Int, channel: Int, completion: ((array: NSArray?) -> Void)?) {
        if channel != 0 {
            self.dataManger()?.read(YDSDKArticleModelEx.self, condition: "state=\(YDSDKModelState.Normal.rawValue) and channel=\(channel) ORDER BY aid DESC LIMIT 0, \(count)", complete: { (successed, result) in
                completion?(array: successed ? (result as? NSArray) : nil)
            })
        }else {
            self.dataManger()?.read(YDSDKArticleModelEx.self, condition: "state=\(YDSDKModelState.Normal.rawValue) ORDER BY aid DESC LIMIT 0, \(count)", complete: { (successed, result) in
                completion?(array: successed ? (result as? NSArray) : nil)
            })
        }
    }
    
    private func updateActiveArticleModel() {
        if self.activeArticleModel == nil {
            //获取最近播放的一篇文章
            self.listPreplay(1, completion: { (array) in
                if let model = array?.first as? YDSDKArticleModelEx {
                    self.activeArticleModel = model
                }
            })
        }
    }
}
