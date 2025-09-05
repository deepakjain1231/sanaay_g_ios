//
//  Register2VC.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 14/06/23.
//

import UIKit
import Alamofire

class Register2VC: UIViewController {
    
    var screenFrom = ScreenType.none
    var mediaPicker: PDImagePicker?
    var dic_Value = [String: Any]()
    var dataSource = [D_RegisterData]()
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var tbl_View: UITableView!
    @IBOutlet weak var constraint_view_Bottom: NSLayoutConstraint!
    private let viewModel: RegisterViewModel = RegisterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if self.screenFrom == .edit_profile {
            self.lbl_title.text = "Update Details"
        }
        
        if #available(iOS 15.0, *) {
            self.tbl_View.sectionHeaderTopPadding = 0.0
        } else {
            // Fallback on earlier versions
        }
    
        
        //Register Table cell
        self.tbl_View.register(nibWithCellClass: SetProfileTableCell.self)
        self.tbl_View.register(nibWithCellClass: RegisterFieldTableCell.self)
        self.tbl_View.register(nibWithCellClass: RegisterButtonTableCell.self)
        
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
            self.constraint_view_Bottom.constant = keyboardSize.size.height
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

        let str_clinic_Name = self.dic_Value[RegistationKey.clinic_name.rawValue] as? String ?? ""
        let str_clinic_address = self.dic_Value[RegistationKey.clinic_address.rawValue] as? String ?? ""
        let str_clinic_city = self.dic_Value[RegistationKey.city.rawValue] as? String ?? ""
        let str_landmark = self.dic_Value[RegistationKey.landmark.rawValue] as? String ?? ""

        if str_clinic_Name.trimed() == "" {
            self.view.makeToast("Please enter clinic name.")
            return
        }
        if str_clinic_address.trimed() == "" {
            self.view.makeToast("Please enter clinic address.")
            return
        }
        if str_clinic_city.trimed() == "" {
            self.view.makeToast("Please enter city name.")
            return
        }
        if str_landmark.trimed() == "" {
            self.view.makeToast("Please enter landmark.")
            return
        }

        let dic_Param = ["clinic": str_clinic_Name,
                         "address": str_clinic_address,
                         "city": str_clinic_city,
                         "landmark": str_landmark]

        self.callAPIforRegisterClinicDetails(dic_Param)

        
        //Go To Home Screen
//        let obj = Story_Dashboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
//        self.navigationController?.pushViewController(obj, animated: true)
        
    }
}


//MARK: - API CALL
extension Register2VC {

    func callAPIforRegisterClinicDetails(_ paramss: [String: Any]) {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            var strURL = BASE_URL + APIEndpoints.AddClinic.rawValue
            
            if self.screenFrom == .edit_profile {
                strURL = BASE_URL + APIEndpoints.EditClinic.rawValue
            }
            
            if let imageData = (self.dic_Value["clinic_logo"] as? UIImage)?.jpegData(compressionQuality: 0.50) {
                ServiceCustom.shared.requestMultiPartWithUrlAndParameters(strURL, Method: "POST", parameters: paramss, fileParameterName: "clinic_icon", fileName: "doctor_clicnic.png", fileData: imageData, mimeType: "image/jpeg") { requestttt, urlresponsess, dictionaryyyyy, dataaaa in
                    DismissProgressHud()
                    let status = requestttt?["status"] as? String ?? ""
                    if status == "success" {
                        if let dic_Data = dataaaa {

                            do {
                                let result = try JSONDecoder().decode(LoginModel.self, from: dic_Data)
                                debugPrint("APIService: result-> \(result)")
                                
                                guard let dataa = result.data else {
                                    return
                                }
                                
                                setUserDataInUserDefault(dataa)
                                kUserDefaults.set(true, forKey: AppMessage.USER_LOGIN)
                                
                                //Go To Home Screen
                                let obj = Story_Dashboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                                self.navigationController?.pushViewController(obj, animated: true)
                                
                            }catch {
                                debugPrint("APIService: Unable to decode \(error.localizedDescription)")
                            }

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
                
                var strEndPoint = APIEndpoints.AddClinic
                
                if self.screenFrom == .edit_profile {
                    strEndPoint = APIEndpoints.EditClinic
                }
                
                self.viewModel.doctor_clinic_Registation(body: paramss, endpoint: strEndPoint) { status, result, error in
                    DismissProgressHud()
                    switch status {
                    case .loading:
                        break
                    case .success:
                        DismissProgressHud()
                        if result?.status == "success" {
                            if let dataaa = result?.data {

                                if self.screenFrom == .edit_profile {
                                    var dic_user_data = dataaa
                                    dic_user_data.token = Utils.getAuthToken()
                                    setUserDataInUserDefault(dic_user_data)
                                }
                                else {
                                    setUserDataInUserDefault(dataaa)
                                    kUserDefaults.set(true, forKey: AppMessage.USER_LOGIN)
                                }

                                DispatchQueue.main.async {
                                    //Go To Home Screen
                                    let obj = Story_Dashboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                                    self.navigationController?.pushViewController(obj, animated: true)
                                }
                                

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
}


    //MARK: - UITableView Delegate Datasource Method

extension Register2VC: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    func setupData() {
        if self.screenFrom == .edit_profile {
            self.dic_Value["clinic_icon"] = getUserDetail()?.clinic_icon ?? ""
            self.dic_Value["clinic"] = getUserDetail()?.clinic ?? ""
            self.dic_Value["clinic_address"] = getUserDetail()?.address ?? ""
            self.dic_Value["city"] = getUserDetail()?.city ?? ""
            self.dic_Value["landmark"] = getUserDetail()?.landmark ?? ""
        }
    }
    
    func manageSection() {
        
        self.dataSource.removeAll()
        self.dataSource.append(D_RegisterData.init(key: .clinic_icon, title: "Set clinic logo", placeholder: "", type: .profile, identifier: .profile))
        
        self.dataSource.append(D_RegisterData.init(key: .clinic_name, title: "Clinic name", placeholder: "eg: Nirog yoga center*", type: .name, identifier: .textfield))
                
        self.dataSource.append(D_RegisterData.init(key: .clinic_address, title: "Clinic address", placeholder: "eg: Building Number and Street Name*", type: .name, identifier: .textfield))
        
        self.dataSource.append(D_RegisterData.init(key: .city, title: "City", placeholder: "eg: London, Greater London*", type: .name, identifier: .textfield))
        
        self.dataSource.append(D_RegisterData.init(key: .landmark, title: "Landmark", placeholder: "eg: Near petrol pump", type: .name, identifier: .textfield))
        
        self.dataSource.append(D_RegisterData.init(key: .other, title: "Finish", placeholder: "", type: .other, identifier: .button))
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
            cell.btn_location.isHidden = true
            cell.txt_Field.accessibilityHint = str_key.rawValue
            cell.txt_Field.placeholder = str_placeholder
            cell.txt_Field_Mobile.delegate = self
            cell.view_countryBG.isHidden = true
            cell.txt_Field_Mobile.isHidden = true
            cell.txt_Field_Mobile.addDoneToolbar()
            cell.txt_Field_Mobile.accessibilityHint = str_key.rawValue
            cell.txt_Field_Mobile.keyboardType = .phonePad
            cell.txt_Field_Mobile.placeholder = str_placeholder
            
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
            cell.txt_Field.isHidden = false
            cell.view_countryBG.isHidden = true
            cell.txt_Field_Mobile.isHidden = true
            cell.txt_Field.keyboardType = .default
            cell.txt_Field.text = self.dic_Value[str_key.rawValue] as? String ?? ""
            
            
            return cell
        }
        else if identifierType == .profile  {
            let cell = tableView.dequeueReusableCell(withClass: SetProfileTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.lbl_Title.text = str_title
            
            if let imgProfile = self.dic_Value["clinic_logo"] as? UIImage {
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
            self.dic_Value[strKey] = textField.text ?? ""
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let strKey = textField.accessibilityHint {
            let newLength: Int = textField.text!.count + string.count - range.length
            let numberOnly = NSCharacterSet.init(charactersIn: "0123456789").inverted
            let strValid = string.rangeOfCharacter(from: numberOnly) == nil
            if strKey == RegistationKey.clinic_name.rawValue || strKey == RegistationKey.city.rawValue {
                if !(newLength <= 50) {
                    return false
                }
            }
            else if strKey == RegistationKey.clinic_number.rawValue {
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

}

extension Register2VC: PDImagePickerDelegate {
    
    func showMediaPicker() {
        if mediaPicker == nil {
            mediaPicker = PDImagePicker(presentingVC: self, delegate: self, mediaTypes: [.image], allowsEditing: true)
        }
        mediaPicker?.present()
    }
    
    func imagePicker(_ imagePicker: PDImagePicker, didSelectImage image: UIImage?) {
        if let image = image {
            self.dic_Value["clinic_logo"] = image
            self.tbl_View.reloadData()
        }
    }
    
    func imagePicker(_ imagePicker: PDImagePicker, didSelectMovie url: URL?) {
    }
}

