//
//  AddHealthComplainVC.swift
//  SaNaay
//
//  Created by DEEPAK JAIN on 07/07/24.
//

import UIKit
import Alamofire

class AddHealthComplainVC: UIViewController, delegate_Pulse_DoneAction {

    var str_patientID = ""
    var screenFrom = ScreenType.none
    var dic_response: PatientListDataResponse?
    
   
    var arr_selected_health_tag = [[String: Any]]()
    var arr_selected_history_tag = [[String: Any]]()
    var arr_selected_family_history_tag = [[String: Any]]()
    var arr_selected_daily_routine_tag = [[String: Any]]()
    var arr_selected_investigation_tag = [[String: Any]]()
    
    var arr_health_tag = [[String: Any]]()
    var arr_history_tag = [[String: Any]]()
    var arr_family_history_tag = [[String: Any]]()
    var arr_daily_routine_tag = [[String: Any]]()
    var arr_investigation_tag = [[String: Any]]()
    
    var arr_section = [[String: Any]]()
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var constraint_view_Bottom: NSLayoutConstraint!
    var arr_typeTag: [kSearchTypeTag] = [.kHealthComplaints, .kPersonalHistory, .kFamilyHistory, .kDailyRoutine]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Regsiter Table Cell
        self.tblView.register(nibWithCellClass: AddHealthComplainTableCell.self)
        self.tblView.register(nibWithCellClass: RegisterButtonTableCell.self)
        
        self.getSelectedPreviousTag()
        
        if self.getTagData() {
            self.manageSection()
            self.tblView.reloadData()
        }
        else {
            self.callAPIforHealthTag(search_key: "", search_type: .kHealthComplaints)
        }
    }
    
    func getTagData()-> Bool {
        var is_value = false
        
        if let dataa = kUserDefaults.object(forKey: kSearchTypeTag.kHealthComplaints.rawValue) {
            if let tag_data = NSKeyedUnarchiver.unarchiveObject(with: dataa as! Data) as? [[String: Any]] {
                is_value = true
                self.arr_health_tag = tag_data
            }
        }
        
        if let dataa = kUserDefaults.object(forKey: kSearchTypeTag.kPersonalHistory.rawValue) {
            if let tag_data = NSKeyedUnarchiver.unarchiveObject(with: dataa as! Data) as? [[String: Any]] {
                is_value = true
                self.arr_history_tag = tag_data
            }
        }
        
        if let dataa = kUserDefaults.object(forKey: kSearchTypeTag.kFamilyHistory.rawValue) {
            if let tag_data = NSKeyedUnarchiver.unarchiveObject(with: dataa as! Data) as? [[String: Any]] {
                is_value = true
                self.arr_family_history_tag = tag_data
            }
        }
        
        if let dataa = kUserDefaults.object(forKey: kSearchTypeTag.kDailyRoutine.rawValue) {
            if let tag_data = NSKeyedUnarchiver.unarchiveObject(with: dataa as! Data) as? [[String: Any]] {
                is_value = true
                self.arr_daily_routine_tag = tag_data
            }
        }
        
        return is_value
    }
    
    func getSelectedPreviousTag() {
        self.arr_selected_health_tag.removeAll()
        self.arr_selected_history_tag.removeAll()
        self.arr_selected_family_history_tag.removeAll()
        self.arr_selected_daily_routine_tag.removeAll()
        self.arr_selected_investigation_tag.removeAll()
        
        if let str_health = self.dic_response?.health_complaints, str_health.trimed() != "", str_health.trimed() != "NA" {
            let arr_tag = str_health.components(separatedBy: ",")
            for str_tag_text in arr_tag {
                let tag_Data = ["tagname": str_tag_text,
                                "tagtype": "health_complaints"]
                self.arr_selected_health_tag.append(tag_Data)
            }
        }
        
        if let str_history = self.dic_response?.personal_history, str_history.trimed() != "", str_history.trimed() != "NA" {
            let arr_tag = str_history.components(separatedBy: ",")
            for str_tag_text in arr_tag {
                let tag_Data = ["tagname": str_tag_text,
                                "tagtype": "personal_history"]
                self.arr_selected_history_tag.append(tag_Data)
            }
        }
        
        if let str_history = self.dic_response?.family_history, str_history.trimed() != "", str_history.trimed() != "NA" {
            let arr_tag = str_history.components(separatedBy: ",")
            for str_tag_text in arr_tag {
                let tag_Data = ["tagname": str_tag_text,
                                "tagtype": "personal_history"]
                self.arr_selected_family_history_tag.append(tag_Data)
            }
        }
        
        if let str_daily_routine = self.dic_response?.daily_routine, str_daily_routine.trimed() != "", str_daily_routine.trimed() != "NA" {
            let arr_tag = str_daily_routine.components(separatedBy: ",")
            for str_tag_text in arr_tag {
                let tag_Data = ["tagname": str_tag_text,
                                "tagtype": "daily_routine"]
                self.arr_selected_daily_routine_tag.append(tag_Data)
            }
        }
        
        if let str_patient_investigation = self.dic_response?.patient_investigation, str_patient_investigation.trimed() != "", str_patient_investigation.trimed() != "NA" {
            let arr_tag = str_patient_investigation.components(separatedBy: ",")
            for str_tag_text in arr_tag {
                let tag_Data = ["tagname": str_tag_text,
                                "tagtype": "daily_routine"]
                self.arr_selected_investigation_tag.append(tag_Data)
            }
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
    
    // MARK: - Navigation
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        var is_screen = false
        
        if self.screenFrom == .retest_now {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            
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
    }

}

//MARK: - API CALL
extension AddHealthComplainVC {
    
    func callAPIforHealthTag(search_key: String, search_type: kSearchTypeTag) {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)

            let urlString = BASE_URL +  APIEndpoints.GetTags.rawValue
            
            let param = ["search_key": search_key,
                         "search_type": search_type.rawValue]
            
            Alamofire.request(urlString, method: .post, parameters: param, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { [weak self] response in
                guard let `self` = self else {
                    return
                }
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? [String: Any]) else {
                        DispatchQueue.main.async(execute: {
                            DismissProgressHud()
                        })
                        return
                    }

                    if dicResponse["status"] as? String == "error" {
                        DispatchQueue.main.async(execute: {
                            DismissProgressHud()
                            //Utils.showAlert(withMessage: dicResponse["message"] as? String ?? "Something went wrong, please try again")
                        })
                        return
                    }

                    guard let arr_result = (dicResponse["data"] as? [[String: Any]]) else {
                        DispatchQueue.main.async(execute: {
                            DismissProgressHud()
                        })
                        return
                    }
                    
                    if search_type == .kHealthComplaints {
                        self.arr_health_tag = arr_result
                    }
                    else if search_type == .kPersonalHistory {
                        self.arr_history_tag = arr_result
                    }
                    else if search_type == .kFamilyHistory {
                        self.arr_family_history_tag = arr_result
                    }
                    else if search_type == .kDailyRoutine {
                        self.arr_daily_routine_tag = arr_result
                    }
                    else if search_type == .kInvestigations {
                        self.arr_investigation_tag = arr_result
                    }
                    
                    if search_key == "" {
                        let tag_Data = NSKeyedArchiver.archivedData(withRootObject: arr_result)
                        kUserDefaults.set(tag_Data, forKey: search_type.rawValue)
                        
                        self.arr_typeTag.remove(at: 0)
                        if self.arr_typeTag.count != 0, let first_tag = self.arr_typeTag.first {
                            self.callAPIforHealthTag(search_key: "", search_type: first_tag)
                        }
                        else {
                            self.manageSection()
                            self.tblView.reloadData()
                        }
                    }
                    else {
                        var int_row = 0
                        self.manageSection()
                        
                        if search_type == .kHealthComplaints {
                            int_row = 0
                        }
                        else if search_type == .kPersonalHistory {
                            int_row = 1
                        }
                        else if search_type == .kFamilyHistory {
                            int_row = 2
                        }
                        else if search_type == .kDailyRoutine {
                            int_row = 3
                        }
                        else if search_type == .kInvestigations {
                            int_row = 4
                        }

                        if let currentcell = tblView.cellForRow(at: IndexPath.init(row: int_row, section: 0)) as? AddHealthComplainTableCell {
                            currentcell.arr_data = self.arr_section[int_row]["tag"] as? [[String: Any]] ?? [[:]]
                        }
                    }
                    

                case .failure(let error):
                    print(error)
                    Utils.showAlertOkController(title: "", message: error.localizedDescription, buttons: ["Ok"]) { success in
                    }
                }
                DispatchQueue.main.async(execute: {
                    DismissProgressHud()
                })
            }
        } else {
            Utils.showAlertOkController(title: "", message: AppMessage.no_internet, buttons: ["Ok"]) { success in
            }
        }
    }
    
    func callAPIforSubmitDetails() {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)

            let urlString = BASE_URL +  APIEndpoints.PatientDiagnosis.rawValue
            
            let arr_health = self.arr_selected_health_tag.map { dic in
                return (dic["tagname"] as? String ?? "").trimed()
            }
            
            let arr_history = self.arr_selected_history_tag.map { dic in
                return (dic["tagname"] as? String ?? "").trimed()
            }
            
            let arr_family_history = self.arr_selected_family_history_tag.map { dic in
                return (dic["tagname"] as? String ?? "").trimed()
            }
            
            let arr_daily_routine = self.arr_selected_daily_routine_tag.map { dic in
                return (dic["tagname"] as? String ?? "").trimed()
            }
            
            let arr_investigation = self.arr_selected_investigation_tag.map { dic in
                return (dic["tagname"] as? String ?? "").trimed()
            }
            
            let param = ["health_complaints": arr_health.joined(separator: ", "),
                         "personal_history": arr_history.joined(separator: ", "),
                         "family_history": arr_family_history.joined(separator: ", "),
                         "daily_routine": arr_daily_routine.joined(separator: ", "),
                         "patient_investigation": arr_investigation.joined(separator: ", "),
                         "patient_id": self.str_patientID] as [String : Any]
            
            
            Alamofire.request(urlString, method: .post, parameters: param, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { [weak self] response in
                guard let `self` = self else {
                    return
                }
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? [String: Any]) else {
                        DispatchQueue.main.async(execute: {
                            DismissProgressHud()
                        })
                        return
                    }

                    if dicResponse["status"] as? String == "error" {
                        DispatchQueue.main.async(execute: {
                            DismissProgressHud()
                            Utils.showAlert(withMessage: dicResponse["message"] as? String ?? "Something went wrong, please try again")
                        })
                        return
                    }

                    guard let dic_result = (dicResponse["data"] as? [String: Any]) else {
                        DispatchQueue.main.async(execute: {
                            DismissProgressHud()
                        })
                        return
                    }
                    
                    if self.screenFrom == .retest_now {
                        self.gotoPulseAssessmentInstruction()
                    }
                    else {
                        self.alertDialouge()
                    }
                    
                    
                    

                case .failure(let error):
                    print(error)
                    Utils.showAlertOkController(title: "", message: error.localizedDescription, buttons: ["Ok"]) { success in
                    }
                }
                DispatchQueue.main.async(execute: {
                    DismissProgressHud()
                })
            }
        } else {
            Utils.showAlertOkController(title: "", message: AppMessage.no_internet, buttons: ["Ok"]) { success in
            }
        }
    }
    
    func alertDialouge() {
        let alert = UIAlertController.init(title: nil, message: "", preferredStyle: UIAlertController.Style.alert)
        
        let attributedMessage = NSMutableAttributedString(string: "Please select an option", attributes: [NSAttributedString.Key.font: UIFont.AppFontMedium(16)])
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        
        let actionCancel = UIAlertAction.init(title: "Book appointment", style: UIAlertAction.Style.default, handler: { (action) in
            
            let vc = ScheduleAppoinmentVC.instantiate(fromAppStoryboard: .Dashboard)
            vc.str_patientID = self.str_patientID
            vc.dic_response = self.dic_response
            vc.screenForm = .bookappointment
            self.navigationController?.pushViewController(vc, animated: true)
        })
        
        let actionOK = UIAlertAction.init(title: "Test now", style: UIAlertAction.Style.default, handler: { (action) in
            self.gotoPulseAssessmentInstruction()
        })
        
        alert.addAction(actionOK)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
        for textfield: UIView in (alert.textFields ?? [])! {
            let container: UIView = textfield.superview!
            let effectView: UIView = container.superview!.subviews[0]
            container.backgroundColor = UIColor.clear
            effectView.removeFromSuperview()
        }
    }
    
    
    func gotoPulseAssessmentInstruction() {
        ARBleManager.shareInstance.isBluetoothPermissionGiven(fromVC: self)
        if ARBleManager.shareInstance.isBleEnable {
            if let parent = appDelegate.window?.rootViewController {
                let objDialouge = PulseInstructionVC(nibName:"PulseInstructionVC", bundle:nil)
                objDialouge.delegate = self
                parent.addChild(objDialouge)
                objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
                parent.view.addSubview((objDialouge.view)!)
                objDialouge.didMove(toParent: parent)
            }
        }
    }
    
    func doneClicked_Action(_ isClicked: Bool) {
        let vc = ARBPLOximeterReaderVC.instantiate(fromAppStoryboard: .BPLDevices)
        vc.dic_response = appDelegate.dic_patient_response
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - TableView Delegate DataSource Method
extension AddHealthComplainVC: UITableViewDelegate, UITableViewDataSource {
    
    func manageSection() {
        self.arr_section.removeAll()
        
        self.arr_section.append(["title": "Common health complaints", "type": kSearchTypeTag.kHealthComplaints, "tag": self.arr_health_tag, "selected_tag": self.arr_selected_health_tag])
        self.arr_section.append(["title": "History", "type": kSearchTypeTag.kPersonalHistory, "tag": self.arr_history_tag, "selected_tag": self.arr_selected_history_tag])
        self.arr_section.append(["title": "Family history", "type": kSearchTypeTag.kFamilyHistory, "tag": self.arr_family_history_tag, "selected_tag": self.arr_selected_family_history_tag])
        self.arr_section.append(["title": "Daily routine", "type": kSearchTypeTag.kDailyRoutine, "tag": self.arr_daily_routine_tag, "selected_tag": self.arr_selected_daily_routine_tag])
        self.arr_section.append(["title": "Patient's previous investigation", "type": kSearchTypeTag.kInvestigations, "tag": self.arr_investigation_tag, "selected_tag": self.arr_selected_investigation_tag])
        
        self.arr_section.append(["title": "Submit", "type": kSearchTypeTag.kSubmitButton])
        //self.tblView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_section.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let str_type = self.arr_section[indexPath.row]["type"] as? kSearchTypeTag ?? .kNone
        
        if str_type == .kSubmitButton {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterButtonTableCell", for: indexPath) as! RegisterButtonTableCell
            cell.selectionStyle = .none
            cell.btn_Title.text = self.arr_section[indexPath.row]["title"] as? String ?? ""
            cell.constraint_btn_Register_TOP.constant = 20
            
            cell.didTapped_onRegister = { (sender) in
                self.callAPIforSubmitDetails()
            }
            
            return cell
        }
        
        else {
            let cell = tableView.dequeueReusableCell(withClass: AddHealthComplainTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.btn_Add.alpha = 0.5
            cell.txt_field.delegate = self
            cell.btn_Add.isUserInteractionEnabled = false
            
            
            cell.txt_field.accessibilityHint = str_type.rawValue
            cell.btn_Add.accessibilityHint = str_type.rawValue
            cell.txt_field.addTarget(self, action: #selector(self.textdield_change(_:)), for: .editingChanged)
            
            var arr_TempData = self.arr_section[indexPath.row]["tag"] as? [[String: Any]] ?? [[:]]
            if (self.arr_section[indexPath.row]["tag"]) == nil {
                arr_TempData.removeAll()
            }
            
            var arr_TempData_1 = self.arr_section[indexPath.row]["selected_tag"] as? [[String: Any]] ?? [[:]]
            if (self.arr_section[indexPath.row]["selected_tag"]) == nil {
                arr_TempData_1.removeAll()
            }
            
            cell.type_tag = self.arr_section[indexPath.row]["type"] as? kSearchTypeTag ?? .kNone
            cell.lbl_Title.text = self.arr_section[indexPath.row]["title"] as? String ?? ""
            cell.arr_data = arr_TempData
            cell.arr_selected_data = arr_TempData_1
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                let get_height = cell.tag_collectionView.intrinsicContentSize.height
                cell.constraint_collection_view_height.constant = arr_TempData.count == 0 ? 0 : get_height
                
                let get_height_1 = cell.selected_tag_collectionView.intrinsicContentSize.height
                cell.constraint_selected_tag_collection_view_height.constant = arr_TempData_1.count == 0 ? 0 : get_height_1
            }
            
            cell.didTappedAdd = { (sender) in
                let str_tag_text = cell.txt_field.text ?? ""
                var dic_data = self.arr_section[indexPath.row]
                cell.btn_Add.alpha = 0.5
                cell.btn_Add.isUserInteractionEnabled = false
                
                if str_tag_text != "" {
                    cell.txt_field.text = ""
                    let tag_Data = ["tagname": str_tag_text,
                                    "tagtype": sender.accessibilityHint ?? ""]
                    
                    if sender.accessibilityHint == kSearchTypeTag.kHealthComplaints.rawValue {
                        self.arr_selected_health_tag.append(tag_Data)
                        dic_data["selected_tag"] = self.arr_selected_health_tag
                    }
                    else if sender.accessibilityHint == kSearchTypeTag.kPersonalHistory.rawValue {
                        self.arr_selected_history_tag.append(tag_Data)
                        dic_data["selected_tag"] = self.arr_selected_history_tag
                    }
                    else if sender.accessibilityHint == kSearchTypeTag.kFamilyHistory.rawValue {
                        self.arr_selected_family_history_tag.append(tag_Data)
                        dic_data["selected_tag"] = self.arr_selected_family_history_tag
                    }
                    else if sender.accessibilityHint == kSearchTypeTag.kDailyRoutine.rawValue {
                        self.arr_selected_daily_routine_tag.append(tag_Data)
                        dic_data["selected_tag"] = self.arr_selected_daily_routine_tag
                    }
                    else if sender.accessibilityHint == kSearchTypeTag.kInvestigations.rawValue {
                        self.arr_selected_investigation_tag.append(tag_Data)
                        dic_data["selected_tag"] = self.arr_selected_investigation_tag
                    }
                    
                    self.manageSection()
//                    self.arr_section.remove(at: indexPath.row)
//                    self.arr_section.insert(dic_data, at: indexPath.row)
                }
                self.tblView.reloadData()
//                cell.arr_data = arr_TempData
//                cell.arr_selected_data = self.arr_section[indexPath.row]["selected_tag"] as? [[String: Any]] ?? [[:]]
//                cell.selected_tag_collectionView.reloadData()
//                cell.layoutSubviews()
//                self.view.layoutIfNeeded()
            }
            
            cell.completation_selected_tag = { (tag_Data, tag_Type) in
                cell.txt_field.text = ""
                var dic_data = self.arr_section[indexPath.row]
                
                if tag_Type == .kHealthComplaints {
                    if let indx = self.arr_selected_health_tag.firstIndex(where: { dic_tag in
                        return (dic_tag["tagname"] as? String ?? "") == (tag_Data["tagname"] as? String ?? "")
                    }) { }
                    else {
                        self.arr_selected_health_tag.append(tag_Data)
                    }
                    dic_data["selected_tag"] = self.arr_selected_health_tag
                }
                else if tag_Type == .kPersonalHistory {
                    if let indx = self.arr_selected_history_tag.firstIndex(where: { dic_tag in
                        return (dic_tag["tagname"] as? String ?? "") == (tag_Data["tagname"] as? String ?? "")
                    }) { }
                    else {
                        self.arr_selected_history_tag.append(tag_Data)
                    }
                    dic_data["selected_tag"] = self.arr_selected_history_tag
                }
                else if tag_Type == .kFamilyHistory {
                    if let indx = self.arr_selected_family_history_tag.firstIndex(where: { dic_tag in
                        return (dic_tag["tagname"] as? String ?? "") == (tag_Data["tagname"] as? String ?? "")
                    }) { }
                    else {
                        self.arr_selected_family_history_tag.append(tag_Data)
                    }
                    dic_data["selected_tag"] = self.arr_selected_family_history_tag
                }
                else if tag_Type == .kDailyRoutine {
                    if let indx = self.arr_selected_daily_routine_tag.firstIndex(where: { dic_tag in
                        return (dic_tag["tagname"] as? String ?? "") == (tag_Data["tagname"] as? String ?? "")
                    }) { }
                    else {
                        self.arr_selected_daily_routine_tag.append(tag_Data)
                    }
                    dic_data["selected_tag"] = self.arr_selected_daily_routine_tag
                }
                else if tag_Type == .kInvestigations {
                    if let indx = self.arr_selected_investigation_tag.firstIndex(where: { dic_tag in
                        return (dic_tag["tagname"] as? String ?? "") == (tag_Data["tagname"] as? String ?? "")
                    }) { }
                    else {
                        self.arr_selected_investigation_tag.append(tag_Data)
                    }
                    dic_data["selected_tag"] = self.arr_selected_investigation_tag
                }
                
                self.arr_section.remove(at: indexPath.row)
                self.arr_section.insert(dic_data, at: indexPath.row)
                
                self.tblView.reloadData()
                cell.layoutSubviews()
                self.view.layoutIfNeeded()
//                cell.arr_data = arr_TempData
//                cell.arr_selected_data = self.arr_section[indexPath.row]["selected_tag"] as? [[String: Any]] ?? [[:]]
//                cell.selected_tag_collectionView.reloadData()
//                cell.layoutSubviews()
            }
            
            cell.completation_removed_tag = { (arr_tag_Data, tag_Type) in
                var dic_data = self.arr_section[indexPath.row]
                
                if tag_Type == .kHealthComplaints {
                    self.arr_selected_health_tag = arr_tag_Data
                    dic_data["selected_tag"] = self.arr_selected_health_tag
                }
                else if tag_Type == .kPersonalHistory {
                    self.arr_selected_history_tag = arr_tag_Data
                    dic_data["selected_tag"] = self.arr_selected_history_tag
                }
                else if tag_Type == .kFamilyHistory {
                    self.arr_selected_family_history_tag = arr_tag_Data
                    dic_data["selected_tag"] = self.arr_selected_family_history_tag
                }
                else if tag_Type == .kDailyRoutine {
                    self.arr_selected_daily_routine_tag = arr_tag_Data
                    dic_data["selected_tag"] = self.arr_selected_daily_routine_tag
                }
                else if tag_Type == .kInvestigations {
                    self.arr_selected_investigation_tag = arr_tag_Data
                    dic_data["selected_tag"] = self.arr_selected_investigation_tag
                }
                
                self.arr_section.remove(at: indexPath.row)
                self.arr_section.insert(dic_data, at: indexPath.row)
                
                self.tblView.reloadData()
//                cell.arr_data = arr_TempData
//                cell.arr_selected_data = self.arr_section[indexPath.row]["selected_tag"] as? [[String: Any]] ?? [[:]]
//                cell.selected_tag_collectionView.reloadData()
//                cell.layoutSubviews()
            }
            
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

//MARK: - uitextField Delegate Datasource method
extension AddHealthComplainVC: UITextFieldDelegate {
    
    @objc func textdield_change(_ textfield: UITextField) {
        let str_Text = textfield.text ?? ""
        if let str_type = textfield.accessibilityHint {
            
            var int_row = 0
            if str_type == kSearchTypeTag.kHealthComplaints.rawValue {
                int_row = 0
            }
            else if str_type == kSearchTypeTag.kPersonalHistory.rawValue {
                int_row = 1
            }
            else if str_type == kSearchTypeTag.kFamilyHistory.rawValue {
                int_row = 2
            }
            else if str_type == kSearchTypeTag.kDailyRoutine.rawValue {
                int_row = 3
            }
            else if str_type == kSearchTypeTag.kInvestigations.rawValue {
                int_row = 4
            }
            
            
            if let currentcell = tblView.cellForRow(at: IndexPath.init(row: int_row, section: 0)) as? AddHealthComplainTableCell {
                if str_Text.trimed() == "" {
                    currentcell.btn_Add.alpha = 0.5
                    currentcell.btn_Add.isUserInteractionEnabled = false
                }
                else {
                    currentcell.btn_Add.alpha = 1
                    currentcell.btn_Add.isUserInteractionEnabled = true
                }
            }
            
            DispatchQueue.main.asyncDeduped(target: self, after: 0.75) { [weak self] in
                guard let self = self else { return }
                self.callAPIforHealthTag(search_key: str_Text, search_type: kSearchTypeTag(rawValue: str_type) ?? .kNone)
            }
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
