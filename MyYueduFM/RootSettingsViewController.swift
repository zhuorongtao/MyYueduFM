//
//  RootSettingsViewController.swift
//  MyYueduFM
//
//  Created by apple on 16/5/30.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class RootSettingsViewController: SettingsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = LOC("menu_settings")
        
        if let service = SRV(SettingsService) {
            let rows1: [[String: Any]] = [
                [
                    "title": LOC("settings_flow_protection"),
                    "accessoryView": UISwitch.switchWithOn(service.flowProtection, action: { (isOn) in
                        service.flowProtection = isOn
                    })
                ]
            ]
            
            let section1: [String: Any] = [
                "header": LOC("settings_flow"),
                "footer": LOC("settings_flow_protection_prompt"),
                "rows": rows1
            ]
            
            let rows2: [[String: Any]] = [
                [
                    "title": LOC("settings_auto_close"),
                    "detail": (service.autoCloseRestTime > 0) ? String.fullStringWithSeconds(service.autoCloseRestTime) : "",
                    "config": {
                        (cell: UITableViewCell) in
                        if let setting = SRV(SettingsService) {
                            setting.bk_addObserverForKeyPath("autoCloseRestTime", task: { (target) in
                                dispatch_async(dispatch_get_main_queue(), {
                                    if let seconds = SRV(SettingsService)?.autoCloseRestTime {
                                        cell.detailTextLabel?.text = seconds > 0 ? String.fullStringWithSeconds(seconds) : nil
                                    }
                                })
                            })
                        }
                    },
                    "accessoryType": UITableViewCellAccessoryType.DisclosureIndicator,
                    "action": {
                        [weak self] (cell: UITableViewCell) in
                        let autoCloseVC = AutoCloseSettingsViewController(nibName: "AutoCloseSettingsViewController", bundle: nil)
                        self?.navigationController?.pushViewController(autoCloseVC, animated: true)
                    }
                ],
                [
                    "title": LOC("settings_clean_space"),
                    "accessoryType": UITableViewCellAccessoryType.DisclosureIndicator,
                    "action": {
                        [weak self] (cell: UITableViewCell) in
                        let clearVC = ClearSettingsViewController(nibName: "ClearSettingsViewController", bundle: nil)
                        self?.navigationController?.pushViewController(clearVC, animated: true)
                    }
                ],
                [
                    "title": LOC("settings_star"),
                    "accessoryType": UITableViewCellAccessoryType.DisclosureIndicator,
                    "action": {
                        [weak self] (cell: UITableViewCell) in
                        if let url = self?.rateURL() {
                            UIApplication.sharedApplication().openURL(url)
                        }
                    }
                ],
                [
                    "title": LOC("settings_about"),
                    "accessoryType": UITableViewCellAccessoryType.DisclosureIndicator,
                    "action": {
                        [weak self] (cell: UITableViewCell) in
                        let aboutVC = AboutViewController(nibName: "AboutViewController", bundle: nil)
                        self?.navigationController?.pushViewController(aboutVC, animated: true)
                    }
                ],
                [
                    "title": LOC("settings_version"),
                    "detail": "v\(NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] ?? "")"
                ]
            ]
            
            let section2: [String: Any] = [
                "header": "应用",
                "rows": rows2
            ]
            self.tableData = [section1, section2]
        }else {
            print("\(self)无法获取SettingsService")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func rateURL() -> NSURL? {

        var URLString = ""
        let appId = "1048612734"
        
        let version = Float(UIDevice.currentDevice().systemVersion) ?? 0.0
        
        if version >= 7.0 && version < 7.1 {
            URLString = "itms-apps://itunes.apple.com/app/id\(appId)"
        }else if version >= 8.0 {
            URLString = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(appId)"
        }else {
            URLString = "itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=\(appId)"
        }
        
        return URLString.url
    }

}
