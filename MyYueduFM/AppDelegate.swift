//
//  AppDelegate.swift
//  MyYueduFM
//
//  Created by apple on 16/5/12.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import SVProgressHUD
import RESideMenu

let __appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var sideMenu: RESideMenu?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        self.window = UIWindow()
        self.window?.frame = UIScreen.mainScreen().bounds
        self.window?.makeKeyAndVisible()
        application.statusBarHidden = false
        
        self.setupAppearance()
        self.setupService()
        
        let mainVC = MainViewController(nibName: "MainViewController", bundle: nil)
        
        let nVC = UINavigationController(rootViewController: mainVC)
        nVC.navigationBar.translucent = false
        nVC.navigationBar.barTintColor = kThemeColor
        nVC.navigationBar.tintColor = UIColor.whiteColor()
        nVC.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor()
        ]
        nVC.navigationBar.barStyle = .Black
        
        let menuVC = MenuViewController(nibName: "MenuViewController", bundle: nil)
        
        self.sideMenu = RESideMenu.init(contentViewController: nVC, leftMenuViewController: menuVC, rightMenuViewController: nil)!
        
        PlayerBar.setContainer(self.sideMenu!.view)
        
        self.showGuideViewIfNeed()
        
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        self.becomeFirstResponder()
        ServiceCenter.defaultCenter.stopAllServices()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        var bgTask: UIBackgroundTaskIdentifier = 0
        bgTask = application.beginBackgroundTaskWithExpirationHandler {
            dispatch_async(dispatch_get_main_queue(), { 
                if bgTask != UIBackgroundTaskInvalid {
                    bgTask = UIBackgroundTaskInvalid
                }
            })
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
            dispatch_async(dispatch_get_main_queue(), { 
                if bgTask != UIBackgroundTaskInvalid {
                    bgTask = UIBackgroundTaskInvalid
                }
            })
        }
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
        ServiceCenter.defaultCenter.startAllServices()
        self.resignFirstResponder()
    }

    func applicationWillTerminate(application: UIApplication) {
    }
    
    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void) {
        SRV(DownloadService)?.backgroundTransferCompletionHandler = completionHandler
    }

    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        SRV(StreamerService)?.remoteControlReceivedWithEvent(event)
    }
    
    // MARK: - 本类私有方法
    private func setupAppearance() {
        UIBarButtonItem.appearance().tintColor = kThemeColor
        let image = UIImage(named: "icon_nav_back.png")?.resizableImageWithCapInsets(UIEdgeInsetsMake(0, 25, 0, 0))
        UIBarButtonItem.appearance().setBackButtonBackgroundImage(image, forState: .Normal, barMetrics: .Default)
        SVProgressHUD.setDefaultMaskType(.Black)
    }
    
    private func setupService() {
        ServiceCenter.defaultCenter.setup()
        SRV(DownloadService)?.taskDidFinished = {
            (model) in
            dispatch_async(dispatch_get_main_queue(), { 
                MessageKit.showWithSuccessedMessage("\(model.title) \(LOC("download_done_prompt"))")
            })
        }
    }
    
    private func showGuideViewIfNeed() {
        if let firstLaunch = USER_CONFIG("FirstLaunch") as? String {
            if firstLaunch != "true" {
                self.showGuideView()
            }else {
                self.window?.rootViewController = self.sideMenu
            }
        }else {
            self.showGuideView()
        }
        USER_SET_CONFIG("FirstLaunch", value: "true")
    }
    
    private func showGuideView() {
        let guideVC = GuideViewController()
        guideVC.guideDidFinished = {
            [weak self] in
            dispatch_async(dispatch_get_main_queue(), {
                self?.window?.rootViewController = self?.sideMenu
                self?.window?.makeKeyAndVisible()
            })
        }
        
        self.window?.rootViewController = guideVC
    }
}

