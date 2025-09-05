//
//  SelectAggaravationVC.swift
//  SaNaay
//
//  Created by Deepak Jain on 21/07/24.
//

import UIKit
import Alamofire

class SelectAggaravationVC: UIViewController, delegate_selection_Action {
    
    var arr_selected_aggrattion = [String]()
    var str_aggravattion = (appDelegate.dic_patient_response?.vikriti ?? "").lowercased()
    var arr_All_Answers = [[String: Any]]()
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var btn_kapha: UIControl!
    @IBOutlet weak var btn_pitta: UIControl!
    @IBOutlet weak var btn_vata: UIControl!
    @IBOutlet weak var btn_balanced: UIControl!
    @IBOutlet weak var btn_continue: UIControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupdata(type: self.str_aggravattion)
    }
    
    func setupdata(type: String) {
        if type != "" {
            self.arr_selected_aggrattion.append(type)
        }
        
        self.btn_kapha.backgroundColor = .white
        self.btn_pitta.backgroundColor = .white
        self.btn_vata.backgroundColor = .white
        self.btn_balanced.backgroundColor = .white
        self.btn_kapha.layer.borderColor = AppColor.app_TextGrayColor.cgColor
        self.btn_pitta.layer.borderColor = AppColor.app_TextGrayColor.cgColor
        self.btn_vata.layer.borderColor = AppColor.app_TextGrayColor.cgColor
        self.btn_balanced.layer.borderColor = AppColor.app_TextGrayColor.cgColor
        
        if self.arr_selected_aggrattion.count == 1 && self.arr_selected_aggrattion.first?.lowercased() == "kapha" {
            self.btn_kapha.backgroundColor = UIColor.init(hex: "ECFFF1")
            self.btn_kapha.layer.borderColor = AppColor.app_GreenColor.cgColor
        }
        else if self.arr_selected_aggrattion.count == 1 && self.arr_selected_aggrattion.first?.lowercased() == "pitta" {
            self.btn_pitta.backgroundColor = UIColor.init(hex: "ECFFF1")
            self.btn_pitta.layer.borderColor = AppColor.app_GreenColor.cgColor
        }
        else if self.arr_selected_aggrattion.count == 1 && self.arr_selected_aggrattion.first?.lowercased() == "vata" {
            self.btn_vata.backgroundColor = UIColor.init(hex: "ECFFF1")
            self.btn_vata.layer.borderColor = AppColor.app_GreenColor.cgColor
        }
        else if self.arr_selected_aggrattion.count == 1 && self.arr_selected_aggrattion.first?.lowercased() == "balanced" {
            self.btn_balanced.backgroundColor = UIColor.init(hex: "ECFFF1")
            self.btn_balanced.layer.borderColor = AppColor.app_GreenColor.cgColor
        }
        else if self.arr_selected_aggrattion.contains("kapha") && self.arr_selected_aggrattion.contains("pitta") {
            self.btn_kapha.backgroundColor = UIColor.init(hex: "ECFFF1")
            self.btn_pitta.backgroundColor = UIColor.init(hex: "ECFFF1")
            self.btn_pitta.layer.borderColor = AppColor.app_GreenColor.cgColor
            self.btn_kapha.layer.borderColor = AppColor.app_GreenColor.cgColor
        }
        else if self.arr_selected_aggrattion.contains("kapha") && self.arr_selected_aggrattion.contains("vata") {
            self.btn_kapha.backgroundColor = UIColor.init(hex: "ECFFF1")
            self.btn_vata.backgroundColor = UIColor.init(hex: "ECFFF1")
            self.btn_vata.layer.borderColor = AppColor.app_GreenColor.cgColor
            self.btn_kapha.layer.borderColor = AppColor.app_GreenColor.cgColor
        }
        else if self.arr_selected_aggrattion.contains("pitta") && self.arr_selected_aggrattion.contains("vata") {
            self.btn_pitta.backgroundColor = UIColor.init(hex: "ECFFF1")
            self.btn_vata.backgroundColor = UIColor.init(hex: "ECFFF1")
            self.btn_vata.layer.borderColor = AppColor.app_GreenColor.cgColor
            self.btn_pitta.layer.borderColor = AppColor.app_GreenColor.cgColor
        }
        
        if self.arr_selected_aggrattion.count == 0 {
            self.btn_continue.isUserInteractionEnabled = false
            self.btn_continue.backgroundColor = AppColor.app_TextGrayColor
        }
        else {
            self.btn_continue.isUserInteractionEnabled = true
            self.btn_continue.backgroundColor = AppColor.app_GreenColor
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
    
    func openPopup() {
        let objDialouge = SelectAggravationDialouge(nibName:"SelectAggravationDialouge", bundle:nil)
        objDialouge.delegate = self
        objDialouge.str_aggravation_doctor = self.arr_selected_aggrattion.joined(separator: "-")
        objDialouge.str_aggravation_sanaay = self.str_aggravattion
        self.addChild(objDialouge)
        objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview((objDialouge.view)!)
        objDialouge.didMove(toParent: self)
    }
    
    func aggravation_Action(_ isClicked: Bool, aggravation_type: String) {
        if isClicked {
            self.callAPIforSubmitVikritiResponse(aggravation: aggravation_type.capitalized)
        }
        
    }

    //MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_continue_Action(_ sender: UIButton) {
        var str_agg = ""
        
        if self.arr_selected_aggrattion.count == 1 {
            str_agg = self.arr_selected_aggrattion[0].lowercased()
        }
        else if self.arr_selected_aggrattion.count == 2 {
            let str_agg = self.arr_selected_aggrattion.joined(separator: "-")
        }
       
        
        if self.str_aggravattion.lowercased() == str_agg {
            //Directt api Call
            self.callAPIforSubmitVikritiResponse(aggravation: str_agg)
        }
        else {
            self.openPopup()
        }
        
    }
    
    @IBAction func btn_kapha_Action(_ sender: UIControl) {
        if self.arr_selected_aggrattion.count == 1 {
            if self.arr_selected_aggrattion.contains("balanced") {
                self.arr_selected_aggrattion.removeAll()
                self.setupdata(type: "kapha")
            }
            else if self.arr_selected_aggrattion.contains("kapha") {
                self.arr_selected_aggrattion.removeAll()
                self.setupdata(type: "")
            }
            else if self.arr_selected_aggrattion.contains("pitta") || self.arr_selected_aggrattion.contains("vata") {
                self.setupdata(type: "kapha")
            }
        }
        else if self.arr_selected_aggrattion.count == 2 {
            if self.arr_selected_aggrattion.contains("kapha") {
                if let indx = self.arr_selected_aggrattion.firstIndex(of: "kapha") {
                    self.arr_selected_aggrattion.remove(at: indx)
                }
                self.setupdata(type: "")
            }
        }
        else {
            self.setupdata(type: "kapha")
        }
    }
    
    @IBAction func btn_pitta_Action(_ sender: UIControl) {
        if self.arr_selected_aggrattion.count == 1 {
            if self.arr_selected_aggrattion.contains("balanced") {
                self.arr_selected_aggrattion.removeAll()
                self.setupdata(type: "pitta")
            }
            else if self.arr_selected_aggrattion.contains("pitta") {
                self.arr_selected_aggrattion.removeAll()
                self.setupdata(type: "")
            }
            else if self.arr_selected_aggrattion.contains("kapha") || self.arr_selected_aggrattion.contains("vata") {
                self.setupdata(type: "pitta")
            }
        }
        else if self.arr_selected_aggrattion.count == 2 {
            if self.arr_selected_aggrattion.contains("pitta") {
                if let indx = self.arr_selected_aggrattion.firstIndex(of: "pitta") {
                    self.arr_selected_aggrattion.remove(at: indx)
                }
                self.setupdata(type: "")
            }
        }
        else {
            self.setupdata(type: "pitta")
        }
    }
    
    @IBAction func btn_vata_Action(_ sender: UIControl) {
        if self.arr_selected_aggrattion.count == 1 {
            if self.arr_selected_aggrattion.contains("balanced") {
                self.arr_selected_aggrattion.removeAll()
                self.setupdata(type: "vata")
            }
            else if self.arr_selected_aggrattion.contains("vata") {
                self.arr_selected_aggrattion.removeAll()
                self.setupdata(type: "")
            }
            else if self.arr_selected_aggrattion.contains("kapha") || self.arr_selected_aggrattion.contains("pitta") {
                self.setupdata(type: "vata")
            }
        }
        else if self.arr_selected_aggrattion.count == 2 {
            if self.arr_selected_aggrattion.contains("vata") {
                if let indx = self.arr_selected_aggrattion.firstIndex(of: "vata") {
                    self.arr_selected_aggrattion.remove(at: indx)
                }
                self.setupdata(type: "")
            }
        }
        else {
            self.setupdata(type: "vata")
        }
    }
    
    @IBAction func btn_balance_Action(_ sender: UIControl) {
        self.arr_selected_aggrattion.removeAll()
        self.setupdata(type: "balanced")
    }
}


//MARK: - API Call
extension SelectAggaravationVC {
    
    func callAPIforSubmitVikritiResponse(aggravation: String) {
        
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            let urlString = BASE_URL + APIEndpoints.Ksubmit_vikratiResponse.rawValue
            let params = ["ffs": "",
                          "ppf": "",
                          "vikriti_type": "2",
                          "language_id": "1",
                          "vikriti": aggravation,
                          "vikriti_answer": self.arr_All_Answers.jsonStringRepresentation ?? "",
                          "graph_params": appDelegate.dic_patient_response?.graph_params ?? "",
                          "oxymeter_vikriti": appDelegate.dic_patient_response?.vikriti ?? "",
                          "vikriti_percentage": appDelegate.dic_patient_response?.vikriti_prensentage ?? "",
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
                            }
                        })
                        return
                    }
                    
                    DispatchQueue.main.async(execute: {
                        DismissProgressHud()
                    })
                    let dic_response = dicResponse["data"] as? [String: Any] ?? [:]

                    let obj = Story_Dashboard.instantiateViewController(withIdentifier: "SuggestionVC") as! SuggestionVC
                    self.navigationController?.pushViewController(obj, animated: true)
                    
                    
                case .failure(let error):
                    Utils.showAlertWithTitleInController("", message: error.localizedDescription, controller: self)
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
