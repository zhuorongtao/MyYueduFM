//
//  NSFileManagerEX.swift
//  MyYueduFM
//
//  Created by apple on 16/5/18.
//  Copyright © 2016年 apple. All rights reserved.
//

import Foundation
import UIKit

extension NSFileManager {
    /**
     文件的大小
     
     - parameter path: 文件路径(可以有子目录)
     
     - returns: 文件的大小
     */
    func fileSizeAtPath(path: String) -> UInt64 {
        let manager = NSFileManager.defaultManager()
        var isDirectory: ObjCBool = false
        
        if !manager.fileExistsAtPath(path, isDirectory: &isDirectory) {
            return 0
        }
            
        if !isDirectory {
            //没有子文件
            return self.singleFileSizeAtPath(path)
        }else {
            var folderSize: UInt64 = 0
            
            if let childFilesArray = manager.subpathsAtPath(path) {
                let childFilesEnumerator = childFilesArray.enumerate()
                
                for fileName in childFilesEnumerator {
                    let fileAbsolutePath = (path as NSString).stringByAppendingPathComponent(fileName.element)
                    folderSize += self.singleFileSizeAtPath(fileAbsolutePath)
                }
                return folderSize
//                var fileName: String?
//                let childFilesEnumerator = (childFilesArray as NSArray).objectEnumerator()
//                fileName = childFilesEnumerator.nextObject() as? String
//                while fileName != nil {
//                    let fileAbsolutePath = (path as NSString).stringByAppendingPathComponent(fileName!)
//                    folderSize += self.singleFileSizeAtPath(fileAbsolutePath)
//                    return folderSize
//                }
            }else {
                return 0
            }
        }
    }
    
    /**
     获取单文件的大小
     
     - parameter filePath: 指定文件的路径(没有子目录)
     
     - returns: 文件的大小
     */
    private func singleFileSizeAtPath(filePath: String) -> UInt64 {
        let manger = NSFileManager.defaultManager()
        if manger.fileExistsAtPath(filePath) {
            do {
                let fileAttr: NSDictionary = try manger.attributesOfItemAtPath(filePath)
                return fileAttr.fileSize()
//                if let fileSize = fileAttr[NSFileSize] as? NSNumber {
//                    return fileSize.longLongValue
//                }else {
//                    
//                    print("无法获取文件大小")
//                }
            }catch {
            
                print("无法获取文件大小")
            }
        }else {
            print("文件路径不存在")
        }
        
        return 0
    }
}