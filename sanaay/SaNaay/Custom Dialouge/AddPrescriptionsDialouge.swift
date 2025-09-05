//
//  AddPrescriptionsDialouge.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 14/04/24.
//

protocol delegate_AddAushadhi {
    func did_select_aushadhi(_ success: Bool, arr_data: [[String: Any]])
}

import UIKit
import Alamofire

class AddPrescriptionsDialouge: UIViewController, UITextViewDelegate {

    var delegate: delegate_AddAushadhi?
    var str_selected_dose = ""
    var str_selected_duration = ""
    var str_selected_morning = ""
    var str_selected_afternoon = ""
    var str_selected_evening = ""
    var selection_type = ScreenType.none
    var dic_selected_aushadhi = [String: Any]()
    var arr_AushadhiData = [[String: Any]]()
    
    var arr_Timing = [String]()
    
    var arr_Dose = [String]()
    var arr_Duration = [String]()
    var arr_Aushadi = [[String: Any]]()
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var collect_view: UICollectionView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btn_Close: UIControl!
    @IBOutlet weak var btn_Save: UIControl!
    @IBOutlet weak var txt_dose: UITextField!
    @IBOutlet weak var txt_duration: UITextField!
    @IBOutlet weak var txt_notes: UITextView!
    @IBOutlet weak var txt_morning: UITextField!
    @IBOutlet weak var txt_afternoon: UITextField!
    @IBOutlet weak var txt_evening: UITextField!
    @IBOutlet weak var txt_aushdhiName: UITextField!
    
    @IBOutlet weak var img_morning_arrow: UIImageView!
    @IBOutlet weak var img_afternoon_arrow: UIImageView!
    @IBOutlet weak var img_evening_arrow: UIImageView!
    
    @IBOutlet weak var constraint_top: NSLayoutConstraint!
    @IBOutlet weak var constraint_bottom: NSLayoutConstraint!
    
    var picker_selection = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.check_enable_SaveButton()
        self.txt_notes.addDoneToolbar()
        self.txt_aushdhiName.addDoneToolbar()
        self.picker_selection.delegate = self
        self.picker_selection.dataSource = self
        for i in 1...30 {
            self.arr_Duration.append("\(i) Day")
        }
        self.arr_Timing = ["Before food", "After food", "NA"]
        
        self.collect_view.register(UINib(nibName: "HomeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionCell")
        
        self.callAPIforGetAuashdhiForm()
        self.constraint_top.constant = UIScreen.main.bounds.size.height
        self.constraint_bottom.constant = -UIScreen.main.bounds.size.height
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
        self.view_Main.roundCorners(corners: [.topLeft, .topRight], radius: 16)
        
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
            self.constraint_bottom.constant = keyboardSize.size.height/2
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.constraint_bottom.constant = 0
        self.view.layoutIfNeeded()
    }
        
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_top.constant = 60
            self.constraint_bottom.constant = 0
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.view_Main.roundCorners(corners: [.topLeft, .topRight], radius: 16)
        }
    }
    
    func clkToClose(_ action: Bool = false) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_top.constant = UIScreen.main.bounds.size.height
            self.constraint_bottom.constant = -UIScreen.main.bounds.size.height
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            self.delegate?.did_select_aushadhi(true, arr_data: self.arr_AushadhiData)
        }
    }

    //MARK: - UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    //MARK: - UITextView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Anuoana" {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Anuoana"
            textView.textColor = .lightGray
        }
    }
    
    func check_enable_SaveButton() {
        var is_enable = false
        let str_name = self.txt_aushdhiName.text ?? ""
        let str_dose = self.txt_dose.text ?? ""
        let str_duration = self.txt_duration.text ?? ""
        let str_aushadhi = self.dic_selected_aushadhi["name"] as? String ?? ""

        if str_aushadhi.trimed() != "" && str_name.trimed() != "" && str_dose.trimed() != "" && str_duration != "" {
            is_enable = true
        }
        
        if is_enable {
            self.btn_Save.isEnabled = true
            self.btn_Save.backgroundColor = AppColor.app_GreenColor
        }
        else {
            self.btn_Save.isEnabled = false
            self.btn_Save.backgroundColor = AppColor.app_GreenColor.withAlphaComponent(0.5)
        }
    }
    
    
    //MARK: - API Call
    func callAPIforGetAuashdhiForm() {

        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            let urlString = BASE_URL + endPoint.kGetAushadiForm.rawValue
            
            Alamofire.request(urlString, method: .post, parameters: nil, encoding:URLEncoding.default,headers: Utils.apiCallHeaders).responseJSON  { response in
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
                    
                    DispatchQueue.main.async(execute: {
                        DismissProgressHud()
                    })
                    let arr_response = dicResponse["data"] as? [[String: Any]] ?? [[:]]
                    self.arr_Aushadi = arr_response
                    self.collect_view.reloadData()
                    
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
    
    func callAPIforAddAushadhi() {
        var str_aushadhi_form_id = self.dic_selected_aushadhi["id"] as? String ?? ""
        if str_aushadhi_form_id == "" {
            str_aushadhi_form_id = "\(self.dic_selected_aushadhi["id"] as? Int ?? 0)"
        }
        
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            let urlString = BASE_URL + endPoint.kAddAushadhiName.rawValue
            
            let params = ["aushadhi_name": self.txt_aushdhiName.text ?? "",
                          "aushadhi_form_id": str_aushadhi_form_id]
            
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
                    
                    DispatchQueue.main.async(execute: {
                        DismissProgressHud()
                    })
                    let is_Status = dicResponse["status"] as? Bool ?? false
                    if is_Status {
                        let str_msg = dicResponse["message"] as? String ?? ""
                        self.view.makeToast(str_msg)
                    }
                    else {
                        self.view.makeToast("Aushadhi added")
                    }
                    
                    self.clearData()
                    
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - Button Action
    @IBAction func btn_close(_ sender: UIButton) {
        self.clkToClose()
    }

    // MARK: - UIButton Action
    @IBAction func btn_Close_Action(_ sender: UIButton) {
        self.view.endEditing(true)
        self.clkToClose()
    }
    
    @IBAction func btn_Save_Action(_ sender: UIControl) {
        self.view.endEditing(true)
        self.callAPIforAddAushadhi()
    }

    func clearData() {
        let str_aush_type = self.dic_selected_aushadhi["name"] as? String ?? ""
        let str_aushadhi_name = self.txt_aushdhiName.text ?? ""
        var str_dose = self.txt_dose.text ?? ""
        let str_duration = self.txt_duration.text ?? ""
        let str_morning = self.txt_morning.text ?? ""
        let str_afternoon = self.txt_afternoon.text ?? ""
        let str_evening = self.txt_evening.text ?? ""
        var str_notes = self.txt_notes.text ?? ""
        if str_notes.lowercased().trimed() == "Anuoana" {
            str_notes = ""
        }
        
//        if str_aush_type.lowercased() == "tablet" || str_aush_type.lowercased() == "capsule" || str_aush_type.lowercased() == "churna" {
//            let arr_aush = str_aushadhi_name.components(separatedBy: " ")
//            str_dose = arr_aush.first ?? ""
//        }
        
        let dic_schedule = ["morning": str_morning, "afternoon": str_afternoon, "evening": str_evening]
        let dic_aushadhi = ["aushadhi_form": self.dic_selected_aushadhi["name"] as? String ?? "", "aushadhi_name": str_aushadhi_name, "dosage": str_dose, "duration": str_duration, "schedule": dic_schedule, "additional_note": str_notes] as [String : Any]
        self.arr_AushadhiData.append(dic_aushadhi)
        
        
        //Clear Data
        self.dic_selected_aushadhi = [:]
        self.txt_aushdhiName.text = ""
        self.txt_dose.text = ""
        self.txt_duration.text = ""
        self.txt_morning.text = ""
        self.txt_afternoon.text = ""
        self.txt_evening.text = ""
        self.txt_notes.text = "Anuoana"
        self.txt_notes.textColor = .lightGray
        self.collect_view.reloadData()
        self.check_enable_SaveButton()
    }
}


//MARK: - UICollectionView Delegate DataSource Method
extension AddPrescriptionsDialouge: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arr_Aushadi.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionCell", for: indexPath) as! HomeCollectionCell
        cell.view_Base.backgroundColor = .clear
        
        let strText = self.arr_Aushadi[indexPath.item]["name"] as? String ?? ""
        cell.lbl_Title.text = strText
        
        let str_aushdhiName = self.dic_selected_aushadhi["name"] as? String ?? ""
        if str_aushdhiName == strText {
            cell.lbl_Title.textColor = AppColor.app_GreenColor
            cell.view_Base.layer.borderColor = AppColor.app_GreenColor.cgColor
        }
        else {
            cell.lbl_Title.textColor = UIColor.lightGray
            cell.view_Base.layer.borderColor = UIColor.lightGray.cgColor
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let strText = self.arr_Aushadi[indexPath.item]["name"] as? String ?? ""
        var getWidth = strText.widthOfString(usingFont: UIFont.AppFontRegular(14))
        getWidth = getWidth + 25
        return CGSize.init(width: getWidth, height: self.collect_view.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.arr_Dose.removeAll()
        self.view.endEditing(true)
        self.txt_dose.text = ""
        self.dic_selected_aushadhi = self.arr_Aushadi[indexPath.item]
        let str_aushadhi = self.arr_Aushadi[indexPath.item]["name"] as? String ?? ""
        
        if str_aushadhi.lowercased() == "tablet" || str_aushadhi.lowercased() == "capsule" {
            for i in 1...30 {
                self.arr_Dose.append("\(i) \(str_aushadhi)")
            }
        }
        else if str_aushadhi.lowercased() == "churna" {
            for i in 1...30 {
                self.arr_Dose.append("\(i) gram")
            }
        }

        self.collect_view.reloadData()
        self.collect_view.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
        self.check_enable_SaveButton()
    }
}


// MARK: - UITextField Delegate Method
extension AddPrescriptionsDialouge: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txt_dose {
            if self.arr_Dose.count != 0 {
                selection_type = ScreenType.dose
                self.txt_dose.inputView = self.picker_selection
                self.picker_selection.reloadAllComponents()
                self.picker_selection.selectRow(0, inComponent: 0, animated: true)
                
                if let text = txt_dose.text, !text.isEmpty {
                } else {
                    if let index = arr_Dose.firstIndex(of: self.txt_dose.text ?? "") {
                        self.picker_selection.selectRow(index, inComponent: 0, animated: false)
                    } else {
                        self.str_selected_dose = self.arr_Dose.first ?? ""
                        self.picker_selection.selectRow(0, inComponent: 0, animated: false)
                    }
                }
                
                self.addDoneToolBar(textField, pickerview: self.picker_selection, clicked: #selector(picker_done_Clicked))
            }
            else {
                self.txt_dose.inputView = nil
            }
        }
        else if textField == self.txt_duration {
            if self.arr_Duration.count != 0 {
                self.selection_type = .duration
                self.txt_duration.inputView = self.picker_selection
                self.picker_selection.reloadAllComponents()
                if let text = textField.text, !text.isEmpty {
                } else {
                    if let index = arr_Duration.firstIndex(of: self.txt_duration.text ?? "") {
                        self.picker_selection.selectRow(index, inComponent: 0, animated: false)
                    } else {
                        self.str_selected_duration = self.arr_Duration.first ?? ""
                        self.picker_selection.selectRow(0, inComponent: 0, animated: false)
                    }
                }
                
                self.addDoneToolBar(textField, pickerview: self.picker_selection, clicked: #selector(picker_done_Clicked))
            }
            else {
                self.txt_duration.inputView = nil
            }
        }
        else if textField == self.txt_morning {
            self.selection_type = .morning
            self.txt_morning.inputView = self.picker_selection
            self.picker_selection.reloadAllComponents()
            if let text = textField.text, !text.isEmpty {
            } else {
                if let index = arr_Timing.firstIndex(of: self.txt_morning.text ?? "") {
                    self.picker_selection.selectRow(index, inComponent: 0, animated: false)
                } else {
                    self.str_selected_morning = self.arr_Timing.first ?? ""
                    self.picker_selection.selectRow(0, inComponent: 0, animated: false)
                }
            }

            self.addDoneToolBar(textField, pickerview: self.picker_selection, clicked: #selector(picker_done_Clicked))
        }
        else if textField == self.txt_afternoon {
            self.selection_type = .afternoon
            self.txt_afternoon.inputView = self.picker_selection
            self.picker_selection.reloadAllComponents()
            if let text = textField.text, !text.isEmpty {
            } else {
                if let index = arr_Timing.firstIndex(of: self.txt_afternoon.text ?? "") {
                    self.picker_selection.selectRow(index, inComponent: 0, animated: false)
                } else {
                    self.str_selected_afternoon = self.arr_Timing.first ?? ""
                    self.picker_selection.selectRow(0, inComponent: 0, animated: false)
                }
            }

            self.addDoneToolBar(textField, pickerview: self.picker_selection, clicked: #selector(picker_done_Clicked))
        }
        else if textField == self.txt_evening {
            self.selection_type = .evening
            self.txt_evening.inputView = self.picker_selection
            self.picker_selection.reloadAllComponents()
            if let text = textField.text, !text.isEmpty {
            } else {
                if let index = arr_Timing.firstIndex(of: self.txt_evening.text ?? "") {
                    self.picker_selection.selectRow(index, inComponent: 0, animated: false)
                } else {
                    self.str_selected_evening = self.arr_Timing.first ?? ""
                    self.picker_selection.selectRow(0, inComponent: 0, animated: false)
                }
            }

            self.addDoneToolBar(textField, pickerview: self.picker_selection, clicked: #selector(picker_done_Clicked))
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
    }
    
    @objc func picker_done_Clicked(_ sender: UIBarButtonItem) {
        if selection_type == .dose {
            self.txt_dose.text = self.str_selected_dose
        } else if selection_type == .duration {
            self.txt_duration.text = self.str_selected_duration
        } else if selection_type == .morning {
            self.txt_morning.text = self.str_selected_morning
        } else if selection_type == .afternoon {
            self.txt_afternoon.text = self.str_selected_afternoon
        } else if selection_type == .evening {
            self.txt_evening.text = self.str_selected_evening
        }
        self.view.endEditing(true)
        self.check_enable_SaveButton()
    }
    
    // MARK: - UIPickerView Delegate Datasource Method
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.selection_type == .dose {
            return self.arr_Dose.count
        }
        else if self.selection_type == .duration {
            return self.arr_Duration.count
        }
        else {
            return self.arr_Timing.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.selection_type == .dose {
            return self.arr_Dose[row]
        }
        else if self.selection_type == .duration {
            return self.arr_Duration[row]
        }
        else {
            return self.arr_Timing[row]
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.selection_type == .dose {
            self.str_selected_dose = self.arr_Dose[row]
        }
        else if self.selection_type == .duration {
            self.str_selected_duration = self.arr_Duration[row]
        }
        else if self.selection_type == .morning {
            self.str_selected_morning = self.arr_Timing[row]
        }
        else if self.selection_type == .afternoon {
            self.str_selected_afternoon = self.arr_Timing[row]
        }
        else {
            self.str_selected_evening = self.arr_Timing[row]
        }
    }
}
