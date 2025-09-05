//
//  AddPatientVC.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 17/06/23.
//

import UIKit
import Alamofire
import FirebaseAuth

class AddPatientVC: UIViewController, delegate_Pulse_DoneAction {

    //var dic_patientResponse: PatientListDataResponse?
    var screenFrom = ScreenType.none
    var is_hide_mobile = false
    var str_SelectedCountry = Country(code: "", name: "", phoneCode: "")
    var api_params = [String: Any]()
    var dic_Value = [String: Any]()
    var dataSource = [D_RegisterData]()
    @IBOutlet weak var tbl_View: UITableView!
    @IBOutlet weak var lbl_nav_Header: UILabel!
    @IBOutlet weak var constraint_view_Bottom: NSLayoutConstraint!
    private let viewModel: RegisterViewModel = RegisterViewModel()
    
    private lazy var datePicker: UIDatePicker = {
      let datePicker = UIDatePicker(frame: .zero)
      datePicker.datePickerMode = .date
      datePicker.timeZone = TimeZone.current
      return datePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if self.screenFrom == .edit_patient {
            self.lbl_nav_Header.text = "Update Patient Details"
        }
        
        if #available(iOS 15.0, *) {
            self.tbl_View.sectionHeaderTopPadding = 0.0
        } else {
            // Fallback on earlier versions
        }
        
        if #available(iOS 14, *) {
            self.datePicker.preferredDatePickerStyle = .wheels
        }
        
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            print(countryCode)
            let arr_country =  SMCountry.shared.getAllCountry(withreload: true)
            if let objCounty = arr_country.filter({ dic_country in
                return (dic_country.code ?? "") == countryCode
            }) as? [Country] {
                self.str_SelectedCountry = objCounty.first!
                self.dic_Value["country_code"] = objCounty.first?.phoneCode ?? "+91"
                self.dic_Value["country"] = objCounty.first?.name ?? ""
            }
        }

        //Register Table cell
        self.tbl_View.register(nibWithCellClass: HeightWeightTableCell.self)
        self.tbl_View.register(nibWithCellClass: RegisterFieldTableCell.self)
        self.tbl_View.register(nibWithCellClass: RegisterButtonTableCell.self)
        self.tbl_View.register(nibWithCellClass: GenderTableCell.self)
        self.tbl_View.register(nibWithCellClass: FoodPreferenceTableCell.self)

        self.setupData()
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

    // MARK: - Navigation
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func btn_Register_Action() {
        self.view.endEditing(true)
        let strName = self.dic_Value[RegistationKey.patient_name.rawValue] as? String ?? ""
        let strMobile = self.dic_Value[RegistationKey.patient_mobile.rawValue] as? String ?? ""
        let strEmail = self.dic_Value[RegistationKey.patient_email.rawValue] as? String ?? ""
        let strWeight = self.dic_Value[RegistationKey.patient_weight.rawValue] as? String ?? ""
        var strHeight = self.dic_Value[RegistationKey.patient_height.rawValue] as? String ?? ""
        let strFeet = self.dic_Value["feet"] as? String ?? ""
        let strInch = self.dic_Value["inch"] as? String ?? ""
        let strAge = self.dic_Value[RegistationKey.patient_age.rawValue] as? String ?? ""
        let strWeight_Unit = self.dic_Value["weight_unit"] as? String ?? ""
        var strHeight_Unit = self.dic_Value["height_unit"] as? String ?? ""
        let str_gender = self.dic_Value["gender"] as? String ?? ""
        
        if strMobile.trimed() == "" {
            if self.is_hide_mobile == false {
                self.view.makeToast("Please enter mobile number.")
                return
            }
        }
        
        if strName.trimed() == "" {
            self.view.makeToast("Please enter name.")
            return
        }
        
        if strEmail.trimed() != "" {
            if !isValidEmail(email: strEmail) {
                self.view.makeToast("Please enter valid email.")
                return
            }
        }
        
        if strWeight.trimed() == "" {
            self.view.makeToast("Please enter weight.")
            return
        }
        
        if strHeight_Unit == "ft" {
            if strFeet != "" && strInch != "" {
                let getcm = Utils.convertHeightInCms(ft: strFeet, inc: strInch)
                self.dic_Value[RegistationKey.patient_heightUnit.rawValue] = "cm"
                self.dic_Value[RegistationKey.patient_height.rawValue] = "\(getcm)"
                strHeight = "\(getcm)"
                strHeight_Unit = "cm"
            }
            else {
                self.view.makeToast("Please enter proper height.")
                return
            }
        }
        
        if strHeight_Unit == "cm" {
            if strHeight.trimed() == "" {
                self.view.makeToast("Please enter height.")
                return
            }
        }
        
        if strAge.trimed() == "" {
            self.view.makeToast("Please enter age.")
            return
        }
        
        let str_country_code = self.dic_Value["country_code"] as? String ?? ""
        let str_measurements = "[" + "\"" + strHeight + "\"" + "," +
                "\"" + strWeight + "\"" + "," + "\"" + strHeight_Unit + "\"" + "," + "\"" + strWeight_Unit + "\"" + "]"
        
        self.api_params = ["patient_name": strName,
                           "patient_mobile": strMobile,
                           "patient_email": strEmail,
                           "patient_gender": str_gender,
                           "patient_measurements": str_measurements,
                           "patient_age": strAge,
                           "countrycode": str_country_code,
                           "country": self.dic_Value["country"] as? String ?? "",
                           "patient_consent": self.dic_Value["patient_consent"] as? String ?? "",
                           "food_preference": self.dic_Value["food_preference"] as? String ?? ""]

        if self.is_hide_mobile == false {
            self.generateOTP(country_code: str_country_code, mobile: strMobile)
        }
        else {
            self.callAPIforAddPatient()
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

//MARK: - API CALL
extension AddPatientVC {
    
    func callAPIforAddPatient() {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)

            var urlString = BASE_URL +  APIEndpoints.AddPatient.rawValue
            
            if self.screenFrom == .edit_patient {
                urlString = BASE_URL + APIEndpoints.EdtiPatient.rawValue
                
                self.api_params["patient_id"] = appDelegate.dic_patient_response?.patient_id ?? ""
            }
            
            
            Alamofire.request(urlString, method: .post, parameters: self.api_params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { [weak self] response in
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
                    let str_country_code = dic_result["countrycode"] as? String ?? ""

                    var str_doctor_id = "\(dic_result["doctor_id"] as? Int ?? 0)"
                    if str_doctor_id == "" || str_doctor_id == "0" {
                        str_doctor_id = dic_result["doctor_id"] as? String ?? ""
                    }
                    let str_food_preference = dic_result["food_preference"] as? String ?? ""
                    let str_age = dic_result["patient_age"] as? String ?? ""
                    let str_patient_email = dic_result["patient_email"] as? String ?? ""
                    let str_patient_gender = dic_result["patient_gender"] as? String ?? ""
                    
                    var str_patient_id = "\(dic_result["patient_id"] as? Int ?? 0)"
                    if str_patient_id == "" || str_patient_id == "0" {
                        str_patient_id = dic_result["patient_id"] as? String ?? ""
                    }
                    
                    let str_patient_measurement = dic_result["patient_measurement"] as? String ?? ""
                    let str_patient_mobile = dic_result["patient_mobile"] as? String ?? ""
                    let str_patient_name = dic_result["patient_name"] as? String ?? ""
                    let str_patient_status = dic_result["patient_status"] as? String ?? ""
                    
                    let dic_response = PatientListDataResponse.init(countrycode: str_country_code, doctor_id: str_doctor_id, food_preference: str_food_preference, patient_age: str_age, patient_email: str_patient_email, patient_gender: str_patient_gender, patient_id: str_patient_id, patient_measurement: str_patient_measurement, patient_mobile: str_patient_mobile, patient_name: str_patient_name, patient_status: str_patient_status, report_id: "", appointment: "", appointment_start: "", appointment_end: "", attended: "", created_at: "", new_patient_id: str_patient_id, appointment_date: "", appointment_time: "")
                    
                    appDelegate.dic_patient_response = dic_response
                    
                    if self.screenFrom == .edit_patient {
                        appDelegate.window?.rootViewController?.view.makeToast("Patient details updated successfully")
                        if let stackVCs = self.navigationController?.viewControllers {
                            if let activeSubVC = stackVCs.first(where: { type(of: $0) == PatientHistoryVC.self }) {
                                (activeSubVC as? PatientHistoryVC)?.callAPIforPatientHistoryList()
                            }
                            if let activeSubVC = stackVCs.first(where: { type(of: $0) == PatientListVC.self }) {
                                (activeSubVC as? PatientListVC)?.is_update_details = true
                                (activeSubVC as? PatientListVC)?.callAPIforPatientList()
                            }
                        }
                        self.navigationController?.popViewController(animated: true)
                    }
                    else {
                        let vc = AddHealthComplainVC.instantiate(fromAppStoryboard: .Dashboard)
                        vc.str_patientID = str_patient_id
                        vc.dic_response = appDelegate.dic_patient_response
                        self.navigationController?.pushViewController(vc, animated: true)
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
    
}


//MARK: - UITableView Delegate Datasource Method

extension AddPatientVC: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, countryPickDelegate {
    
    func setupData() {
        if self.screenFrom == .edit_patient {
            self.dic_Value["countrycode"] = appDelegate.dic_patient_response?.countrycode ?? ""
            self.dic_Value["patient_mobile"] = appDelegate.dic_patient_response?.patient_mobile ?? ""
            self.dic_Value["patient_name"] = appDelegate.dic_patient_response?.patient_name ?? ""
            self.dic_Value["patient_email"] = appDelegate.dic_patient_response?.patient_email ?? ""
            self.dic_Value["gender"] = appDelegate.dic_patient_response?.patient_gender ?? ""
            self.dic_Value["patient_age"] = appDelegate.dic_patient_response?.patient_age ?? ""

            if let measurement = appDelegate.dic_patient_response?.patient_measurement as? String {
                let arrMeasurement = Utils.parseValidValue(string: measurement).components(separatedBy: ",")
                if arrMeasurement.count >= 2 {
                    let str_Height = "\(Double(arrMeasurement[0].replacingOccurrences(of: "\"", with: "")) ?? 75.0)"
                    let str_weight = "\(Double(arrMeasurement[1].replacingOccurrences(of: "\"", with: "")) ?? 160.0)"
                    let str_Height_Unit = "\(arrMeasurement[2].replacingOccurrences(of: "\"", with: ""))"
                    let str_weight_Unit = "\(arrMeasurement[3].replacingOccurrences(of: "\"", with: ""))"
                    self.dic_Value[RegistationKey.patient_weight.rawValue] = str_weight
                    self.dic_Value[RegistationKey.patient_height.rawValue] = str_Height
                    
                    self.dic_Value["weight_unit"] = str_weight_Unit
                    self.dic_Value["height_unit"] = str_Height_Unit
                }
            }
            
            let str_food_preference = appDelegate.dic_patient_response?.food_preference ?? ""
            if str_food_preference == "3" {
                self.dic_Value[RegistationKey.food_preference.rawValue] = kFoodPreferencesType.kNonVegetarian.rawValue
            }
            else if str_food_preference == "2" {
                self.dic_Value[RegistationKey.food_preference.rawValue] = kFoodPreferencesType.kEggetarian.rawValue
            }
            else {
                self.dic_Value[RegistationKey.food_preference.rawValue] = kFoodPreferencesType.kVegetarian.rawValue
            }
        }
        else {
            self.dic_Value["gender"] = "male"
            self.dic_Value["patient_consent"] = "1"
            self.dic_Value[RegistationKey.patient_weightUnit.rawValue] = HeightWeigtType.kg.rawValue
            self.dic_Value[RegistationKey.patient_heightUnit.rawValue] = HeightWeigtType.ft.rawValue
            self.dic_Value[RegistationKey.food_preference.rawValue] = kFoodPreferencesType.kVegetarian.rawValue
        }
    }
    
    func manageSection() {
        self.dataSource.removeAll()
        
        self.dataSource.append(D_RegisterData.init(key: .patient_mobile, title: "Mobile number", placeholder: "eg. 2071234567*", type: .mobile, identifier: .textfield))

        self.dataSource.append(D_RegisterData.init(key: .patient_name, title: "Patient Name", placeholder: "eg. Jane Doe*", type: .name, identifier: .textfield))

        self.dataSource.append(D_RegisterData.init(key: .patient_email, title: "Email id", placeholder: "eg. abcd@gmail.com", type: .email, identifier: .textfield))
        
        self.dataSource.append(D_RegisterData.init(key: .doc_gender, title: "Gender", placeholder: "", type: .gender, identifier: .doc_gender))
        
        self.dataSource.append(D_RegisterData.init(key: .patient_weight, title: "Weight", placeholder: "eg. 59", type: .weight, identifier: .height_weightTextfield))
        
        self.dataSource.append(D_RegisterData.init(key: .patient_height, title: "Height", placeholder: "eg. 5'9", type: .height, identifier: .height_weightTextfield))
        
        self.dataSource.append(D_RegisterData.init(key: .patient_age, title: "Age", placeholder: "eg. 32", type: .age, identifier: .textfield))
        
        self.dataSource.append(D_RegisterData.init(key: .food_preference, title: "Food Preference", placeholder: "", type: .food_preference, identifier: .food_preferencesField))
        
        let str_btnName = self.is_hide_mobile == false ? "Send OTP" : "Submit"
        self.dataSource.append(D_RegisterData.init(key: .other, title: str_btnName, placeholder: "", type: .other, identifier: .button))
        self.tbl_View.reloadData()
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
        
        if identifierType == .textfield || identifierType == .label {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterFieldTableCell", for: indexPath) as! RegisterFieldTableCell
            cell.selectionStyle = .none
            cell.txt_Field.delegate = self
            cell.view_countryBG.isHidden = true
            cell.txt_Field_Mobile.isHidden = true
            cell.txt_Field_Mobile.delegate = self
            cell.txt_Field_Mobile.addDoneToolbar()
            cell.lbl_Title.text = str_title
            cell.txt_Field.keyboardType = .default
            cell.txt_Field.accessibilityHint = str_key.rawValue
            cell.txt_Field_Mobile.accessibilityHint = str_key.rawValue
            cell.txt_Field.placeholder = str_placeholder
            cell.txt_Field_Mobile.keyboardType = .phonePad
            cell.txt_Field_Mobile.placeholder = str_placeholder
            cell.lbl_countryCode.text = self.str_SelectedCountry.phoneCode ?? ""

            if identifierType == .label {
                cell.lbl_Title.text = ""
                cell.lbl_bottomText.text = str_title
                cell.constraint_lbl_Title_TOP.constant = -18
                cell.constraint_view_TextFieldBg_Height.constant = 0
            }
            else {
                cell.lbl_bottomText.text = ""
                cell.lbl_Title.text = str_title
                cell.constraint_lbl_Title_TOP.constant = 12
                cell.constraint_view_TextFieldBg_Height.constant = 50
            }

            //Set Keyboard TYPE
            if str_key == .patient_mobile {
                cell.txt_Field.inputView = nil
                cell.txt_Field.isHidden = true
                cell.view_countryBG.isHidden = false
                cell.txt_Field_Mobile.isHidden = false
                cell.txt_Field.addDoneToolbar()
                cell.view_HideMobile.isHidden = false
                cell.txt_Field.keyboardType = .phonePad
                cell.txt_Field_Mobile.text = self.dic_Value[str_key.rawValue] as? String ?? ""
                cell.lbl_countryCode.text = self.dic_Value["country_code"] as? String ?? ""
                
                if self.is_hide_mobile {
                    cell.img_HideMobile.image = UIImage.init(named: "icon_check_box_select")
                }
                else {
                    cell.img_HideMobile.image = UIImage.init(named: "icon_check_box_unselect")
                }
            }
            else if str_key == .patient_email {
                cell.txt_Field.inputView = nil
                cell.txt_Field.isHidden = false
                cell.view_HideMobile.isHidden = true
                cell.view_countryBG.isHidden = true
                cell.txt_Field_Mobile.isHidden = true
                cell.txt_Field.keyboardType = .emailAddress
                cell.txt_Field.text = self.dic_Value[str_key.rawValue] as? String ?? ""
            }
            else if str_key == .patient_age {
                cell.txt_Field.isHidden = false
                cell.view_HideMobile.isHidden = true
                cell.view_countryBG.isHidden = true
                cell.txt_Field_Mobile.isHidden = true
                cell.txt_Field.keyboardType = .numberPad
                
                let str_dob = self.dic_Value[str_key.rawValue] as? String ?? ""
                //let dateFormatter = DateFormatter()
                //dateFormatter.dateFormat = "yyyy-MM-dd"
                //if let dobb = dateFormatter.date(from: str_dob) {
                //    dateFormatter.dateFormat = "dd-MMM-yyyy"
                //    cell.txt_Field.text = dateFormatter.string(from: dobb)
                //}
                //else {
                    cell.txt_Field.text = self.dic_Value[str_key.rawValue] as? String ?? ""
                //}
                cell.txt_Field.addDoneToolbar()
                cell.txt_Field.inputView = nil// self.datePicker
                //self.datePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
            }
            else {
                cell.txt_Field.inputView = nil
                cell.txt_Field.isHidden = false
                cell.view_HideMobile.isHidden = true
                cell.view_countryBG.isHidden = true
                cell.txt_Field_Mobile.isHidden = true
                cell.txt_Field.keyboardType = .default
                cell.txt_Field.text = self.dic_Value[str_key.rawValue] as? String ?? ""
            }
            
            cell.didTappedCountry = {(sender) in
                self.view.endEditing(true)
                let objDialouge = CountrySelectionVC(nibName:"CountrySelectionVC", bundle:nil)
                objDialouge.delegate = self
                self.addChild(objDialouge)
                objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
                self.view.addSubview((objDialouge.view)!)
                objDialouge.didMove(toParent: self)
            }
            
            cell.didTappedHideMobile = { (sender) in
                if self.is_hide_mobile == false {
                    self.AlertDontShowMobile()
                }
                else {
                    self.is_hide_mobile = false
                    self.tbl_View.reloadData()
                }
                
            }

            return cell
        }
        else if identifierType == .height_weightTextfield {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeightWeightTableCell", for: indexPath) as! HeightWeightTableCell
            cell.selectionStyle = .none
            cell.txt_Field.delegate = self
            cell.txt_Field_feet.delegate = self
            cell.txt_Field_inch.delegate = self
            cell.lbl_Title.text = str_title
            cell.txt_Field.addDoneToolbar()
            cell.txt_Field_feet.addDoneToolbar()
            cell.txt_Field_inch.addDoneToolbar()
            cell.txt_Field.keyboardType = .default
            cell.txt_Field.keyboardType = .numberPad
            cell.txt_Field_feet.keyboardType = .numberPad
            cell.txt_Field_inch.keyboardType = .numberPad
            cell.txt_Field_feet.accessibilityHint = "feet"
            cell.txt_Field_inch.accessibilityHint = "inch"
            cell.txt_Field.accessibilityHint = str_key.rawValue
            cell.btn1.accessibilityHint = str_key.rawValue
            cell.btn2.accessibilityHint = str_key.rawValue
            cell.txt_Field.placeholder = str_placeholder
            cell.txt_Field.text = self.dic_Value[str_key.rawValue] as? String ?? ""
            

            if self.dataSource[indexPath.row].type == .weight {
                cell.view_TextFieldBg.isHidden = false
                cell.stach_feet_inch.isHidden = true
                
                cell.lbl_btnTitle1.text = HeightWeigtType.kg.rawValue
                cell.lbl_btnTitle2.text = HeightWeigtType.lbs.rawValue
                
                let str_weightType = self.dic_Value[RegistationKey.patient_weightUnit.rawValue] as? String ?? ""
                
                if str_weightType == HeightWeigtType.kg.rawValue {
                    cell.lbl_btnTitle1.textColor = UIColor.white
                    cell.lbl_btnTitle2.textColor = AppColor.app_GreenColor
                    cell.btn1.backgroundColor = AppColor.app_GreenColor
                    cell.btn2.backgroundColor = UIColor.white
                }
                else {
                    cell.lbl_btnTitle2.textColor = UIColor.white
                    cell.lbl_btnTitle1.textColor = AppColor.app_GreenColor
                    cell.btn2.backgroundColor = AppColor.app_GreenColor
                    cell.btn1.backgroundColor = UIColor.white
                }
            }
            else {
                cell.lbl_btnTitle1.text = HeightWeigtType.ft.rawValue
                cell.lbl_btnTitle2.text = HeightWeigtType.cm.rawValue
                
                let str_heightType = self.dic_Value[RegistationKey.patient_heightUnit.rawValue] as? String ?? ""
                
                if str_heightType == HeightWeigtType.ft.rawValue {
                    cell.lbl_btnTitle1.textColor = .white
                    cell.lbl_btnTitle2.textColor = AppColor.app_GreenColor
                    cell.btn1.backgroundColor = AppColor.app_GreenColor
                    cell.btn2.backgroundColor = UIColor.white
                    cell.view_TextFieldBg.isHidden = true
                    cell.stach_feet_inch.isHidden = false
                    cell.txt_Field_feet.text = self.dic_Value["feet"] as? String ?? ""
                    cell.txt_Field_inch.text = self.dic_Value["inch"] as? String ?? ""
                }
                else {
                    cell.lbl_btnTitle2.textColor = .white
                    cell.lbl_btnTitle1.textColor = AppColor.app_GreenColor
                    cell.btn2.backgroundColor = AppColor.app_GreenColor
                    cell.btn1.backgroundColor = UIColor.white
                    cell.view_TextFieldBg.isHidden = false
                    cell.stach_feet_inch.isHidden = true
                }
            }
                
            cell.didTappedButton1 = {(sender) in
                if sender.accessibilityHint == RegistationKey.patient_weight.rawValue {
                    //For Weight
                    self.dic_Value[RegistationKey.patient_weightUnit.rawValue] = HeightWeigtType.kg.rawValue
                }
                else {
                    //For Height
                    self.dic_Value[RegistationKey.patient_heightUnit.rawValue] = HeightWeigtType.ft.rawValue
                    let getCM = self.dic_Value[RegistationKey.patient_height.rawValue] as? String ?? ""
                    if getCM != "" {
                        let cms: Double = Double(getCM) ?? 0.0
                        let heightMeasure = Utils.convertHeightInFtIn(cms: cms)
                        self.dic_Value["feet"] = "\(heightMeasure.0)"
                        self.dic_Value["inch"] = "\(heightMeasure.1)"
                        cell.txt_Field_feet.text = "\(heightMeasure.0)"
                        cell.txt_Field_inch.text = "\(heightMeasure.1)"
                    }
                }
                self.tbl_View.reloadData()
            }
            cell.didTappedButton2 = {(sender) in
                if sender.accessibilityHint == RegistationKey.patient_weight.rawValue {
                    //For Weight
                    self.dic_Value[RegistationKey.patient_weightUnit.rawValue] = HeightWeigtType.lbs.rawValue
                }
                else {
                    self.dic_Value[RegistationKey.patient_heightUnit.rawValue] = HeightWeigtType.cm.rawValue
                    let strFT = self.dic_Value["feet"] as? String ?? ""
                    let strIN = self.dic_Value["inch"] as? String ?? ""
                    if strFT != "" && strIN != "" {
                        let getcm = Utils.convertHeightInCms(ft: strFT, inc: strIN)
                        self.dic_Value[RegistationKey.patient_height.rawValue] = "\(getcm)"
                        cell.txt_Field.text = "\(getcm)"
                    }
                    else {
                        self.dic_Value["feet"] = ""
                        self.dic_Value["inch"] = ""
                        self.dic_Value[RegistationKey.patient_height.rawValue] = ""
                    }
                }
                self.tbl_View.reloadData()
            }
            
            
            return cell
        }
        else if identifierType == .profile  {
            let cell = tableView.dequeueReusableCell(withClass: SetProfileTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.lbl_Title.text = str_title
            
            
            return cell
        }
        else if identifierType == .food_preferencesField  {
            let cell = tableView.dequeueReusableCell(withClass: FoodPreferenceTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.lbl_Title.text = str_title
            
            let str_food_preferrence = self.dic_Value[str_key.rawValue] as? String ?? ""
            if str_food_preferrence == kFoodPreferencesType.kEggetarian.rawValue {
                cell.img_Veg.image = UIImage.init(named: "icon_unselected")
                cell.img_Egg.image = UIImage.init(named: "icon_selected")
                cell.img_NonVeg.image = UIImage.init(named: "icon_unselected")
            }
            else if str_food_preferrence == kFoodPreferencesType.kNonVegetarian.rawValue {
                cell.img_Veg.image = UIImage.init(named: "icon_unselected")
                cell.img_Egg.image = UIImage.init(named: "icon_unselected")
                cell.img_NonVeg.image = UIImage.init(named: "icon_selected")
            }
            else {
                cell.img_Veg.image = UIImage.init(named: "icon_selected")
                cell.img_Egg.image = UIImage.init(named: "icon_unselected")
                cell.img_NonVeg.image = UIImage.init(named: "icon_unselected")
            }
            
            cell.didTappedVeg = { (sender) in
                self.dic_Value[str_key.rawValue] = kFoodPreferencesType.kVegetarian.rawValue
                self.tbl_View.reloadData()
            }
            
            cell.didTappedEgg = { (sender) in
                self.dic_Value[str_key.rawValue] = kFoodPreferencesType.kEggetarian.rawValue
                self.tbl_View.reloadData()
            }
            
            cell.didTappedNonVeg = { (sender) in
                self.dic_Value[str_key.rawValue] = kFoodPreferencesType.kNonVegetarian.rawValue
                self.tbl_View.reloadData()
            }
            
            return cell
        }
        else if identifierType == .doc_gender  {
            let cell = tableView.dequeueReusableCell(withClass: GenderTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            
            let str_gender = self.dic_Value["gender"] as? String ?? ""
            if str_gender == "female" {
                cell.lbl_female.textColor = UIColor.white
                cell.lbl_male.textColor = UIColor.black
                cell.btn_male.backgroundColor = UIColor.white
                cell.btn_female.backgroundColor = AppColor.app_GreenColor
                cell.img_male.image = UIImage.init(named: "icon_male_black")
                cell.img_female.image = UIImage.init(named: "icon_female_white")
            }
            else {
                cell.lbl_male.textColor = UIColor.white
                cell.lbl_female.textColor = UIColor.black
                cell.btn_female.backgroundColor = UIColor.white
                cell.btn_male.backgroundColor = AppColor.app_GreenColor
                cell.img_male.image = UIImage.init(named: "icon_male_white")
                cell.img_female.image = UIImage.init(named: "icon_female_black")
            }
            
            cell.didTapped_onMale = { (sender) in
                self.dic_Value["gender"] = "male"
                self.tbl_View.reloadData()
            }
            
            cell.didTapped_onFeMale = { (sender) in
                self.dic_Value["gender"] = "female"
                self.tbl_View.reloadData()
            }
            
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterButtonTableCell", for: indexPath) as! RegisterButtonTableCell
            cell.selectionStyle = .none
            let str_btnName = self.is_hide_mobile == false ? "Send OTP" : "Submit"
            cell.btn_Title.text = str_btnName
            cell.constraint_btn_Register_TOP.constant = 35
            
            cell.didTapped_onRegister = { (sender) in
                self.btn_Register_Action()
            }
            
            return cell
        }
    }
    
    func AlertDontShowMobile() {
        let alert = UIAlertController.init(title: "Declaration!", message: "", preferredStyle: UIAlertController.Style.alert)
        
        let attributedMessage = NSMutableAttributedString(string: "I, Dr. \(getUserDetail()?.doctor_name ?? ""), have educated the patient on SaNaaYs terms and conditions as well as privacy policies and the patient has consented to the same", attributes: [NSAttributedString.Key.font: UIFont.AppFontMedium(16)])
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        
        let actionCancel = UIAlertAction.init(title: "No", style: UIAlertAction.Style.cancel, handler: { (action) in
            self.AlertDialougeShowMobile()
        })
        
        let actionOK = UIAlertAction.init(title: "Yes", style: UIAlertAction.Style.destructive, handler: { (action) in
            self.is_hide_mobile = true
            self.dic_Value["patient_consent"] = "1"
            alert.dismiss(animated: true, completion: nil)
            self.tbl_View.reloadData()
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
    
    func AlertDialougeShowMobile() {
        let alert = UIAlertController.init(title: "SaNaaY", message: "", preferredStyle: UIAlertController.Style.alert)
        
        let attributedMessage = NSMutableAttributedString(string: "The patient's report will not be personalized with Patient's name and his/her other details will be anonymous.", attributes: [NSAttributedString.Key.font: UIFont.AppFontMedium(16)])
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        
        let actionCancel = UIAlertAction.init(title: "Close", style: UIAlertAction.Style.cancel, handler: { (action) in
            self.is_hide_mobile = true
            self.dic_Value["patient_consent"] = "0"
            alert.dismiss(animated: true, completion: nil)
            self.tbl_View.reloadData()
        })
        
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
        for textfield: UIView in (alert.textFields ?? [])! {
            let container: UIView = textfield.superview!
            let effectView: UIView = container.superview!.subviews[0]
            container.backgroundColor = UIColor.clear
            effectView.removeFromSuperview()
        }
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.dic_Value["date_of_birth"] = dateFormatter.string(from: sender.date)
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    
    //MARK: - UITextField Delegate Method
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let strKey = textField.accessibilityHint {
            if strKey == "date_of_birth" {
                self.tbl_View.reloadData()
            }
            else {
                self.dic_Value[strKey] = textField.text ?? ""
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let strKey = textField.accessibilityHint {
            let newLength: Int = textField.text!.count + string.count - range.length
            let numberOnly = NSCharacterSet.init(charactersIn: "0123456789").inverted
            let strValid = string.rangeOfCharacter(from: numberOnly) == nil
            if strKey == RegistationKey.patient_name.rawValue || strKey == RegistationKey.patient_email.rawValue {
                if !(newLength <= 50) {
                    return false
                }
            }
            else if strKey == "feet" || strKey == "inch" {
                if string == "0" && (textField.text ?? "").trimed().count == 0 {
                    return false
                }
                else if !(strValid && (newLength <= 2)){
                    return (strValid && (newLength <= 2))
                }
            }
            else if strKey == RegistationKey.patient_mobile.rawValue {
                if string == "0" && (textField.text ?? "").trimed().count == 0 {
                    return false
                }
                else if !(strValid && (newLength <= 10)){
                    return (strValid && (newLength <= 10))
                }
            }
            else if strKey == RegistationKey.patient_age.rawValue || strKey == RegistationKey.patient_weight.rawValue  {
                if !(strValid && (newLength <= 10)){
                    return (strValid && (newLength <= 10))
                }
            }
            
            
        }
        return true
    }
    
    
    //MARK: - Country Selection
    func selectCountry(screenFrom: String, is_Pick: Bool, selectedCountry: Country?) {
        if is_Pick {
            self.str_SelectedCountry = selectedCountry!
            self.dic_Value["country_code"] = selectedCountry?.phoneCode
            self.dic_Value["country"] = selectedCountry?.name ?? ""
            self.tbl_View.reloadData()
        }
    }
}


//MARK: - OTP
extension AddPatientVC: delegateDoneAction {
    
    func generateOTP(country_code: String, mobile: String) {
        if Connectivity.isConnectedToInternet {
            //Firebase OTP generator
            ShowProgressHud(message: AppMessage.plzWait)
            let phone = country_code + mobile
            
            print("phone=",phone)
            
            PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { (verificationID, error) in
                DispatchQueue.main.async(execute: {
                    DismissProgressHud()
                })
                if let error = error {
                    print("### OTP error : ", error.localizedDescription)
                    self.view.makeToast(error.localizedDescription)
                    return
                }
                
                //Go To Next Screen
                self.goToOTPVC(country_code: country_code, mobile: mobile, verificationID: verificationID)
            }
        }else {
            DismissProgressHud()
            self.view.makeToast(AppMessage.no_internet)
        }
    }
    
    func goToOTPVC(country_code: String, mobile: String, verificationID: String?) {
        //Go To Next Screen
        let objDialouge = OTPDialogVC(nibName:"OTPDialogVC", bundle:nil)
        objDialouge.super_vc = self
        objDialouge.delegate = self
        objDialouge.strMobileNo = mobile
        objDialouge.screenFrom = .add_patient
        objDialouge.strCountryCode = country_code
        objDialouge.verificationID = verificationID ?? ""
        self.addChild(objDialouge)
        objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview((objDialouge.view)!)
        objDialouge.didMove(toParent: self)
    }
    
    func doneClicked_Action(_ isClicked: Bool, fromScreen: ScreenType, str_type: String) {
        if fromScreen == .add_patient {
            self.callAPIforAddPatient()
        }
        else {
            var strName = self.dic_Value[RegistationKey.patient_name.rawValue] as? String ?? ""
            if strName.contains(" ") {
                let arrName = strName.components(separatedBy:  " ")
                strName = (arrName.first)?.trimed().capitalized ?? ""
            }
            else {
                strName = strName.trimed().capitalized
            }
            
            self.gotoPulseAssessmentInstruction()
        }
    }
}
