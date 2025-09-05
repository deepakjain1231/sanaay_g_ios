//
//  ARBPLOximeterReaderVC+SparshnaAlgo.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 21/06/22.
//  Copyright © 2022 AyuRythm. All rights reserved.
//

import UIKit
import AVFoundation
import Alamofire

class ARSparshnaAlgo {
    
    let FRAMES_PER_SECOND = 30
    
    var count = 0
    
    var arrRed = [Float]()
    var arrGreen = [Float]()
    var arrBlue = [Float]()
    var arrHuePoints = [Float]()
    var arrHeartRates = [Float]()
    
    var dAge = 0.0
    var dHei: Double = 1.0
    var dWei: Double = 1.0
    var demo_user_name = ""
    var maxRedValue = 210.0
    
    var isMale = true
    var Q = 0.0
    
    var ppgData = [Int]()
    var fftDataServer = [String]()
    var newFFT = FFT()
    
    var isTalaRegular = false
    
    var oximeterPulseArray = [Int]()
    var pulseValue = 90
    var spO2Value = 98
    var aSamplingFreq = 0
    var pi_index = 0.0
    var fromVC: UIViewController?
    var dic_sparshna = [String : Any]()
    
    var k_prakriti = 0
    var p_prakriti = 0
    var v_prakriti = 0
    
    init() {
        doSetup()
    }
}

extension ARSparshnaAlgo {
    private func doSetup() {

        if dAge == 0.0 {
            let str_age = appDelegate.dic_patient_response?.patient_age ?? ""
            let str_gender = appDelegate.dic_patient_response?.patient_gender ?? ""

            if str_age.trimed() == "" && str_gender.trimed() == "" {
                if let fromvc = self.fromVC {
                    Utils.showAlertWithTitleInController("", message: "Please update your profile with correct data", controller: fromvc)
                }
                return
            }
            else {
                dAge = Double(str_age) ?? 0
            }

            isMale = str_gender.lowercased() == "male" ? true : false

            if let measurement = appDelegate.dic_patient_response?.patient_measurement as? String {
                let arrMeasurement = Utils.parseValidValue(string: measurement).components(separatedBy: ",")
                if arrMeasurement.count >= 2 {
                    dHei = Double(arrMeasurement[0].replacingOccurrences(of: "\"", with: "")) ?? 75.0
                    dWei = Double(arrMeasurement[1].replacingOccurrences(of: "\"", with: "")) ?? 160.0
                }
            }

        } else {
            dAge = 1.0
        }

        Q = isMale ? 5.0 : 4.5

    }
    
    func get_KPV_result(_ dicResp: [String: Any]) -> String {
        let kaphaCount = dicResp["Kapha"] as? Double ?? 0.0
        let pittaCount = dicResp["Pitta"] as? Double ?? 0.0
        let vataCount = dicResp["Vata"] as? Double ?? 0.0
        
        let total = kaphaCount + pittaCount + vataCount
        
        var percentKapha = kaphaCount*100.0/total
        var percentPitta = pittaCount*100.0/total
        var percentVata = vataCount*100.0/total
        
        if total == 0 {
            return ""
        }
        
        percentKapha = percentKapha.rounded(.up)
        percentPitta = percentPitta.rounded(.up)
        percentVata = 100 - (percentKapha + percentPitta)
        
        return "\"\(percentKapha.roundToOnePlace)\",\"\(percentPitta.roundToOnePlace)\",\"\(percentVata.roundToOnePlace)\""
    }
    
  
    //MARK: === PROGRESS COMPLETED
    func processSparshnaLogic() {
        
        var acounter = arrRed.count
        let sampleFrequency = aSamplingFreq
        let ignoreTime = 0
        
        // Ignore 120 samples from the beginning
        let ignoreSamples = ignoreTime * sampleFrequency ;
        
        let actualTime = 32 - ignoreTime
        
        var NaRed: [Double] = [Double](repeating: 0, count: acounter - ignoreSamples)
        for z in ignoreSamples..<acounter  {
            NaRed[z - ignoreSamples] = Double((-1) * arrRed[z]);
            
        }
        
        acounter = acounter - ignoreSamples ;
        
        //BUTTER WORTH
        let aRed_HR_ButterWorth: [Double] = HeartRateDetectionModel.butterworthBandpassFilter(NaRed) as! [Double]
        
        /****************INVERSE FFT ON BUTTERWORTH*********************/
        
        let invFFT: [Double] =  newFFT.invCalculate(aRed_HR_ButterWorth, fps: Double(sampleFrequency))
        
        /**************************************/
        
        let arrFilteredData: [Double] = newFFT.calculate(invFFT, fps: Double(sampleFrequency))
        
        /***** For respiratory rate and gati , please use the raw signal not this filtered butterworth.  ****/
        //get the peak data ---
        //MARK: == GATI
        let gati_index = self.GatiCalculationAlgo(fft_gati: aRed_HR_ButterWorth, SamplingRate: sampleFrequency, numFrame: acounter)
        
        let fftDataForKPV = newFFT.calculate(NaRed, fps: Double(sampleFrequency))
        let absFftDataForKPV = fftDataForKPV.map({abs($0)})
        
        var kapha = 0.0
        var pitta = 0.0
        var vata = 0.0
        
        let frequencyResolution = (Double(sampleFrequency) * 1.0)/Double(fftDataForKPV.count)
        
        let lowerIndex = Int(0.8 / frequencyResolution)
        let upperIndex = Int(1.16 / frequencyResolution)
        let subArray = absFftDataForKPV[lowerIndex..<upperIndex]
        let frequencyDiff = 1.16 - 0.8
        kapha = subArray.reduce(0, +)/frequencyDiff
        
        let lowerIndexP = Int(1.16 / frequencyResolution)
        let upperIndexP = Int(1.33 / frequencyResolution)
        let subArrayP = absFftDataForKPV[lowerIndexP..<upperIndexP]
        let frequencyDiffP = 1.33 - 1.16
        pitta = subArrayP.reduce(0, +)/frequencyDiffP
        
        let lowerIndexV = Int(1.33 / frequencyResolution)
        let upperIndexV = Int(1.6 / frequencyResolution)
        let subArrayV = absFftDataForKPV[lowerIndexV..<upperIndexV]
        let frequencyDiffV = 1.6 - 1.33
        vata = subArrayV.reduce(0, +)/frequencyDiffV
        
        var gatiType = ""
        if gati_index >= 0.8 && gati_index <= 1.16  {
            gatiType = "Kapha"
            
        }
        if gati_index > 1.16 && gati_index <= 1.33 {
            gatiType = "Pitta"
        }
        if gati_index > 1.33 && gati_index <= 1.6 {
            gatiType = "Vata"
        }
        print("GATI TYPE === \(gatiType)")
        
        //MARK: == RYTHM
        
        let aRed_HR = NaRed.compactMap({return -1 * (HeartRateDetectionModel.butterworthBandpassFilter([$0]) as! [Double]).first!})
        
        //TETSED  let aRed_HR_ButterWorthHue: [Double] = HeartRateDetectionModel.butterworthBandpassFilter(arrFilteredData) as! [Double]
        
        //   PASS
        let aRed_HR_ButterWorthHue: [Double] = HeartRateDetectionModel.butterworthBandpassFilter(arrFilteredData) as! [Double]
        
        let avgHR = Double(oximeterPulseArray.reduce(0, +)) / Double(oximeterPulseArray.count)
        let mean_HR = avgHR
        
        let Rythm = self.getTalaValue()
        //self.HRVCalculationAlgo(ppgData: aRed_HR, samplingRate: sampleFrequency, numFrame: acounter, mean_HR: Int(mean_HR)) ;
        
        //MARK: == RR(Respiratory Rate)
        let rr = self.FFT2(input: NaRed, samplingFrequency: sampleFrequency, sizeOld: acounter)
        let RR_red = ceil(60.0 * rr) ;
        print(RR_red)
        let mean_RR = Int(RR_red)
        acounter = acounter + ignoreSamples ;
        
        //calculating the mean of red and blue intensities on the whole period of recording
        let meanr = arrRed.reduce(0, +) / Float(acounter)
        let meanb = arrBlue.reduce(0, +) / Float(acounter);
        
        //calculating the standard  deviation
        var Stdb: Float = 0.0
        var Stdr: Float = 0.0
        for i in 0..<acounter - 1 {
            let bufferb = arrBlue[i];
            Stdb = Stdb + ((bufferb - meanb) * (bufferb - meanb));
            
            let bufferr = arrRed[i];
            Stdr = Stdr + ((bufferr - meanr) * (bufferr - meanr));
            
        }
        
        //calculating the variance
        let varr = sqrt(Stdr / Float(acounter - 1));
        let varb = sqrt(Stdb / Float(acounter - 1));
        
        //calculating ratio between the two means and two variances
        let R = (varr / meanr) / (varb / meanb);
        
        //estimating SPo2
        let spo2 = 100 - 5 * (R)
        
        //let o2 = spo2
        let o2 = Float(spO2Value)
        
        //MARK: == BMI and BMR
        let total = ((dHei / 100) * (dHei / 100))
        let BMI = (dWei / (total <= 0 ? 1 : total));
        //let BMR = (66 + (13.7 * dWei) + (5 * dHei) - (6.8 * dAge));
        
        var BMR = 10*dWei + 6.25*dHei - 5*dAge + 5
        
        if self.isMale == false {
            //Female
            BMR = 10*dWei + 6.25*dHei - 5*dAge - 161
        }
        
        // BP calculation
        let meanHRInt = Double(Int(mean_HR))
        let ROB = 18.5;
        let ET = (364.5 - 1.23 * meanHRInt);
        let BSA = 0.007184 * (pow(dWei, 0.425)) * (pow(dHei, 0.725));
        let temp = Double(0.62 * meanHRInt) - Double(40.4 * BSA)
        let temp2 = Double(-6.6 + (0.25 * (ET - 35)))
        let SV = temp2 - temp - Double(0.51 * dAge);
        let sTemp1 = Double(0.007 * dAge) + Double(0.004 * meanHRInt)
        let sTemp = Double(0.013 * dWei) - sTemp1
        let PP = SV / (sTemp + 1.307);
        let MPP = Q * ROB;
        let fraction = Int(3.0 / 2.0)
        let SP = Int(MPP + Double(fraction) * PP);
        let DP = Int(Double(MPP) - PP / 3);
        
        //MARK == Kathinya Calculation
        let t_pulse: Double = Double(60.0 / mean_HR);
        let kathinya = (dHei / t_pulse);
        
        //MARK == Bala - diff og SP and DP
        let bala = SP - DP;
        
        /************************
         CALCULATION FOR SENDING IN API
         *************************/
        let fs = Double(sampleFrequency) / 2.0
        let step = Double(fs / Double(acounter))
        
        let min_freq = 0.5
        let max_freq = 2.0
        
        let low_count = Int(min_freq / step)
        let hi_count = Int(max_freq / step)
        
        var cnt = Int(low_count);
        var value = min_freq;
        
        var g = 0;
        
        var running_avg_gati: [[Double]] = [[Double]](repeating: [Double](repeating: 0, count: 2), count: acounter / 3 - 1);
        
        while ((cnt + 2) < hi_count) {
            running_avg_gati[g][0] = (arrFilteredData[cnt] + arrFilteredData[cnt + 1] + arrFilteredData[cnt + 2]) / 3.0;
            let data = "{" + "\(value)" + "," + "\(running_avg_gati[g][0])" + "}";
            fftDataServer.append(data)
            
            running_avg_gati[g][1] = value;
            value = value + 3 * step;
            cnt += 3;
            g += 1;
        }
        /******************************/
        
        //MARK: CALCULATE KPV
        var kaphaOld = 0.0
        var pittaOld = 0.0
        var vataOld = 0.0
        
        if (mean_HR <= 70) {
            kaphaOld += 1;
        } else if (mean_HR > 70 && mean_HR < 80) {
            pittaOld += 1
        } else {
            vataOld += 1
        }
        
        if (SP <= 90) {
            vataOld += 1;
        } else if (SP>90 && SP<=120) {
            pittaOld += 1;
        }
        else if (SP>120) {
            kaphaOld += 1;
        }
        
        if (DP<=60) {
            vataOld += 1;
        } else if (DP>60 && DP<=80) {
            pittaOld += 1;
        }
        else if (DP>80) {
            kaphaOld += 1;
        }
        
        //tala
        if !isTalaRegular {
            vataOld += 1;
        }
        
        
        if (bala<=30) {
            vataOld += 1;
        } else if (bala>40) {
            pittaOld += 1;
        } else if (bala>30 && bala<=40) {
            kaphaOld += 1;
        }
        
        if (kathinya>310) {
            vataOld += 1;
        } else if (kathinya<210) {
            pittaOld += 1;
        } else if (kathinya>=210 && kathinya<=310) {
            kaphaOld += 1;
        }
        
        var sparshnaValue = ""
        
        let totalGatiKPV = kapha + pitta + vata
        let gatiKPercentage = (kapha * 100.0)/totalGatiKPV
        let gatiPPercentage = (pitta * 100.0)/totalGatiKPV
        let gatiVPercentage = (vata * 100.0)/totalGatiKPV
        
        var vataKPercentage = 0.0
        var vataPPercentage = 0.0
        var vataVPercentage = 0.0
        
        
        if isTalaRegular { //6
            let totalVataKPV = kaphaOld * 154 + pittaOld * 154 + vataOld * 154
            vataKPercentage = Double((kaphaOld * 154 * 100)/totalVataKPV)
            vataPPercentage = Double((pittaOld * 154 * 100)/totalVataKPV)
            vataVPercentage = Double((vataOld * 154 * 100)/totalVataKPV)
            
            //commented for oximeter to put 75% weightage for gati KPV Percentage
            //sparshnaValue = "\(gatiKPercentage + vataKPercentage),\(gatiPPercentage + vataPPercentage ),\(gatiVPercentage + vataVPercentage)"
            sparshnaValue = "\((gatiKPercentage*0.75) + (vataKPercentage*0.25))" + "," +
            "\((gatiPPercentage*0.75) + (vataPPercentage*0.25))" + "," +
            "\((gatiVPercentage*0.75) + (vataVPercentage*0.25))"
            kUserDefaults.set(sparshnaValue, forKey: VIKRITI_SPARSHNA)
        } else { //7
            let totalVataKPV = kaphaOld * 132 + pittaOld * 132 + vataOld * 132
            vataKPercentage = Double((kaphaOld * 132 * 100)/totalVataKPV)
            vataPPercentage = Double((pittaOld * 132 * 100)/totalVataKPV)
            vataVPercentage = Double((vataOld * 132 * 100)/totalVataKPV)
            
            //commented for oximeter to put 75% weightage for gati KPV Percentage
            sparshnaValue = "\((gatiKPercentage*0.75) + (vataKPercentage*0.25))" + "," +
            "\((gatiPPercentage*0.75) + (vataPPercentage*0.25))" + "," +
            "\((gatiVPercentage*0.75) + (vataVPercentage*0.25))"
            kUserDefaults.set(sparshnaValue, forKey: VIKRITI_SPARSHNA)
        }
        
        let result = "[" + Utils.getVikritiValue() + "]"
        
        var sparshnaResults = ""
        
        self.dic_sparshna = ["bpm": Int(mean_HR), "sp": Int(SP),"dp": Int(DP), "rythm": Rythm, "bala": Int(bala), "kath": Int(kathinya), "gati": "\(gatiType)", "o2r": Int(o2), "pbreath": mean_RR, "bmi": BMI, "bmr": Int(BMR), "tbpm": 165] as [String : Any]
        //TODO: need to check tbpm in android -- why used ??
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self.dic_sparshna, options: JSONSerialization.WritingOptions.prettyPrinted)
            sparshnaResults = String(bytes: jsonData, encoding: .utf8) ?? ""
        } catch let error {
            print(error)
        }
        
        let graphParamsDictValue = ["counter": acounter, "SamplingFreq": sampleFrequency, "Red_HR": arrRed.jsonStringRepresentation ?? "", "fft_gati": arrFilteredData.jsonStringRepresentation ?? "", "ppgData": self.ppgData.jsonStringRepresentation ?? ""] as [String: Any]
        
        let graphParamsStringValue = graphParamsDictValue.jsonStringRepresentation ?? ""
        
        debugPrint(">> result: \n \(result)")
        debugPrint(">> sparshnaResults: \n \(sparshnaResults)")
        debugPrint(">> sparshnaValue: \n \(sparshnaValue)")
        debugPrint(">> graphParamsStringValue: \n \(graphParamsStringValue)")
        
        let newValues = Utils.parseValidValue(string: result)
        appDelegate.dic_patient_response?.graph_params = graphParamsStringValue
        appDelegate.dic_patient_response?.vikriti_prensentage = result
        appDelegate.dic_patient_response?.last_assessment_data = sparshnaResults
        
        let aggrivation_Type = Utils.getCalculateAggrivation().stringValue
        appDelegate.dic_patient_response?.vikriti = aggrivation_Type
        appDelegate.dic_patient_response?.row_ppg = self.ppgData.jsonStringRepresentation ?? ""
        appDelegate.dic_patient_response?.spo = spO2Value
        appDelegate.dic_patient_response?.hr = Int(mean_HR)
        appDelegate.dic_patient_response?.pi_index = self.pi_index
        
        
        // MARK: upload sprashna data on server
        if let fromVC = fromVC {
            
            if (appDelegate.dic_patient_response?.prakriti ?? "") == "" {
                self.callAPIfor_prakriti_ml()
            }
            else {
                //                let aggrivation_Type = Utils.getCalculateAggrivation().stringValue
                //                appDelegate.dic_patient_response?.vikriti = aggrivation_Type
                //
                //                let vc = PredictedPrakritiVC.instantiate(fromAppStoryboard: .Dashboard)
                //                vc.arrRed = self.arrRed
                //                vc.dAge = self.dAge
                //                vc.dHei = self.dHei
                //                vc.dWei = self.dWei
                //                vc.spO2Value = self.spO2Value
                //                vc.isMale = self.isMale
                //                vc.dic_sparshna = self.dic_sparshna
                //                fromVC.navigationController?.pushViewController(vc, animated: true)
                
                
                self.callAPIForVikritiPridiction()
            }
            
        }
    }
        
    func callAPIfor_prakriti_ml() {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            
            var str_ppgData = ""
            let urlString = URL_prakriti_ml
            
            for ppgData in self.arrRed {
                str_ppgData += "\(ppgData) "
            }
            
            let params = ["ppg": str_ppgData.trimed(),
                          "gender": self.isMale ? "Male" : "Female",
                          "age": Int(dAge),
                          "height": dHei,
                          "weight": dWei] as [String : Any]
            
            debugPrint("API URL========>>>\(urlString)\n\n\nAPI Params========>>", params)
            
            let paramsJSON = JSON(params)
            let paramsString = paramsJSON.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions.prettyPrinted)!
            let postData = paramsString.data(using: .utf8)
            var request = URLRequest(url: URL(string: urlString)!,timeoutInterval: 60)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = postData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    print(String(describing: error))
                    DismissProgressHud()
                    print("facenaadi api response:======>>", response ?? [])
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(PrakritiML_RegModel.self, from: data)
                    debugPrint("APIService: result-> \(result)")
                    if result.status == "success" {
                        DismissProgressHud()
                        appDelegate.dic_patient_response?.prakriti_value = result.reg ?? ""
                        
                        DispatchQueue.main.async {
                            if let formvc = self.fromVC {
                                
                                
                                let aggrivation_Type = Utils.getCalculateAggrivation().stringValue
                                appDelegate.dic_patient_response?.vikriti = aggrivation_Type

                                let vc = PredictedPrakritiVC.instantiate(fromAppStoryboard: .Dashboard)
                                vc.arrRed = self.arrRed
                                vc.dAge = self.dAge
                                vc.dHei = self.dHei
                                vc.dWei = self.dWei
                                vc.spO2Value = self.spO2Value
                                vc.isMale = self.isMale
                                vc.dic_sparshna = self.dic_sparshna
                                formvc.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                        
                        
                    }
                    else {
                        DismissProgressHud()
                        Utils.showAlert(withMessage: "Something went wrong please try again")
                    }

                }catch {
                    DismissProgressHud()
                    debugPrint("APIService: Unable to decode \(error.localizedDescription)")
                }
                
            }
            
            task.resume()
        }
        else {
            Utils.showAlert(withMessage: AppMessage.no_internet)
        }
        
    }
    
    
    
    
    
    func logic_for_meanual_prediction(_ mlDosha: String) {
        if (appDelegate.dic_patient_response?.prakriti_value ?? "") != "" {

            var kapha = 0.0
            var pitta = 0.0
            var vata = 0.0
            
            if let str_prashna = appDelegate.dic_patient_response?.prakriti_value as? String {
                var strPrashna = str_prashna.replacingOccurrences(of: "[", with: "")
                strPrashna = strPrashna.replacingOccurrences(of: "]", with: "")
                strPrashna = strPrashna.replacingOccurrences(of: "\"", with: "")
                strPrashna = strPrashna.trimed()
                let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
                if  arrPrashnaScore.count == 3 {
                    kapha = Double(arrPrashnaScore[0]) ?? 0
                    pitta = Double(arrPrashnaScore[1]) ?? 0
                    vata = Double(arrPrashnaScore[2]) ?? 0
                }
            }

            if (appDelegate.dic_patient_response?.vikriti ?? "") != mlDosha {

                var jsonArray = [String]()
                if (mlDosha.contains("-")) {
                    let arr_aggravatedDosha = mlDosha.components(separatedBy: "-")
                    if (arr_aggravatedDosha.count > 2) {
                        // Case 4: all dosha aggravated
                        var kaphaPittaVata = ["", "", ""]
                        var kpv = [0.0, 0.0, 0.0]

                        // Determine the order of kapha, pitta, and vata
                        if (kapha > pitta && kapha > vata) {
                            kaphaPittaVata[0] = "KAPHA";
                            kpv[0] = kapha;
                            if (pitta > vata) {
                                kaphaPittaVata[1] = "PITTA";
                                kaphaPittaVata[2] = "VATA";
                                kpv[1] = pitta;
                                kpv[2] = vata;
                            } else {
                                kaphaPittaVata[1] = "VATA";
                                kaphaPittaVata[2] = "PITTA";
                                kpv[1] = vata;
                                kpv[2] = pitta;
                            }
                        } else if (pitta > kapha && pitta > vata) {
                            kaphaPittaVata[0] = "PITTA";
                            kpv[0] = pitta;
                            if (kapha > vata) {
                                kaphaPittaVata[1] = "KAPHA";
                                kaphaPittaVata[2] = "VATA";
                                kpv[1] = kapha;
                                kpv[2] = vata;
                            } else {
                                kaphaPittaVata[1] = "VATA";
                                kaphaPittaVata[2] = "KAPHA";
                                kpv[1] = vata;
                                kpv[2] = kapha;
                            }
                        } else {
                            kaphaPittaVata[0] = "VATA";
                            kpv[0] = vata;
                            if (kapha > pitta) {
                                kaphaPittaVata[1] = "KAPHA";
                                kaphaPittaVata[2] = "PITTA";
                                kpv[1] = kapha;
                                kpv[2] = pitta;
                            } else {
                                kaphaPittaVata[1] = "PITTA";
                                kaphaPittaVata[2] = "KAPHA";
                                kpv[1] = pitta;
                                kpv[2] = kapha;
                            }
                        }

                        // Adjust the values
                        var tempKpv = [kpv[0] + 6, kpv[1] + 6, kpv[2]]
                        let tempTotalKpv = tempKpv[0] + tempKpv[1];

                        if (tempTotalKpv < 100) {
                            pitta += 6;
                            vata += 6;
                            kapha = 100 - pitta - vata;
                        } else {
                            tempKpv[2] = 2.0;
                            let diff = (kpv[2] - 2.0) / 2;
                            kpv[0] += diff;
                            kpv[1] += diff;
                            kpv[2] = 2.0;

                            for i in 0..<2 {
                                switch (kaphaPittaVata[i]) {
                                case "KAPHA":
                                    kapha = kpv[i];
                                    break;
                                case "PITTA":
                                    pitta = kpv[i];
                                    break;
                                case "VATA":
                                    vata = kpv[i];
                                    break;
                                default:
                                    kapha = kpv[i];
                                    break;
                                }
                            }

                            if (kaphaPittaVata[0] == "vata") {
                                //binding.txtDosha.setText(getString(R.string.your_vata_aggrivated1));
                                //Singleton.getInstance().setVikritiBySanaay("VATA");
                            } else if (kaphaPittaVata[0] == "pitta") {
//                                binding.txtDosha.setText(getString(R.string.your_pitta_aggrivated));
//                                Singleton.getInstance().setVikritiBySanaay("PITTA");
                            } else {
//                                binding.txtDosha.setText(getString(R.string.your_kapha_aggrivated));
//                                Singleton.getInstance().setVikritiBySanaay("KAPHA");
                            }
                        }
                    } else if ((arr_aggravatedDosha[0] == "kapha" &&
                                arr_aggravatedDosha[1] == "pitta") ||
                               arr_aggravatedDosha[0] == "pitta" &&
                               (arr_aggravatedDosha[1] == "kapha")) {
                        // Case 3: 2 dosha aggravated - kapha-pitta or pitta-kapha
                        let tempK = kapha + 6;
                        let tempP = pitta + 6;
                        let total = tempK + tempP;

                        if (total > 100) {
                            let diff = (vata - 2.0) / 2;
                            vata = 2.0;
                            kapha += diff;
                            pitta += diff;
                        } else {
                            kapha = tempK;
                            pitta = tempP;
                            vata = 100 - kapha - pitta;
                        }
                    } else if ((arr_aggravatedDosha[0] == "pitta" &&
                                (arr_aggravatedDosha[1] == "vata" ||
                                 arr_aggravatedDosha[1] == "vatta") ||
                                (arr_aggravatedDosha[0] == "vata" ||
                                 arr_aggravatedDosha[0] == "vatta") &&
                                (arr_aggravatedDosha[1] == "pitta"))) {
                        // Case 3: 2 dosha aggravated - pitta-vata or vata-pitta
                        let tempP = pitta + 6;
                        let tempV = vata + 6;
                        let total = tempP + tempV;

                        if (total > 100) {
                            let diff = (kapha - 2.0) / 2;
                            kapha = 2.0;
                            pitta += diff;
                            vata += diff;
                        } else {
                            pitta = tempP;
                            vata = tempV;
                            kapha = 100 - pitta - vata;
                        }
                    } else if ((arr_aggravatedDosha[0] == "kapha" &&
                                (arr_aggravatedDosha[1] == "vata" ||
                                 arr_aggravatedDosha[1] == "vatta") ||
                                (arr_aggravatedDosha[0] == "vata" ||
                                 arr_aggravatedDosha[0] == "vatta") &&
                                (arr_aggravatedDosha[1] == "kapha"))) {
                        // Case 3: 2 dosha aggravated - kapha-vata or vata-kapha
                        let tempK = kapha + 6;
                        let tempV = vata + 6;
                        let total = tempK + tempV;
                        
                        if (total > 100) {
                            let diff = (pitta - 2.0) / 2;
                            pitta = 2.0;
                            kapha += diff;
                            vata += diff;
                        } else {
                            kapha = tempK;
                            vata = tempV;
                            pitta = 100 - kapha - vata;
                        }
                    }
                } else if mlDosha == "kapha" {
                    //Case 2: one dosha aggravated
                    kapha = kapha + 6;
                    pitta = pitta - 3;
                    vata = ((100 - pitta) - kapha);
                } else if mlDosha == "pitta" {
                    //Case 2: one dosha aggravated
                    pitta = pitta + 6;
                    kapha = kapha - 3;
                    vata = ((100 - kapha) - pitta);
                } else if mlDosha == "vata" {
                    //Case 2: one dosha aggravated
                    vata = vata + 6;
                    kapha = kapha - 3;
                    pitta = ((100 - kapha) - vata);
                } else {
                    // Case 1: Balanced ( show same as prakriti )
                }

                jsonArray.append(String.init(format: "%.1f", kapha));
                jsonArray.append(String.init(format: "%.1f", pitta));
                jsonArray.append(String.init(format: "%.1f", vata));

                appDelegate.dic_patient_response?.vikriti_prensentage = jsonArray.jsonStringRepresentation
            }
        }
    }
}

// MARK: - Utilities
extension ARSparshnaAlgo {
    //MARK: FFT2
    /*
     Implementation use for RR
     */
    func FFT2(input:[Double], samplingFrequency: Int, sizeOld: Int) -> Double {

        let size = 512 //self.highestPowerof2(n: sizeOld) //ceil(log(Double(size))/log(2)) //512

        var temp: Double = 0.0;
        var POMP = 0.0;
        var frequency = 0.0
        var output = [Double](repeating: 0, count: 2*size)

        for x in 0..<output.count {
            output[x] = input[x]
        }

        let doubleOutput = output.map { return Double($0) }

        let arrAfterFFT: [Double] =  newFFT.calculate(doubleOutput, fps: Double(samplingFrequency))//fft.bandFrequencies

        for x in 0..<size {
            //Befor Resp not 1
            var aRed_HR: [Double] = HeartRateDetectionModel.butterworthBandpassFilter([arrAfterFFT[x]]) as! [Double]//([arrAfterFFT[x]], sample: Int32(samplingFrequency)) as! [Double]
            if aRed_HR.count > 0{
                output[x] = aRed_HR[0]
            }
        }

        for x in 0..<2*size {
            output[x] = abs(output[x])
        }

        //max Resp index   === 0  7
        //Size
        for p in 0..<size {
            if(temp < output[p]) {
                temp = output[p];
                POMP = Double(p);
            }
        }

        frequency = Double(POMP*Double(samplingFrequency)/Double(2*size));

        print("FREQUENCY ======= \(samplingFrequency) = \(frequency)=====\(POMP)")
        return frequency;
    }
    
    func highestPowerof2(n: Int) -> Int
    {
        var res = 0;
        for i in stride(from: n, to: 1, by: -1) {
            // If i is a power of 2
            if ((i & (i - 1)) == 0)
            {
                res = i;
                break;
            }
        }
        return res;
    }
    
    //MARK: HRCalculationAlgo
//    func HRCalculationAlgo(ppgFiltData:[Double], samplingRate: Double, numFrame: Double, winSec: Double, winSlideSec:Double) -> Int {
//        var red_window:[Double] = [Double](repeating: 0, count: ppgFiltData.count)
//        
//        // Sliding Widow, Number of samples in a window 6*fps = 180
//        let window_seconds = winSec;
//        // Number of samples in the 6 sec window
//        let num_window_samples = Int(round(window_seconds * samplingRate))// 64
//        //TODO:
//        //Int(round(window_seconds * samplingRate));
//        
//        // Time between heart rate estimations - 0.5 * fps(30) = 15
//        let bpm_sampling_period = winSlideSec;
//        // number of samples in 0.5 seconds
//        let bpm_sampling_period_samples = Int(round(bpm_sampling_period * samplingRate));
//        
//        // Processing through sliding window
//        // Take first window with 180 samples and slide through window with 15 samples
//        //         Finds out the number of windows which need to be processed
//        // E.g. for 30 seconds, number of samples = 30*fps(30) = 900 samples
//        //        First window is 180, then the window slides every 15 samples
//        //        Hence in remaining (900-180) = 720 samples, the number of window is 720/15 = 60
//        
//        let num_bpm_samples = Int(floor(Double((numFrame - Double(num_window_samples)) / Double(bpm_sampling_period_samples))));
//        
//        var bpm: [Double] = [Double](repeating: 0, count: num_bpm_samples + 10) // 180
//        var bpm_smooth: [Double] = [Double](repeating: 0, count: num_bpm_samples + 10)
//        
//        // Loop through each window
//        for loop in 1...num_bpm_samples {
//            
//            //                    Log.v(TAG, " inside loop, count: " + loop);
//            
//            let window_start = (loop - 1) * bpm_sampling_period_samples; // start of sample in each window
//            for l in window_start...window_start + num_window_samples where loop - window_start >= 0 {
//                red_window[loop - window_start] = ppgFiltData[l];  // store in red_window[]
//            }
//            
//            //                        for (int m = 0; m <= num_window_samples; m++) {
//            //                            Log.v(TAG, " red_window : " + red_window[m].toString() + "  " + Integer.toString(m));
//            //                        }
//            
//            // Calculate Hanning Window
//            for l in 1...num_window_samples {
//                // i = index into Hann window function
//                red_window[l] = (red_window[l] * 0.5 * (1.0 - cos(2.0 * Double.pi * Double(l) / Double(num_window_samples))));
//            }
//            
//            // FFT
//            /*    let fft = TempiFFT(withSize: num_window_samples, sampleRate: Float(samplingRate))
//             fft.windowType = TempiFFTWindowType.hanning
//             let arrF = red_window.map { return Float($0) }
//             
//             fft.fftForward(arrF)
//             
//             // Interpoloate the FFT data so there's one band per pixel.
//             let screenWidth = UIScreen.main.bounds.size.width * UIScreen.main.scale
//             fft.calculateLinearBands(minFrequency: 0, maxFrequency: fft.nyquistFrequency, numberOfBands: Int(screenWidth))
//             */
//            let fft_ret:[Double] =  newFFT.calculate(red_window, fps: samplingRate) //fft.bandFrequencies
//            //let  fft_ret: [Double] = Fft.FFT(red_window, num_window_samples, samplingRate);
//            
//            //                        for (int m = 0; m < num_window_samples; m++) {
//            //                            Log.v(TAG, " fft_ret : " + Double.toString(fft_ret[m]) );
//            //                        }
//            
//            // BPM range has been taken as 40 and 230
//            let il = (40.0 / 60.0) * (Double(num_window_samples) / samplingRate) + 1; // value 5
//            let ih = (230.0 / 60.0) * (Double(num_window_samples) / samplingRate) + 1;   // value 25
//            // index_range = il:ih;
//            
//            //            Log.v(TAG, " il ; ih : " + il + "  " + ih);
//            
//            let il1 = Int(ceil(il));
//            let ih1 = Int(floor(ih));
//            //                    Log.v(TAG, " il ; ih : il1 ; ih1 " + il + "  " + ih + "  " + il + "  " + ih1);
//            
//            var fft_range: [Double] = [Double](repeating: 0, count: ih1)
//            //TODO===
//            for p in il1...Int(ih-1) where p - il1 >= 0 {
//                fft_range[p - il1] = Double(fft_ret[p]);
//            }
//            
//            //            for (int m = 0; m < ih; m++) {
//            //                        Log.v(TAG, " fft_range : " + Double.toString(fft_range[m]) + "  " + Integer.toString(m));
//            //            }
//            
//            // Find peaks
//            var peak_arr: [[Double]] = [[Double]](repeating: [Double](repeating: 0, count: 2), count: fft_range.count);
//            
//            //            // Initialise peak_arr
//            //            for z in 0..<fft_range.count {
//            //                peak_arr[z][0] = 0;
//            //                peak_arr[z][1] = 0;
//            //            }
//            
//            // TODO find out the index of the maximum peak
//            peak_arr = self.findpeaks(arr: fft_range);
//            
//            //            for (int m = 0; m < 7; m++) {
//            //                        Log.v(TAG, " peak_arr : " + Double.toString(peak_arr[m][0]) + "  " + Double.toString(peak_arr[m][1]));
//            //            }
//            
//            var max_val = 0.0;
//            var max_index = 0;
//            // Find max in peak_arr[z]
//            for z in 0..<fft_range.count {
//                if (peak_arr[z][0] >= max_val) {
//                    max_val = peak_arr[z][0];
//                    max_index = Int(peak_arr[z][1]);
//                }
//                
//            }
//            
//            let max_f_index = il + Double(max_index);
//            bpm[loop] = (max_f_index) * (samplingRate * 60.0) / Double(num_window_samples);
//            
//            let freq_resolution = 1 / winSec; // WINDOW_SECONDS = 6
//            
//            // lowest, hence (-), half the resolution (half the samples)
//            let lowf = bpm[loop] / 60.0 - winSlideSec * freq_resolution;
//            let freq_inc = 1 / 60.0;     // FINE_TUNING_FREQ_INCREMENT = 1
//            let test_freqs = freq_resolution / freq_inc; // 10
//            let test_freq: Int = Int(test_freqs);
//            
//            
//            // Initialise power
//            var power: [Double] = [Double](repeating: 0, count: test_freq)
//            for z in 0..<test_freq {
//                power[z] = 0;
//            }
//            
//            var freqs = [Double](repeating: 0, count: test_freq)
//            for z in 0..<test_freq {
//                freqs[z] = Double(z) * freq_inc + lowf;
//            }
//            for h in 0..<test_freq {
//                var re = 0.0;
//                var im = 0.0;
//                var phi = 0.0;
//                for j in 0..<num_window_samples {
//                    phi = 2.0 * (22.0 / 7.0) * freqs[h] * (Double(j) / samplingRate);
//                    re = re + red_window[j + 1] * cos(Double(phi));
//                    im = im + red_window[j + 1] * sin(Double(phi));
//                }
//                
//                power[h] = Double(re * re + im * im);
//            }
//            
//            // Peak power
//            var peak_power: [[Double]] = [[Double]](repeating: [Double](repeating: 0, count: 2), count: power.count)
//            
//            // Initialise peak_arr
//            for z in 0..<power.count {
//                peak_power[z][0] = 0;
//                peak_power[z][1] = 0;
//            }
//            
//            // TODO find out the index of the maximum peak
//            peak_power = self.findpeaks(arr: power);
//            max_val = 0;
//            max_index = 0;
//            for z in 0..<power.count - 1 {
//                if (peak_power[z][0] >= max_val) {
//                    max_val = peak_power[z][0];
//                    max_index = z;
//                }
//            }
//            
//            let max_index_1 = Int(max_index);
//            bpm_smooth[loop] = 60 * freqs[max_index_1];
//        }
//        
//        
//        // Find mean of bpm_smooth
//        var sum_bpm_smooth = 0.0;
//        for loop1 in 1..<num_bpm_samples {
//            sum_bpm_smooth = sum_bpm_smooth + bpm_smooth[loop1];
//        }
//        
//        let mean_HR1 = (sum_bpm_smooth / Double(num_bpm_samples));
//        return Int(mean_HR1);
//    }
    
    /*
     Method used to find peaks
     */
    func findpeaks(arr:[Double]) -> [[Double]] {
        var j = 0;
        let size  = arr.count ;
        var peaks: [[Double]] = [[Double]](repeating: [Double](repeating: 0, count: 2), count: size)
        for i in 1..<size - 1 {
            if ((arr[i] > arr[i-1] ) && (arr[i + 1] < arr[i])) {
                peaks[j][0] = arr[i] ;
                peaks[j][1] = Double(i) ;
                j += 1;
            }
        }
        return peaks ;
    }
    
    //MARK: HRVCalculationAlgo
//    func HRVCalculationAlgo(ppgData:[Double], samplingRate: Int, numFrame: Int, mean_HR: Int) -> Int {
//        // Find HRV
//        // Find peaks
//        var dbydt_HR = [Double]()
//        var daRed_HR = [Double]()
//        // Initialise peak_arr
//        daRed_HR = ppgData;
//
//        // Size of one window is mean_HR/60,
//        // Since need to take 3 RR in one window, size of one window will be meah_HR*4/60
//        // Hence number of samples per window is (mean_HR*4*SamplingRate/60)
//        // Example: Lets say framerate 30, samples 900 for 30 seconds, HR is 60
//
//        let window_size_RR =  (mean_HR * 4 * samplingRate / 60);  // based on number of samples window size 120
//        // find peak locations where dbydt = 0
//        var RR_peaks:[[Double]] = [[Double]](repeating: [Double](repeating: 0, count: 2), count: window_size_RR + 1);  // Find the peaks of each pulse within the window
//        // Window slides with one pulse width
//        let sliding_samples_window_RR = mean_HR * samplingRate / 60;
//
//
//        // Number of sliding window in this example = (900 -120) / 30 = 26
//        let num_sliding_window_RR = (numFrame - window_size_RR) / sliding_samples_window_RR; //
//
//        var RR_vals: [[Double]] = [[Double]](repeating: [Double](repeating: 0, count: 3), count: num_sliding_window_RR + 1) // RR1, RR2 and RR3
//
//        var category:[Int] = [Int](repeating: 0, count: num_sliding_window_RR) // identify category for each window
//        // Inside window
//
//        for iter in 1...num_sliding_window_RR {
//            // num_sliding_window_RR, loop for 26 times
//
//            let win_start = (iter - 1) * sliding_samples_window_RR; // start of sample in each window
//            for l in win_start...win_start + window_size_RR {
//                daRed_HR[l - win_start] = ppgData[l];  // store in daRed_HR
//            }
//
//            // TODO find out the index of the peaks
//            //TODO: ===
//            dbydt_HR = self.derivative(arr: daRed_HR, size: window_size_RR, fps: samplingRate)
//
//            var k = 0;
//            for j in 1...window_size_RR {
//                // Take positive peaks
//                if (((dbydt_HR[j] > 0 && dbydt_HR[j + 1] < 0) || dbydt_HR[j] == 0)) {
//                    RR_peaks[k][0] = daRed_HR[j];
//                    RR_peaks[k][1] = Double(j);
//                    k += 1
//                }  // All the peaks (+) peaks are in RR_peaks value in index 0 and offset in [1]
//            }
//            var temp = 0;
//            // Sort the RR_peaks and take the maximum, below is the algo to sort in decending order i.e. Max => min
//            for i in 0..<window_size_RR {
//                for j in 0..<(window_size_RR - i - 1) {
//                    if (RR_peaks[j][0] < RR_peaks[j + 1][0]) {
//                        temp = Int(RR_peaks[j][0]);
//                        RR_peaks[j][0] = RR_peaks[j + 1][0];
//                        RR_peaks[j + 1][0] = Double(temp);
//                    }
//                }
//            }
//
//            //var RtoR = [Double]();
//            RR_vals[iter][0] =  abs(RR_peaks[0][1] - RR_peaks[1][1]) // RR1
//            RR_vals[iter][1] = abs(RR_peaks[1][1] - RR_peaks[2][1]); // RR2
//            RR_vals[iter][2] = abs(RR_peaks[2][1] - RR_peaks[3][1]); //RR3
//
//
//        }  // End of sliding window if loop
//
//        // Apply the algo for Regular/Irregular Rythm
//        // Now iterate through each of the window and find the category
//        guard num_sliding_window_RR - 3 > 0 else  {
//            return 0
//        }
//
//        for iter1 in 1..<(num_sliding_window_RR - 3)  {
//            category[iter1] = 1; // Initially set as category 1 by default i.e. Regular - Step - 2
//
//            // If RR2 < .6 sec
//            if (((RR_vals[iter1][1] / Double(samplingRate)) < 0.6) && (RR_vals[iter1][1] < RR_vals[iter1][2])) {
//                category[iter1] = 5;  // Step - 3
//            }
//            var pulse = 1;
//            for i in 1...3 {
//                if ((RR_vals[iter1 + i][0] / Double(samplingRate)) < 0.8 && (RR_vals[iter1 + i][1] / Double(samplingRate)) < 0.8 &&
//                    (RR_vals[iter1 + i][2] / Double(samplingRate)) < 0.8 &&
//                    (RR_vals[iter1][0] + RR_vals[iter1][1] + RR_vals[iter1][2]) / Double(samplingRate) < 1.8) {
//                    category[iter1] = 5;   // Step - 3a
//                    pulse += 1;
//                }
//            }  // end of local loop
//
//            if (pulse < 4) {
//                category[iter1] = 1;
//                // Step - 3b
//            }
//
//            if (RR_vals[iter1][1] < 0.9 * RR_vals[iter1][0] && RR_vals[iter1][0] < 0.9 * RR_vals[iter1][2]) {
//
//                if ((RR_vals[iter1][1] + RR_vals[iter1][2]) < 2 * RR_vals[iter1][1]) {
//                    category[iter1] = 2;
//                } else {
//                    category[iter1] = 3;
//                }
//            }   // Step 4a and 4b
//            if (RR_vals[iter1][1] > 1.5 * RR_vals[iter1][0]) {
//                category[iter1] = 4;   // Step - 5
//            }
//        }  // End of sliding window algo loop Rythm
//        var count = 0.0;
//        for iter2 in 1..<(num_sliding_window_RR - 3) {
//            if (category[iter2] == 1) {
//                count += 1;
//            }
//        }
//
//        var Rythm = 0 ;
//        if (count >= 0.95 * Double(num_sliding_window_RR)) {
//            Rythm = 1;
//        }
//        return Rythm ;
//    }
    
    func getTalaValue() -> Int {
        let arrTimePerBeat = self.arrHeartRates.compactMap({$0/60.0})
        let total = arrTimePerBeat.reduce(0) { x, y in
            x + y
        }
        var squaredData = [Float]()
        for i in 1...(arrTimePerBeat.count-1) {
            let diff = arrTimePerBeat[i] - arrTimePerBeat[i - 1]
            squaredData.append(diff*diff)
        }
        squaredData.append(0)
        
        let totalSquare = squaredData.reduce(0) { x, y in
            x + y
        }
        
        let mean = totalSquare/total
        // let interval = totalSquare / Float(self.arrHeartRates.count - 1)
        let result = mean.squareRoot()
        if result >= 0.115 {
            isTalaRegular = false
            return 0 //(Vata)Irregular
        }
        isTalaRegular = true
        return 1 //Regular
    }
    
    
    /*
     Method to calculate derivative
     */
    func derivative(arr:[Double], size: Int, fps: Int) -> [Double]
    {
        var diffs = [Double]()
        for i in 1...(arr.count-1) {
            diffs.append(arr[i] - arr[i - 1])
        }
        return diffs;
    }
    
    //MARK: GATI CALCULATION
    func GatiCalculationAlgo(fft_gati:[Double], SamplingRate: Int, numFrame: Int) -> Double
    {
        var peak_gati: [[Double]] = [[Double]](repeating: [Double](repeating: 0, count: 2), count: numFrame)
        // Initialise peak_arr
        for z in 0..<numFrame {
            peak_gati[z][0] = 0;
            peak_gati[z][1] = 0;
        }
        
        let fs = Double(SamplingRate / 2);
        let step = (fs / Double(numFrame));
        
        let min_freq = 0.5;
        let max_freq = 2;
        
        let low_count = Int(min_freq / Double(step));
        let hi_count = Int(Double(max_freq) / step);
        
        var cnt = low_count;
        var value = min_freq;
        
        var g = 0;
        
        var running_avg_gati: [[Double]] = [[Double]](repeating: [Double](repeating: 0, count: 2), count: numFrame / 3 - 1)
        
        while ((cnt + 2) < hi_count)
        {
            running_avg_gati[g][0] = (fft_gati[cnt] + fft_gati[cnt + 1] + fft_gati[cnt + 2]) / 3.0;
            running_avg_gati[g][1] = value;
            value = value + 3 * Double(step);
            cnt += 3;
            g += 1;
        }
        peak_gati = self.darray_findpeaks(arr: running_avg_gati);
        var max_peak_gati = 0.0;
        var max_peak_index = 0.0;
        for z in 0..<peak_gati.count {
            if (peak_gati[z][0] >= max_peak_gati) {
                
                if ( (peak_gati[z][1] > 0.8) && (peak_gati[z][1] <= 1.6) ) {
                    max_peak_gati = peak_gati[z][0];
                    max_peak_index = peak_gati[z][1];
                }
            }
        }
        return Double(max_peak_index);
    }
    
    /*
     Method to find peak in array
     */
    func darray_findpeaks(arr:[[Double]]) -> [[Double]] {
        var j = 0;
        let size  = arr.count ;
        
        var  peaks = [[Double]](repeating: [Double](repeating: 0, count: 2), count: size)
        for i in 1..<size - 1 {
            if ((arr[i][0] >= arr[i-1][0] ) && (arr[i + 1][0] <= arr[i][0])) {
                peaks[j][0] = arr[i][0] ;
                peaks[j][1] = arr[i][1] ;
                j += 1;
            }
        }
        return peaks ;
    }
    
    
    
    
    
    //MARK: - CALL API for Vikriti Predction
    func callAPIForVikritiPridiction() {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            
            var str_ppgData = ""
            let urlString = URL_vikriti_prediction
            
            for ppgData in self.arrRed {
                str_ppgData += "\(ppgData) "
            }
                        
            var kapha_P = 0.0
            var pitta_P = 0.0
            var vata_P = 0.0
            var kapha_V = 0.0
            var pitta_V = 0.0
            var vata_V = 0.0
            
            if let str_prashna = appDelegate.dic_patient_response?.prakriti_value as? String {
                var strPrashna = str_prashna.replacingOccurrences(of: "[", with: "")
                strPrashna = strPrashna.replacingOccurrences(of: "]", with: "")
                strPrashna = strPrashna.replacingOccurrences(of: "\"", with: "")
                let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
                if  arrPrashnaScore.count == 3 {
                    kapha_P = (Double(arrPrashnaScore[0].trimed()) ?? 0).rounded(.up)
                    pitta_P = (Double(arrPrashnaScore[1].trimed()) ?? 0).rounded(.up)
                    vata_P = 100 - kapha_P - pitta_P
                }
            }
            
            if let str_vikriti_V = appDelegate.dic_patient_response?.vikriti_prensentage as? String {
                var strVikriti = str_vikriti_V.replacingOccurrences(of: "[", with: "")
                strVikriti = strVikriti.replacingOccurrences(of: "]", with: "")
                strVikriti = strVikriti.replacingOccurrences(of: "\"", with: "")
                let arrVikritiScore:[String] = strVikriti.components(separatedBy: ",")
                if  arrVikritiScore.count == 3 {
                    kapha_V = (Double(arrVikritiScore[0].trimed()) ?? 0).rounded(.up)
                    pitta_V = (Double(arrVikritiScore[1].trimed()) ?? 0).rounded(.up)
                    vata_V = 100 - kapha_V - pitta_V
                }
            }
            
            let str_prakriti = "\(Int(kapha_P)) \(Int(pitta_P)) \(Int(vata_P))"
            let str_vikriti = "\(Int(kapha_V)) \(Int(pitta_V)) \(Int(vata_V))"
            
            
            let params = ["ppg": str_ppgData.trimed(),
                          "spo2": self.spO2Value,
                          "gender": self.isMale ? "Male" : "Female",
                          "age": Int(self.dAge),
                          "height": self.dHei,
                          "weight": self.dWei,
                          "vikriti": str_vikriti,
                          "prakriti": str_prakriti,
                          "sysbp": self.dic_sparshna["sp"] as? Int ?? 0,
                          "diabp": self.dic_sparshna["dp"] as? Int ?? 0,
                          "bpm": self.dic_sparshna["bpm"] as? Int ?? 0,
                          "tbpm": self.dic_sparshna["tbpm"] as? Int ?? 0,
                          "kath": self.dic_sparshna["kath"] as? Int ?? 0,
                          "bala": self.dic_sparshna["bala"] as? Int ?? 0,
                          "gati": self.dic_sparshna["gati"] as? String ?? "",
                          "bmi": self.dic_sparshna["bmi"] as? Double ?? 0.0,
                          "bmr": self.dic_sparshna["bmr"] as? Int ?? 0,
                          "pbreath": self.dic_sparshna["pbreath"] as? Int ?? 0,
                          "doshaSelected": appDelegate.dic_patient_response?.vikriti ?? ""] as [String : Any]
            
            debugPrint("API URL========>>>\(urlString)\n\n\nAPI Params========>>", params)
            
            let paramsJSON = JSON(params)
            let paramsString = paramsJSON.rawString(String.Encoding.utf8, options: JSONSerialization.WritingOptions.prettyPrinted)!
            let postData = paramsString.data(using: .utf8)
            var request = URLRequest(url: URL(string: urlString)!,timeoutInterval: 60)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = postData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    print(String(describing: error))
                    DismissProgressHud()
                    print("vikriti prediction api response:======>>", response ?? [])
                    return
                }
                
                do {
                    let result = try JSONDecoder().decode(Vikriti_Prediction_Model.self, from: data)
                    debugPrint("Prakriti Cloud Result--------> \(result)")
                    
                    DismissProgressHud()
                    
                    DispatchQueue.main.async {
                        let str_type = (result.type ?? "")
                        appDelegate.dic_patient_response?.cloud_vikriti = str_type
                        
                        var d_kapha_V = 0.0
                        var d_pitta_V = 0.0
                        var d_vata_V = 0.0
                        var str_v_presendtage = (result.agg_kpv ?? "").trimed()
                        if str_v_presendtage != "" {
                            str_v_presendtage = str_v_presendtage.replacingOccurrences(of: "[", with: "")
                            str_v_presendtage = str_v_presendtage.replacingOccurrences(of: "]", with: "")
                            str_v_presendtage = str_v_presendtage.replacingOccurrences(of: ",", with: "")
                            let arr_v = str_v_presendtage.components(separatedBy: " ")
                            if arr_v.count == 3 {
                                d_kapha_V = Double(arr_v[0].trimed()) ?? 0
                                d_pitta_V = Double(arr_v[1].trimed()) ?? 0
                                d_vata_V = Double(arr_v[2].trimed()) ?? 0
                            }
                        }
                        
                        let str_vik = "[\(d_kapha_V), \(d_pitta_V), \(d_vata_V)]"
                        appDelegate.dic_patient_response?.cloud_vikriti_prensentage = str_vik

                        let vc = VikratiResultVC.instantiate(fromAppStoryboard: .Dashboard)
                        self.fromVC?.navigationController?.pushViewController(vc, animated: true)
                        
                        
                    }
                    
                }catch {
                    DismissProgressHud()
                    debugPrint("APIService: Unable to decode \(error.localizedDescription)")
                }
                
            }
            
            task.resume()
        }
        else {
            Utils.showAlert(withMessage: AppMessage.no_internet)
        }
        
    }
}
