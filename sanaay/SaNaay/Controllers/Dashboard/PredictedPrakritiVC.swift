//
//  PredictedPrakritiVC.swift
//  SaNaay
//
//  Created by Deepak Jain on 17/06/24.
//

import UIKit
import Alamofire
import LKRulerPicker

class PredictedPrakritiVC: UIViewController {


    var dAge = 1.0
    var dHei: Double = 1.0
    var dWei: Double = 1.0
    var arrRed = [Float]()
    var spO2Value = 0
    var isMale = true
    var dic_sparshna = [String : Any]()
    
    var kapha = false;
    var pitta = false;
    var vata = false;
    var firstAggravation = -1
    var is_initial = false
    
    var k_Prensetange = 0
    var p_Prensetange = 0
    var v_Prensetange = 0
    var str_Predomient = ""
    var str_patientID = ""
    var str_dosha = ""
    var screenFrom = ScreenType.none
    var dic_response: PatientListDataResponse?
    
    @IBOutlet weak var lbl_kapha_rular_prensentage: UILabel!
    @IBOutlet weak var lbl_pitta_rular_prensentage: UILabel!
    @IBOutlet weak var lbl_vata_rular_prensentage: UILabel!
    
    @IBOutlet weak var lbl_kapha: UILabel!
    @IBOutlet weak var lbl_pitta: UILabel!
    @IBOutlet weak var lbl_vata: UILabel!
    @IBOutlet weak var lbl_doshs: UILabel!
    
    // Added Using Storyboard.
    @IBOutlet weak var kapha_Picker: LKRulerPicker!
    @IBOutlet weak var pitta_Picker: LKRulerPicker!
    @IBOutlet weak var vata_Picker: LKRulerPicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let str_age = appDelegate.dic_patient_response?.patient_age ?? ""
        let str_gender = appDelegate.dic_patient_response?.patient_gender ?? ""

        if str_age.trimed() == "" && str_gender.trimed() == "" {
            Utils.showAlertWithTitleInController("", message: "Please update your profile with correct data", controller: self)
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

        self.configureUI()
    }
    
    func configureUI() {
        var kaphaCount = 0.0
        var pittaCount = 0.0
        var vataCount = 0.0
        self.str_patientID = appDelegate.dic_patient_response?.patient_id ?? ""
        
        let strkpvValue = appDelegate.dic_patient_response?.prakriti_value ?? ""
        if strkpvValue != "" {
            var strPrashna = strkpvValue.replacingOccurrences(of: "[", with: "")
            strPrashna = strPrashna.replacingOccurrences(of: "]", with: "")
            strPrashna = strPrashna.replacingOccurrences(of: "\"", with: "")
            strPrashna = strPrashna.replacingOccurrences(of: " ", with: "")

            let arrPrashnaScore:[String] = strPrashna.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kaphaCount += Double(arrPrashnaScore[0].trimed()) ?? 0
                pittaCount += Double(arrPrashnaScore[1].trimed()) ?? 0
                vataCount += Double(arrPrashnaScore[2].trimed()) ?? 0
            } else {
                return
            }
        } else {
            //return
        }
        
        var total = kaphaCount + pittaCount + vataCount
        if total == 0 {
            kaphaCount = 33.33
            pittaCount = 33.33
            vataCount = 33.34
            total = kaphaCount + pittaCount + vataCount
        }
        
        self.k_Prensetange = Int(round(kaphaCount*100.0/total))
        self.p_Prensetange =  Int(round(pittaCount*100.0/total))
        self.v_Prensetange =  100 - k_Prensetange - p_Prensetange
        print("percentKapha=", self.k_Prensetange)
        print("percentPitta=", self.p_Prensetange)
        print("percentVata =", self.v_Prensetange)

        let str_K_presentage_P = "\(Int(self.k_Prensetange)).0"
        let str_P_presentage_P = "\(Int(self.p_Prensetange)).0"
        let str_V_presentage_P = "\(Int(self.v_Prensetange)).0"
        
        self.lbl_kapha.text = str_K_presentage_P
        self.lbl_pitta.text = str_P_presentage_P
        self.lbl_vata.text = str_V_presentage_P
        
        self.lbl_kapha_rular_prensentage.text = str_K_presentage_P + "%"
        self.lbl_pitta_rular_prensentage.text = str_P_presentage_P + "%"
        self.lbl_vata_rular_prensentage.text = str_V_presentage_P + "%"

        self.calculatePrakriti()
        self.configureKaphaPicker()
        self.configurePittaPicker()
        self.configureVataPicker()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            self.is_initial = true
        }
    }
    
    func set_prikriti_status(_ currentPraktitiStatus: CurrentPrakritiStatus) {
        switch currentPraktitiStatus {
        case .TRIDOSHIC:
            self.str_dosha = "Tridoshic"
            self.str_Predomient = "You are tridoshic"

        case .KAPHA_VATA:
            self.str_dosha = "Kapha-Vata"
            self.str_Predomient = "Your predominant dosha is Kapha-Vata"
            
        case .KAPHA_PITTA:
            self.str_dosha = "Kapha-Pitta"
            self.str_Predomient = "Your predominant dosha is Kapha-Pitta"
            
        case .PITTA_KAPHA:
            self.str_dosha = "Pitta-Kapha"
            self.str_Predomient = "Your predominant dosha is Pitta-Kapha"
            
        case .VATA_PITTA:
            self.str_dosha = "Vata-Pitta"
            self.str_Predomient = "Your predominant dosha is Vata-Pitta"
            
        case .VATA :
            self.str_dosha = "Vata"
            self.str_Predomient = "Your predominant dosha is Vata"

        case .PITTA:
            self.str_dosha = "Pitta"
            self.str_Predomient = "Your predominant dosha is Pitta"
            
        case .KAPHA:
            self.str_dosha = "Kapha"
            self.str_Predomient = "Your predominant dosha is Kapha"
        }
        
        self.lbl_doshs.text = self.str_Predomient
        appDelegate.dic_patient_response?.prakriti = self.str_dosha
    }
    
    
    func configureKaphaPicker() {
        var kvalue = self.k_Prensetange
        if self.is_initial == false {
            kvalue = kvalue - 1
        }
        let weightMetrics = LKRulerPickerConfiguration.Metrics(minimumValue: 0,
                                                               defaultValue: kvalue,
                                                               maximumValue: 100,
                                                               divisions: 10,
                                                               fullLineSize: 30,
                                                               midLineSize: 18,
                                                               smallLineSize: 18)
        self.kapha_Picker.configuration = LKRulerPickerConfiguration(scrollDirection: .horizontal, alignment: .start, metrics: weightMetrics)
        self.kapha_Picker.highlightLineColor = UIColor.clear
        self.kapha_Picker.tintColor = UIColor.init(hex: "D8E8D8")
        self.kapha_Picker.font = UIFont.systemFont(ofSize: 0)
        self.kapha_Picker.highlightFont = UIFont.systemFont(ofSize: 0)
        self.kapha_Picker.dataSource = self
        self.kapha_Picker.delegate = self
    }
    
    func configurePittaPicker() {
        var pvalue = self.p_Prensetange
        if self.is_initial == false {
            pvalue = pvalue - 1
        }
        let weightMetrics = LKRulerPickerConfiguration.Metrics(minimumValue: 0,
                                                               defaultValue: pvalue,
                                                               maximumValue: 100,
                                                               divisions: 10,
                                                               fullLineSize: 30,
                                                               midLineSize: 18,
                                                               smallLineSize: 18)
        self.pitta_Picker.configuration = LKRulerPickerConfiguration(scrollDirection: .horizontal, alignment: .start, metrics: weightMetrics)
        self.pitta_Picker.highlightLineColor = UIColor.clear
        self.pitta_Picker.tintColor = UIColor.init(hex: "D8E8D8")
        self.pitta_Picker.font = UIFont.systemFont(ofSize: 0)
        self.pitta_Picker.highlightFont = UIFont.systemFont(ofSize: 0)
        self.pitta_Picker.dataSource = self
        self.pitta_Picker.delegate = self
    }
    
    func configureVataPicker() {
        var vvalue = self.v_Prensetange
        if self.is_initial == false {
            vvalue = vvalue - 1
        }
        let weightMetrics = LKRulerPickerConfiguration.Metrics(minimumValue: 0,
                                                               defaultValue: vvalue,
                                                               maximumValue: 100,
                                                               divisions: 10,
                                                               fullLineSize: 30,
                                                               midLineSize: 18,
                                                               smallLineSize: 18)
        self.vata_Picker.configuration = LKRulerPickerConfiguration(scrollDirection: .horizontal, alignment: .start, metrics: weightMetrics)
        self.vata_Picker.highlightLineColor = UIColor.clear
        self.vata_Picker.tintColor = UIColor.init(hex: "D8E8D8")
        self.vata_Picker.font = UIFont.systemFont(ofSize: 0)
        self.vata_Picker.highlightFont = UIFont.systemFont(ofSize: 0)
        self.vata_Picker.dataSource = self
        self.vata_Picker.delegate = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func btn_Back_Action(_ sender: UIControl) {
        var is_screen = false
        if let stackVCs = self.navigationController?.viewControllers {
            if let activeSubVC = stackVCs.first(where: { type(of: $0) == HomeVC.self }) {
                is_screen = true
                self.navigationController?.popToViewController(activeSubVC, animated: true)
            }
        }
        if is_screen == false {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btn_menual_prikriti_Action(_ sender: UIControl) {
        let vc = PrakritiQuestionVC.instantiate(fromAppStoryboard: .Assessment)
        vc.screenFrom = self.screenFrom
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_continue_Action(_ sender: UIControl) {
        //let prakrit_kpv = "/[\"\(self.k_Prensetange)", "\(self.p_Prensetange)", "\(self.v_Prensetange)"]"
        
        //KPV
        let result = "[" + "\"\(self.k_Prensetange)\",\"\(self.p_Prensetange)\",\"\(self.v_Prensetange)\"" + "]"
        self.callAPIforsubmitPrakriti(presentage: result)

    }
    
}


extension PredictedPrakritiVC: LKRulerPickerDelegate, LKRulerPickerDataSource {
    
    func rulerPicker(_ picker: LKRulerPicker, didSelectItemAtIndex index: Int) {
        //self.lbl_kapha_rular_prensentage.text = rulerPicker(picker, highlightTitleForIndex: index)
    }
    
    func rulerPicker(_ picker: LKRulerPicker, titleForIndex index: Int) -> String? {
        guard index % picker.configuration.metrics.divisions == 0 else { return nil }
        switch picker {
        case kapha_Picker:
            return "\(picker.configuration.metrics.minimumValue + index)"
        case pitta_Picker:
            return "\(picker.configuration.metrics.minimumValue + index)"
        case vata_Picker:
            return "\(picker.configuration.metrics.minimumValue + index)"
        default:
            fatalError("Handler picker")
        }
        
    }
    
    func rulerPicker(_ picker: LKRulerPicker, highlightTitleForIndex index: Int) -> String? {
        switch picker {
        case kapha_Picker:
            if (self.firstAggravation == -1) {
                self.firstAggravation = 1;
            }
            kapha = true;
            pitta = false;
            vata = false;
            let k_count = picker.configuration.metrics.minimumValue + index
            self.logic_for_change_KPV(value: k_count)
            
            return "\(picker.configuration.metrics.minimumValue + index)%"
        case pitta_Picker:
            
            if (self.firstAggravation == -1) {
                self.firstAggravation = 2;
            }
            kapha = false;
            pitta = true;
            vata = false;
            let p_count = picker.configuration.metrics.minimumValue + index
            self.logic_for_change_KPV(value: p_count)
            
            //let p_count = picker.configuration.metrics.minimumValue + index
            //self.logic_for_customKPV(k_count: 0, p_count: p_count, v_count: 0)
            return "\(picker.configuration.metrics.minimumValue + index)%"
        case vata_Picker:
            
            if (self.firstAggravation == -1) {
                self.firstAggravation = 3;
            }
            kapha = false;
            pitta = false;
            vata = true;
            
            let v_count = picker.configuration.metrics.minimumValue + index
            self.logic_for_change_KPV(value: v_count)
            
            //let v_count = picker.configuration.metrics.minimumValue + index
            //self.logic_for_customKPV(k_count: 0, p_count: 0, v_count: v_count)
            return "\(picker.configuration.metrics.minimumValue + index)%"
        default:
            fatalError("Handler picker")
        }
    }
    
    func logic_for_change_KPV(value: Int) {
        if self.is_initial == false {
            return
        }
        if (kapha) {
            if (firstAggravation == 1) {
                self.k_Prensetange = value
                self.p_Prensetange = (100 - value) / 2;
                self.v_Prensetange = (100 - value) / 2;
                self.configurePittaPicker()
                self.configureVataPicker()
                self.lbl_kapha.text = "\(value).0%"
                self.lbl_pitta.text = "\(self.p_Prensetange).0%"
                self.lbl_vata.text = "\(self.v_Prensetange).0%"
                self.lbl_kapha_rular_prensentage.text = "\(value).0%"
                self.lbl_pitta_rular_prensentage.text = "\(self.p_Prensetange).0%"
                self.lbl_vata_rular_prensentage.text = "\(self.v_Prensetange).0%"
            } else if (firstAggravation == 2) {
                if (self.k_Prensetange > value) {
                    self.v_Prensetange = self.v_Prensetange + (self.k_Prensetange - value);
                } else if (self.k_Prensetange < value) {
                    self.v_Prensetange = self.v_Prensetange - (value - self.k_Prensetange);
                }
                if (self.v_Prensetange >= 0) {
                    self.configureVataPicker()
                } else {
                    self.k_Prensetange = self.k_Prensetange + self.v_Prensetange
                    self.configureKaphaPicker()
                }
            } else if (firstAggravation == 3) {
                if (self.k_Prensetange > value) {
                    p_Prensetange = p_Prensetange + (self.k_Prensetange - value);
                } else if (self.k_Prensetange < value) {
                    p_Prensetange = p_Prensetange - (value - self.k_Prensetange);
                }
                if (p_Prensetange >= 0) {
                    self.configurePittaPicker()
                } else {
                    self.k_Prensetange = self.k_Prensetange + self.p_Prensetange
                    self.configureKaphaPicker()
                }
            }
            self.k_Prensetange = value;
            self.v_Prensetange = 100 - k_Prensetange - p_Prensetange
        }
        else if (pitta) {
            if (firstAggravation == 1) {
                if (self.p_Prensetange > value) {
                    self.v_Prensetange = self.v_Prensetange + (self.p_Prensetange - value);
                } else if (self.p_Prensetange < value) {
                    self.v_Prensetange = self.v_Prensetange - (value - self.p_Prensetange);
                }
                if (self.v_Prensetange >= 0) {
                    self.configureVataPicker()
                } else {
                    self.p_Prensetange = self.p_Prensetange + self.v_Prensetange
                }
            } else if (firstAggravation == 2) {
                self.k_Prensetange = (100 - value) / 2;
                self.v_Prensetange = (100 - value) / 2;
                self.configureKaphaPicker()
                self.configureVataPicker()
            } else if (firstAggravation == 3) {
                if (self.p_Prensetange > value) {
                    self.k_Prensetange = self.k_Prensetange + (self.p_Prensetange - value);
                } else if (self.p_Prensetange < value) {
                    self.k_Prensetange = self.k_Prensetange - (value - self.p_Prensetange);
                }
                if (k_Prensetange >= 0) {
                    self.configureKaphaPicker()
                } else {
                    self.p_Prensetange = self.p_Prensetange + k_Prensetange
                }
            }
            self.p_Prensetange = value;
            self.v_Prensetange = 100 - k_Prensetange - p_Prensetange
        }
        else if (vata) {
            if (firstAggravation == 1) {
                if (self.v_Prensetange > value) {
                    self.p_Prensetange = self.p_Prensetange + (self.v_Prensetange - value);
                } else if (self.v_Prensetange < value) {
                    self.p_Prensetange = self.p_Prensetange - (value - self.v_Prensetange);
                }
                if (self.p_Prensetange >= 0) {
                    self.configurePittaPicker()
                } else {
                    self.v_Prensetange = self.v_Prensetange + self.p_Prensetange
                    self.configureVataPicker()
                }
            } else if (firstAggravation == 2) {
                if (self.v_Prensetange > value) {
                    self.k_Prensetange = self.k_Prensetange + (self.v_Prensetange - value);
                } else if (self.v_Prensetange < value) {
                    self.k_Prensetange = self.k_Prensetange - (value - self.v_Prensetange);
                }
                if (self.k_Prensetange >= 0) {
                    self.configureKaphaPicker()
                } else {
                    self.v_Prensetange = self.v_Prensetange + self.k_Prensetange
                    configureVataPicker()
                }
            } else if (firstAggravation == 3) {
                self.k_Prensetange = (100 - value) / 2;
                self.p_Prensetange = (100 - value) / 2;
                self.configureKaphaPicker()
                self.configurePittaPicker()
            }
            self.v_Prensetange = value;
            if (self.k_Prensetange >= 0) {
                self.p_Prensetange = 100 - k_Prensetange - v_Prensetange
            }
            else {
                self.k_Prensetange = 100 - p_Prensetange - v_Prensetange
            }
        }
        self.lbl_kapha.text = "\(self.k_Prensetange).0"
        self.lbl_pitta.text = "\(self.p_Prensetange).0"
        self.lbl_vata.text = "\(self.v_Prensetange).0"
        self.lbl_kapha_rular_prensentage.text = "\(self.k_Prensetange).0%"
        self.lbl_pitta_rular_prensentage.text = "\(self.p_Prensetange).0%"
        self.lbl_vata_rular_prensentage.text = "\(self.v_Prensetange).0%"
        self.calculatePrakriti();
    }
    
    func calculatePrakriti() {
        let currentPraktitiStatus = Utils.getCustom_Prakriti(k_cout: self.k_Prensetange, p_cout: self.p_Prensetange, v_cout: self.v_Prensetange)
        self.set_prikriti_status(currentPraktitiStatus)
    }
    
}


//MARK: - API CALL
extension PredictedPrakritiVC {
    

    func callAPIforsubmitPrakriti(presentage: String) {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            let urlString = BASE_URL + APIEndpoints.Ksubmit_prakritiQuestion.rawValue
            
            let params = ["patient_id": self.str_patientID,
                          "language_id": 1,
                          "prakriti_type": 2,
                          "prakriti_value": self.str_dosha,
                          "prakriti_percentage": presentage] as [String : Any]

            debugPrint("Perameters=========>>\(params)")
            
            Alamofire.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default,headers: Utils.apiCallHeaders).responseJSON  { response in
                switch response.result {
                    
                case .success(let values):
                    print(response)
                    guard let dicResponse = (values as? Dictionary<String,AnyObject>) else {
                        DispatchQueue.main.async(execute: {
                            DismissProgressHud()
                        })
                        return
                    }
                    
                    if dicResponse["status"] as? String == "error" {
                        DispatchQueue.main.async(execute: {
                            DismissProgressHud()
                            Utils.showAlertOkController(title: "", message: (dicResponse["message"] as? String ?? ""), buttons: ["Ok"]) { success in
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                        return
                    }
                    
                    debugPrint(dicResponse)
                    
                    //KPV
                    let result = "[" + "\"\(self.k_Prensetange)\",\"\(self.p_Prensetange)\",\"\(self.v_Prensetange)\"" + "]"
                    appDelegate.dic_patient_response?.prakriti_value = result
                    appDelegate.dic_patient_response?.prakriti = self.str_dosha
                    
                    if self.screenFrom == .edit_prakriti {
                        if let stackVCs = self.navigationController?.viewControllers {
                            if let activeSubVC = stackVCs.first(where: { type(of: $0) == PatientHistoryVC.self }) {
                                (activeSubVC as? PatientHistoryVC)?.callAPIforPatientHistoryList()
                                self.navigationController?.popToViewController(activeSubVC, animated: true)
                            }
                            if let activeSubVC = stackVCs.first(where: { type(of: $0) == PatientListVC.self }) {
                                (activeSubVC as? PatientListVC)?.is_update_details = true
                                (activeSubVC as? PatientListVC)?.callAPIforPatientList()
                            }
                        }
                    }
                    else {
                        self.callAPIForVikritiPridiction()
                    }
                    
                case .failure(let error):
                    Utils.showAlertWithTitleInController("", message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    DismissProgressHud()
                })
            }
        }else {
            Utils.showAlertWithTitleInController("", message: AppMessage.no_internet, controller: self)
        }
    }
    
    
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
                        self.navigationController?.pushViewController(vc, animated: true)
                        
                        
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
