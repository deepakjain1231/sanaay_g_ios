//
//  ARBleDevice.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 18/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import CoreBluetooth

//Bluetooth Device Protocol
protocol ARBleDeviceDelegate: NSObjectProtocol {
    func deviceDidBecomeReady(_ device: ARBleDevice)
    func device(_ device: ARBleDevice, didDiscoverServices error: Error?)
    func device(_ device: ARBleDevice, didDiscoverCharacteristicsFor service: CBService, error: Error?)
    func device(_ device: ARBleDevice, didUpdateValueFor characteristic: CBCharacteristic, value: Data?, error: Error?)
}

//bluetooth device
open class ARBleDevice: NSObject {
    //MARK: public property
    public var name: String
    public var peripheral: CBPeripheral?
    
    var uuid: String {
        return peripheral?.identifier.uuidString ?? ""
    }
    
    var isConnected: Bool {
        return peripheral?.state == .connected
    }
    
    var delegate: ARBleDeviceDelegate?
    //private property
    var allServices = [CBService]()
    var allCharacteristics = [CBCharacteristic]()
    private var readBlockDic: [String: ARBleReadDeviceInfoBlock] = [:]
    private var writeBlockDic: [String: ARBleWriteDeviceBlock] = [:]
    
    init( _ peripheral: CBPeripheral?) {
        self.name = peripheral?.name ?? "No Name"
        self.peripheral = peripheral
    }
}

//MARK:- public method
extension ARBleDevice {
    //Set Characteristic Notification to fetch frequent updated value from device
    func setNotification(for characteristic: CBCharacteristic?, enable: Bool) {
        guard let characteristic = characteristic else { return }
        peripheral?.setNotifyValue(enable, for: characteristic)
    }
    
    //Read device information
    public func readDeviceInfo(_ uuid: String, complete:@escaping ARBleReadDeviceInfoBlock) {
        guard let peripheral = self.peripheral else { return }
        let readInfoBlock = {(data: Data?) in
            complete(data)
        }
        readBlockDic[uuid] = readInfoBlock
        let characteristic = self.characteristicWithUUID(uuid)
        guard let myCharacteristic = characteristic else {
            complete(nil)
            ARBle_debug_log("Characteristic not found")
            return
        }
        peripheral.readValue(for: myCharacteristic)
    }
    
    //write data input
    public func writeDevice(_ uuid: String, bytes: [UInt8], writeDeviceBlock: @escaping ARBleWriteDeviceBlock) {
        guard let peripheral = self.peripheral else { return }
        writeBlockDic[uuid] = writeDeviceBlock
        let characteristic = self.characteristicWithUUID(uuid)
        guard let myCharacteristic = characteristic  else {
            ARBle_debug_log("Characteristic not found")
            return
        }
        let data = Data(bytes: bytes, count: bytes.count)
        peripheral.writeValue(data, for: myCharacteristic, type: CBCharacteristicWriteType.withResponse)
    }
}

//MARK:- private method
extension ARBleDevice {
    //Get characteristic based on characteristicUUID
    private func characteristicWithUUID(_ uuid: String) -> CBCharacteristic? {
        for bleCharacteristic in self.allCharacteristics {
            if bleCharacteristic.uuid.uuidString == uuid {
                return bleCharacteristic
            }
        }
        return nil
    }
}

//MARK:- Bluetooth Device Protocol
extension ARBleDevice: CBPeripheralDelegate {
    //Discovery Device Service Agreement
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        let services = peripheral.services ?? []
        ARBle_debug_log("Discover Services : \(services.map{ $0.uuid })")
        allServices = services
        delegate?.device(self, didDiscoverServices: error)
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    //Characteristic Value Protocol under Discovery Service
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        //ARBle_debug_log("Discover Characteristics")
        allServices.remove(object: service)
        if allServices.isEmpty {
            ARBle_debug_log("Device ready")
            let bleDevice = ARBleDevice(peripheral)
            self.delegate?.deviceDidBecomeReady(bleDevice)
        }
        //Save all characteristics found
        let characteristics = service.characteristics ?? []
        ARBle_debug_log("Discover Characteristics : \(characteristics.map{ $0.uuid })")
        self.allCharacteristics.append(contentsOf: characteristics)
        delegate?.device(self, didDiscoverCharacteristicsFor: service, error: error)
    }
    
    //Characteristic notificaation state protocol
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            ARBle_debug_log("Error setting char notif : \(error.localizedDescription)")
            return
        }
        
        ARBle_debug_log("Success setting char notif : \(characteristic.uuid.uuidString)")
    }
    
    //Characteristic value read success protocol
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let value = characteristic.value
        let uuid = characteristic.uuid.uuidString
        let readDeviceInfoBlock =  readBlockDic[uuid]
        readDeviceInfoBlock?(value)
        delegate?.device(self, didUpdateValueFor: characteristic, value: value, error: error)
    }
    
    //write success protocol
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        var success: Bool = true
        if error != nil {
            success = false
        }
        let uuid = characteristic.uuid.uuidString
        let writeDeviceBlock =  writeBlockDic[uuid]
        if writeDeviceBlock != nil {
            writeDeviceBlock!(success)
        }
    }
}
