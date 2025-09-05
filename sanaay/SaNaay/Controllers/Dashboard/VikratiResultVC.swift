//
//  VikratiResultVC.swift
//  SaNaay Wellness
//
//  Created by DEEPAK JAIN on 22/10/23.
//

import UIKit
import Alamofire

class VikratiResultVC: UIViewController {

    var str_K_presentage_Cloud = ""
    var str_P_presentage_Cloud = ""
    var str_V_presentage_Cloud = ""
    
    var resultDic: [String: Any] = [String: Any]()
//    var str_K_presentage_V = ""
//    var str_P_presentage_V = ""
//    var str_V_presentage_V = ""
    var arr_section = [[String: Any]]()
    var dic_AllData = [String: Any]()
    var resultParams = [SparshnaResultParamModel]()
//  var currentKPVStatus = Utils.getYourCurrentKPVState()
    var Cloud_currentKPVStatus = Utils.getYourCurrentKPVState()
    
    @IBOutlet weak var tblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        
        //Register Table Cell
        self.tblView.register(nibWithCellClass: CurrentBalTableCell.self)
        self.tblView.register(nibWithCellClass: ParamsTableCell.self)
        self.tblView.register(nibWithCellClass: MenualAssessmentTableCell.self)
        
        //self.configureUI()
        self.configureUI_forCloud_logic()
        self.setupParamsData()
        self.manageSection()
    }
    
//    func configureUI() {
//        var kaphaCount = 0.0
//        var pittaCount = 0.0
//        var vataCount = 0.0
//        self.currentKPVStatus = Utils.getYourCurrentKPVState()
//
//        if let str_vikriti = appDelegate.dic_patient_response?.vikriti_prensentage as? String {
//            var str_vikritiPrensentage = str_vikriti.replacingOccurrences(of: "[", with: "")
//            str_vikritiPrensentage = str_vikritiPrensentage.replacingOccurrences(of: "]", with: "")
//            str_vikritiPrensentage = str_vikritiPrensentage.replacingOccurrences(of: "\"", with: "")
//            let arrPrashnaScore:[String] = str_vikritiPrensentage.components(separatedBy: ",")
//            if  arrPrashnaScore.count == 3 {
//                kaphaCount += Double(arrPrashnaScore[0].trimed()) ?? 0
//                pittaCount += Double(arrPrashnaScore[1].trimed()) ?? 0
//                vataCount += Double(arrPrashnaScore[2].trimed()) ?? 0
//            } else {
//                return
//            }
//        } else {
//            return
//        }
//
//        let total = kaphaCount + pittaCount + vataCount
//
//        let percentKapha = round(kaphaCount*100.0/total)
//        let percentPitta =  round(pittaCount*100.0/total)
//        let percentVata =  round(vataCount*100.0/total)
//
//        self.str_K_presentage_V = "\(Int(percentKapha))%"
//        self.str_P_presentage_V = "\(Int(percentPitta))%"
//
//        if (Int(percentKapha) + Int(percentPitta) + Int(percentVata)) == 100 {
//            self.str_V_presentage_V = "\(Int(percentVata))%"
//        } else {
//            self.str_V_presentage_V = "\(Int(100 - (percentKapha + percentPitta)))%"
//        }
//    }
    
    func configureUI_forCloud_logic() {
        var kaphaCount = 0.0
        var pittaCount = 0.0
        var vataCount = 0.0
        self.Cloud_currentKPVStatus = Utils.getYourCurrentKPVState_Temp_Cloud()

        if let str_vikriti = appDelegate.dic_patient_response?.cloud_vikriti_prensentage as? String {
            var str_vikritiPrensentage = str_vikriti.replacingOccurrences(of: "[", with: "")
            str_vikritiPrensentage = str_vikritiPrensentage.replacingOccurrences(of: "]", with: "")
            str_vikritiPrensentage = str_vikritiPrensentage.replacingOccurrences(of: "\"", with: "")
            let arrPrashnaScore:[String] = str_vikritiPrensentage.components(separatedBy: ",")
            if  arrPrashnaScore.count == 3 {
                kaphaCount += Double(arrPrashnaScore[0].trimed()) ?? 0
                pittaCount += Double(arrPrashnaScore[1].trimed()) ?? 0
                vataCount += Double(arrPrashnaScore[2].trimed()) ?? 0
            } else {
                return
            }
        } else {
            return
        }

        let total = kaphaCount + pittaCount + vataCount

        let percentKapha = round(kaphaCount*100.0/total)
        let percentPitta =  round(pittaCount*100.0/total)
        let percentVata =  round(vataCount*100.0/total)

        self.str_K_presentage_Cloud = "\(Int(percentKapha))%"
        self.str_P_presentage_Cloud = "\(Int(percentPitta))%"

        if (Int(percentKapha) + Int(percentPitta) + Int(percentVata)) == 100 {
            self.str_V_presentage_Cloud = "\(Int(percentVata))%"
        } else {
            self.str_V_presentage_Cloud = "\(Int(100 - (percentKapha + percentPitta)))%"
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        //self.back_cklick()
    }
    
    func back_cklick() {
        var is_back = false
        if let stackVCs = self.navigationController?.viewControllers {
            if let activeSubVC = stackVCs.first(where: { type(of: $0) == HomeVC.self }) {
                is_back = true
                self.navigationController?.popToViewController(activeSubVC, animated: true)
            }
        }
        
        if is_back == false {
            self.navigationController?.popViewController(animated: true)
        }
    }

}

//MARK: - UITableView Delegate DataSource Method

extension VikratiResultVC: UITableViewDelegate, UITableViewDataSource {
    
    func getLastAssessmentData()  -> [String: Any]  {
        //kUserDefaults.value(forKey: LAST_ASSESSMENT_DATA) as? String
        guard let lastAssData = appDelegate.dic_patient_response?.last_assessment_data as? String, !lastAssData.isEmpty else {
            return [:]
        }
        let resultString = lastAssData
        guard let dataStr = resultString.data(using: .utf8) else {
            return [:]
        }
        
        do {
            let jsonData = try JSONSerialization.jsonObject(with: dataStr, options: .allowFragments)
            let resultDic = jsonData as! [String: Any]
            print(resultDic)
            return resultDic
        } catch let error {
            print(error)
            return [:]
        }
    }
    
    func setupParamsData() {
        self.dic_AllData["current_dosha"] = self.Cloud_currentKPVStatus.rawValue.capitalized
        
        resultDic = getLastAssessmentData()
        
        let dic1 = ["favorite_id": 1,
                    "what_does_means": "- You may often feel bloating and constipation\n- Make sure you don't eat raw foods and veggies, steam them a bit and a drop of ghee is a must to correct Vata imbalance",
                    "aggravation_type": self.Cloud_currentKPVStatus.rawValue,
                    "short_description": "How fast your pulse beats, measured as high / medium / low.",
                    "parameter": "bpm",
                    "title": "Heart Rate"] as [String : Any]

        let dic2 = ["title": "Matra",
                    "what_does_means": "- Add rock salt to your diet\n- Hydrate as much as you can",
                    "favorite_id": 3,
                    "aggravation_type": self.Cloud_currentKPVStatus.rawValue,
                    "parameter": "sp",
                    "short_description": "Subjective pressure felt on physician’s fingers when blood vessel is full. Classified as high/medium/low."] as [String : Any]

        let dic3 = ["what_does_means": "Eat smaller regular meals and keep a regular check on your blood pressure.",
                    "title": "Tanaav",
                    "favorite_id": 4,
                    "aggravation_type": self.Cloud_currentKPVStatus.rawValue,
                    "short_description": "Subjective pressure felt of physician’s fingers when blood vessel is empty. Classified as high/medium/low.",
                    "parameter": "dp"] as [String : Any]

        let dic4 = ["aggravation_type": self.Cloud_currentKPVStatus.rawValue,
                    "parameter": "bala",
                    "short_description": "Subjective pressure felt on physician’s finger. Classified as weak/moderate/strong.",
                    "what_does_means": "- Hydrate as much as you can\n- Do not self-medicate",
                    "favorite_id": 6,
                    "title": "Pulse Pressure"] as [String : Any]

        let dic5 = ["short_description": "Subjective hardness of radial artery felt by physician. Classified as soft or moderately hard or hard and brittle.",
                    "parameter": "kath",
                    "favorite_id": 5,
                    "aggravation_type": self.Cloud_currentKPVStatus.rawValue,
                    "what_does_means": "- Maintain your heart health\n- Regular workouts and nutrition is the key",
                    "title": "Stiffness Index"] as [String : Any]

        let dic6 = ["short_description": "Subjective feeling of how the pulse is moving. Classified as slow and shallow/smooth and moderate/fast and strong.",
                    "aggravation_type": self.Cloud_currentKPVStatus.rawValue,
                    "parameter": "gati",
                    "favorite_id": 7,
                    "title": "Pulse Morphology",
                    "what_does_means": "- Warm nourishing food and oil massages will help you feel better"] as [String : Any]
        
        let dic10 = ["short_description": "Measure of the amount of oxygen-carrying hemoglobin in the blood relative to the amount of hemoglobin not carrying oxygen.",
                    "aggravation_type": self.Cloud_currentKPVStatus.rawValue,
                    "parameter": "o2r",
                    "favorite_id": 7,
                    "title": "SpO₂",
                    "what_does_means": ""] as [String : Any]

        let dic7 = ["favorite_id": 2,
                    "parameter": "rhythm",
                    "title": "Rhythm",
                    "short_description": "Rhythm or stability of pulse",
                    "aggravation_type": self.Cloud_currentKPVStatus.rawValue,
                    "what_does_means": "- Your tala tends to go irregular\n- Right nutrition, proper sleep and exercise is the key"] as [String : Any]

        let dic8 = ["title": "Body Mass Index",
                    "favorite_id": 9,
                    "parameter": "bmi",
                    "what_does_means": "",
                    "aggravation_type": self.Cloud_currentKPVStatus.rawValue,
                    "short_description": "Measure of body fat based on height and weight (kgs/sqm) that applies to adult men and women."] as [String : Any]

        let dic9 = ["parameter": "bmr",
                    "favorite_id": 10,
                    "what_does_means": "",
                    "aggravation_type": self.Cloud_currentKPVStatus.rawValue,
                    "short_description": "Calories burnt by an individual’s body at rest.",
                    "title": "Basal Metabolic Rate"] as [String : Any]
        
        var dataArray = [[String: Any]]()
        dataArray.append(dic1)
        dataArray.append(dic2)
        dataArray.append(dic3)
        dataArray.append(dic4)
        dataArray.append(dic5)
        dataArray.append(dic6)
        dataArray.append(dic10)
        dataArray.append(dic7)
        dataArray.append(dic8)
        dataArray.append(dic9)

        var resultParamArr = [SparshnaResultParamModel]()
        dataArray.forEach { data in
            let paramData = SparshnaResultParamModel(fromDictionary: data)
            if paramData.paramType == .bmi {
                let value = self.resultDic[paramData.paramType.rawValue] as? Double ?? 0
                paramData.paramStringValue = String(value)
            } else if paramData.paramType == .gati {
                let value = self.resultDic[paramData.paramType.rawValue] as? String ?? ""
                paramData.paramStringValue = value
            } else if paramData.paramType == .rythm {
                let value = self.resultDic["rythm"] as? Int ?? 0
                paramData.paramStringValue = String(value)
            } else {
                let value = self.resultDic[paramData.paramType.rawValue] as? Int ?? 0
                paramData.paramStringValue = String(value)
            }
            paramData.updateParamDetails()
            if paramData.aggravationType != "" {
                resultParamArr.append(paramData)
            }
        }
        self.resultParams = resultParamArr
    }
    
    func manageSection() {
        self.arr_section.removeAll()
        
        self.arr_section.append(["identifier": "kpv_res"])
        self.arr_section.append(["identifier": "detailed_res"])
        self.arr_section.append(["identifier": "bottom"])
        
        self.tblView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let str_identifier = self.arr_section[indexPath.row]["identifier"] as? String ?? ""
        if str_identifier == "kpv_res" {
            let cell = tableView.dequeueReusableCell(withClass: CurrentBalTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            
            //Vikriti Result
//            cell.lbl_kapha.text = self.str_K_presentage_V
//            cell.lbl_pitta.text = self.str_P_presentage_V
//            cell.lbl_vata.text = self.str_V_presentage_V
//            
//            cell.lbl_kapha_cloud.text = self.str_K_presentage_Cloud
//            cell.lbl_pitta_cloud.text = self.str_P_presentage_Cloud
//            cell.lbl_vata_cloud.text = self.str_V_presentage_Cloud
            
            cell.lbl_kapha.text = self.str_K_presentage_Cloud
            cell.lbl_pitta.text = self.str_P_presentage_Cloud
            cell.lbl_vata.text = self.str_V_presentage_Cloud
            
            //if (appDelegate.dic_patient_response?.vikriti ?? "") == CurrentKPVStatus.BALANCED.rawValue {
            if (appDelegate.dic_patient_response?.cloud_vikriti ?? "") == CurrentKPVStatus.BALANCED.rawValue {
                cell.img_aggravation.image = UIImage.init(named: "icon_balanced")
                cell.lbl_aggravation.text = "Patient is Balanced"
            }
            else {
                cell.lbl_aggravation.text = "Patient \((appDelegate.dic_patient_response?.cloud_vikriti ?? "").uppercased()) is aggravated"
                
                // "Patient \((appDelegate.dic_patient_response?.vikriti ?? "").uppercased()) is aggravated"
                
                if (appDelegate.dic_patient_response?.vikriti ?? "").uppercased() == CurrentKPVStatus.KAPHA.rawValue.uppercased() {
                    cell.img_aggravation.image = UIImage.init(named: "icon_kapha")
                }
                else if (appDelegate.dic_patient_response?.vikriti ?? "").uppercased() == CurrentKPVStatus.PITTA.rawValue.uppercased() {
                    cell.img_aggravation.image = UIImage.init(named: "icon_pitta")
                }
                else {
                    cell.img_aggravation.image = UIImage.init(named: "icon_vata")
                }
            }
            
//            if (appDelegate.dic_patient_response?.cloud_vikriti ?? "") == CurrentKPVStatus.BALANCED.rawValue {
//                cell.lbl_aggravation_cloud.text = "Patient is Balanced"
//            }
//            else {
//                cell.lbl_aggravation_cloud.text = "Patient \((appDelegate.dic_patient_response?.cloud_vikriti ?? "").uppercased()) is aggravated"
//            }
            
            
            return cell
        }
        else if str_identifier == "detailed_res" {
            let cell = tableView.dequeueReusableCell(withClass: ParamsTableCell.self, for: indexPath)
            cell.delegate = self
            cell.selectionStyle = .none
            var getHeihjt:Double = Double(Double(self.resultParams.count) / 2.0).rounded(.up)
            getHeihjt = getHeihjt * 140
            cell.constraint_collect_viewHeight.constant = getHeihjt + 50
            cell.configureUI(resultParams: self.resultParams)
        
            return cell
        }else {
            let cell = tableView.dequeueReusableCell(withClass: MenualAssessmentTableCell.self, for: indexPath)
            cell.selectionStyle = .none

            
            cell.didTappedYesButton = { (sender) in
                self.callAPIforSubmitVikritiResponse(fromVC: self, go_to_screen: "naadi_question")
            }
            
            cell.didTappedSkipButton = { (sender) in
                self.callAPIforSubmitVikritiResponse(fromVC: self, go_to_screen: "skip")
            }
            
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension VikratiResultVC: SparshnaResultParamListCellDelegate {
    func showInfoOfParam(at index: Int) {
        let resultParam = self.resultParams[index]
        let vc = ResultParamDetailVC.instantiate(fromAppStoryboard: .Dashboard)
        vc.resultParam = resultParam
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        if let tabVC = self.tabBarController {
            tabVC.present(vc, animated: true, completion: nil)
        } else {
            self.present(vc, animated: true, completion: nil)
        }
    }
}

//MARK: - APi Call
extension VikratiResultVC {
    
    func callAPIforSubmitVikritiResponse(fromVC: UIViewController, go_to_screen: String) {
        
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            let urlString = BASE_URL + APIEndpoints.Ksubmit_vikratiResponse.rawValue
            let params = ["ffs": "",
                          "ppf": "",
                          "vikriti_type": "1",
                          "language_id": "1",
                          "graph_params": appDelegate.dic_patient_response?.graph_params ?? "",
                          "vikriti": appDelegate.dic_patient_response?.cloud_vikriti ?? "",
                          "oxymeter_vikriti": appDelegate.dic_patient_response?.cloud_vikriti ?? "",
                          "vikriti_percentage": appDelegate.dic_patient_response?.cloud_vikriti_prensentage ?? "",
                          "patient_id": appDelegate.dic_patient_response?.patient_id ?? "",
                          "vikriti_sparshna_response": appDelegate.dic_patient_response?.last_assessment_data ?? "",
                          "row_ppg": appDelegate.dic_patient_response?.row_ppg ?? "",
                          "pi_index": appDelegate.dic_patient_response?.pi_index ?? 0.0,
                          "spo": appDelegate.dic_patient_response?.spo ?? 0,
                          "hr": appDelegate.dic_patient_response?.hr ?? 0] as [String : Any]
            
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
                                fromVC.navigationController?.popViewController(animated: true)
                            }
                        })
                        return
                    }
                    
                    DispatchQueue.main.async(execute: {
                        DismissProgressHud()
                    })
                    let dic_response = dicResponse["data"] as? [String: Any] ?? [:]

                    if go_to_screen == "naadi_question" {
                        let obj = Story_Assessment.instantiateViewController(withIdentifier: "NaadiQuestionaireVC") as! NaadiQuestionaireVC
                        self.navigationController?.pushViewController(obj, animated: true)
                    }
                    else {
                        let obj = Story_Dashboard.instantiateViewController(withIdentifier: "SuggestionVC") as! SuggestionVC
                        self.navigationController?.pushViewController(obj, animated: true)
                    }
                    
                    
                    
                case .failure(let error):
                    Utils.showAlertWithTitleInController("", message: error.localizedDescription, controller: fromVC)
                }
                DispatchQueue.main.async(execute: {
                    DismissProgressHud()
                })
            }
        }else {
            Utils.showAlert(withMessage: AppMessage.no_internet)
        }
    }
}
