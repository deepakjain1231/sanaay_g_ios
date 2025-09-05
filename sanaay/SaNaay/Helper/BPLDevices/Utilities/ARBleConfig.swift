//
//  ARBleConfig.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 18/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import Foundation

open class ARBleConfig: NSObject {
    //Whether to enable logging, not enabled by default
    public static var enableLog: Bool = true
    
    public static var continueScan: Bool = true
    //Limit scan to device name
    public static var acceptableDeviceNames: [String]?
    //Limit discoverable device serviceUUIDs
    public static var acceptableDeviceServiceUUIDs: [String]?
    
}
