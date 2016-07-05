//
//  AutoCloseSettingsViewController.swift
//  MyYueduFM
//
//  Created by apple on 16/5/30.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit

class AutoCloseSettingsViewController: SettingsViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = LOC("settings_auto_close")
        
        let action = {
            [weak self] (cell: UITableViewCell) in
            self?.tableView.visibleCells.forEach({ (cell) in
                cell.accessoryView = nil
            })
            cell.accessoryView = UIImageView(image: UIImage(named: "icon_cell_check.png"))
            SRV(SettingsService)?.autoCloseLevel = self?.tableView.indexPathForCell(cell)?.row ?? 0
        }
        
        var rows: [[String: Any]] = []
        
        let level = SRV(SettingsService)?.autoCloseLevel
        SRV(SettingsService)?.autoCloseTimes?.forEach({ (time) in
            var row: [String: Any] = [:]
            row["title"] = self.formatTime(time)
            row["action"] = action
            if SRV(SettingsService)?.autoCloseTimes?.indexOf(time) == level {
                row["accessoryView"] = UIImageView(image: UIImage(named: "icon_cell_check.png"))
            }
            rows.append(row)
        })
        
        let section1: [String: Any] = [
            "header": LOC("time"),
            "rows": rows
        ]
        
        self.tableData = [section1]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func formatTime(minius: Int) -> String {
        let h = minius / 60
        let m = minius % 60
        
        var timeString = ""
        if h == 0 && m == 0 {
            timeString += LOC("none")
        }else {
            if h > 0 {
                timeString += String(format: "%d%@", h, LOC("hour"))
            }
            
            if m > 0 {
                timeString += String(format: "%d%@", m, LOC("minute"))
            }
        }
        
        return timeString
    }

}
