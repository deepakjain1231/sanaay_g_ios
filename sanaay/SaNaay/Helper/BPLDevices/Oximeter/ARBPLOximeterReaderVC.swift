//
//  ARBPLOximeterReaderVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 15/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import MKMagneticProgress
import CoreBluetooth
import Charts

//// MARK: - Oximeter
enum BPLOximeterParams {
    static let SupportedBPLOximeterDeviceNames = ["Oximeter-BLE"]
    
    // services and charcteristics Identifiers
    static let HeartRateServiceUUID = CBUUID.init(string: "0000FFE2-0000-1000-8000-00805F9B34FB")
    static let HeartRateCharacteristicUUID = CBUUID.init(string: "0000FFE2-0000-1000-8000-00805F9B34FB")
    static let ClientConfigCharacteristicUUID = CBUUID.init(string: "00002902-0000-1000-8000-00805F9B34FB")
    
    static func getServiceList() -> [CBUUID] {
        return [BPLOximeterParams.HeartRateServiceUUID]
    }
    
    static func getCharacteristicList() -> [CBUUID] {
        return [BPLOximeterParams.HeartRateCharacteristicUUID]
    }
}

// MARK: -
class ARBPLOximeterReaderVC: UIViewController {
    
    var pi_indx: Double?
    @IBOutlet weak var lbl_pulse: UILabel!
    @IBOutlet weak var lbl_spO2: UILabel!
    @IBOutlet weak var lbl_PI: UILabel!
    @IBOutlet weak var progress_Vieww: UIProgressView!
    
    @IBOutlet weak var chartView: LineChartView!
        
    var oximeterDevice: ARBleDevice?
    var heartRateChar: CBCharacteristic?
    var dic_response: PatientListDataResponse?
    
    var dataReading = false
    
    var timer: Timer?
    var readingTimeInterval: TimeInterval = 0.1 //100 miliseconds
    var maxReadingTimeInterval = 30.0
    var readingStartTime = 0.0
    var currentReadingTime = 0.0
    var isDataReadingDone = false
    
    //Algo data
    var aCounter = 0
    var aSamplingFreq = 0
    var arrHeartRates = [Float]()
    
    var gData = [Float]()
    var ppgData = [Int]()
    var pData = [Int]()
    var spO2Value = 0
    var pulseValue = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "BPL Oximeter"
        setBackButtonTitle()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startBleScanning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopReadingOximeterDevice()
        ARBleManager.shareInstance.delegate = nil
    }
    
    func setupUI() {
        self.progress_Vieww.transform = self.progress_Vieww.transform.scaledBy(x: 1, y: 0.8)
        self.progress_Vieww.setProgress(0, animated: false)
        
        // Set the rounded edge for the outer bar
        self.progress_Vieww.layer.cornerRadius = 5
        self.progress_Vieww.clipsToBounds = true

        // Set the rounded edge for the inner bar
        self.progress_Vieww.layer.sublayers![1].cornerRadius = 5
        self.progress_Vieww.subviews[1].clipsToBounds = true
        
        setupChartView()
        setupBleDevice()
    }
    
    func setupBleDevice() {
        ARBleConfig.continueScan = true
        ARBleConfig.acceptableDeviceNames = BPLOximeterParams.SupportedBPLOximeterDeviceNames
        ARBleConfig.acceptableDeviceServiceUUIDs = [BPLOximeterParams.HeartRateServiceUUID.uuidString]
        ARBleManager.shareInstance.delegate = self
    }
    
    func setupChartView() {
        // enable description text
        chartView.chartDescription.enabled = true
        
        // disable touch gestures
        chartView.isUserInteractionEnabled = false
        chartView.drawGridBackgroundEnabled = false
        
        let xl = chartView.xAxis
        xl.labelTextColor = .clear
        xl.gridLineDashLengths = [4, 4]
        xl.labelPosition = .bottom
        xl.granularity = 1
        xl.granularityEnabled = true
        
        let leftAxis = chartView.leftAxis
        leftAxis.labelTextColor = .clear
        leftAxis.gridLineDashLengths = [4, 4]
        leftAxis.drawGridLinesEnabled = true
        
        let rightAxis = chartView.rightAxis
        rightAxis.enabled = false
        
        let lineData = LineChartData()
        lineData.setValueTextColor(AppColor.app_GreenColor)
        
        let purpleColor =  #colorLiteral(red: 0.3921568627, green: 0.6980392157, blue: 0.2705882353, alpha: 1)//#64B245
        let dataSet = LineChartDataSet(entries: [], label: "Pulse Data")
        dataSet.axisDependency = .left
        dataSet.setColor(purpleColor)
        dataSet.setCircleColor(.clear)
        dataSet.lineWidth = 2
        dataSet.circleRadius = 1
        dataSet.fillAlpha = 65
        dataSet.fillColor = purpleColor.withAlphaComponent(0.5)
        dataSet.highlightColor = purpleColor
        dataSet.valueTextColor = AppColor.app_GreenColor
        dataSet.valueFont = UIFont.systemFont(ofSize: 8)
        dataSet.drawValuesEnabled = false
        dataSet.drawFilledEnabled = true

        // lineData.addDataSet(dataSet)
        lineData.append(dataSet)
        chartView.data = lineData
    }
    
    func startBleScanning() {
        if oximeterDevice != nil {
            ARBle_debug_log("already connected to oximeter, don't start scan")
            return
        }
        
        if isDataReadingDone {
            ARBle_debug_log("already done reading oximeter data, don't start scan")
            return
        }
        
        if ARBleManager.shareInstance.isBleEnable {
            ARBle_debug_log("scanning ...")
            ARBleManager.shareInstance.scanForDevices()
        } else {
            ARBle_debug_log("Bluetooth is OFF")
        }
    }
    
    func updateUI(spO2: Int, pi: Float, pluse: Int) {
        self.pi_indx = Double(pi)
        self.lbl_spO2.text = "\(spO2)%"
        self.lbl_pulse.text = String(pluse)
        self.lbl_PI.text = String(format: "%.1f", pi)
    }
    
    deinit {
        debugPrint("-")
        stopReadingOximeterDevice()
    }
    
    // MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
//
extension ARBPLOximeterReaderVC {
    func processOnOximterData(_ data: [UInt8]) {
        ARBle_debug_log("Data read - SUCCESS Data : \(data), count : \(data.count)")
        
        spO2Value = Int(data[6] & 0xFF);
        ARBle_debug_log("data-read1===>\(spO2Value)");
        
        if self.dataReading {
            if (spO2Value < 80) {
                self.dataReading = false;
                stopProcessOnOximterData()
            }
        }
        
        if (spO2Value > 0) {
            self.dataReading = true;
            
            if currentReadingTime > 0 { //added to fix infinite or NaN value
                aCounter += 1
                aSamplingFreq = Int(Double(aCounter) / currentReadingTime) //calculating sampling frequency
            }
            
            pulseValue = Int(data[7] & 0xFF);
            spO2Value = Int(data[6] & 0xFF);
            let pi = (Float(data[8]) * 10)/100
            debugPrint("BPM = \(pulseValue)\n spO2 = \(spO2Value)\n PI = \(pi)")
            
            if (spO2Value < 60) {
                self.dataReading = false;
                stopProcessOnOximterData()
            } else if (pulseValue > 140) {
                self.dataReading = false;
                stopProcessOnOximterData()
            }
            self.updateUI(spO2: spO2Value, pi: pi, pluse: pulseValue)
            self.pData.append(pulseValue);
            //self.ppgData.append(pulseValue);
            
            debugPrint("aSamplingFreq", aSamplingFreq);
            
            gData.append(Float(data[12]))
            gData.append(Float(data[13]))
            
            let lineData = chartView.data ?? LineChartData()
            let dataSet = lineData.dataSets.first ?? LineChartDataSet()
            
            let highByteData = Int(data[12] & 0xFF) << 8;
            let lowByteData = Int(data[13] & 0xFF)
            let curveThrough = highByteData + lowByteData;
            self.ppgData.append(curveThrough)
            
            let chartEntry = ChartDataEntry(x: Double(dataSet.entryCount), y: Double(curveThrough))
            lineData.appendEntry(chartEntry, toDataSet: 0)
            lineData.notifyDataChanged()
            chartView.notifyDataSetChanged()
            chartView.setVisibleXRangeMaximum(200)
            chartView.moveViewToX(Double(lineData.entryCount))
            
            //FOR TALA
            if currentReadingTime >= 15 && currentReadingTime <= 25 {
                let hr = HeartRateDetectionModel.getMeanHR(gData, time: 0)
                arrHeartRates.append(hr)
            }
            
            if !isTimerStarted && !isDataReadingDone {
                if spO2Value != 127, pulseValue != 255, pi != 0 {
                    startTimer()
                }
            } else {
                if spO2Value == 127 || pulseValue == 255 || pi == 0 {
                    stopProcessOnOximterData(isError: true)
                } else if spO2Value <= 0 || spO2Value > 100 {
                    updateUI(spO2: 0, pi: 0, pluse: 0)
                }
            }
        }
    }
    
    func stopProcessOnOximterData(isError: Bool = false) {
        stopReadingOximeterDevice()
        //Reset values
        //updateUI(spO2: 0, pi: 0, pluse: 0)
        if isError {
            showDataReadingErrorAlert()
        }
    }
    
    func showDataReadingErrorAlert() {
        let title = "Unable to capture data\nProbable causes:"
        let message = "1. Finger not placed properly\n2. Finger is removed from oximeter"
        Utils.showAlertOkController(title: title, message: message, buttons: ["Ok"]) { ok_click in
            DispatchQueue.delay(.milliseconds(100), closure: {
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    func calculateResult() {
        debugPrint("--> last aSamplingFreq : \(aSamplingFreq)")
        debugPrint("--> aCounter : \(aCounter)")
        debugPrint("--> sample data count[\(gData.count)] : \(gData)")
        debugPrint("--> pulse data count[\(pData.count)] : \(ppgData)")
        debugPrint("--> arrHeartRates[\(arrHeartRates.count)] : \(arrHeartRates), ")
        
        let sparshnaAlgo = ARSparshnaAlgo()
        sparshnaAlgo.arrRed = gData
        sparshnaAlgo.arrGreen = gData
        sparshnaAlgo.arrBlue = gData
        sparshnaAlgo.arrHeartRates = arrHeartRates
        sparshnaAlgo.count = aCounter
        sparshnaAlgo.spO2Value = spO2Value
        sparshnaAlgo.pi_index = self.pi_indx ?? 0.0
        sparshnaAlgo.aSamplingFreq = aSamplingFreq
        sparshnaAlgo.oximeterPulseArray = pData
        sparshnaAlgo.ppgData = self.ppgData
        sparshnaAlgo.fromVC = self
        sparshnaAlgo.processSparshnaLogic()
    }
    
}
//
extension ARBPLOximeterReaderVC {
    var isTimerStarted: Bool {
        return (timer != nil)
    }
    
    func startTimer() {
        stopTimer()
        readingStartTime = Date().timeIntervalSinceReferenceDate
        timer = Timer.scheduledTimer(timeInterval: readingTimeInterval,
                                     target: self,
                                     selector: #selector(timerFire(timer:)),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func timerFire(timer: Timer) {
        //Total time since timer started, in seconds
        currentReadingTime = Date().timeIntervalSinceReferenceDate - readingStartTime
        ARBle_debug_log(">>> timer currentReadingTime : \(String(format: "%.2f", currentReadingTime))")
        
        let progress = currentReadingTime/maxReadingTimeInterval
        self.progress_Vieww.setProgress(Float(progress), animated: true)
        
        //The rest of your code goes here
        if currentReadingTime >= maxReadingTimeInterval {
            isDataReadingDone = true
            stopProcessOnOximterData()
            calculateResult()
        }
    }
}

extension ARBPLOximeterReaderVC: ARBleManagerDelegate {
    func manager(_ manager: ARBleManager, didStateChange state: ARBleState) {
        ARBle_debug_log("status change : \(state)")
    }
    
    func manager(_ manager: ARBleManager, didScan device: ARBleDevice) {
        ARBle_debug_log("scanned oximeter : \(device.name)")
        oximeterDevice = device
        ARBleManager.shareInstance.connectDevice(device)
    }
    
    func managerDidScanTimeout(_ manager: ARBleManager) {
        ARBle_debug_log("scan timeout")
    }
    
    func manager(_ manager: ARBleManager, didConnect device: ARBleDevice) {
        ARBle_debug_log("oximeter did connect : \(device.name)")
    }
    
    func manager(_ manager: ARBleManager, didConnectTimeout device: ARBleDevice) {
        ARBle_debug_log("connect timeout : \(device.name)")
    }
    
    func manager(_ manager: ARBleManager, didFailToConnect device: ARBleDevice, error: Error?) {
        ARBle_debug_log("did fail to connect : \(device.name), error: \(error?.localizedDescription ?? "-")")
    }
    
    func manager(_ manager: ARBleManager, didDisconnect device: ARBleDevice, error: Error?) {
        ARBle_debug_log("did disconnect : \(device.name), error: \(error?.localizedDescription ?? "-")")
    }
    
    func manager(_ manager: ARBleManager, didReceiveAdvertisementData data: Data) {
        let finalData = [UInt8](data)
        ARBle_debug_log("did rececive adv data : \(finalData), count : \(finalData.count)")
    }
    
    func manager(_ manager: ARBleManager, deviceDidReady device: ARBleDevice) {
        ARBle_debug_log("oximeter did ready : \(device.name)")
    }
    
    func manager(_ manager: ARBleManager, device: ARBleDevice, didDiscoverServices error: Error?) {
        ARBle_debug_log("oximeter did Discover Services : \(device.name)")
        ARBle_debug_log("did discover services : \(device.allServices)")
        DispatchQueue.main.async {
            if device == self.oximeterDevice {
                if let error = error {
                    ARBle_debug_log("Fail to connect device: \(error.localizedDescription)")
                } else if device.allServices.first(where: { $0.uuid == BPLOximeterParams.HeartRateServiceUUID }) == nil {
                    ARBle_debug_log("Fail to connect device: No required service found on device")
                }
            }
        }
    }
    
    func manager(_ manager: ARBleManager, device: ARBleDevice, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        ARBle_debug_log("did discover characteristics for service : \(service.uuid.uuidString)")
        guard let oximeterDevice = oximeterDevice, oximeterDevice.uuid == device.uuid else { return }
        
        if let char = device.allCharacteristics.first(where: { $0.uuid == BPLOximeterParams.HeartRateCharacteristicUUID }) {
            heartRateChar = char
            oximeterDevice.setNotification(for: char, enable: true)
        }
    }
    
    func manager(_ manager: ARBleManager, device: ARBleDevice, didUpdateValueFor characteristic: CBCharacteristic, value: Data?, error: Error?) {
        guard let data = value, !data.isEmpty else { return }
        if characteristic.uuid == BPLOximeterParams.HeartRateServiceUUID {
            DispatchQueue.main.async {
                self.processOnOximterData([UInt8](data))
            }
        }
    }
    
    func stopReadingOximeterDevice() {
        stopTimer()
        if let oximeterDevice = oximeterDevice {
            if oximeterDevice.peripheral?.state == .connected {
                oximeterDevice.setNotification(for: heartRateChar, enable: false)
            }
            ARBleManager.shareInstance.disonnectDevice(oximeterDevice)
        }
        oximeterDevice = nil
        ARBleManager.shareInstance.stopScan()
    }
}



//extension ARBPLOximeterReaderVC {
//    static func showScreen(fromVC: UIViewController) {
//        let vc = ARBPLOximeterReaderVC.instantiate(fromAppStoryboard: .BPLDevices)
//        fromVC.navigationController?.pushViewController(vc, animated: true)
//    }
//}
