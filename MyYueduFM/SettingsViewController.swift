//
//  SettingsViewController.swift
//  MyYueduFM
//
//  Created by apple on 16/5/30.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

private struct SettingsIndetifier {
    static var kCellIdentifier = "kCellIdentifier"
}

class SettingsViewController: BaseViewController {

    @IBOutlet var tableView: UITableView!
    var tableData: [[String: Any]]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame: self.view.bounds, style: .Grouped)
        self.tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.view.addSubview(self.tableView)
        
        self.tableView.registerNib(UINib(nibName: "RightAlignedTableViewCell", bundle: nil), forCellReuseIdentifier: SettingsIndetifier.kCellIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension SettingsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.tableData?[section]["rows"] as? [[String: Any]])?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SettingsIndetifier.kCellIdentifier, forIndexPath: indexPath)
        
        if let info = (self.tableData?[indexPath.section]["rows"] as? [[String: Any]])?[indexPath.row] {
            cell.textLabel?.text = info["title"] as? String
            cell.detailTextLabel?.text = info["detail"] as? String
            cell.accessoryView = info["accessoryView"] as? UIView
            
            if let typeNumber = info["accessoryType"] as? UITableViewCellAccessoryType {
                cell.accessoryType = typeNumber
            }else {
               cell.accessoryType = .None
            }
            
            let config = info["config"] as? ((cell: UITableViewCell) -> Void)
            config?(cell: cell)
        }else if let info = (self.tableData?[indexPath.section]["rows"] as? [[String: NSObject]])?[indexPath.row] {
            cell.textLabel?.text = info["title"] as? String
            cell.accessoryView = info["accessoryView"] as? UIView
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.tableData?.count ?? 0
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.tableData?[section]["header"] as? String ?? ""
    }
    
    func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.tableData?[section]["footer"] as? String ?? ""
    }
}

extension SettingsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let info = (self.tableData?[indexPath.section]["rows"] as? [[String: Any]])?[indexPath.row]
        
        let action = info?["action"] as? (cell: UITableViewCell) -> Void
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            action?(cell: cell)
        }
    }
}


