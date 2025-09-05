//
//  RegisterVC.swift
//  Sanaay
//
//  Created by Deepak Jain on 12/08/22.
//

import UIKit
import FirebaseAuth

class D_RegisterData {
    var key: RegistationKey?
    var title: String?
    var placeholder: String?
    var type: D_RegisterFieldType
    var identifier: D_RegisterIdentified
    
    internal init(key: RegistationKey? = nil, title: String? = nil, placeholder: String? = nil, type: D_RegisterFieldType = .other, identifier: D_RegisterIdentified = .other) {
        self.key = key
        self.title = title
        self.placeholder = placeholder
        self.type = type
        self.identifier = identifier
    }
}


class RegisterVC: UIViewController {
    
    var str_mobile = ""
    var str_country_code = ""
    var str_selected_Type = ""
    var is_termsCondition = false
    var picker_selection = UIPickerView()
    
    var str_SelectedCountry = Country(code: "", name: "", phoneCode: "")
    var mediaPicker: PDImagePicker?
    var dic_Value = [String: Any]()
    var dic_Param = [String: Any]()
    var dataSource = [D_RegisterData]()
    var arr_Register_as = ["Individual Doctor", "Corporate doctor"]
    
    @IBOutlet weak var tbl_View: UITableView!
    @IBOutlet weak var constraint_view_Bottom: NSLayoutConstraint!
    private let viewModel: RegisterViewModel = RegisterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if #available(iOS 15.0, *) {
            self.tbl_View.sectionHeaderTopPadding = 0.0
        } else {
            // Fallback on earlier versions
        }
        
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            print(countryCode)
            let arr_country =  SMCountry.shared.getAllCountry(withreload: true)
            if let objCounty = arr_country.filter({ dic_country in
                return (dic_country.code ?? "") == countryCode
            }) as? [Country] {
                self.str_SelectedCountry = objCounty.first!
                self.dic_Value[RegistationKey.countrycode.rawValue] = objCounty.first?.phoneCode ?? "+91"
            }
        }
        
        self.picker_selection.delegate = self
        self.picker_selection.dataSource = self

        //Register Table cell
        self.tbl_View.register(nibWithCellClass: SetProfileTableCell.self)
        self.tbl_View.register(nibWithCellClass: RegisterFieldTableCell.self)
        self.tbl_View.register(nibWithCellClass: RegisterButtonTableCell.self)
        self.tbl_View.register(nibWithCellClass: TermsConditionTableCell.self)

        if self.str_mobile != "" {
            self.dic_Value["doctor_mobile"] = self.str_mobile
            self.dic_Value["countrycode"] = self.str_country_code
        }
        
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
        let strName = self.dic_Value[RegistationKey.doctor_name.rawValue] as? String ?? ""
        let strRegisterType = self.dic_Value[RegistationKey.register_as.rawValue] as? String ?? ""
        let strMobile = self.dic_Value[RegistationKey.doctor_mobile.rawValue] as? String ?? ""
        let strEmail = self.dic_Value[RegistationKey.doctor_email.rawValue] as? String ?? ""
        let strRegisterNumber = self.dic_Value[RegistationKey.doctor_registration.rawValue] as? String ?? ""
        
        if strName.trimed() == "" {
            self.view.makeToast("Please enter name.")
            return
        }
        else if strRegisterType.trimed() == "" {
            self.view.makeToast("Please enter register as.")
            return
        }
        else if strMobile.trimed() == "" {
            self.view.makeToast("Please enter mobile number.")
            return
        }
        else if strEmail.trimed() == "" {
            self.view.makeToast("Please enter email.")
            return
        }
        else if !isValidEmail(email: strEmail) {
            self.view.makeToast("Please enter valid email.")
            return
        }
        if strRegisterNumber.trimed() == "" {
            self.view.makeToast("Please enter registation number.")
            return
        }
        if self.is_termsCondition == false {
            self.view.makeToast("Please agree terms and conditions.")
            return
        }
        
        let str_loginType = self.str_selected_Type == "Individual Doctor" ? "sanaay_g" : "sanaay_c"
                
        self.dic_Param = ["doctor_status": "0",
                          "doctor_name": strName,
                          "doctor_email": strEmail,
                          "register_type": str_loginType,
                          "invoice_id": self.dic_Value["invoice_id"] as? String ?? "",
                          "doctor_mobile": strMobile,
                          "doctor_deviceid": self.dic_Value["doctor_deviceid"] as? String ?? "",
                          "doctor_registration": strRegisterNumber,
                          "countrycode": (self.dic_Value["countrycode"] as? String ?? "")]

        self.callAPIforRegisterDoctor()
    }
}

// MARK: - UIPICKER Delegate Method
extension RegisterVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let strKey = textField.accessibilityHint {
            if strKey == "register_as" {
                textField.inputView = self.picker_selection
                self.picker_selection.reloadAllComponents()
                self.picker_selection.selectRow(0, inComponent: 0, animated: true)
                
                if let text = textField.text, !text.isEmpty {
                } else {
                    if let index = arr_Register_as.firstIndex(of: textField.text ?? "") {
                        self.picker_selection.selectRow(index, inComponent: 0, animated: false)
                    } else {
                        self.str_selected_Type = self.arr_Register_as.first ?? ""
                        self.picker_selection.selectRow(0, inComponent: 0, animated: false)
                    }
                }
                
                self.addDoneToolBar(textField, pickerview: self.picker_selection, clicked: #selector(picker_done_Clicked))
            }
            else {
                textField.inputView = nil
            }
        }
        
        return true
    }
    
    func addDoneToolBar(_ textFild: UITextField, pickerview: UIPickerView, clicked: Selector?) {
        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = .default
        numberToolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .plain, target: self, action: clicked)]
        numberToolbar.sizeToFit()
        textFild.inputAccessoryView = numberToolbar
        textFild.inputView = pickerview
    }
    
    @objc func doneDatePicker() {
        self.view.endEditing(true)
        self.tbl_View.reloadData()
    }
    
    @objc func picker_done_Clicked(_ sender: UIBarButtonItem) {
        self.dic_Value["register_as"] = self.str_selected_Type
        self.view.endEditing(true)
        self.tbl_View.reloadData()
    }
    
    // MARK: - UIPickerView Delegate Datasource Method
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.arr_Register_as.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.arr_Register_as[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            self.str_selected_Type = self.arr_Register_as[row]
    }
}

//MARK: - API CALL
extension RegisterVC: delegateDoneAction {
    
    func callAPIforPreRegisterDoctor() {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            
            self.viewModel.preRegisterDoctor(body: self.dic_Param, endpoint: APIEndpoints.preRegisterDoc) { status, result, error in
                DismissProgressHud()
                
                switch status {
                case .loading:
                    break
                case .success:
                    DismissProgressHud()
                    if result?.status == "success" {
                        
                        self.generateOTP(country_code: self.dic_Param[RegistationKey.countrycode.rawValue] as? String ?? "",
                                         mobile: self.dic_Param[RegistationKey.doctor_mobile.rawValue] as? String ?? "")
                    }
                    else {
                        guard let msgg = result?.message else {
                            return
                        }
                        self.view.makeToast(msgg)
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
    
    func callAPIforVerifyDoctor() {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            
            self.viewModel.doctorVerify(body: self.dic_Param, endpoint: APIEndpoints.verify_doctor) { status, result, error in
                DismissProgressHud()
                
                switch status {
                case .loading:
                    break
                case .success:
                    DismissProgressHud()
                    if result?.status == "success" {
                        
                        self.callAPIforRegisterDoctor()
                        
                    }
                    else {
                        guard let msgg = result?.message else {
                            return
                        }
                        self.view.makeToast(msgg)
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
    
    func callAPIforRegisterDoctor() {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            var param = self.dic_Param
            param["doctor_status"] = "1"
            
            let strURL = BASE_URL + APIEndpoints.doctor_register.rawValue

            if let imageData = (self.dic_Value["profile_pic"] as? UIImage)?.jpegData(compressionQuality: 0.50) {
                ServiceCustom.shared.requestMultiPartWithUrlAndParameters(strURL, Method: "POST", parameters: param, fileParameterName: "doctor_icon", fileName: "doctor_profile.png", fileData: imageData, mimeType: "image/jpeg") { requestttt, urlresponsess, dictionaryyyyy, dataaaa in
                    DismissProgressHud()
                    let status = requestttt?["status"] as? String ?? ""
                    if status == "success" {
                        if let dic_Data = requestttt?["data"] as? [String: Any] {
                            kUserDefaults.set(dic_Data["token"] as? String ?? "", forKey: AppMessage.Authorise_Token)
                            
                            //Go To Add Clicnic Screen
                            let obj = Story_Main.instantiateViewController(withIdentifier: "Register2VC") as! Register2VC
                            self.navigationController?.pushViewController(obj, animated: true)
                        }
                    }
                    else {
                        let msgg = requestttt?["message"] as? String ?? ""
                        if msgg != "" {
                            self.view.makeToast(msgg)
                        }
                    }

                } failure: { errorrr in
                    debugPrint(errorrr)
                    DismissProgressHud()
                }
            }
            else {
                self.viewModel.doctorRegistation(body: param, endpoint: APIEndpoints.doctor_register) { status, result, error in
                    DismissProgressHud()
                    switch status {
                    case .loading:
                        break
                    case .success:
                        DismissProgressHud()
                        if result?.status == "success" {
                            if let dataaa = result?.data {
                                kUserDefaults.set(dataaa.token ?? "", forKey: AppMessage.Authorise_Token)


                                //Go To Add Clicnic Screen
                                let obj = Story_Main.instantiateViewController(withIdentifier: "Register2VC") as! Register2VC
                                self.navigationController?.pushViewController(obj, animated: true)
                                
                            }
                        }
                        else {
                            guard let msgg = result?.message else {
                                return
                            }
                            self.view.makeToast(msgg)
                        }
                        break
                    case .error:
                        DismissProgressHud()
                        break
                    }
                }
            }

        }else {
            DismissProgressHud()
            self.view.makeToast(AppMessage.no_internet)
        }
    }
    
    func generateOTP(country_code: String, mobile: String) {
        if Connectivity.isConnectedToInternet {
            //Firebase OTP generator
            ShowProgressHud(message: AppMessage.plzWait)
            let phone = country_code + mobile
            
            print("phone=",phone)
            
            //PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { (verificationID, error) in
                DispatchQueue.main.async(execute: {
                    DismissProgressHud()
                })
                //if let error = error {
                //    print("### OTP error : ", error.localizedDescription)
                //    self.view.makeToast(error.localizedDescription)
                //    return
                //}
                
                //Go To Next Screen
                self.goToOTPVC(country_code: country_code, mobile: mobile, verificationID: "")
            //}
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
        objDialouge.strCountryCode = country_code
        objDialouge.verificationID = verificationID ?? ""
        self.addChild(objDialouge)
        objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview((objDialouge.view)!)
        objDialouge.didMove(toParent: self)
    }
    
    func doneClicked_Action(_ isClicked: Bool, fromScreen: ScreenType, str_type: String) {
        //self.callAPIforRegisterDoctor()
    }
}


//MARK: - UITableView Delegate Datasource Method

extension RegisterVC: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, countryPickDelegate {
    
    func manageSection() {

        self.dataSource.removeAll()
        self.dataSource.append(D_RegisterData.init(key: .doctor_icon, title: "Set profile picture", placeholder: "", type: .profile, identifier: .profile))
        
        self.dataSource.append(D_RegisterData.init(key: .doctor_name, title: "Doctor name", placeholder: "e.g. Dr Roy*", type: .name, identifier: .textfield))
        
        self.dataSource.append(D_RegisterData.init(key: .register_as, title: "Register as", placeholder: "Select type*", type: .name, identifier: .textfield))
        
        self.dataSource.append(D_RegisterData.init(key: .doctor_mobile, title: "Mobile number", placeholder: "e.g. 2071234567*", type: .mobile, identifier: .textfield))
        
        self.dataSource.append(D_RegisterData.init(key: .doctor_email, title: "Email id", placeholder: "e.g. tavisa@gmail.com*", type: .email, identifier: .textfield))
                
        self.dataSource.append(D_RegisterData.init(key: .doctor_registration, title: "Registration number", placeholder: "e.g. AN47498327", type: .registration_no, identifier: .textfield))
        
        self.dataSource.append(D_RegisterData.init(key: .sannay_id, title: "SaNaaY ID", placeholder: "e.g. AN232K90", type: .registration_no, identifier: .textfield))
        
        self.dataSource.append(D_RegisterData.init(key: .invoice_id, title: "Invoice Number", placeholder: "e.g. SYN909", type: .registration_no, identifier: .textfield))
        
        
        self.dataSource.append(D_RegisterData.init(key: .terms_condition, title: "", type: .terms_condition, identifier: .checkbox_type))
        
        self.dataSource.append(D_RegisterData.init(key: .other, title: "Register", placeholder: "", type: .other, identifier: .button))
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
            cell.txt_Field_Mobile.delegate = self
            cell.view_countryBG.isHidden = true
            cell.txt_Field_Mobile.isHidden = true
            cell.txt_Field_Mobile.addDoneToolbar()
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
            if str_key == .register_as {
                cell.img_arrow_down.isHidden = false
                cell.txt_Field.inputView = self.picker_selection
                cell.txt_Field.text = self.dic_Value[str_key.rawValue] as? String ?? ""
            }
            else if str_key == .doctor_mobile {
                cell.txt_Field.inputView = nil
                cell.txt_Field.isHidden = true
                cell.view_countryBG.isHidden = false
                cell.txt_Field_Mobile.isHidden = false
                cell.txt_Field.addDoneToolbar()
                cell.img_arrow_down.isHidden = true
                cell.txt_Field.keyboardType = .phonePad
                cell.txt_Field_Mobile.text = self.dic_Value[str_key.rawValue] as? String ?? ""
                cell.lbl_countryCode.text = self.dic_Value[RegistationKey.countrycode.rawValue] as? String ?? ""
            }
            else if str_key == .doctor_email {
                cell.txt_Field.isHidden = false
                cell.img_arrow_down.isHidden = true
                cell.view_countryBG.isHidden = true
                cell.txt_Field_Mobile.isHidden = true
                cell.txt_Field.keyboardType = .emailAddress
                cell.txt_Field.inputView = nil
                cell.txt_Field.text = self.dic_Value[str_key.rawValue] as? String ?? ""
            }
            else {
                cell.txt_Field.inputView = nil
                cell.txt_Field.isHidden = false
                cell.img_arrow_down.isHidden = true
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
            
            
            
            return cell
        }
        else if identifierType == .checkbox_type {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TermsConditionTableCell", for: indexPath) as! TermsConditionTableCell
            cell.selectionStyle = .none
            cell.txt_terms_condition.delegate = self
            cell.setupTermsConditionText()
            
            
            cell.didTapped_onTermsCondition = { (sender) in
                self.btn_terms_condition_Action(cell.img_check)
            }
            
            return cell
        }
        else if identifierType == .profile  {
            let cell = tableView.dequeueReusableCell(withClass: SetProfileTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.lbl_Title.text = str_title
            
            if let imgProfile = self.dic_Value["profile_pic"] as? UIImage {
                cell.img_profile.image = imgProfile
            }
            
            cell.didTapped_onProfile = { (sender) in
                self.showMediaPicker()
            }
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterButtonTableCell", for: indexPath) as! RegisterButtonTableCell
            cell.selectionStyle = .none
            cell.btn_Title.text = str_title
            cell.constraint_btn_Register_TOP.constant = 35
            
            cell.didTapped_onRegister = { (sender) in
                self.btn_Register_Action()
            }
            
            return cell
        }
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
            if strKey != "register_as" {
                self.dic_Value[strKey] = textField.text ?? ""
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let strKey = textField.accessibilityHint {
            let newLength: Int = textField.text!.count + string.count - range.length
            let numberOnly = NSCharacterSet.init(charactersIn: "0123456789").inverted
            let strValid = string.rangeOfCharacter(from: numberOnly) == nil
            if strKey == RegistationKey.doctor_name.rawValue || strKey == RegistationKey.doctor_email.rawValue {
                if !(newLength <= 50) {
                    return false
                }
            }
            else if strKey == RegistationKey.doctor_registration.rawValue {
                if !(newLength <= 15) {
                    return false
                }
            }
            else if strKey == RegistationKey.doctor_mobile.rawValue {
                if string == "0" && (textField.text ?? "").trimed().count == 0 {
                    return false
                }
                else if !(strValid && (newLength <= 10)){
                    return (strValid && (newLength <= 10))
                }
            }
        }
        return true
    }
    
    func btn_terms_condition_Action(_ sender: UIImageView) {
        if self.is_termsCondition == false {
            self.is_termsCondition = true
            sender.image = UIImage.init(named: "icon_check_box_select")
        }
        else {
            self.is_termsCondition = false
            sender.image = UIImage.init(named: "icon_check_box_unselect")
        }
    }
    
    //MARK: - UITextView Delegate Method
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let strKey = textView.accessibilityHint {
            if textView.textColor == UIColor.lightGray {
                textView.text = ""
                textView.textColor = UIColor.black
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let strKey = textView.accessibilityHint {
            self.dic_Value[strKey] = textView.text ?? ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let strKey = textView.accessibilityHint {
            if textView.text.isEmpty {
                textView.text = "15+ years in Obstetrics and Gynaecology. specializing in menopause and pregnancy care. Trained at XYZ University, holding senior positions at top hospitals."
                textView.textColor = UIColor.lightGray
            }
        }
    }
    
    // MARK: - TEXTVIEW DELEGATE
    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        UIApplication.shared.open(URL)
        return false
    }
    
    
    //MARK: - Country Selection
    func selectCountry(screenFrom: String, is_Pick: Bool, selectedCountry: Country?) {
        if is_Pick {
            self.str_SelectedCountry = selectedCountry!
            self.dic_Value[RegistationKey.countrycode.rawValue] = selectedCountry?.phoneCode
            self.tbl_View.reloadData()
        }
    }
    
}

extension RegisterVC: PDImagePickerDelegate {
    
    func showMediaPicker() {
        if mediaPicker == nil {
            mediaPicker = PDImagePicker(presentingVC: self, delegate: self, mediaTypes: [.image], allowsEditing: true)
        }
        mediaPicker?.present()
    }
    
    func imagePicker(_ imagePicker: PDImagePicker, didSelectImage image: UIImage?) {
        if let image = image {
            self.dic_Value["profile_pic"] = image
            self.tbl_View.reloadData()
        }
    }
    
    func imagePicker(_ imagePicker: PDImagePicker, didSelectMovie url: URL?) {
    }
}



