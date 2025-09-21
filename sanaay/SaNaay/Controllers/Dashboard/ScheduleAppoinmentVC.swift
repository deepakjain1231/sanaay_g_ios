//
//  ScheduleAppoinmentVC.swift
//  SaNaay
//
//  Created by DEEPAK JAIN on 15/07/24.
//

import UIKit
import Alamofire
import WebKit

class ScheduleAppoinmentVC: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var str_patientID = ""
    var str_pdf_name = ""
    var dic_API_Params = [String: Any]()
    var screenForm = ScreenType.none
    var dic_response: PatientListDataResponse?
    
    var arr_bookedAppoinement = [[String: Any]]()
    
    private lazy var datePicker: UIDatePicker = {
      let datePicker = UIDatePicker(frame: .zero)
      datePicker.datePickerMode = .date
      datePicker.timeZone = TimeZone.current
      return datePicker
    }()
    
    var api_date = ""
    var selected_date = ""
    var date_selectedDate = Date()
    
    var strToday_date = ""
    var arr_AllTimeSlots = [String]()
    var arr_FromDuration = [String]()
    var arr_ToDuration = [String]()
    var picker_selection = UIPickerView()
    var selection_type = ScreenType.none
    var selected_fromTime = ""
    var selected_toTime = ""
    
    @IBOutlet weak var lbl_nav_Title: UILabel!
    @IBOutlet weak var txt_Date: UITextField!
    @IBOutlet weak var txt_fromTime: UITextField!
    @IBOutlet weak var txt_toTime: UITextField!
    @IBOutlet weak var lbl_Reschedule: UILabel!
    @IBOutlet weak var lbl_Skip: UILabel!
    
    @IBOutlet weak var btn_Reschedule: UIControl!
    @IBOutlet weak var btn_Skip: UIControl!
    @IBOutlet weak var webView_iPad: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.picker_selection.delegate = self
        self.picker_selection.dataSource = self
        self.txt_Date.accessibilityHint = "date"
        self.txt_fromTime.accessibilityHint = "from_time"
        self.txt_toTime.accessibilityHint = "to_time"
        self.addDoneDatePickerToolBar(self.txt_Date, clicked: #selector(doneDatePicker))
        
        self.getTimeSlot()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        self.strToday_date = formatter.string(from: Date())
        self.txt_Date.text = formatter.string(from: Date())
        self.selected_date = formatter.string(from: Date())
        
        formatter.dateFormat = "yyyy-MM-dd"
        self.api_date = formatter.string(from: Date())
        
        
        if #available(iOS 14, *) {
            self.datePicker.preferredDatePickerStyle = .wheels
        }
        
        self.txt_fromTime.addDoneToolbar()
        self.txt_toTime.addDoneToolbar()
        self.txt_Date.inputView = self.datePicker
        self.txt_fromTime.inputView = self.datePicker
        self.txt_toTime.inputView = self.datePicker
        self.datePicker.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
        
        if self.screenForm == .bookappointment {
            self.btn_Skip.isHidden = true
            self.lbl_Reschedule.text = "Schedule"
        }
        else if screenForm == .rescheduleAppointment {
            self.btn_Skip.isHidden = true
            self.lbl_nav_Title.text = "Reschedule"
            self.lbl_Reschedule.text = "Reschedule"
        }
        self.callAPIforCheckAppointment()
    }
    
    func getTimeSlot() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm a"

        let formatter2 = DateFormatter()
        formatter2.dateFormat = "hh:mm a"

        let startDate = "20-08-2018 12:00 AM"
        let endDate = "20-08-2018 11:59 PM"

        let date1 = formatter.date(from: startDate)
        let date2 = formatter.date(from: endDate)

        var i = 1
        while true {
            let date = date1?.addingTimeInterval(TimeInterval(i*10*60))
            let string = formatter2.string(from: date!)

            if date! >= date2! {
                break;
            }

            i += 1
            self.arr_AllTimeSlots.append(string)
        }
        self.arr_AllTimeSlots.insert("12:00 AM", at: 0)
        print(self.arr_AllTimeSlots)
    }
    
    @objc func handleDatePicker(sender: UIDatePicker) {
        self.date_selectedDate = sender.date
     }
    
    //MARK:  - Date Picket
    func addDoneDatePickerToolBar(_ textFild: UITextField, clicked: Selector?) {
        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = .default
        numberToolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .plain, target: self, action: clicked)]
        numberToolbar.sizeToFit()
        textFild.inputAccessoryView = numberToolbar
        textFild.inputView = self.datePicker
    }
    
    @objc func doneDatePicker(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.txt_toTime.text = ""
        self.txt_fromTime.text = ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        self.txt_Date.text = dateFormatter.string(from: self.date_selectedDate)
        self.selected_date = dateFormatter.string(from: self.date_selectedDate)
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.api_date = dateFormatter.string(from: self.date_selectedDate)
        self.callAPIforCheckAppointment()
    }
    

    //MARK: - API Call
    func callAPIforCheckAppointment() {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)

            let urlString = BASE_URL +  APIEndpoints.CheckAppointment.rawValue
            
            let param = ["date_time": self.api_date] as [String : Any]
            
            
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

                    guard let arr_result = (dicResponse["data"] as? [[String: Any]]) else {
                        DispatchQueue.main.async(execute: {
                            DismissProgressHud()
                        })
                        return
                    }
                    self.arr_bookedAppoinement = arr_result
                    
                case .failure(let error):
                    print(error)
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
    
    @IBAction func btn_reschedule_Action(_ sender: UIControl) {
        if self.screenForm == .bookappointment && self.btn_Reschedule.backgroundColor == AppColor.app_GreenColor {
            self.callAPIforScheduleAppointment(is_reschedule: false)
        }
        else if screenForm == .rescheduleAppointment && self.btn_Reschedule.backgroundColor == AppColor.app_GreenColor {
            self.callAPIforScheduleAppointment(is_reschedule: true)
        }
        else if screenForm == .fromm_suggesttion && self.btn_Reschedule.layer.borderColor == AppColor.app_GreenColor.cgColor {
            self.dic_API_Params["date_time"] = self.api_date
            self.dic_API_Params["from_time"] = self.txt_fromTime.text ?? ""
            self.dic_API_Params["to_time"] = self.txt_toTime.text ?? ""
            
            self.callAPIforSubmitSaNaaYResult()
        }
    }
    
    @IBAction func btn_skip_Action(_ sender: UIControl) {
        self.callAPIforSubmitSaNaaYResult()
    }
}

// MARK: - UITextField Delegate Method
extension ScheduleAppoinmentVC: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.accessibilityHint == "date" && textField.text == "" {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MM-yyyy"
            self.txt_Date.text = dateFormatter.string(from: self.datePicker.date)
            self.selected_date = dateFormatter.string(from: self.datePicker.date)
            
            dateFormatter.dateFormat = "yyyy-MM-dd"
            self.api_date = dateFormatter.string(from: self.datePicker.date)
            
            self.txt_fromTime.text = ""
            self.txt_toTime.text = ""
        }
        else if textField == txt_fromTime {
            
            if self.txt_Date.text?.trimed() == "" {
                return false
            }
            
            if self.strToday_date == self.selected_date {
                let formatter = DateFormatter()
                let current_time = Date().next10Minit // "May 23, 2020 at 1:00  AM"
                formatter.dateFormat = "hh:mm a"
                //formatter.timeZone = TimeZone.current
                let str_currentttime = formatter.string(from: current_time)
                if let indx = self.arr_AllTimeSlots.firstIndex(where: { str_date in
                    return str_date == str_currentttime
                }) {
                    self.arr_FromDuration.removeAll()
                    
                    for i in (indx ..< self.arr_AllTimeSlots.count) {
                        self.arr_FromDuration.append(self.arr_AllTimeSlots[i])
                    }

                }

            }
            else {
                self.arr_FromDuration = self.arr_AllTimeSlots
            }

            self.selection_type = .from_time
            self.txt_fromTime.inputView = self.picker_selection
            self.picker_selection.reloadAllComponents()
            self.picker_selection.selectRow(0, inComponent: 0, animated: true)

            if let text = self.txt_fromTime.text, !text.isEmpty {
            } else {
                if let index = self.arr_FromDuration.firstIndex(of: self.txt_fromTime.text ?? "") {
                    self.picker_selection.selectRow(index, inComponent: 0, animated: false)
                } else {
                    self.selected_fromTime = self.arr_FromDuration.first ?? ""
                    self.picker_selection.selectRow(0, inComponent: 0, animated: false)
                }
            }
            self.addDoneToolBar(textField, pickerview: self.picker_selection, clicked: #selector(picker_done_Clicked))
        }
        else if textField == txt_toTime {
            if self.txt_fromTime.text?.trimed() == "" {
                return false
            }

            if let indx = self.arr_AllTimeSlots.firstIndex(where: { str_date in
                return str_date == self.txt_fromTime.text
            }) {
                self.arr_ToDuration.removeAll()

                for i in (indx ..< self.arr_AllTimeSlots.count) {
                    self.arr_ToDuration.append(self.arr_AllTimeSlots[i])
                }
            }
            else {
                self.arr_ToDuration = self.arr_AllTimeSlots
            }

            self.selection_type = .to_time
            self.txt_fromTime.inputView = self.picker_selection
            self.picker_selection.reloadAllComponents()
            self.picker_selection.selectRow(0, inComponent: 0, animated: true)

            if let text = self.txt_toTime.text, !text.isEmpty {
            } else {
                if let index = self.arr_ToDuration.firstIndex(of: self.txt_toTime.text ?? "") {
                    self.picker_selection.selectRow(index, inComponent: 0, animated: false)
                } else {
                    self.selected_toTime = self.arr_ToDuration.first ?? ""
                    self.picker_selection.selectRow(0, inComponent: 0, animated: false)
                }
            }
            self.addDoneToolBar(textField, pickerview: self.picker_selection, clicked: #selector(picker_done_Clicked))
        }
        

        
        return true
    }
    
    
    
    //MARK: - Picker View
    func addDoneToolBar(_ textFild: UITextField, pickerview: UIPickerView, clicked: Selector?) {
        let numberToolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        numberToolbar.barStyle = .default
        numberToolbar.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .plain, target: self, action: clicked)]
        numberToolbar.sizeToFit()
        textFild.inputAccessoryView = numberToolbar
        textFild.inputView = pickerview
    }
    
    @objc func picker_done_Clicked(_ sender: UIBarButtonItem) {
        if selection_type == .from_time {
            self.txt_toTime.text = ""
            self.txt_fromTime.text = self.selected_fromTime
        } else if selection_type == .to_time {
            self.txt_toTime.text = self.selected_toTime
        }
        
        if (self.txt_Date.text ?? "") != "" && (self.txt_fromTime.text ?? "") != "" && (self.txt_toTime.text ?? "") != ""  {
            if self.screenForm == .bookappointment || self.screenForm == .rescheduleAppointment {
                self.lbl_Reschedule.textColor = .white
                self.btn_Reschedule.backgroundColor = AppColor.app_GreenColor
            }
            else {
                self.lbl_Reschedule.textColor = AppColor.app_GreenColor
                self.btn_Reschedule.layer.borderColor = AppColor.app_GreenColor.cgColor
                self.btn_Reschedule.backgroundColor = .white
            }
        }
        else {
            self.btn_Reschedule.layer.borderColor = UIColor.init(hex: "777777").cgColor
            self.btn_Reschedule.backgroundColor = .white
        }
        
        self.view.endEditing(true)
    }
    
    // MARK: - UIPickerView Delegate Datasource Method
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if self.selection_type == .from_time {
            return self.arr_FromDuration.count
        }
        else if self.selection_type == .to_time {
            return self.arr_ToDuration.count
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if self.selection_type == .from_time {
            return self.arr_FromDuration[row]
        }
        else {
            return self.arr_ToDuration[row]
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.selection_type == .from_time {
            self.selected_fromTime = self.arr_FromDuration[row]
        }
        else {
            self.selected_toTime = self.arr_ToDuration[row]
        }
    }
}


//MARK: - SChedule Appointment API
extension ScheduleAppoinmentVC {
    
    func callAPIforScheduleAppointment(is_reschedule: Bool) {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)

            var param = [String: Any]()
            var urlString = BASE_URL +  APIEndpoints.AddPatientApppointment.rawValue

            param["date_time"] = self.api_date
            param["from_time"] = self.txt_fromTime.text ?? ""
            param["to_time"] = self.txt_toTime.text ?? ""
            
            if is_reschedule {
                param["id"] = self.dic_response?.id ?? ""
                urlString = BASE_URL +  APIEndpoints.EditPatientAppointment.rawValue
            }
            else {
                param["patient_id"] = self.str_patientID
            }

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

                    let strStatus = dicResponse["status"] as? String ?? ""
                    if strStatus == "success" {
                        
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd-MM-yyyy"
                        let str_Date = dateFormatter.string(from: self.date_selectedDate)
                        
                        
                        //Go To Home Screen
                        if let stackVCs = self.navigationController?.viewControllers {
                            if let activeSubVC = stackVCs.first(where: { type(of: $0) == HomeVC.self }) {
                                (activeSubVC as? HomeVC)?.callAPIforGetAppointment(str_date: str_Date)
                                self.navigationController?.popToViewController(activeSubVC, animated: true)
                            }
                        }
                        
                    }
                    
                case .failure(let error):
                    print(error)
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
    
    func callAPIforSubmitSaNaaYResult() {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            
            let urlString = BASE_URL + APIEndpoints.AddSuggetions_Report.rawValue
            ServiceCustom.shared.requestURL(urlString, Method: .post, parameters: self.dic_API_Params) { responsee, isSuccess, errorrr, status in
                DismissProgressHud()
                debugPrint(responsee)
                if let isSuccess = responsee?["status"] as? String, isSuccess == "success" {
                    
                    guard let dataaa = responsee?["data"] as? [[String: Any]] else {
                        return
                    }
                    let strreporrtlink = dataaa[0]["report_link"] as? String ?? ""
                    debugPrint(dataaa[0]["report_link"] as? String ?? "")
                    self.goToshowingreport(report_link: strreporrtlink)
                }
                
            }
        }
        else {
            DismissProgressHud()
            self.view.makeToast(AppMessage.no_internet)
        }
    }
    
    func goToshowingreport(report_link: String) {
        if report_link != "" {
            let arr_pdfname = report_link.components(separatedBy: "/")
            self.str_pdf_name = "sanaay_report_\(arr_pdfname.last ?? "1").pdf"
            
            
            ShowProgressHud(message: AppMessage.generating_report)
            self.webView_iPad.uiDelegate = self
            self.webView_iPad.navigationDelegate = self
            self.webView_iPad.accessibilityValue = report_link
            
            DispatchQueue.main.async {
                if let url = URL(string: report_link) {
                    let request = URLRequest(url: url)
                    self.webView_iPad.load(request)
                }
                else {
                    DismissProgressHud()
                }
            }
        }
        else {
            self.view.makeToast("Something went wrong please retest again")
        }
        
        
        
//        let safariVC = SFSafariViewController(url: URL(string: report_link)!)
//        self.present(safariVC, animated: true, completion: nil)
//        safariVC.delegate = self

//        ShowProgressHud(message: AppMessage.plzWait)
//        self.webView_iPad.uiDelegate = self
//        self.webView_iPad.navigationDelegate = self
//        self.webView_iPad.accessibilityValue = report_link
//        if let url = URL(string: report_link) {
//            let request = URLRequest(url: url)
//            self.webView_iPad.load(request)
//        }
//        else {
//            DismissProgressHud()
//        }
        
//        let vc = ReportVC.instantiate(fromAppStoryboard: .Assessment)
//        vc.str_reportLink = report_link
//        vc.screenFrom = .direct_back
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - WEB VIEW DELEGATE
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
//            DismissProgressHud()
//            
//            let vc = ReportVC.instantiate(fromAppStoryboard: .Assessment)
//            vc.screenFrom = .direct_back
//            vc.str_reportLink = self.webView_iPad.accessibilityValue ?? ""
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
//            self.exportToPDF()
//        }
        
        
        // Keep checking until the page is fully loaded
        waitUntilJSRendered(in: webView) { [weak self] in
            guard let self = self else { return }
            print("📄 Page fully loaded, exporting PDF...")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.exportToPDF()
            }
        }
    }
    
    private func waitUntilJSRendered(in webView: WKWebView, completion: @escaping () -> Void) {
        let js = """
        (function() {
            if (document.readyState !== 'complete') {
                return false;
            }
            // Check if DOM size has stabilized (for JS-rendered content)
            var body = document.body;
            var html = document.documentElement;
            var height = Math.max(body.scrollHeight, body.offsetHeight,
                                  html.clientHeight, html.scrollHeight, html.offsetHeight);
            
            if (window.__lastHeight === height) {
                return true; // Height hasn't changed → assume rendering is done
            }
            window.__lastHeight = height;
            return false;
        })();
        """

        webView_iPad.evaluateJavaScript(js) { result, _ in
            if let isReady = result as? Bool, isReady {
                print("✅ JS rendering finished")
                completion()
            } else {
                // Retry after short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.waitUntilJSRendered(in: webView, completion: completion)
                }
            }
        }
    }
    
//    private func handleReportLoading() {
//        let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let fileURL = docPath.appendingPathComponent(self.str_pdf_name)
//        
//        if FileManager.default.fileExists(atPath: fileURL.path) {
//            // ✅ File already exists → Open directly
//            print("📂 PDF already exists, loading from local")
//            self.moveReportScreen(pdf_fileURL: fileURL)
//        } else {
//            // ❌ File not found → Generate new PDF
//            print("🆕 Generating new PDF")
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                self.exportToPDF()
//            }
//        }
//    }
    
    // MARK: - Export to PDF
    func exportToPDF() {
        let config = WKPDFConfiguration()
        
        self.webView_iPad.createPDF(configuration: config) { result in
            switch result {
            case .success(let data):
                // Save PDF in Documents
                let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let fileURL = docPath.appendingPathComponent(self.str_pdf_name)

                do {
                    
                    // ✅ Remove old file if exists
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        try FileManager.default.removeItem(at: fileURL)
                        print("🗑 Old PDF removed: \(fileURL)")
                    }
                    
                    try data.write(to: fileURL)
                    print("✅ PDF Saved at: \(fileURL)")
                    self.moveReportScreen(pdf_fileURL: fileURL)
                    
                } catch {
                    print("❌ Failed to save PDF: \(error.localizedDescription)")
                    Utils.showAlertOkController(title: "", message: "Failed to load PDF", buttons: ["Ok"]) { success in
                    }
                }

            case .failure(let error):
                print("❌ Failed to create PDF: \(error.localizedDescription)")
                Utils.showAlertOkController(title: "", message: "Failed to load PDF", buttons: ["Ok"]) { success in
                }
            }
        }
    }
    
    func moveReportScreen(pdf_fileURL: URL? = nil) {
        DismissProgressHud()
//        let editorVC = PDFEditorViewController()
//        editorVC.documentURL = pdf_fileURL
//        editorVC.strFileName = self.str_pdf_name
//        let nav = UINavigationController(rootViewController: editorVC)
//        nav.modalPresentationStyle = .fullScreen
//        self.present(nav, animated: true)
        
        
        let vc = ReportVC.instantiate(fromAppStoryboard: .Assessment)
        vc.documentURL = pdf_fileURL
        vc.screenFrom = .direct_back
        vc.str_reportLink = pdf_fileURL?.absoluteString ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
