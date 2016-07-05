//
//  NSURLEX.swift
//  MyYueduFM
//
//  Created by apple on 16/5/19.
//  Copyright © 2016年 apple. All rights reserved.
//

import Foundation
import UIKit
import DOUAudioStreamer

extension NSURL: DOUAudioFile {
    public func audioFileURL() -> NSURL! {
        return self
    }
}