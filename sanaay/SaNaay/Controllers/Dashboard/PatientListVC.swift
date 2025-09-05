//
//  PatientListVC.swift
//  Sanaay
//
//  Created by Deepak Jain on 18/08/22.
//

import UIKit
import Alamofire

class PatientListVC: UIViewController, delegateDoneAction {

    var pateitnID = ""
    var is_Search_Open = false
    var is_update_details = false
    var arr_Data = [PatientListDataResponse?]()
    var arr_All_Data = [PatientListDataResponse?]()
    @IBOutlet weak var tbl_view: UITableView!
    @IBOutlet weak var view_SearchBG: UIView!
    @IBOutlet weak var txt_SearchBar: UISearchBar!
    @IBOutlet weak var view_NoDataBG: UIView!
    @IBOutlet weak var constraint_view_Search_HEIGHT: NSLayoutConstraint!
    
    private let viewModel: RegisterViewModel = RegisterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view_NoDataBG.isHidden = true
        
        
        //Register Table Cell
        self.tbl_view.register(nibWithCellClass: patientlistTableCell.self)
        
        self.callAPIforPatientList()
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
    
    @IBAction func btn_Search_Action(_ sender: UIButton) {
        if self.is_Search_Open == false {
            UIView.animate(withDuration: 0.3, delay: 0.2, options: UIView.AnimationOptions.curveEaseInOut) {
                self.constraint_view_Search_HEIGHT.constant = 50
            } completion: { successs in
                self.is_Search_Open = true
            }
        }
        else {
            UIView.animate(withDuration: 0.3, delay: 0.2, options: UIView.AnimationOptions.curveEaseInOut) {
                self.constraint_view_Search_HEIGHT.constant = 0
            } completion: { successs in
                self.is_Search_Open = false
            }
        }
    }
    
    func doneClicked_Action(_ isClicked: Bool, fromScreen: ScreenType, str_type: String) {
        
    }
    
    
    @IBAction func btn_AddNewPatient_Action(_ sender: UIControl) {
        let obj = Story_Dashboard.instantiateViewController(withIdentifier: "AddPatientVC") as! AddPatientVC
        self.navigationController?.pushViewController(obj, animated: true)
    }
}

//MARK: - API CALL
extension PatientListVC {
    
    func callAPIforPatientList() {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            
            self.viewModel.getPatientList_API(body: nil, endpoint: APIEndpoints.patient_list) { status, result, error in
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
                        self.arr_All_Data = dataaa
                        self.view_NoDataBG.isHidden = self.arr_Data.count == 0 ? false : true
                        self.tbl_view.reloadData()
                        
                        if self.is_update_details {
                            if let indx = self.arr_All_Data.firstIndex(where: { response_patient in
                                return (response_patient?.patient_id ?? "") == (appDelegate.dic_patient_response?.patient_id ?? "")
                            }) {
                                appDelegate.dic_patient_response = self.arr_All_Data[indx]
                            }
                        }
                        
                    }
                    else {
                        guard let msgg = result?.message else {
                            return
                        }
                        //self.view.makeToast(msgg)
                        self.arr_Data.removeAll()
                        self.arr_All_Data.removeAll()
                        self.view_NoDataBG.isHidden = self.arr_Data.count == 0 ? false : true
                        self.tbl_view.reloadData()
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
extension PatientListVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "patientlistTableCell", for: indexPath) as! patientlistTableCell
        cell.selectionStyle = .none
        
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
            cell.view_Aggravation_BG.backgroundColor = UIColor.init(hex: "E8FFB4")
        }
        
        
        //Button Action
        cell.didTappedonDelete = { (sender) in
            self.AlertDeletePatient(patient_id: dic_detail?.patient_id ?? "")
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        appDelegate.dic_patient_response = self.arr_Data[indexPath.row]
        
        //appDelegate.dic_patient_response?.prakriti_ml_reg = "[20, 30, 50]"
        
//        let vc = PredictedPrakritiVC.instantiate(fromAppStoryboard: .Dashboard)
//        vc.str_patientID = self.arr_Data[indexPath.row]?.patient_id ?? ""
//        vc.dic_response = appDelegate.dic_patient_response
//        self.navigationController?.pushViewController(vc, animated: true)
        
        
        
        let vc = PatientHistoryVC.instantiate(fromAppStoryboard: .Dashboard)
        vc.pateitnID = self.arr_Data[indexPath.row]?.patient_id ?? ""
        self.navigationController?.pushViewController(vc, animated: true)
        
        
        
//        let vc = AddHealthComplainVC.instantiate(fromAppStoryboard: .Dashboard)
//        vc.screenFrom = .patient_Detail
//        vc.str_patientID = self.arr_Data[indexPath.row]?.patient_id ?? ""
//        vc.dic_response = appDelegate.dic_patient_response
//        self.navigationController?.pushViewController(vc, animated: true)
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

//MARK: - UISearch Deleggate
extension PatientListVC: UISearchBarDelegate {
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        self.arr_Data = searchText.isEmpty ? self.arr_All_Data : self.arr_All_Data.filter({ dic_data in
            return (dic_data?.patient_name ?? "").range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        self.view_NoDataBG.isHidden = self.arr_Data.count == 0 ? false : true
        self.tbl_view.reloadData()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if (searchBar.text ?? "") == "" {
            self.view.endEditing(true)
            self.closeSearchBar()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    }
    
    func closeSearchBar() {
        UIView.animate(withDuration: 0.3, delay: 0.2, options: UIView.AnimationOptions.curveEaseInOut) {
            self.constraint_view_Search_HEIGHT.constant = 0
        } completion: { successs in
            self.is_Search_Open = false
            self.view.endEditing(true)
        }
    }
}
