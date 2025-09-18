//
//  PatientHistoryVC.swift
//  SaNaay
//
//  Created by DEEPAK JAIN on 22/07/24.
//

import UIKit
import Alamofire
import SafariServices
import WebKit

class PatientHistoryVC: UIViewController, WKNavigationDelegate, SFSafariViewControllerDelegate, WKUIDelegate {
    
    var pateitnID = ""
    var str_pdf_name = ""
    var arr_Data = [PatientListDataResponse?]()
    @IBOutlet weak var tbl_view: UITableView!
    @IBOutlet weak var view_SearchBG: UIView!
    @IBOutlet weak var txt_SearchBar: UISearchBar!
    @IBOutlet weak var view_NoDataBG: UIView!
    @IBOutlet weak var btn_EditPatient: UIButton!
    @IBOutlet weak var btn_EditPrakriti: UIControl!
    @IBOutlet weak var constraint_view_Search_HEIGHT: NSLayoutConstraint!
    
    @IBOutlet weak var webView_iPad: WKWebView!
    private let viewModel: RegisterViewModel = RegisterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view_NoDataBG.isHidden = true
        //self.btn_EditPatient.isHidden = true
        
        
        //Register Table Cell
        self.tbl_view.register(nibWithCellClass: patientlistTableCell.self)
        
        self.callAPIforPatientHistoryList()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_bookAppointment_Action(_ sender: UIButton) {
        let vc = ScheduleAppoinmentVC.instantiate(fromAppStoryboard: .Dashboard)
        vc.str_patientID = self.pateitnID
        vc.dic_response = appDelegate.dic_patient_response
        vc.screenForm = .bookappointment
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_retest_Now_Action(_ sender: UIButton) {
        let vc = AddHealthComplainVC.instantiate(fromAppStoryboard: .Dashboard)
        vc.screenFrom = .retest_now
        vc.str_patientID = self.pateitnID
        vc.dic_response = appDelegate.dic_patient_response
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btn_Edit_Patient_Action(_ sender: UIButton) {
        let obj = Story_Dashboard.instantiateViewController(withIdentifier: "AddPatientVC") as! AddPatientVC
        obj.screenFrom = ScreenType.edit_patient
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func btn_Edit_Prakriti_Action(_ sender: UIButton) {
        let obj = EditPrakritiVC.instantiate(fromAppStoryboard: .Assessment)
        
        //let obj = Story_Assessment.instantiateViewController(withIdentifier: "PrakritiQuestionVC") as! PrakritiQuestionVC
        //obj.screenFrom = ScreenType.edit_prakriti
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    
    func doneClicked_Action(_ isClicked: Bool, fromScreen: ScreenType, str_type: String) {
        
    }
    
}

    //MARK: - API CALL
extension PatientHistoryVC {
    
    func callAPIforPatientHistoryList() {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            
            let params = ["patient_id": self.pateitnID]
            
            self.viewModel.getPatientList_API(body: params, endpoint: APIEndpoints.patient_history) { status, result, error in
                switch status {
                case .loading:
                    break
                case .success:
                    DismissProgressHud()
                    if result?.status == "success" {
                        guard let dataaa = result?.data else {
                            return
                        }
                        debugPrint(dataaa)
                        self.arr_Data = dataaa
                        self.view_NoDataBG.isHidden = self.arr_Data.count == 0 ? false : true
                        self.tbl_view.reloadData()
                        
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
}

    //MARK: - UITableView Delegste Datasourcr Method
extension PatientHistoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "patientlistTableCell", for: indexPath) as! patientlistTableCell
        cell.selectionStyle = .none
        cell.btn_delete.isHidden = true
        
        let dic_detail = self.arr_Data[indexPath.row]
        cell.lbl_Name.text = dic_detail?.patient_name ?? ""
        cell.lbl_Aggravation.text = (dic_detail?.vikriti ?? "-") == "" ? "-" : dic_detail?.vikriti ?? "-"
        cell.lbl_LastVisited.text = "Last visited at \(dic_detail?.visit_time ?? "")"
        
        let straggravition = dic_detail?.vikriti ?? ""
        
        if straggravition.lowercased() == "pitta" {
            cell.img_Aggravation.image = UIImage.init(named: "icon_pitta")
            cell.view_Aggravation_BG.backgroundColor = UIColor.init(hex: "FFEEC3")
        }
        else if straggravition.lowercased() == "vata" {
            cell.img_Aggravation.image = UIImage.init(named: "icon_vata")
            cell.view_Aggravation_BG.backgroundColor = UIColor.init(hex: "D0DFFF")
        }
        else {
            cell.img_Aggravation.image = UIImage.init(named: "icon_kapha")
            cell.view_Aggravation_BG.backgroundColor = (dic_detail?.vikriti ?? "-") == "" ? UIColor.clear : UIColor.init(hex: "E8FFB4")
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let str_report = self.arr_Data[indexPath.row]?.report_link ?? ""

        if str_report != "" {
            let arr_pdfname = str_report.components(separatedBy: "/")
            self.str_pdf_name = "sanaay_report_\(arr_pdfname.last ?? "1").pdf"
            
            
            ShowProgressHud(message: AppMessage.plzWait)
            self.webView_iPad.uiDelegate = self
            self.webView_iPad.navigationDelegate = self
            self.webView_iPad.accessibilityValue = str_report
            if let url = URL(string: str_report) {
                let request = URLRequest(url: url)
                self.webView_iPad.load(request)
            }
            else {
                DismissProgressHud()
            }
        }
        else {
            self.view.makeToast("Something went wrong please retest again")
        }
        
    }
    
    //MARK: - WEB VIEW DELEGATE
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0) {
//            DismissProgressHud()
//            
//            let vc = ReportVCNew.instantiate(fromAppStoryboard: .Assessment)
//            vc.str_reportLink = self.webView_iPad.accessibilityValue ?? ""
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        // Export after a short delay (wait for JS/CSS to finish)
        //DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            self.handleReportLoading()
        //}
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.exportToPDF()
        }
        
    }
    
    private func handleReportLoading() {
        let docPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = docPath.appendingPathComponent(self.str_pdf_name)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            // ✅ File already exists → Open directly
            print("📂 PDF already exists, loading from local")
            self.moveReportScreen(pdf_fileURL: fileURL)
        } else {
            // ❌ File not found → Generate new PDF
            print("🆕 Generating new PDF")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.exportToPDF()
            }
        }
    }
    
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
        vc.str_reportLink = pdf_fileURL?.absoluteString ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    
    func AlertDeletePatient(patient_id: String) {
        let alert = UIAlertController.init(title: "Delete Patient", message: "", preferredStyle: UIAlertController.Style.alert)
        
        let attributedMessage = NSMutableAttributedString(string: "\nAre you sure, you want to delete this patient?", attributes: [NSAttributedString.Key.font: UIFont.AppFontMedium(16)])
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        
        let actionCancel = UIAlertAction.init(title: "No", style: UIAlertAction.Style.cancel, handler: { (action) in
            self.dismiss(animated: true)
        })
        
        let actionOK = UIAlertAction.init(title: "Yes", style: UIAlertAction.Style.destructive, handler: { (action) in
            self.callAPIforDeletePatient(patientid: patient_id)
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
    
    func callAPIforDeletePatient(patientid: String) {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            
            let urlString = BASE_URL +  APIEndpoints.DeletePatientInfo.rawValue
            
            let param = ["patient_id": patientid] as [String : Any]
            
            
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
                    
                    let str_status = dicResponse["status"] as? String ?? ""
                    if str_status == "success" {
                        if let indx = self.arr_Data.firstIndex(where: { dic_patient in
                            return (dic_patient?.patient_id ?? "") == patientid
                        }) {
                            self.arr_Data.remove(at: indx)
                        }
                        self.tbl_view.reloadData()
                        
                    }
                    
                    DispatchQueue.main.async(execute: {
                        DismissProgressHud()
                    })
                    
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


