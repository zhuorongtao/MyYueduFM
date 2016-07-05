//
//  ExpandTableViewController.swift
//  MyYueduFM
//
//  Created by apple on 16/5/20.
//  Copyright © 2016年 apple. All rights reserved.
//

import UIKit
import YueduFMSDK

protocol ExpandTableViewControllerProtocol {
    func nibForExpandCell() -> UINib?
    func heightForExpandCell() -> CGFloat
    func heightForRowAtIndexPath(indexPath: NSIndexPath) -> CGFloat
    func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell?
}

let kExpandCellIdentifier = "kExpandCellIdentifier"

class ExpandTableViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    /// tableData应该装的是ExpandObject
    var tableData: [AnyObject]?
    
    private var openedIndexPath: NSIndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate   = self
        self.tableView.dataSource = self
        
        if self.nibForExpandCell() != nil {
            self.tableView.registerNib(self.nibForExpandCell(), forCellReuseIdentifier: kExpandCellIdentifier)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func reloadData(data: [AnyObject]) {
        dispatch_async(dispatch_get_main_queue()) { 
            self.tableData = data
            self.openedIndexPath = nil
            self.tableView.reloadData()
        }
    }
    
    func closeExpand() {
        if self.openedIndexPath != nil {
           dispatch_async(dispatch_get_main_queue(), {
                self.tableView.beginUpdates()
                self.tableData?.removeAtIndex(self.openedIndexPath!.row)
                self.tableView.deleteRowsAtIndexPaths([self.openedIndexPath!], withRowAnimation: .None)
                self.tableView.endUpdates()
                self.openedIndexPath = nil
            })
        }
    }
    
    func deleteCellWithModel(model: AnyObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            self.closeExpand()
            usleep(200 * 1000)
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.beginUpdates()
                if let data = self.tableData {
                    let row = (data as NSArray).indexOfObject(model)
                    if row != NSNotFound {
                        let indexPath = NSIndexPath(forRow: row, inSection: 0)
                        self.tableData?.removeAtIndex(row)
                        self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    }
                }
                self.tableView.endUpdates()
                self.openedIndexPath = nil
            })
        }
    }
    
}

// MARK: - ExpandTableViewControllerProtocol
extension ExpandTableViewController: ExpandTableViewControllerProtocol {
    func nibForExpandCell() -> UINib? {
        return nil
    }
    
    func heightForExpandCell() -> CGFloat {
        return 0
    }
    
    func heightForRowAtIndexPath(indexPath: NSIndexPath) -> CGFloat {
        return 0
    }
    
    func cellForRowAtIndexPath(indexPath: NSIndexPath) -> UITableViewCell? {
        return nil
    }
}

// MARK: - UITableViewDataSource
extension ExpandTableViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let model = self.tableData?[indexPath.row] as? ExpandObject {
            let cell = tableView.dequeueReusableCellWithIdentifier(kExpandCellIdentifier, forIndexPath: indexPath) as? ExpandTableViewCell
            assert(cell != nil, "ExpandCell must be inherit from ExpandTableViewCell class")
            cell?.expandTableViewController = self
            cell?.model = model.model
            return cell!
        }else {
            
            return self.cellForRowAtIndexPath(indexPath)!
        }
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}

// MARK: - UITableViewDelegate
extension ExpandTableViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let _ = self.tableData?[indexPath.row] as? ExpandObject {
            return self.heightForExpandCell()
        }else {
            return self.heightForRowAtIndexPath(indexPath)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        tableView.beginUpdates()
        if self.tableData != nil {
            let object = ExpandObject.objectWithModel(self.tableData![indexPath.row])
            if let openIndex = self.openedIndexPath {
                self.tableData?.removeAtIndex(openIndex.row)
                tableView.deleteRowsAtIndexPaths([openIndex], withRowAnimation: .None)
                if openIndex.row == indexPath.row + 1 {
                    self.openedIndexPath = nil
                }else {
                    let row = openIndex.row > indexPath.row ?  indexPath.row + 1 : indexPath.row
                    self.openedIndexPath = NSIndexPath(forRow: row, inSection: indexPath.section)
                    self.tableData?.insert(object, atIndex: self.openedIndexPath!.row)
                    tableView.insertRowsAtIndexPaths([self.openedIndexPath!], withRowAnimation: .None)
                }
            }else {
                self.openedIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
                self.tableData?.insert(object, atIndex: self.openedIndexPath!.row)
                tableView.insertRowsAtIndexPaths([self.openedIndexPath!], withRowAnimation: .None)
            }
        }
        tableView.endUpdates()
    }
}
