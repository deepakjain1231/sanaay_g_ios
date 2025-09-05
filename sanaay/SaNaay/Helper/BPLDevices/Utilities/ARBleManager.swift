//
//  ARBleManager.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 18/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import Foundation
import CoreBluetooth

// MARK: -
public enum ARBleState {
    case PowerOff
    case PowerOn
}

public typealias ARBleReadDeviceInfoBlock = (_ data: Data?) -> Void //Get device information block
public typealias ARBleWriteDeviceBlock = (_ success: Bool) -> Void //write data block

func ARBle_debug_log(_ msg: String) {
    if ARBleConfig.enableLog {
        print("~~ ARBle log : ", msg)
    }
}

let defaultScanTimeoutInterval = 60.0
let defaultConnectTimeoutInterval = 60.0

protocol ARBleManagerDelegate {
    //System bluetooth status change
    func manager(_ manager: ARBleManager, didStateChange state: ARBleState)
    //Callback after scanning to device
    func manager(_ manager: ARBleManager, didScan device: ARBleDevice)
    //Scan timeout callback
    func managerDidScanTimeout(_ manager: ARBleManager)
    //Callback when the device is connected successfully
    func manager(_ manager: ARBleManager, didConnect device: ARBleDevice)
    //connection timeout callback
    func manager(_ manager: ARBleManager, didConnectTimeout device: ARBleDevice)
    //fail to connect callback
    func manager(_ manager: ARBleManager, didDisconnect device: ARBleDevice, error: Error?)
    //disconnect callback
    func manager(_ manager: ARBleManager, didFailToConnect device: ARBleDevice, error: Error?)
    //get the  scan adv data
    func manager(_ manager: ARBleManager, didReceiveAdvertisementData data: Data)
    
    //All features of the device have been detected and we can now read and write
    func manager(_ manager: ARBleManager, deviceDidReady device: ARBleDevice)
    //did discover connected device services
    func manager(_ manager: ARBleManager, device: ARBleDevice, didDiscoverServices error: Error?)
    //did discover connected device characteristics for given service
    func manager(_ manager: ARBleManager, device: ARBleDevice, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    //did Update Value For characteristic
    func manager(_ manager: ARBleManager, device: ARBleDevice, didUpdateValueFor characteristic: CBCharacteristic, value: Data?, error: Error?)
}

extension ARBleManagerDelegate {
    func manager(_ manager: ARBleManager, didStateChange state: ARBleState) {}
    func manager(_ manager: ARBleManager, didScan device: ARBleDevice) {}
    func managerDidScanTimeout(_ manager: ARBleManager) {}
    func manager(_ manager: ARBleManager, didConnect device: ARBleDevice) {}
    func manager(_ manager: ARBleManager, didConnectTimeout device: ARBleDevice) {}
    func manager(_ manager: ARBleManager, didReceiveAdvertisementData data: Data) {}
    func manager(_ manager: ARBleManager, didDisconnect device: ARBleDevice, error: Error?) {}
    func manager(_ manager: ARBleManager, didFailToConnect device: ARBleDevice, error: Error?) {}
    
    func manager(_ manager: ARBleManager, deviceDidReady device: ARBleDevice) {}
    func manager(_ manager: ARBleManager, device: ARBleDevice, didDiscoverServices error: Error?) {}
    func manager(_ manager: ARBleManager, device: ARBleDevice, didDiscoverCharacteristicsFor service: CBService, error: Error?) {}
    func manager(_ manager: ARBleManager, device: ARBleDevice, didUpdateValueFor characteristic: CBCharacteristic, value: Data?, error: Error?) {}
}

open class ARBleManager: NSObject {
    public static let shareInstance = ARBleManager()
    //MARK: public properties and methods
    //scan timeout interval
    public var scanTimeoutInterval: TimeInterval!
    //connection timeout interval
    public var connectTimeoutInterval: TimeInterval!
    //current bluetooth On/Off status
    public private(set) var isBleEnable: Bool = false
    
    var delegate: ARBleManagerDelegate?
    
    //MARK: private property
    private var group: DispatchGroup?
    private var bleEnableBlock:((_ enable: Bool) -> Void)?
    var state: ARBleState = .PowerOff
    private var scanTimeoutTimer: Timer?
    private var connectTimeroutTimer: Timer?
    private var currentManager: CBCentralManager?
    private var currentPeripheral: CBPeripheral?
    private var willConnectDevices: NSMutableArray!
    private var connectedDevices: NSMutableArray!
    private var arr_BleDevice: [CBPeripheral]?
    
    override init() {
        super.init()
        self.scanTimeoutInterval = defaultScanTimeoutInterval
        self.connectTimeoutInterval = defaultConnectTimeoutInterval
        self.willConnectDevices = NSMutableArray()
        self.connectedDevices = NSMutableArray()
        self.arr_BleDevice = [CBPeripheral]()
        group = DispatchGroup()
        group!.enter()
        let queue = DispatchQueue(label: "com.ayurythm.bluetooth.queue")
        self.currentManager = CBCentralManager(delegate: self, queue: queue, options: [CBCentralManagerOptionShowPowerAlertKey: true])
        group!.wait()
    }
}

//MARK:- public method
extension ARBleManager {
    //scan for devices
    public func scanForDevices(withServices services: [CBUUID]? = nil, options: [String : Any]? = nil) {
        if currentManager != nil && isBleEnable {
            if !ARBleConfig.continueScan {
                invalidateTimer(scanTimeoutTimer)
                scanTimeoutTimer = Timer.scheduledTimer(timeInterval: scanTimeoutInterval, target: self, selector: #selector(timeoutScan), userInfo: nil, repeats: false)
            }
            currentManager?.scanForPeripherals(withServices: services, options: options)
        }
    }
    //connect to device
    public func connectDevice(_ device: ARBleDevice) {
        guard let peripheral = device.peripheral else { return }
        if currentManager != nil && isBleEnable {
            addDeviceToConnectQueue(device)
            currentManager?.connect(peripheral, options: nil)
        }
    }
    //disconnect device
    public func disonnectDevice(_ device: ARBleDevice) {
        guard let peripheral = device.peripheral else { return }
        currentManager?.cancelPeripheralConnection(peripheral)
    }
    //get connected devices
    public func connectedDevice() -> ARBleDevice? {
        return connectedDevices?.firstObject as? ARBleDevice
    }
    //stop scanning
    public func stopScan() {
        if currentManager?.isScanning ?? false {
            currentManager?.stopScan()
        }
        invalidateTimer(scanTimeoutTimer)
    }
}
////MARK:- private method
extension ARBleManager {
    //Update bluetooth status
    private func updateManagerState(_ central: CBCentralManager?) {
        guard let central = central else { return }
        switch central.state {
        case .poweredOn:
            state = .PowerOn
        default:
            state = .PowerOff
        }
        isBleEnable = (state == .PowerOn)
    }
    
    //cancel timer
    private func invalidateTimer(_ timer: Timer?) {
        var myTimer = timer
        myTimer?.invalidate()
        myTimer = nil
    }
    
    //Scan timeout callback
    @objc private func timeoutScan() {
        currentManager?.stopScan()
        invalidateTimer(scanTimeoutTimer)
        delegate?.managerDidScanTimeout(self)
    }
    
    //connection timeout callback
    @objc private func timeoutConnect(timer: Timer) {
        let device =  timer.userInfo as? ARBleDevice
        guard let bleDevice = device else { return }
        guard let peripheral = bleDevice.peripheral else { return }
        currentManager?.cancelPeripheralConnection(peripheral)
        removeDeviceFromConnectQueue(bleDevice)
        delegate?.manager(self, didConnectTimeout: bleDevice)
    }
    
    //Add device to connection queue
    private func addDeviceToConnectQueue(_ device: ARBleDevice) {
        device.delegate = self
        invalidateTimer(connectTimeroutTimer)
        DispatchQueue.main.async(execute: {
            self.connectTimeroutTimer = Timer.scheduledTimer(timeInterval: self.connectTimeoutInterval, target: self, selector: #selector(self.timeoutConnect(timer:)), userInfo: device, repeats: false)
        })
        willConnectDevices.add(device)
    }
    
    //Remove the device from the connection queue
    private func removeDeviceFromConnectQueue(_ device: ARBleDevice?) {
        guard let device = device else { return }
        invalidateTimer(connectTimeroutTimer)
        willConnectDevices.remove(device)
    }
    
    //Get Device according to peripheral
    private func deviceWithPeripheral(_ peripheral: CBPeripheral) -> ARBleDevice? {
        for device in willConnectDevices {
            let bleDevice = device as! ARBleDevice
            if bleDevice.peripheral == peripheral {
                return bleDevice
            }
        }
        return nil
    }
}


//MARK:- Bluetooth protocol
extension ARBleManager: CBCentralManagerDelegate {
    //Bluetooth State Change Protocol
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        updateManagerState(central)
        delegate?.manager(self, didStateChange: state)
        if group != nil {
            group!.leave()
            group = nil
        }
    }
    
    //Scan Success Protocol
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
            DispatchQueue.main.async {
                self.delegate?.manager(self, didReceiveAdvertisementData: manufacturerData)
            }
        }
        
        ARBle_debug_log("find device:\(RSSI) \(peripheral.name ?? "<null>") \(advertisementData ) " )
        
        if let acceptableDeviceNames = ARBleConfig.acceptableDeviceNames {
            if !(acceptableDeviceNames.contains(peripheral.name ?? "")) {
                return
            }
        }
        
        let bleDevice = ARBleDevice(peripheral)
        if ((self.arr_BleDevice?.contains(peripheral)) != nil) {
            self.arr_BleDevice?.append(peripheral)
        }
        
        debugPrint(bleDevice.peripheral?.identifier.uuidString)
        debugPrint(self.arr_BleDevice)
        
        
        delegate?.manager(self, didScan: bleDevice)
    }
    
    //connection success protocol
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        ARBle_debug_log("connect success : \(peripheral.name ?? "-")")
        currentPeripheral = peripheral
        let bleDevice = deviceWithPeripheral(peripheral)
        guard let device = bleDevice else { return }
        removeDeviceFromConnectQueue(device)
        connectedDevices.add(device)
        peripheral.delegate = device
        var services: [CBUUID]?
        if let serviceUUIDs =  ARBleConfig.acceptableDeviceServiceUUIDs {
            if !(serviceUUIDs.isEmpty) {
                services = [CBUUID]()
                for uuid in serviceUUIDs {
                    let cbUUID = CBUUID(string: uuid)
                    services?.append(cbUUID)
                }
            }
        }
        peripheral.discoverServices(nil)
        //peripheral.discoverServices(services)
        delegate?.manager(self, didConnect: device)
    }
    
    //connection failure protocol
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        ARBle_debug_log("connect failed : \(peripheral.name ?? "-")")
        let bleDevice = deviceWithPeripheral(peripheral)
        guard let device = bleDevice else { return }
        removeDeviceFromConnectQueue(device)
        connectedDevices.remove(device)
        delegate?.manager(self, didFailToConnect: device, error: error)
    }
    
    //device did disconnect protocol
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        ARBle_debug_log("did disconnect : \(peripheral.name ?? "-")")
        let bleDevice = deviceWithPeripheral(peripheral)
        guard let device = bleDevice else { return }
        connectedDevices.remove(device)
        delegate?.manager(self, didDisconnect: device, error: error)
    }
}

//MARK:-ARBleDeviceDelegate
extension ARBleManager: ARBleDeviceDelegate {
    func deviceDidBecomeReady(_ device: ARBleDevice) {
        delegate?.manager(self, deviceDidReady: device)
    }
    
    func device(_ device: ARBleDevice, didDiscoverServices error: Error?) {
        delegate?.manager(self, device: device, didDiscoverServices: error)
    }
    
    func device(_ device: ARBleDevice, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        delegate?.manager(self, device: device, didDiscoverCharacteristicsFor: service, error: error)
    }
    
    func device(_ device: ARBleDevice, didUpdateValueFor characteristic: CBCharacteristic, value: Data?, error: Error?) {
        delegate?.manager(self, device: device, didUpdateValueFor: characteristic, value: value, error: error)
    }
}

extension ARBleManager {
    func isBluetoothPermissionGiven(fromVC: UIViewController) -> Bool {
        guard let currentManager = currentManager else {
            ARBle_debug_log("currentManager not initialize yet")
            return false
        }
        
        let state: ARBleState = (currentManager.state == .poweredOn) ? .PowerOn : .PowerOff
        delegate?.manager(self, didStateChange: state)
        if !isBleEnable {
            /*if currentManager.state == .poweredOff {
             openAppOrSystemSettingsAlert(title: "Bluetooth seems to be Off. Please switch on Bluetooth from the settings.", message: "", fromVC: fromVC)
             return false
             }*/
            
            if #available(iOS 13.0, *) {
                if (CBCentralManager().authorization != .allowedAlways) {   //System will automatically ask user to turn on iOS system Bluetooth if this returns false
                    openAppOrSystemSettingsAlert(title: "Bluetooth permission is currently disabled for the application. Enable Bluetooth from the application settings.", message: "", fromVC: fromVC)
                    return false
                }
            } else {
                let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String
                openAppOrSystemSettingsAlert(title: "\"\(appName ?? "You Application Nam")\" would like to use Bluetooth for new connections", message: "You can allow new connections in Settings", fromVC: fromVC)
                return false
            }
        }
        return true
    }
    
    func openAppOrSystemSettingsAlert(title: String, message: String, fromVC: UIViewController) {
        let alertController = UIAlertController (title: title, message: message, preferredStyle: .alert)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        alertController.addAction(settingsAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        fromVC.present(alertController, animated: true, completion: nil)
    }
}
