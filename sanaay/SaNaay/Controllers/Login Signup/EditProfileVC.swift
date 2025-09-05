//
//  EditProfileVC.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 07/07/23.
//

import UIKit
import SDWebImage

class EditProfileVC: UIViewController, UITextViewDelegate {

    var mediaPicker: PDImagePicker?
    var dic_Value = [String: Any]()
    var dic_API_Param = [String: Any]()
    var dataSource = [D_RegisterData]()

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
        
        //Register Table cell
        self.tbl_View.register(nibWithCellClass: SetProfileTableCell.self)
        self.tbl_View.register(nibWithCellClass: RegisterFieldTableCell.self)
        self.tbl_View.register(nibWithCellClass: RegisterButtonTableCell.self)
        self.tbl_View.register(nibWithCellClass: RegisterTextViewTableCell.self)
        //*******************************************************************//
        

        self.setupDataforEditProfile()
        self.manageSection_forEdirProfile()
    }

    func setupDataforEditProfile() {
        self.dic_Value["doctor_name"] = getUserDetail()?.doctor_name ?? ""
        self.dic_Value["doctor_mobile"] = getUserDetail()?.doctor_mobile ?? ""
        self.dic_Value["doctor_email"] = getUserDetail()?.doctor_email ?? ""
        self.dic_Value["countrycode"] = getUserDetail()?.countrycode ?? ""
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
        let strMobile = self.dic_Value[RegistationKey.doctor_mobile.rawValue] as? String ?? ""
        let strEmail = self.dic_Value[RegistationKey.doctor_email.rawValue] as? String ?? ""

        if strName.trimed() == "" {
            self.view.makeToast("Please enter name.")
            return
        }
        if strMobile.trimed() == "" {
            self.view.makeToast("Please enter mobile number.")
            return
        }
        if strEmail.trimed() == "" {
            self.view.makeToast("Please enter email.")
            return
        }
        if !isValidEmail(email: strEmail) {
            self.view.makeToast("Please enter valid email.")
            return
        }

        self.dic_API_Param = ["doctor_name": strName,
                              "doctor_email": strEmail,
                              "about_doctor": "",
                              "doctor_mobile": strMobile,
                              "doctor_designation": "",
                              "countrycode": (self.dic_Value["countrycode"] as? String ?? "")]
        
        self.callAPIforUpdateProfile()

    }
}

//MARK: - API CALL
extension EditProfileVC {
    
    func callAPIforUpdateProfile() {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            let param = self.dic_API_Param
            let strURL = BASE_URL + APIEndpoints.EditProfileDoctor.rawValue
            
            var img_fileData: Data?
            if let imageData = (self.dic_Value["profile_pic"] as? UIImage)?.jpegData(compressionQuality: 0.25) {
                img_fileData = imageData
            }
            
            ServiceCustom.shared.requestMultiPartWithUrlAndParameters(strURL, Method: "POST", parameters: param, fileParameterName: "doctor_icon", fileName: "doctor_profile.png", fileData: img_fileData, mimeType: "image/jpeg") { requestttt, urlresponsess, dictionaryyyyy, dataaaa in
                DismissProgressHud()
                let status = requestttt?["status"] as? String ?? ""
                if status == "success" {
                    if let dic_Data = requestttt?["data"] as? [String: Any] {
                        
                        var tempData = getUserDetail()
                        tempData?.doctor_name = dic_Data["doctor_name"] as? String ?? ""
                        tempData?.doctor_icon = dic_Data["doctor_icon"] as? String ?? ""
                        
                        setUserDataInUserDefault(tempData!)
                        
                        
                        
//                        //Go To Add Clicnic Screen
//                        let obj = Story_Main.instantiateViewController(withIdentifier: "Register2VC") as! Register2VC
//                        obj.screenFrom = .edit_profile
//                        self.navigationController?.pushViewController(obj, animated: true)
                        
                        
                        let msgg = requestttt?["message"] as? String ?? ""
                        if msgg != "" {
                            appDelegate.window?.rootViewController?.view.makeToast(msgg)
                        }
                        self.navigationController?.popViewController(animated: true)
                        
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
            
        }else {
            DismissProgressHud()
            self.view.makeToast(AppMessage.no_internet)
        }
    }
    
}

//MARK: - UITableView Delegate Datasource Method

extension EditProfileVC: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    func manageSection_forEdirProfile() {
        self.dataSource.removeAll()
        self.dataSource.append(D_RegisterData.init(key: .doctor_icon, title: "", placeholder: "", type: .profile, identifier: .profile))
        self.dataSource.append(D_RegisterData.init(key: .doctor_name, title: "Doctor name", placeholder: "Name", type: .name, identifier: .textfield))
        self.dataSource.append(D_RegisterData.init(key: .doctor_mobile, title: "Mobile number", placeholder: "eg. 9876543210", type: .mobile, identifier: .textfield))
        self.dataSource.append(D_RegisterData.init(key: .doctor_email, title: "Email id", placeholder: "eg. abcd@gmail.com", type: .email, identifier: .textfield))
        
        self.dataSource.append(D_RegisterData.init(key: .other, title: "Update", placeholder: "", type: .other, identifier: .button))
        
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
            if str_key == .doctor_mobile {
                cell.txt_Field.isHidden = true
                cell.view_countryBG.isHidden = false
                cell.txt_Field_Mobile.isHidden = false
                cell.txt_Field.addDoneToolbar()
                cell.txt_Field.keyboardType = .phonePad
                cell.txt_Field_Mobile.text = self.dic_Value[str_key.rawValue] as? String ?? ""
                cell.lbl_countryCode.text = self.dic_Value[RegistationKey.countrycode.rawValue] as? String ?? ""

                cell.lbl_countryCode.textColor = .lightGray
                cell.txt_Field_Mobile.textColor = .lightGray
                cell.txt_Field_Mobile.isUserInteractionEnabled = false
            }
            else if str_key == .doctor_email {
                cell.txt_Field.isHidden = false
                cell.view_countryBG.isHidden = true
                cell.txt_Field_Mobile.isHidden = true
                cell.txt_Field.keyboardType = .emailAddress
                cell.txt_Field.text = self.dic_Value[str_key.rawValue] as? String ?? ""

                cell.txt_Field.textColor = .lightGray
                cell.txt_Field.isUserInteractionEnabled = false
            }
            else {
                cell.txt_Field.isHidden = false
                cell.view_countryBG.isHidden = true
                cell.txt_Field_Mobile.isHidden = true
                cell.txt_Field.keyboardType = .default
                cell.txt_Field.textColor = UIColor.black
                cell.txt_Field.isUserInteractionEnabled = true
                cell.txt_Field.text = self.dic_Value[str_key.rawValue] as? String ?? ""
            }

            return cell
        }
        else if identifierType == .textview {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RegisterTextViewTableCell", for: indexPath) as! RegisterTextViewTableCell
            cell.selectionStyle = .none
            cell.txt_View.delegate = self
            cell.txt_View.addDoneToolbar()
            cell.txt_View.accessibilityHint = str_key.rawValue
            cell.lbl_Title.text = str_title
            cell.txt_View.text = self.dic_Value[str_key.rawValue] as? String ?? ""
            
            return cell
        }
        else if identifierType == .profile  {
            let cell = tableView.dequeueReusableCell(withClass: SetProfileTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.lbl_Title.text = str_title
            cell.img_plus.image = UIImage.init(named: "icon_edit")
            
            if let imgProfile = self.dic_Value["profile_pic"] as? UIImage {
                cell.img_profile.image = imgProfile
            }
            else {
                let strImgIcon = getUserDetail()?.doctor_icon ?? ""
                cell.img_profile.sd_setImage(with: URL.init(string: strImgIcon), placeholderImage: UIImage.init(named: "icon_default"), progress: nil)
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
            if strKey == RegistationKey.doctor_name.rawValue || strKey == RegistationKey.doctor_email.rawValue {
                if !(newLength <= 50) {
                    return false
                }
            }
        }
        return true
    }
    
    //MARK: - UITextView Delegate Method
    func textViewDidChange(_ textView: UITextView) {
        if let strKey = textView.accessibilityHint {
            self.dic_Value[strKey] = textView.text ?? ""
        }
    }

}

extension EditProfileVC: PDImagePickerDelegate {
    
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



