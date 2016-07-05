
//
//  MenuViewController.swift
//  MyYueduFM
//
//  Created by apple on 16/5/27.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

private let kCellIdentifier = "kCellIdentifier"

class MenuViewController: BaseViewController {

    @IBOutlet weak var headerView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    private var tableData: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableData.append([
            "image": "icon_menu_playlist.png",
            "title": LOC("menu_playlist"),
            "action": {
                [weak self] () in
                let playVC = PlayListViewController(nibName: "PlayListViewController", bundle: nil)
                self?.pushViewController(playVC)
            }
        ])
        
        if let config = SRV(ConfigService)?.config {
            if config.allowDownload {
                self.tableData.append([
                    "image": "icon_menu_download.png",
                    "title": LOC("menu_download"),
                    "action": {
                        [weak self] () in
                        let downloadVC = DownloadViewController(nibName: "DownloadViewController", bundle: nil)
                        self?.pushViewController(downloadVC)
                    }
                ])
            }
        }
        
        self.tableData.append([
                "image": "icon_menu_favor.png",
                "title": LOC("menu_favor"),
                "action": {
                    [weak self] () in
                    let favorVC = FavorViewController(nibName: "FavorViewController", bundle: nil)
                    self?.pushViewController(favorVC)
                }
            ])
        
        self.tableData.append([
                "image": "icon_menu_history.png",
                "title": LOC("menu_history"),
                "action": {
                    [weak self] () in
                    let historyVC = HistoryViewController(nibName: "HistoryViewController", bundle: nil)
                    self?.pushViewController(historyVC)
                }
            ])
        
        self.tableData.append([
                "image": "icon_menu_settings.png",
                "title": LOC("menu_settings"),
                "action": {
                    [weak self] () in
                    let rootVC = RootSettingsViewController(nibName: "RootSettingsViewController", bundle: nil)
                    self?.pushViewController(rootVC)
                }
            ])
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: kCellIdentifier)
        self.tableView.delegate   = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = 50
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

    private func pushViewController(viewController: UIViewController) {
        (self.sideMenuViewController.contentViewController as? UINavigationController)?.pushViewController(viewController, animated: true)
        self.sideMenuViewController.hideMenuViewController()
    }
    
    deinit {
        print("MenuViewController销毁")
    }
    
}

// MARK: - UITableViewDataSource
extension MenuViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellIdentifier, forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.textColor = UIColor.whiteColor()
        cell.accessoryView = UIImageView(image: UIImage(named: "icon_menu_accessory.png"))
        let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, 100, 40))
        selectedBackgroundView.backgroundColor = RGBA(0, G: 0, B: 0, A: 0.2)
        cell.selectedBackgroundView = selectedBackgroundView
        
        let item = self.tableData[indexPath.row]
        cell.imageView?.image = UIImage(named: item["image"] as? String ?? "")
        cell.textLabel?.text = item["title"] as? String ?? ""
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension MenuViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let item = self.tableData[indexPath.row]
        
        if let closure = item["action"] as? () -> Void {
            closure()
        }
    }
}
