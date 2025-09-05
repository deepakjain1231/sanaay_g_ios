//
//  SuggestionVC.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 18/06/23.
//

import UIKit
import Alamofire
import AlignedCollectionViewFlowLayout

class Suggestion_Data {
    var key: RegistationKey?
    var title: String?
    var fav_id: String?
    var placeholder: String?
    var type: D_RegisterFieldType
    var identifier: D_RegisterIdentified
    var tag: [[String: Any]]?
    var selected_tag: [[String: Any]]?
    
    internal init(key: RegistationKey? = nil, title: String? = nil, placeholder: String? = nil, type: D_RegisterFieldType = .other, identifier: D_RegisterIdentified = .other, favid: String = "", tag: [[String: Any]]? = nil, selected_tag: [[String: Any]]? = nil) {
        self.key = key
        self.fav_id = favid
        self.title = title
        self.placeholder = placeholder
        self.type = type
        self.identifier = identifier
        self.tag = tag
        self.selected_tag = selected_tag
    }
}




class SuggestionVC: UIViewController, UITextViewDelegate, delegate_AddAushadhi, delegate_selection {

    var str_aggrivation = appDelegate.dic_patient_response?.vikriti ?? ""
    var is_b_selection_oneTime = false
    var is_l_selection_oneTime = false
    var is_d_selection_oneTime = false
    
    var is_y_selection_oneTime = false
    var is_p_selection_oneTime = false
    var is_me_selection_oneTime = false
    var is_k_selection_oneTime = false
    var is_mu_selection_oneTime = false
    var is_panchkarma_selection_oneTime = false
    var dic_Value = [String: Any]()
    var dataSource = [Suggestion_Data]()
    var arr_selection = [String]()
    var arr_Food_Data = [[String: Any]]()
    var arr_Investigation_Data = [[String: Any]]()
    var arr_selected_aushadhi = [[String: Any]]()
    var arr_selected_food_item = [String]()
    var arr_selected_investigation_item = [String]()
    
    var arr_health_tag = [[String: Any]]()
    var arr_selected_health_tag = [[String: Any]]()
    
    
    var arr_Data: ContentLibraryDataResponse?
    var dic_response: PatientListDataResponse?
    @IBOutlet weak var tbl_View: UITableView!
    @IBOutlet weak var lbl_aggravation: UILabel!
    @IBOutlet weak var constraint_view_Bottom: NSLayoutConstraint!
    private let viewModel: RegisterViewModel = RegisterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if (appDelegate.dic_patient_response?.cloud_vikriti ?? "") == CurrentKPVStatus.BALANCED.rawValue {
            self.lbl_aggravation.text = "Patient is Balanced"
        }
        else {
            self.lbl_aggravation.text = "Patient \((appDelegate.dic_patient_response?.cloud_vikriti ?? "").uppercased()) is aggravated"
        }
        
        //self.lbl_aggravation.text = "Patients \(self.str_aggrivation) is aggravated"
        
        if #available(iOS 15.0, *) {
            self.tbl_View.sectionHeaderTopPadding = 0.0
        } else {
            // Fallback on earlier versions
        }
        
        self.dic_Value[RegistationKey.doctor_assessment.rawValue] = ""
        self.dic_Value[RegistationKey.prescriptions.rawValue] = ""
        self.dic_Value[RegistationKey.food_suggestions.rawValue] = ""
        self.dic_Value[RegistationKey.lifestyle_suggestions.rawValue] = ""
        self.dic_Value[RegistationKey.advice_investigations.rawValue] = ""
        
        
        //Register Table cell
        self.tbl_View.register(nibWithCellClass: AddNewYoga.self)
        self.tbl_View.register(nibWithCellClass: SuggestionTableCell.self)
        self.tbl_View.register(nibWithCellClass: HeaderTitleTableCell.self)
        self.tbl_View.register(nibWithCellClass: KriyaMudraDataTableCell.self)
        self.tbl_View.register(nibWithCellClass: RecommendationsTableCell.self)
        self.tbl_View.register(nibWithCellClass: RegisterButtonTableCell.self)
        self.tbl_View.register(nibWithCellClass: PrescriptionTableCell.self)
        self.tbl_View.register(nibWithCellClass: AutoCompleteSuggestionTableCell.self)
        self.callAPIforGetContentLibrary()
        self.manageSection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.constraint_view_Bottom.constant = keyboardSize.size.height - (appDelegate.window?.safeAreaInsets.bottom ?? 0)
            self.view.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        self.constraint_view_Bottom.constant = 0
        self.view.layoutIfNeeded()
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func goToHomeScreen() {
        if let stackVCs = self.navigationController?.viewControllers {
            if let activeSubVC = stackVCs.first(where: { type(of: $0) == HomeVC.self }) {
                self.navigationController?.popToViewController(activeSubVC, animated: true)
            }
        }
    }

    // MARK: - Navigation
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func btn_Submit_Action() {
        self.view.endEditing(true)
        var strdoc_ass = self.dic_Value[RegistationKey.doctor_assessment.rawValue] as? String ?? ""
        var arr_Prescription = self.dic_Value[RegistationKey.prescriptions.rawValue] as? [String] ?? []
        var strfoodSuggestion = self.dic_Value[RegistationKey.food_suggestions.rawValue] as? String ?? ""
        var strlifestyle_sugg = self.dic_Value[RegistationKey.lifestyle_suggestions.rawValue] as? String ?? ""
        var str_advice = self.dic_Value[RegistationKey.advice_investigations.rawValue] as? String ?? ""
        
        if strdoc_ass.trimed() == "Your text here..." || strdoc_ass.trimed() == "" {
            strdoc_ass = "NA"
        }
        if strfoodSuggestion.trimed() == "Your text here..." || strfoodSuggestion.trimed() == "" {
            strfoodSuggestion = "NA"
        }
        if strlifestyle_sugg.trimed() == "Your text here..." || strlifestyle_sugg.trimed() == "" {
            strlifestyle_sugg = "NA"
        }
        if str_advice.trimed() == "Your text here..." || str_advice.trimed() == "" {
            str_advice = "NA"
        }
        
        var paraamss = [String: Any]()
        paraamss["yogasana"] = ""
        paraamss["meditation"] = ""
        paraamss["pranayam"] = ""
        paraamss["kriya"] = ""
        paraamss["mudra"] = ""
        paraamss["panchkarma_suggestions"] = ""
        paraamss["breakfast_food"] = ""
        paraamss["lunch_food"] = ""
        paraamss["dinner_food"] = ""
        paraamss["herbal_suggestions"] = ""
        paraamss["food_suggestions"] = ""
        paraamss["advice_investigations"] = ""
        paraamss["no_of_days"] = ""
        paraamss["days_selection"] = ""
        paraamss["language_id"] = "1"
        
        paraamss["patient_id"] = appDelegate.dic_patient_response?.patient_id ?? ""
        paraamss["health_complaints"] = appDelegate.dic_patient_response?.health_complaints ?? ""
        paraamss["doctor_assessment"] = strdoc_ass.trimed()
        
        if arr_Prescription.count != 0 {
            paraamss["herbal_suggestions"] = self.arr_selected_aushadhi.jsonStringRepresentation
        }
        
        if self.arr_selected_food_item.count != 0 {
            paraamss["food_suggestions"] = self.arr_selected_food_item.joined(separator: ",")
        }
        
        if let arr_yogasna = self.dic_Value[RegistationKey.yogasana.rawValue] as? [String] {
            paraamss["yogasana"] = arr_yogasna.joined(separator: ",").trimed()
        }
        
        if let arr_pranayam = self.dic_Value[RegistationKey.pranayam.rawValue] as? [String] {
            paraamss["pranayam"] = arr_pranayam.joined(separator: ",").trimed()
        }
        
        if let arr_meditation = self.dic_Value[RegistationKey.meditation.rawValue] as? [String] {
            paraamss["meditation"] = arr_meditation.joined(separator: ",").trimed()
        }

        if let arr_kriya = self.dic_Value[RegistationKey.kriya.rawValue] as? [String] {
            paraamss["kriya"] = arr_kriya.joined(separator: ",").trimed()
        }
        
        if let arr_mudra = self.dic_Value[RegistationKey.mudra.rawValue] as? [String] {
            paraamss["mudra"] = arr_mudra.joined(separator: ",").trimed()
        }
        
        if let arr_panchkarma = self.dic_Value[RegistationKey.panchkarma_suggestions.rawValue] as? [String] {
            paraamss["panchkarma_suggestions"] = arr_panchkarma.joined(separator: ",").trimed()
        }
        paraamss["lifestyle_suggestions"] = strlifestyle_sugg.trimed()
        
        if self.arr_selected_investigation_item.count != 0 {
            paraamss["advice_investigations"] = self.arr_selected_investigation_item.joined(separator: ",")
        }
        
        if let arr_breakfast = self.dic_Value[RegistationKey.breakfast_food.rawValue] as? [String] {
            paraamss["breakfast_food"] = arr_breakfast.joined(separator: ",").trimed()
        }
        
        if let arr_lunch = self.dic_Value[RegistationKey.lunch_food.rawValue] as? [String] {
            paraamss["lunch_food"] = arr_lunch.joined(separator: ",").trimed()
        }
        
        if let arr_dinner = self.dic_Value[RegistationKey.dinner_food.rawValue] as? [String] {
            paraamss["dinner_food"] = arr_dinner.joined(separator: ",").trimed()
        }
        
        
        let vc = ScheduleAppoinmentVC.instantiate(fromAppStoryboard: .Dashboard)
        vc.dic_API_Params = paraamss
        vc.screenForm = .fromm_suggesttion
        self.navigationController?.pushViewController(vc, animated: true)
        
        
        //self.callAPIforSubmitSuggestion(paraamss)
        
//        //Go To Home Screen
//        let obj = Story_Main.instantiateViewController(withIdentifier: "Register2VC") as! Register2VC
//        self.navigationController?.pushViewController(obj, animated: true)
//        //self.callAPIforRegisterDoctor()
    }
}

//MARK: - API CALL
extension SuggestionVC {
    
    func callAPIforGetSuggestionTag(_ str_search: String, type: String, indx_row: String) {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            let urlString = BASE_URL + endPoint.kGetTags.rawValue
            
            let params = ["search_type": type,
                          "search_key": str_search] as [String : Any]
            
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
                        })
                        return
                    }
                    let arr_tempData = dicResponse["data"] as? [[String: Any]] ?? [[:]]
                    
                    if type == "food_items" {
                        self.arr_Food_Data = arr_tempData
                    }
                    else {
                        self.arr_Investigation_Data = arr_tempData
                    }
                    
                    if indx_row != "" {
                        let current_indx = IndexPath.init(row: Int(indx_row) ?? 0, section: 0)
                        self.tbl_View.beginUpdates()
                        self.tbl_View.reloadRows(at: [current_indx], with: .none)
                        self.tbl_View.endUpdates()
                    }
                    else {
                        self.tbl_View.reloadData()
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
    
    func callAPIforGetContentLibrary() {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            
            let params = ["language_id": "1",
                          "type": self.str_aggrivation,
                          "patient_id": appDelegate.dic_patient_response?.patient_id ?? ""]
            
            self.viewModel.getContent_Data_API(body: params, endpoint: APIEndpoints.GetContentLibrary) { status, result, error in
                switch status {
                case .loading:
                    break
                case .success:
                    DismissProgressHud()
                    if result?.status == "success" {
                        guard let dataaa = result?.data else {
                            return
                        }
                        self.arr_Data = dataaa
                        self.defaultData_added()
                        self.manageSection()
                    }
                    else {
                        guard let msgg = result?.message else {
                            return
                        }
                        self.view.makeToast(msgg)
                        self.tbl_View.reloadData()
                    }
                    break
                case .error:
                    DismissProgressHud()
                    break
                }
            }
        }else {
            DismissProgressHud()
            self.view.makeToast(AppMessage.no_internet)
        }
    }
    
    func callAPIforSubmitSuggestion(_ params: [String: Any]) {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            
            let urlString = BASE_URL + APIEndpoints.AddSuggetions_Report.rawValue
            ServiceCustom.shared.requestURL(urlString, Method: .post, parameters: params) { responsee, isSuccess, errorrr, status in
                DismissProgressHud()
                if let isSuccess = responsee?["status"] as? String, isSuccess == "success" {
                    
                    guard let dataaa = responsee?["data"] as? [[String: Any]] else {
                        return
                    }
                    debugPrint(dataaa[0]["report_link"] as? String ?? "")
                    self.goToHomeScreen()
                }
                
            }
        }
        else {
            DismissProgressHud()
            self.view.makeToast(AppMessage.no_internet)
        }
    }
}


//MARK: - UITableView Delegate Datasource Method

extension SuggestionVC: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    func defaultData_added() {
        if let dic_inner = self.arr_Data {

            //BreakFast Data
            if let indx_b_food = self.arr_Data?.food?.firstIndex(where: { dic_food in
                return (dic_food?.section?[0]?.subsection ?? "").lowercased() == "breakfast"
            }) {
                if let arr_b_food = self.arr_Data?.food?[indx_b_food]?.section?[0]?.data {

                    for inner in arr_b_food {

                        guard let str_SelectedName = inner?.name else { return }
                        self.selection_default(is_selection_oneTime: self.is_b_selection_oneTime, name: str_SelectedName, key: .breakfast_food)
                    }

                    self.is_b_selection_oneTime = true
                }
            }

            //Lunch Data
            if let indx_l_food = self.arr_Data?.food?.firstIndex(where: { dic_food in
                return (dic_food?.section?[0]?.subsection ?? "").lowercased() == "lunch"
            }) {
                if let arr_l_food = self.arr_Data?.food?[indx_l_food]?.section?[0]?.data {

                    for inner in arr_l_food {

                        guard let str_SelectedName = inner?.name else { return }
                        self.selection_default(is_selection_oneTime: self.is_l_selection_oneTime, name: str_SelectedName, key: .lunch_food)

                    }

                    self.is_l_selection_oneTime = true
                }
            }

            //Dinner Data
            if let indx_d_food = self.arr_Data?.food?.firstIndex(where: { dic_food in
                return (dic_food?.section?[0]?.subsection ?? "").lowercased() == "dinner"
            }) {
                if let arr_d_food = self.arr_Data?.food?[indx_d_food]?.section?[0]?.data {

                    for inner in arr_d_food {

                        guard let str_SelectedName = inner?.name else { return }
                        self.selection_default(is_selection_oneTime: self.is_d_selection_oneTime, name: str_SelectedName, key: .dinner_food)

                    }

                    self.is_d_selection_oneTime = true
                }
            }

            //Yogasana Data
            if let arr_yogasana = self.arr_Data?.yogasana {
                for inner in arr_yogasana {
                    guard let str_SelectedName = inner?.name else { return }
                    self.selection_default(is_selection_oneTime: self.is_y_selection_oneTime, name: str_SelectedName, key: .yogasana)
                }
                self.is_y_selection_oneTime = true
            }
            
            //Meditation Data
            if let arr_meditation = self.arr_Data?.meditation {
                for inner in arr_meditation {
                    guard let str_SelectedName = inner?.name else { return }
                    self.selection_default(is_selection_oneTime: self.is_me_selection_oneTime, name: str_SelectedName, key: .meditation)
                }
                self.is_me_selection_oneTime = true
            }

            //Pranayam Data
            if let arr_pranayam = self.arr_Data?.pranayam {
                for inner in arr_pranayam {
                    guard let str_SelectedName = inner?.name else { return }
                    self.selection_default(is_selection_oneTime: self.is_p_selection_oneTime, name: str_SelectedName, key: .pranayam)
                }
                self.is_p_selection_oneTime = true
            }

            //Kriya Data
            if let arr_kriya = self.arr_Data?.kriya {
                for inner in arr_kriya {
                    guard let str_SelectedName = inner?.name else { return }
                    self.selection_default(is_selection_oneTime: self.is_k_selection_oneTime, name: str_SelectedName, key: .kriya)
                }
                self.is_k_selection_oneTime = true
            }
                
            //Mudra Data
            if let arr_mudra = self.arr_Data?.mudra {
                for inner in arr_mudra {
                    guard let str_SelectedName = inner?.name else { return }
                        self.selection_default(is_selection_oneTime: self.is_mu_selection_oneTime, name: str_SelectedName, key: .mudra)
                }
                self.is_mu_selection_oneTime = true
            }

            //Panchkarma Data
            if let arr_panchkarma = self.arr_Data?.panchkarma {
                for inner in arr_panchkarma {
                    guard let str_SelectedName = inner?.name else { return }
                    self.selection_default(is_selection_oneTime: self.is_panchkarma_selection_oneTime, name: str_SelectedName, key: .panchkarma_suggestions)
                }
                self.is_panchkarma_selection_oneTime = true
            }
        }
    }
    
    
    func manageSection(is_selection: Bool = false) {
        self.dataSource.removeAll()
        
        //self.dataSource.append(Suggestion_Data.init(key: .prescriptions, title: "Common health complaints", placeholder: "Your text here...", type: .other, identifier: .textview, tag: self.arr_health_tag, selected_tag: self.arr_selected_health_tag))
        
        self.dataSource.append(Suggestion_Data.init(key: .doctor_assessment, title: "Doctor’s assessment", placeholder: "Your text here...", type: .other, identifier: .textview))
        
        self.dataSource.append(Suggestion_Data.init(key: .prescriptions, title: "Prescriptions", placeholder: "Your text here...", type: .other, identifier: .add_prescription))
        
        self.dataSource.append(Suggestion_Data.init(key: .food_suggestions, title: "Food suggestions", placeholder: "Your text here...", type: .other, identifier: .autocomplete_suggestion))
        
        self.dataSource.append(Suggestion_Data.init(key: .lifestyle_suggestions, title: "Lifestyle suggestions", placeholder: "Your text here...", type: .other, identifier: .textview))
        
        self.dataSource.append(Suggestion_Data.init(key: .advice_investigations, title: "Further investigations advice", placeholder: "Your text here...", type: .other, identifier: .autocomplete_suggestion))
        
        if let dic_inner = self.arr_Data {
            
            self.dataSource.append(Suggestion_Data.init(key: .other, title: "Food suggestions", placeholder: "", type: .other, identifier: .single_header))
            
            self.dataSource.append(Suggestion_Data.init(key: .breakfast_food, title: "Breakfast", placeholder: "", type: .breakfast_food, identifier: .recommendations))
            
            if self.arr_selection.contains(RegistationKey.breakfast_food.rawValue) {
                
                if let indx_b_food = self.arr_Data?.food?.firstIndex(where: { dic_food in
                    return (dic_food?.section?[0]?.subsection ?? "").lowercased() == "breakfast"
                }) {
                    if let arr_b_food = self.arr_Data?.food?[indx_b_food]?.section?[0]?.data {
                        
                        for inner in arr_b_food {
                            self.dataSource.append(Suggestion_Data.init(key: .breakfast_food, title: inner?.name, placeholder: "", type: .breakfast_food, identifier: .recommendations_value, favid: ""))

                            guard let str_SelectedName = inner?.name else { return }
                                self.selection_default(is_selection_oneTime: self.is_b_selection_oneTime, name: str_SelectedName, key: .breakfast_food)
                        }

                        if arr_b_food.count >= 5 {
                            self.dataSource.append(Suggestion_Data.init(key: .breakfast_food, title: "View more", placeholder: "", type: .breakfast_food, identifier: .view_more, favid: ""))
                        }
                        
                        self.is_b_selection_oneTime = true
                    }
                }
            }
            
            self.dataSource.append(Suggestion_Data.init(key: .lunch_food, title: "Lunch", placeholder: "", type: .lunch_food, identifier: .recommendations))
            
            if self.arr_selection.contains(RegistationKey.lunch_food.rawValue) {
                
                if let indx_l_food = self.arr_Data?.food?.firstIndex(where: { dic_food in
                    return (dic_food?.section?[0]?.subsection ?? "").lowercased() == "lunch"
                }) {
                    if let arr_l_food = self.arr_Data?.food?[indx_l_food]?.section?[0]?.data {
                        
                        for inner in arr_l_food {
                            self.dataSource.append(Suggestion_Data.init(key: .lunch_food, title: inner?.name, placeholder: "", type: .lunch_food, identifier: .recommendations_value, favid: ""))
                            //
                            guard let str_SelectedName = inner?.name else { return }
                            self.selection_default(is_selection_oneTime: self.is_l_selection_oneTime, name: str_SelectedName, key: .lunch_food)
                            //
                        }
                        
                        if arr_l_food.count >= 5 {
                            self.dataSource.append(Suggestion_Data.init(key: .lunch_food, title: "View more", placeholder: "", type: .lunch_food, identifier: .view_more, favid: ""))
                        }
                        
                        self.is_l_selection_oneTime = true
                    }
                }
            }
            
            self.dataSource.append(Suggestion_Data.init(key: .dinner_food, title: "Dinner", placeholder: "", type: .dinner_food, identifier: .recommendations))
            
            if self.arr_selection.contains(RegistationKey.dinner_food.rawValue) {
                
                if let indx_d_food = self.arr_Data?.food?.firstIndex(where: { dic_food in
                    return (dic_food?.section?[0]?.subsection ?? "").lowercased() == "dinner"
                }) {
                    if let arr_d_food = self.arr_Data?.food?[indx_d_food]?.section?[0]?.data {
                        
                        for inner in arr_d_food {
                            self.dataSource.append(Suggestion_Data.init(key: .dinner_food, title: inner?.name, placeholder: "", type: .dinner_food, identifier: .recommendations_value, favid: ""))
                            //
                            guard let str_SelectedName = inner?.name else { return }
                            self.selection_default(is_selection_oneTime: self.is_d_selection_oneTime, name: str_SelectedName, key: .dinner_food)
                            //
                        }
                        
                        if arr_d_food.count >= 5 {
                            self.dataSource.append(Suggestion_Data.init(key: .dinner_food, title: "View more", placeholder: "", type: .dinner_food, identifier: .view_more, favid: ""))
                        }
                        
                        self.is_d_selection_oneTime = true
                    }
                }
            }
            
            
            self.dataSource.append(Suggestion_Data.init(key: .other, title: "Select recommendations for the patient (Multiple)", placeholder: "", type: .other, identifier: .single_header))
            
            self.dataSource.append(Suggestion_Data.init(key: .yogasana, title: "Yogasana", placeholder: "", type: .yogasana, identifier: .recommendations))
            
            if self.arr_selection.contains(RegistationKey.yogasana.rawValue) {
                if let arr_yogasana = self.arr_Data?.yogasana {
                    for inner in arr_yogasana {
                        self.dataSource.append(Suggestion_Data.init(key: .yogasana, title: inner?.name, placeholder: "", type: .yogasana, identifier: .recommendations_value, favid: inner?.favorite_id ?? ""))
                        
                        //
                        guard let str_SelectedName = inner?.name else { return }
                        self.selection_default(is_selection_oneTime: self.is_y_selection_oneTime, name: str_SelectedName, key: .yogasana)
                        //
                    }
                    
                    if arr_yogasana.count >= 10 {
                        self.dataSource.append(Suggestion_Data.init(key: .yogasana, title: "View more", placeholder: "", type: .yogasana, identifier: .view_more, favid: ""))
                    }
                    
                    //self.dataSource.append(Suggestion_Data.init(key: .yogasana, title: "", placeholder: " Add a new yoga", type: .yogasana, identifier: .recommendations_addNew))
                    
                    self.is_y_selection_oneTime = true
                }
            }
            
            self.dataSource.append(Suggestion_Data.init(key: .meditation, title: "Meditation", placeholder: "", type: .meditation, identifier: .recommendations))
            
            if self.arr_selection.contains(RegistationKey.meditation.rawValue) {
                if let arr_meditation = self.arr_Data?.meditation {
                    for inner in arr_meditation {
                        self.dataSource.append(Suggestion_Data.init(key: .meditation, title: inner?.name, placeholder: "", type: .meditation, identifier: .recommendations_value, favid: inner?.favorite_id ?? ""))
                        
                        //
                        guard let str_SelectedName = inner?.name else { return }
                        self.selection_default(is_selection_oneTime: self.is_me_selection_oneTime, name: str_SelectedName, key: .meditation)
                        //
                    }
                    
                    if arr_meditation.count >= 10 {
                        self.dataSource.append(Suggestion_Data.init(key: .meditation, title: "View more", placeholder: "", type: .meditation, identifier: .view_more, favid: ""))
                    }
                    
                    self.is_me_selection_oneTime = true
                }
                
                //self.dataSource.append(Suggestion_Data.init(key: .meditation, title: "", placeholder: " Add a new meditation", type: .meditation, identifier: .recommendations_addNew))
            }
            
            self.dataSource.append(Suggestion_Data.init(key: .pranayam, title: "Pranayama", placeholder: "", type: .pranayam, identifier: .recommendations))
            
            if self.arr_selection.contains(RegistationKey.pranayam.rawValue) {
                if let arr_pranayam = self.arr_Data?.pranayam {
                    for inner in arr_pranayam {
                        self.dataSource.append(Suggestion_Data.init(key: .pranayam, title: inner?.name, placeholder: "", type: .pranayam, identifier: .recommendations_value, favid: inner?.favorite_id ?? ""))
                        
                        //
                        guard let str_SelectedName = inner?.name else { return }
                        self.selection_default(is_selection_oneTime: self.is_p_selection_oneTime, name: str_SelectedName, key: .pranayam)
                        //
                    }
                    
                    if arr_pranayam.count >= 10 {
                        self.dataSource.append(Suggestion_Data.init(key: .pranayam, title: "View more", placeholder: "", type: .pranayam, identifier: .view_more, favid: ""))
                    }
                    
                    self.is_p_selection_oneTime = true
                }
                
                //self.dataSource.append(Suggestion_Data.init(key: .pranayam, title: "", placeholder: " Add a new pranayama", type: .pranayam, identifier: .recommendations_addNew))
            }
            
            self.dataSource.append(Suggestion_Data.init(key: .kriya, title: "Kriya", placeholder: "", type: .kriya, identifier: .recommendations))
            
            if self.arr_selection.contains(RegistationKey.kriya.rawValue) {
                if let arr_kriya = self.arr_Data?.kriya {
                    for inner in arr_kriya {
                        self.dataSource.append(Suggestion_Data.init(key: .kriya, title: inner?.name, placeholder: "", type: .kriya, identifier: .recommendations_value, favid: inner?.favorite_id ?? ""))
                        
                        //
                        guard let str_SelectedName = inner?.name else { return }
                        self.selection_default(is_selection_oneTime: self.is_k_selection_oneTime, name: str_SelectedName, key: .kriya)
                        //
                    }
                    
                    if arr_kriya.count >= 10 {
                        self.dataSource.append(Suggestion_Data.init(key: .kriya, title: "View more", placeholder: "", type: .kriya, identifier: .view_more, favid: ""))
                    }
                    
                    self.is_k_selection_oneTime = true
                }
                
                //self.dataSource.append(Suggestion_Data.init(key: .kriya, title: "", placeholder: " Add a new kriya", type: .kriya, identifier: .recommendations_addNew))
            }
            
            self.dataSource.append(Suggestion_Data.init(key: .mudra, title: "Mudra", placeholder: "", type: .mudra, identifier: .recommendations))
            
            if self.arr_selection.contains(RegistationKey.mudra.rawValue) {
                if let arr_mudra = self.arr_Data?.mudra {
                    for inner in arr_mudra {
                        self.dataSource.append(Suggestion_Data.init(key: .mudra, title: inner?.name, placeholder: "", type: .mudra, identifier: .recommendations_value, favid: inner?.favorite_id ?? ""))
                        
                        //
                        guard let str_SelectedName = inner?.name else { return }
                        self.selection_default(is_selection_oneTime: self.is_mu_selection_oneTime, name: str_SelectedName, key: .mudra)
                        //
                    }
                    
                    if arr_mudra.count >= 10 {
                        self.dataSource.append(Suggestion_Data.init(key: .mudra, title: "View more", placeholder: "", type: .mudra, identifier: .view_more, favid: ""))
                    }
                    
                    //self.dataSource.append(Suggestion_Data.init(key: .mudra, title: "", placeholder: " Add a new mudra", type: .mudra, identifier: .recommendations_addNew))
                    
                    self.is_mu_selection_oneTime = true
                }
                
            }
            
            self.dataSource.append(Suggestion_Data.init(key: .panchkarma_suggestions, title: "Panchkarma", placeholder: "", type: .panchkarma, identifier: .recommendations))
            
            if self.arr_selection.contains(RegistationKey.panchkarma_suggestions.rawValue) {
                if let arr_panchkarma = self.arr_Data?.panchkarma {
                    for inner in arr_panchkarma {
                        self.dataSource.append(Suggestion_Data.init(key: .panchkarma_suggestions, title: inner?.name, placeholder: "", type: .panchkarma, identifier: .recommendations_value, favid: inner?.favorite_id ?? ""))
                        
                        //
                        guard let str_SelectedName = inner?.name else { return }
                        self.selection_default(is_selection_oneTime: self.is_panchkarma_selection_oneTime, name: str_SelectedName, key: .panchkarma_suggestions)
                        //
                    }
                    
                    if arr_panchkarma.count >= 10 {
                        self.dataSource.append(Suggestion_Data.init(key: .panchkarma_suggestions, title: "View more", placeholder: "", type: .panchkarma, identifier: .view_more, favid: ""))
                    }
                    
                    //self.dataSource.append(Suggestion_Data.init(key: .mudra, title: "", placeholder: " Add a new mudra", type: .mudra, identifier: .recommendations_addNew))
                    
                    self.is_panchkarma_selection_oneTime = true
                }
                
            }
            
        }
        
        
        self.dataSource.append(Suggestion_Data.init(key: .other, title: "Submit", placeholder: "", type: .other, identifier: .button))
        self.tbl_View.reloadData()
    }
    
    func selection_default(is_selection_oneTime: Bool = true, name: String, key: RegistationKey = .other) {
        if is_selection_oneTime == false {
            
            if let arr_SelectedValue = self.dic_Value[key.rawValue] as? [String] {
                var arr_sValue = arr_SelectedValue
                if let indx = arr_sValue.firstIndex(of: name) {
                }
                else {
                    arr_sValue.append(name)
                }
                self.dic_Value[key.rawValue] = arr_sValue
            }
            else {
                let arr_sValue = [name]
                self.dic_Value[key.rawValue] = arr_sValue
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let str_key = self.dataSource[indexPath.row].key ?? RegistationKey.other
        let str_title = self.dataSource[indexPath.row].title
        let identifierType = self.dataSource[indexPath.row].identifier
        let str_placeholder = self.dataSource[indexPath.row].placeholder
        
        if identifierType == .textview {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionTableCell", for: indexPath) as! SuggestionTableCell
            cell.selectionStyle = .none
            cell.txt_View.delegate = self
            cell.txt_View.addDoneToolbar()
            cell.txt_View.accessibilityHint = str_key.rawValue
            cell.lbl_Title.text = str_title
            
            let str_text = self.dic_Value[str_key.rawValue] as? String ?? ""
            if str_text == "" {
                cell.txt_View.text = str_placeholder
                cell.txt_View.textColor = AppColor.app_TextGrayColor
            }
            else {
                cell.txt_View.text = str_text
                cell.txt_View.textColor = .black
            }
            return cell
        }
        else if identifierType == .add_prescription {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PrescriptionTableCell", for: indexPath) as! PrescriptionTableCell
            cell.selectionStyle = .none
            cell.lbl_Title.text = str_title
            
            let arr_aushadhi = self.dic_Value[str_key.rawValue] as? [String] ?? []
            if arr_aushadhi.count != 0 {
                cell.lbl_added_prescription.textColor = .black
                cell.lbl_added_prescription.text = arr_aushadhi.joined(separator: "\n")
            }
            else {
                cell.lbl_added_prescription.text = "Add aushadhi"
                cell.lbl_added_prescription.textColor = .lightGray
            }
            
            //Buton Action
            cell.didTappedonButtonAdd = { (sender) in
                self.open_addAuashdi_Dialouge()
            }
            
            
            return cell
        }
        else if identifierType == .autocomplete_suggestion {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AutoCompleteSuggestionTableCell", for: indexPath) as! AutoCompleteSuggestionTableCell
            cell.selectionStyle = .none
            if str_key == .food_suggestions {
                cell.arr_data = self.arr_Food_Data
                cell.arr_selected_data = self.arr_selected_food_item
            }
            else {
                cell.arr_data = self.arr_Investigation_Data
                cell.arr_selected_data = self.arr_selected_investigation_item
            }
            cell.lbl_Title.text = str_title
            let str_value = self.dic_Value[str_key.rawValue] as? String ?? ""
            cell.txt_suggestion.text = str_value
            cell.txt_suggestion.delegate = self
            cell.txt_suggestion.accessibilityHint = str_key.rawValue
            cell.txt_suggestion.accessibilityLabel = "\(indexPath.row)"
            cell.txt_suggestion.addTarget(self, action: #selector(self.textField_Did_ChangeEditing(_:)), for: .editingChanged)
            
            if str_value.count > 2 {
                cell.btn_Add.backgroundColor = AppColor.app_GreenColor
            }
            else {
                cell.btn_Add.backgroundColor = AppColor.app_GreenColor.withAlphaComponent(0.5)
            }
            
            
            cell.didSelectedTag = { (selected_tag) in
                if str_key == RegistationKey.food_suggestions {
                    self.arr_selected_food_item = selected_tag
                    self.arr_Food_Data.removeAll()
                    self.dic_Value[str_key.rawValue] = ""
                    self.tbl_View.reloadData()
                }
                else {
                    self.arr_selected_investigation_item = selected_tag
                    self.arr_Investigation_Data.removeAll()
                    self.dic_Value[str_key.rawValue] = ""
                    self.tbl_View.reloadData()
                }
                
            }
            
            cell.didTappedonButtonAdd = { (sender) in
                if sender.backgroundColor == AppColor.app_GreenColor {
                    let str_tag = cell.txt_suggestion.text ?? ""
                    
                    if str_key == .food_suggestions {
                        self.arr_Food_Data.removeAll()
                        self.arr_selected_food_item.append(str_tag)
                    }
                    else {
                        self.arr_Investigation_Data.removeAll()
                        self.arr_selected_investigation_item.append(str_tag)
                    }
                    cell.txt_suggestion.text = ""
                    self.dic_Value[str_key.rawValue] = ""
                    self.tbl_View.reloadData()
                }
            }
            
            
            return cell
        }
        else if identifierType == .single_header {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderTitleTableCell", for: indexPath) as! HeaderTitleTableCell
            cell.selectionStyle = .none
            cell.lbl_Title.text = str_title
            
            return cell
        }
        else if identifierType == .recommendations {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendationsTableCell", for: indexPath) as! RecommendationsTableCell
            cell.selectionStyle = .none
            cell.lbl_Title.text = self.dataSource[indexPath.row].title
            
            if self.dataSource[indexPath.row].type == .yogasana {
                cell.img_icon.image = UIImage.init(named: "icon_yogasana")
            }
            else if self.dataSource[indexPath.row].type == .meditation {
                cell.img_icon.image = UIImage.init(named: "icon_meditation")
            }
            else if self.dataSource[indexPath.row].type == .pranayam {
                cell.img_icon.image = UIImage.init(named: "icon_pranayam")
            }
            else if self.dataSource[indexPath.row].type == .mudra {
                cell.img_icon.image = UIImage.init(named: "icon_mudra")
            }
            else if self.dataSource[indexPath.row].type == .kriya {
                cell.img_icon.image = UIImage.init(named: "icon_kriya")
            }
            else if self.dataSource[indexPath.row].type == .breakfast_food {
                cell.img_icon.image = UIImage.init(named: "icon_breakfast_food")
            }
            else if self.dataSource[indexPath.row].type == .lunch_food {
                cell.img_icon.image = UIImage.init(named: "icon_lunch_food")
            }
            else if self.dataSource[indexPath.row].type == .dinner_food {
                cell.img_icon.image = UIImage.init(named: "icon_dinner_food")
            }
            else if self.dataSource[indexPath.row].type == .panchkarma {
                cell.img_icon.image = UIImage.init(named: "icon_panchkarma_food")
            }
            
            
            if let indx = self.arr_selection.firstIndex(of: str_key.rawValue) {
                UIView.animate(withDuration: 0.3) {
                    cell.img_arrow.transform = cell.img_arrow.transform.rotated(by: CGFloat(M_PI_2)*2)
                }
            }
            else {
                UIView.animate(withDuration: 0.3) {
                    cell.img_arrow.transform = .identity
                }
            }
            
            return cell
        }
        else if identifierType == .recommendations_value {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "KriyaMudraDataTableCell", for: indexPath) as! KriyaMudraDataTableCell
            cell.selectionStyle = .none
            let str_Title = self.dataSource[indexPath.row].title ?? ""
            cell.lbl_Title.text = str_Title
            
            if let arr_SelectedValue = self.dic_Value[str_key.rawValue] as? [String] {
                let arr_sValue = arr_SelectedValue
                if let indx = arr_sValue.firstIndex(of: str_Title) {
                    cell.img_icon.image = UIImage.init(named: "icon_selected")
                }
                else {
                    cell.img_icon.image = UIImage.init(named: "icon_unselected")
                }
            }
            else {
                cell.img_icon.image = UIImage.init(named: "icon_unselected")
            }
            
            return cell
        }
        else if identifierType == .recommendations_addNew {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddNewYoga", for: indexPath) as! AddNewYoga
            cell.selectionStyle = .none
            cell.txt_addNew.addDoneToolbar()
            cell.txt_addNew.delegate = self
            cell.txt_addNew.placeholder = str_placeholder
            
            cell.didTappedonAddNew = { (sender) in
                if let strText = cell.txt_addNew.text, strText != "" {
                    self.view.endEditing(true)
                    cell.txt_addNew.text = ""
                    if str_key == .yogasana {
                        self.arr_Data?.yogasana?.append(ContentLibraryKriya.init(name: strText))
                    }
                    else if str_key == .meditation {
                        self.arr_Data?.meditation?.append(ContentLibraryKriya.init(name: strText))
                    }
                    else if str_key == .pranayam {
                        self.arr_Data?.pranayam?.append(ContentLibraryKriya.init(name: strText))
                    }
                    else if str_key == .kriya {
                        self.arr_Data?.kriya?.append(ContentLibraryKriya.init(name: strText))
                    }
                    else if str_key == .mudra {
                        self.arr_Data?.mudra?.append(ContentLibraryKriya.init(name: strText))
                    }
                    self.manageSection()
                }
            }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterButtonTableCell", for: indexPath) as! RegisterButtonTableCell
            cell.selectionStyle = .none
            cell.btn_Title.text = str_title
            cell.constraint_btn_Register_TOP.constant = 20
            
            if identifierType == .view_more {
                cell.constraint_btn_Register_TOP.constant = 12
                cell.constraint_btn_Register_Height.constant = 35
                cell.constraint_btn_Register_Left.constant = 40
                cell.constraint_btn_Register_Right.constant = 40
            }
            else {
                cell.constraint_btn_Register_TOP.constant = 20
                cell.constraint_btn_Register_Height.constant = 50
                cell.constraint_btn_Register_Left.constant = 20
                cell.constraint_btn_Register_Right.constant = 20
            }
            
            cell.didTapped_onRegister = { (sender) in
                self.view.endEditing(true)
                if identifierType == .view_more {
                    let vc = ViewMoreContentLibraryVC.instantiate(fromAppStoryboard: .Assessment)
                    vc.delegate = self
                    vc.aggrivation = self.str_aggrivation
                    vc.int_patientID = appDelegate.dic_patient_response?.patient_id ?? ""
                    vc.str_Type = str_key
                    vc.dic_Value = self.dic_Value
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    self.btn_Submit_Action()
                }
            }
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = self.dataSource[indexPath.row].key ?? RegistationKey.other
        let identifierType = self.dataSource[indexPath.row].identifier
        if identifierType == .recommendations {
            
            if let indx = self.arr_selection.firstIndex(of: type.rawValue) {
                self.arr_selection.remove(at: indx)
            }
            else {
                self.arr_selection.append(type.rawValue)
            }
            self.manageSection()
        }
        else if identifierType == .recommendations_value {
            guard let currentCell = self.tbl_View.cellForRow(at: indexPath) as? KriyaMudraDataTableCell else {
                return
            }
            guard let str_SelectedFavID = self.dataSource[indexPath.row].title else { return }
            if let arr_SelectedValue = self.dic_Value[type.rawValue] as? [String] {
                var arr_sValue = arr_SelectedValue
                if let indx = arr_sValue.firstIndex(of: str_SelectedFavID) {
                    arr_sValue.remove(at: indx)
                    currentCell.img_icon.image = UIImage.init(named: "icon_unselected")
                }
                else {
                    arr_sValue.append(str_SelectedFavID)
                    currentCell.img_icon.image = UIImage.init(named: "icon_selected")
                }
                self.dic_Value[type.rawValue] = arr_sValue
            }
            else {
                let arr_sValue = [str_SelectedFavID]
                self.dic_Value[type.rawValue] = arr_sValue
                currentCell.img_icon.image = UIImage.init(named: "icon_selected")
            }
        }
    }
    
    
    //MARK: - UITextField Delegate Method
    @objc func textField_Did_ChangeEditing(_ textField: UITextField) {
        let str_indx_row = textField.accessibilityLabel ?? ""
        if let str_Text = textField.text {
            self.dic_Value[(textField.accessibilityHint ?? "")] = str_Text
            if let currentCell = self.tbl_View.cellForRow(at: IndexPath.init(row: Int(str_indx_row) ?? 0, section: 0)) as? AutoCompleteSuggestionTableCell {
                if str_Text.count > 2 {
                    currentCell.btn_Add.backgroundColor = AppColor.app_GreenColor
                }
                else {
                    currentCell.btn_Add.backgroundColor = AppColor.app_GreenColor.withAlphaComponent(0.5)
                }
            }
            
            if str_Text.count > 2 {
                if let str_key = textField.accessibilityHint {
                    if str_key == "food_suggestions" {
                        self.callAPIforGetSuggestionTag(str_Text, type: "food_items", indx_row: str_indx_row)
                    }
                    else {
                        self.callAPIforGetSuggestionTag(str_Text, type: "investigations", indx_row: str_indx_row)
                    }
                }
            }
        }
    }
    
    //MARK: - UITextView Delegate Method
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if let strText = textView.text {
            if strText == "Your text here..." {
                textView.text = ""
                textView.textColor = .black
            }
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let strText = textView.text {
            if strText.trimed() == "" {
                textView.text = "Your text here..."
                textView.textColor = AppColor.app_TextGrayColor
            }
            
            if let strKey = textView.accessibilityHint {
                self.dic_Value[strKey] = strText
            }
        }
        
    }
    
    
    func open_addAuashdi_Dialouge() {
        self.view.endEditing(true)
        let objDialouge = AddPrescriptionsDialouge(nibName:"AddPrescriptionsDialouge", bundle:nil)
        objDialouge.arr_AushadhiData = self.arr_selected_aushadhi
        objDialouge.delegate = self
        self.addChild(objDialouge)
        objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview((objDialouge.view)!)
        objDialouge.didMove(toParent: self)
    }
    
    func did_select_aushadhi(_ success: Bool, arr_data: [[String: Any]]) {
        self.arr_selected_aushadhi = arr_data
        var arr_aushadhi = [String]()
        for dic_aush in arr_data {
            let strname = dic_aush["aushadhi_name"] as? String ?? ""
            let strdose = dic_aush["dosage"] as? String ?? ""
            arr_aushadhi.append("\(strname), \(strdose)")
        }
        self.dic_Value[RegistationKey.prescriptions.rawValue] = arr_aushadhi
        self.tbl_View.reloadData()
    }
    
    func did_select_data(_ success: Bool, selected_value: [String: Any], selected_type: RegistationKey) {
        if success {
            self.dic_Value = selected_value
            self.addExtraData(selected_type: selected_type)
            self.manageSection(is_selection: true)
            self.tbl_View.reloadData()
        }
    }
    
    func addExtraData(selected_type: RegistationKey) {
        var str_key = ""
        if selected_type == .breakfast_food {
            str_key = "breakfast"
        }
        else if selected_type == .lunch_food {
            str_key = "lunch"
        }
        else if selected_type == .dinner_food {
            str_key = "dinner"
        }
        
        if selected_type == .breakfast_food || selected_type == .lunch_food || selected_type == .dinner_food {
            
            if let indx_food = self.arr_Data?.food?.firstIndex(where: { dic_food in
                return (dic_food?.section?[0]?.subsection ?? "").lowercased() == str_key
            }) {
                if let arr_food = self.arr_Data?.food?[indx_food]?.section?[0]?.data {
                    var arr_food_data = arr_food
                    arr_food_data.removeAll()

                    if let arr_SelectedValue = self.dic_Value[selected_type.rawValue] as? [String] {
                        
                        for inner in arr_SelectedValue {
                            arr_food_data.append(FoodData?.init(FoodData.init(name: inner)))
                        }
                        self.arr_Data?.food?[indx_food]?.section?[0]?.data = arr_food_data
                    }
                }
            }
                    
        }
        else {
            var arr_dataaaa = [ContentLibraryKriya?]()
            
            if let arr_SelectedValue = self.dic_Value[selected_type.rawValue] as? [String] {
                for inner in arr_SelectedValue {
                    arr_dataaaa.append(ContentLibraryKriya?.init(ContentLibraryKriya.init(favorite_id: "", name: inner)))
                }
            }

            if selected_type == .yogasana {
                self.arr_Data?.yogasana = arr_dataaaa
            }
            else if selected_type == .meditation {
                self.arr_Data?.meditation = arr_dataaaa
            }
            else if selected_type == .pranayam {
                self.arr_Data?.pranayam = arr_dataaaa
            }
            else if selected_type == .kriya {
                self.arr_Data?.kriya = arr_dataaaa
            }
            else if selected_type == .mudra {
                self.arr_Data?.mudra = arr_dataaaa
            }
            else if selected_type == .panchkarma_suggestions {
                self.arr_Data?.panchkarma = arr_dataaaa
            }
        }
    }
    
}
