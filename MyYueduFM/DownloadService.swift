//
//  DownloadService.swift
//  MyYueduFM
//
//  Created by apple on 16/5/13.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import Synchronized
import KVOController

extension NSObject {
    
    private struct AssociatedKey {
        static var ArticleModelIdentifier = "articleModelIdentifier"
    }
    
    var articleModel: YDSDKArticleModelEx? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.ArticleModelIdentifier) as? YDSDKArticleModelEx
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKey.ArticleModelIdentifier, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

let DownloadSeriviceDidChangedNotification   = "DownloadSeriviceDidChangedNotification"
let DownloadSeriviceDidSuccessedNotification = "DownloadSeriviceDidSuccessedNotification"
let DownloadErrorDomain = "DownloadErrorDomain"

enum DownloadErrorCode: Int {
    case AlreadyDownloading = 1000,
         AlreadyDownloaded
}

class DownloadService: BaseService {
    var taskDidFinished: ((model: YDSDKArticleModelEx) -> Void)?
    
    /// 下载代理需要的变量
    private var _session: NSURLSession?
    private var _queue: NSOperationQueue?
    private var _baseDirectory: String?
    var backgroundTransferCompletionHandler: (() -> Void)?
    
    
    required init(serviceCenter: ServiceCenter) {
        super.init(serviceCenter: serviceCenter)
        self.setupURLSession()
        self.setupDirectory()
        self.setupTasks()
        
        SRV(ReachabilityService)?.bk_addObserverForKeyPath("status", task: { (target) in
            if let status = SRV(ReachabilityService)?.status {
                switch status {
                case .ReachableViaWiFi:
                    fallthrough
                case .ReachableViaWWAN:
                    self.setupTasks()
                default:
                    break
                }
            }
        })
        
//        SRV(ReachabilityService)?.status
//        
//        self.KVOController.observe(SRV(ReachabilityService), keyPath: "status", options: [.Initial, .New]) { (_, _, _) in
//            if let status = SRV(ReachabilityService)?.status {
//                switch status {
//                case .ReachableViaWiFi:
//                    fallthrough
//                case .ReachableViaWWAN:
//                    self.setupTasks()
//                default:
//                    break
//                }
//            }
//        }
        
        
    }

    override func start() {
        _session?.getTasksWithCompletionHandler({ (daraTasks, uploadTasks, downloadTasks) in
            if let status = SRV(ReachabilityService)?.status {
                //空任务, 则从数据库读取
                if downloadTasks.count == 0 {
                    SRV(ArticleService)?.listAllDownloading({ (array) in
                        if let array = array as? [YDSDKArticleModelEx] {
                            array.forEach({ (obj) in
                                self.download(obj, protect: status == .ReachableViaWWAN, preprocess: nil)
                            })
                        }
                    })
                }
            }else {
    
                print("网络状态为空!")
            }
        })
    }
    
    // MARK: - 本类共有方法
    func state(completion: ((downloading: Bool) -> Void)?) {
        _session?.getTasksWithCompletionHandler({ (dadaTasks, uploadTasks, downloadTasks) in
            completion?(downloading: downloadTasks.count != 0)
        })
    }
    
    func playableURLForModel(model: YDSDKArticleModelEx?) -> NSURL? {
        if model == nil {
            return nil
        }
        
        if let downloadURLString = model?.downloadURLString {
            if let baseDirectory = _baseDirectory where downloadURLString.characters.count != 0 {
                let absoluteString = "\(baseDirectory)/\(downloadURLString))"
                let exist = NSFileManager.defaultManager().fileExistsAtPath(absoluteString)
                return exist ? absoluteString.fileURL : model?.audioURL.url
            }else {
                return model?.audioURL.url
            }
        }else {
            return model?.audioURL.url
        }
    }
    
    func download(model: YDSDKArticleModelEx, preprocess: ((error: NSError?) -> Void)?) {
        self.download(model, protect: false, preprocess: preprocess)
    }
    
    func download(model: YDSDKArticleModelEx, protect: Bool, preprocess: ((error: NSError?) -> Void)?) {
        SRV(ArticleService)?.update(model, completion: { (newModel) in
            synchronized(self, closure: { 
                if newModel.downloadState == .Successed {
                    preprocess?(error: NSError(domain: DownloadErrorDomain, code: DownloadErrorCode.AlreadyDownloaded.rawValue, userInfo: nil))
                }else {
                    self._session?.getTasksWithCompletionHandler({ (dataTasks, uploadTasks, downloadTasks) in
                        var downloading = false
                        (downloadTasks as NSArray).enumerateObjectsUsingBlock({ (obj, index, stop) in
                            let tk = obj as? NSURLSessionDownloadTask
                            let aModel = tk!.articleModel
                            if aModel == model || tk!.originalRequest!.URL!.absoluteString == model.audioURL {
                                downloading = true
                                stop.memory = true
                            }
                        })
                        
                        var error: NSError?
                        if !downloading {
                            self.didDownload(model, protect: protect)
                        }else {
                            error = NSError(domain: DownloadErrorDomain, code: DownloadErrorCode.AlreadyDownloading.rawValue, userInfo: nil)
                        }
                        
                        preprocess?(error: error)
                    })
                }
            })
        })
    }
    
    func deleteAllDownloadedFiles() {
        do {
            try NSFileManager.defaultManager().removeItemAtPath(_baseDirectory!)
            self.setupDirectory()
        }catch {
            print("清除下载文件失败")
        }
    }
    
    func cacheSize() -> UInt64 {
        return NSFileManager.defaultManager().fileSizeAtPath(_baseDirectory!)
    }
    
    func list(comletion: ((tasks: [AnyObject]?) -> Void)?) {
        _session?.getTasksWithCompletionHandler({ (dataTasks, uploadTasks, downloadTasks) in
            var array = [NSURLSessionDownloadTask]()
            (downloadTasks as NSArray).enumerateObjectsUsingBlock({ (obj, index, stop) in
                if let task = obj as? NSURLSessionDownloadTask {
                    if task.state == .Running || task.state == .Suspended {
                        array.append(task)
                    }
                }
            })
            
            //从小到大排序
            array.sortInPlace({
                $0.taskIdentifier < $1.taskIdentifier
            })
            
            comletion?(tasks: array)
        })
    }
    
    func deleteTask(task: NSURLSessionTask) {
        task.cancel()
        task.articleModel?.downloadState = .Canceled
        if let model = task.articleModel {
            SRV(DataService)?.writeData(model, completion: nil)
        }
    }
    
    func deleteAllTask(completion: (() -> Void)?) {
        _session?.getTasksWithCompletionHandler({ (dataTasks, uploadTasks, downloadTasks) in
            downloadTasks.forEach({
                $0.articleModel?.downloadState = DownloadState.Canceled
                $0.cancel()
                if let model = $0.articleModel {
                    SRV(DataService)?.writeData(model, completion: nil)
                }
            })
            
            completion?()
        })
    }
    
    // MARK: - 本类私有方法
    private func setupURLSession() {
        var configuration: NSURLSessionConfiguration?
        if SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO("8") {
            configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(NSBundle.mainBundle().bundleIdentifier!)
        }else {
            configuration = NSURLSessionConfiguration.backgroundSessionConfiguration(NSBundle.mainBundle().bundleIdentifier!)
        }
        
        configuration?.HTTPMaximumConnectionsPerHost = 1
        
        _session = NSURLSession(configuration: configuration!, delegate: self, delegateQueue: _queue)
    }
    
    private func setupDirectory() {
        _baseDirectory = "\(NSHomeDirectory())/Documents/Dowloads"
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(_baseDirectory!, withIntermediateDirectories: true, attributes: nil)
        }catch {
            print("创建下载路径失败")
        }
    }
    
    private func setupTasks() {
        _session?.getTasksWithCompletionHandler({ (dataTasks, uploadTasks, downloadTasks) in
            let service = SRV(ArticleService)
            let status = SRV(ReachabilityService)?.status
            
            downloadTasks.forEach({ (obj) in
                let task = obj
                service?.modelForAudioURLString(task.originalRequest!.URL!.absoluteString, completion: { (model) in
                    task.articleModel = model
                })
                
                if let status = status where status == .ReachableViaWWAN {
                    task.suspend()
                }else {
                    task.resume()
                }
            })
        })
    }
    
    private func didDownload(model: YDSDKArticleModelEx, protect: Bool) {
        let task = _session?.downloadTaskWithURL(model.audioURL.url!)
        task?.articleModel = model
        if protect {
            task?.resume()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                sleep(1)
                task?.suspend()
            })
        }else {
            task?.resume()
        }
        model.downloadState = .Doing
        model.downloadDate = NSDate()
        SRV(DataService)?.writeData(model, completion: nil)
        NSNotificationCenter.defaultCenter().postNotificationName(DownloadSeriviceDidChangedNotification, object: nil)
    }
    
    private func compareTask(obj1: AnyObject, obj2: AnyObject, contex: Void) -> Int {
        let task1 = obj1 as? NSURLSessionDownloadTask
        let task2 = obj2 as? NSURLSessionDownloadTask
        
        if task1?.taskIdentifier > task2?.taskIdentifier {
            return NSComparisonResult.OrderedDescending.rawValue
        }else if task1?.taskIdentifier == task2?.taskIdentifier {
            return NSComparisonResult.OrderedSame.rawValue
        }else {
            return NSComparisonResult.OrderedAscending.rawValue
        }
    }
    
}

// MARK: - NSURLSessionDownloadDelegate
extension DownloadService: NSURLSessionDownloadDelegate {
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        let URLString = self.URLStringWithTask(downloadTask)
        do {
            try NSFileManager.defaultManager().removeItemAtPath(URLString)
        }catch {
        }
        
        do {
            try NSFileManager.defaultManager().moveItemAtURL(location, toURL: NSURL(fileURLWithPath: URLString))
            
            if let model = downloadTask.articleModel {
                model.downloadState = .Successed
                model.downloadURLString = (URLString as NSString).lastPathComponent
                SRV(DataService)?.writeData(model, completion: {
                    NSNotificationCenter.defaultCenter().postNotificationName(DownloadSeriviceDidChangedNotification, object: nil)
                })
                
                self.taskDidFinished?(model: model)
            }else {
                print("下载任务中没有对应的model")
            }
        }catch let error {
            print("文件移动出错: \(error)")
        }
    }
    
    func URLSessionDidFinishEventsForBackgroundURLSession(session: NSURLSession) {
        if let sessTemp = self._session where sessTemp != session {
            return
        }
        session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            if downloadTasks.count == 0 {
                if self.backgroundTransferCompletionHandler != nil {
                    let completionHandler = self.backgroundTransferCompletionHandler
                    NSOperationQueue.mainQueue().addOperationWithBlock({ 
                        completionHandler?()
                        let localNotification = UILocalNotification()
                        localNotification.alertBody = LOC("playlist_none_prompt")
                        UIApplication.sharedApplication().presentLocalNotificationNow(localNotification)
                    })
                    self.backgroundTransferCompletionHandler = nil
                }
            }
        }
    }
    
    private func URLStringWithTask(task: NSURLSessionDownloadTask) -> String {
        return "\(_baseDirectory!)/\((task.articleModel!.audioURL as NSString).lastPathComponent)"
    }
}
