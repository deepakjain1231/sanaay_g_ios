//
//  HomeVC.swift
//  Sanaay
//
//  Created by Deepak Jain on 18/08/22.
//

import UIKit

class HomeVC: UIViewController {

    var arr_OpenIndx = [Int]()
    var arr_filter = [[String: Any]]()
    var arr_Data = [PatientListDataResponse?]()
    var arr_AllData = [PatientListDataResponse?]()
    var is_Search_Open = false
    var int_selected_Indx = 0
    @IBOutlet weak var view_SearchBG: UIView!
    @IBOutlet weak var view_NoData: UIView!
    @IBOutlet weak var txt_SearchBar: UISearchBar!
    @IBOutlet weak var tbl_view: UITableView!
    @IBOutlet weak var lbl_appointments: UILabel!
    @IBOutlet weak var btn_appointments: UIButton!
    @IBOutlet weak var collection_view: UICollectionView!
    @IBOutlet weak var view_Top_Header: UIView!
    @IBOutlet weak var constraint_collection_Height: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_Search_HEIGHT: NSLayoutConstraint!
    private let viewModel: RegisterViewModel = RegisterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view_NoData.isHidden = true
        self.view_Top_Header.isHidden = true
        if #available(iOS 15.0, *) {
            self.tbl_view.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        
        //Register Table Cell
        self.tbl_view.register(nibWithCellClass: AppointmentHomeTableCell.self)
        self.collection_view.register(UINib(nibName: "HomeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionCell")
        
        self.manageSection()
        
        let dateformaater = DateFormatter()
        dateformaater.dateFormat = "dd-MM-yyyy"
        let str_Date = dateformaater.string(from: Date())
        self.callAPIforGetAppointment(str_date: str_Date)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func closeSearchBar() {
        UIView.animate(withDuration: 0.3, delay: 0.2, options: UIView.AnimationOptions.curveEaseInOut) {
            self.constraint_view_Search_HEIGHT.constant = 0
        } completion: { successs in
            self.is_Search_Open = false
            self.view.endEditing(true)
        }
    }

    // MARK: - UIButton Action
    @IBAction func btn_Menu_Action(_ sender: UIButton) {
        self.view.endEditing(true)
        if let parent = appDelegate.window?.rootViewController {
            let objMenu = Story_Dashboard.instantiateViewController(withIdentifier: "LeftSideMenuVC") as? LeftSideMenuVC
            objMenu?.superViewVC = self
            parent.addChild(objMenu!)
            parent.view.addSubview((objMenu?.view)!)
            objMenu?.didMove(toParent:  parent)
        }
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
            self.closeSearchBar()
        }
    }
    
    @IBAction func btn_AddNewPatient_Action(_ sender: UIControl) {
        let obj = Story_Dashboard.instantiateViewController(withIdentifier: "AddPatientVC") as! AddPatientVC
        
        //let obj = SelectAggaravationVC.instantiate(fromAppStoryboard: .Assessment)
        //let obj = ReportVC.instantiate(fromAppStoryboard: .Assessment)
        //let obj = Story_Dashboard.instantiateViewController(withIdentifier: "AddHealthComplainVC") as! AddHealthComplainVC
        //let obj = PredictedPrakritiVC.instantiate(fromAppStoryboard: .Dashboard)
        self.navigationController?.pushViewController(obj, animated: true)
        
        
    }
    
    
    @IBAction func btn_Add_Action(_ sender: UIButton) {
        let obj = Story_Dashboard.instantiateViewController(withIdentifier: "PatientListVC") as! PatientListVC
        self.navigationController?.pushViewController(obj, animated: true)
    }
    

}

//MARK: - UITableView Delegste Datasourcr Method
extension HomeVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Data.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withClass: AppointmentHomeTableCell.self, for: indexPath)
        cell.selectionStyle = .none
        
        let dicDetail = self.arr_Data[indexPath.row]
        cell.lbl_Name.text = dicDetail?.patient_name ?? ""
        cell.lbl_Time.text = dicDetail?.appointment_time ?? ""
        cell.btn_Download.isHidden = (dicDetail?.report_link ?? "") == "" ? true : false
        
        if let indx = self.arr_OpenIndx.firstIndex(where: { int_indx in
            return int_indx == indexPath.row
        }) {
            cell.view_ButtonBG.isHidden = false
            cell.constraint_view_ButtonBG_Top.constant = 18
        }
        else {
            cell.view_ButtonBG.isHidden = true
            cell.constraint_view_ButtonBG_Top.constant = 8
        }
        
        
        cell.didTappedonReschedule = { (sender) in
            let vc = ScheduleAppoinmentVC.instantiate(fromAppStoryboard: .Dashboard)
            vc.str_patientID = dicDetail?.patient_id ?? ""
            vc.dic_response = dicDetail
            vc.screenForm = .rescheduleAppointment
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        cell.didTappedonRetest = { (sender) in
            let vc = AddHealthComplainVC.instantiate(fromAppStoryboard: .Dashboard)
            vc.screenFrom = .retest_now
            vc.str_patientID = dicDetail?.patient_id ?? ""
            vc.dic_response = dicDetail
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indx = self.arr_OpenIndx.firstIndex(where: { int_indx in
            return int_indx == indexPath.row
        }) {
            self.arr_OpenIndx.remove(at: indx)
        }
        else {
            self.arr_OpenIndx.append(indexPath.row)
        }
        self.tbl_view.reloadRows(at: [indexPath], with: .fade)
    }
    
}

//MARK: - UISearch Deleggate
extension HomeVC: UISearchBarDelegate {
    
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        self.arr_Data = searchText.isEmpty ? self.arr_AllData : self.arr_AllData.filter({ dic_data in
            return (dic_data?.patient_name ?? "").range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        //self.view_NoData.isHidden = self.arr_Data.count == 0 ? false : true
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
}


//MARK: - API CALL
extension HomeVC {
    
    func callAPIforGetAppointment(str_date: String) {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            
            let params = ["searchdate": str_date]
            
            self.viewModel.getAppointmentList_API(body: params, endpoint: APIEndpoints.AppointmentList) { status, result, error in
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
                        self.view_NoData.isHidden = self.arr_Data.count == 0 ? false : true
                        self.view_Top_Header.isHidden = self.arr_Data.count == 0 ? true : false
                        self.tbl_view.reloadData()
                        
                    }
                    else {
                        guard let msgg = result?.message else {
                            return
                        }
                        self.arr_Data.removeAll()
                        self.tbl_view.reloadData()
                        self.view_NoData.isHidden = false
                        self.view_Top_Header.isHidden = true
                        //self.view.makeToast(msgg)
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

//MARK: - UICollection View Delegate DataSource Method
extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func manageSection() {
        self.arr_filter.removeAll()
        
        let date_formatter = DateFormatter()
        date_formatter.dateFormat = "dd/MM/yyyy"
        
        date_formatter.dateFormat = "dd-MM-yyyy"
        let str_Date = date_formatter.string(from: Date())
        
        self.arr_filter.append(["title": "Today", "api_date": str_Date])
        
        let modifiedDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        date_formatter.dateFormat = "dd-MM-yyyy"
        let str_Tomorrow_Date = date_formatter.string(from: modifiedDate)
        
        self.arr_filter.append(["title": "Tomorrow", "api_date": str_Tomorrow_Date])
        
        for i in 1...5 {
            let modified_NewDate = Calendar.current.date(byAdding: .day, value: i, to: modifiedDate)!
            date_formatter.dateFormat = "dd/MM/yyyy"
            let str_Title_Date = date_formatter.string(from: modified_NewDate)
            date_formatter.dateFormat = "dd-MM-yyyy"
            let str_API_Date = date_formatter.string(from: modified_NewDate)
            
            self.arr_filter.append(["title": str_Title_Date, "api_date": str_API_Date])
        }
        
        self.collection_view.reloadData()
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arr_filter.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionCell", for: indexPath) as! HomeCollectionCell
        
        cell.lbl_Title.text = self.arr_filter[indexPath.item]["title"] as? String ?? ""
        
        if self.int_selected_Indx == indexPath.row {
            cell.lbl_Title.textColor = .white
            cell.view_Base.backgroundColor = AppColor.app_GreenColor
        }
        else {
            cell.lbl_Title.textColor = AppColor.app_GreenColor
            cell.view_Base.backgroundColor = UIColor.clear
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let strText = self.arr_filter[indexPath.item]["title"] as? String ?? ""
        var getWidth = strText.widthOfString(usingFont: UIFont.AppFontRegular(14))
        getWidth = getWidth + 25
        return CGSize.init(width: getWidth, height: self.collection_view.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.int_selected_Indx = indexPath.row
        let str_Date = self.arr_filter[indexPath.item]["api_date"] as? String ?? ""
        self.collection_view.reloadData()
        self.callAPIforGetAppointment(str_date: str_Date)
    }
}
