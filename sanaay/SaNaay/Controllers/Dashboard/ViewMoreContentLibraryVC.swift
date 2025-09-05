//
//  ViewMoreContentLibraryVC.swift
//  SaNaay
//
//  Created by DEEPAK JAIN on 15/07/24.
//

protocol delegate_selection {
    func did_select_data(_ success: Bool, selected_value: [String: Any], selected_type: RegistationKey)
}


import UIKit

class ViewMoreContentLibraryVC: UIViewController {

    var delegate: delegate_selection?
    var dic_Value = [String: Any]()
    
    var str_navTitle = ""
    var aggrivation = ""
    var int_patientID = ""
    var str_Type: RegistationKey = .other
    var dataSource = [Suggestion_Data]()
    var arr_Data: ContentLibraryDataResponse?
    private let viewModel: RegisterViewModel = RegisterViewModel()
    
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var tbl_View: UITableView!
    @IBOutlet weak var btn_Save: UIControl!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setTitle()
        
        
        if #available(iOS 15.0, *) {
            self.tbl_View.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        //Register Table cell
        self.tbl_View.register(nibWithCellClass: HeaderTitleTableCell.self)
        self.tbl_View.register(nibWithCellClass: KriyaMudraDataTableCell.self)
        self.callAPIforViewMoreContentLibrary()
    }
    
    func setTitle() {
        if self.str_Type == .breakfast_food {
            self.str_navTitle = "Breakfast"
        }
        else if self.str_Type == .lunch_food {
            self.str_navTitle = "Lunch"
        }
        else if self.str_Type == .dinner_food {
            self.str_navTitle = "Dinner"
        }
        else {
            self.str_navTitle = self.str_Type.rawValue.capitalized
        }
        self.lbl_Title.text = self.str_navTitle
    }
    
    //MARK: - API Call
    
    func callAPIforViewMoreContentLibrary() {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            
            var params = ["language_id": "1",
                          "type": self.aggrivation,
                          "patient_id": self.int_patientID,
                          "content_type": self.str_Type.rawValue] as [String : Any]
            
            if self.str_Type == .breakfast_food || self.str_Type == .lunch_food || self.str_Type == .dinner_food {
                params["content_type"] = "food"
            }
    
            self.viewModel.getContent_Data_API(body: params, endpoint: APIEndpoints.ViewMoreContentLibrary) { status, result, error in
                switch status {
                case .loading:
                    break
                case .success:
                    DismissProgressHud()
                    if result?.status == "success" {
                        guard let dataaa = result?.data else {
                            return
                        }
                        self.arr_Data = dataaa
                        self.manageSection()
                    }
                    else {
                        guard let msgg = result?.message else {
                            return
                        }
                        self.view.makeToast(msgg)
                        self.tbl_View.reloadData()
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
    
    @IBAction func btn_save_Action(_ sender: UIButton) {
        self.delegate?.did_select_data(true, selected_value: self.dic_Value, selected_type: self.str_Type)
        self.navigationController?.popViewController(animated: true)
    }
}


//MARK: - UITableView Delegate Datasource Method

extension ViewMoreContentLibraryVC: UITableViewDelegate, UITableViewDataSource {
    
    func manageSection() {
        self.dataSource.removeAll()
        
        var str_title = ""
        var str_Key = RegistationKey.other
        var str_Type = D_RegisterFieldType.other
        
        if self.str_Type == .breakfast_food {
            str_title = "Breakfast"
            str_Key = .breakfast_food
            str_Type = .breakfast_food
        }
        else if self.str_Type == .lunch_food {
            str_title = "Lunch"
            str_Key = .lunch_food
            str_Type = .lunch_food
        }
        else if self.str_Type == .dinner_food {
            str_title = "Dinner"
            str_Key = .dinner_food
            str_Type = .dinner_food
        }
        else {
            str_title = self.str_navTitle
        }


        if let dic_inner = self.arr_Data {
            
            self.dataSource.append(Suggestion_Data.init(key: .other, title: "Suggested \(str_title)", placeholder: "", type: .other, identifier: .single_header))
            
            if let indx_food = self.arr_Data?.food?.firstIndex(where: { dic_food in
                return (dic_food?.section?[0]?.subsection ?? "").lowercased() == str_title.lowercased()
            }) {
                if let arr_food = self.arr_Data?.food?[indx_food]?.section?[0]?.data {
                    
                    for inner in arr_food {
                        self.dataSource.append(Suggestion_Data.init(key: str_Key, title: inner?.name, placeholder: "", type: str_Type, identifier: .recommendations_value, favid: ""))
                        //
                        guard let str_SelectedName = inner?.name else { return }
                        self.selection_default(name: str_SelectedName, key: str_Key)
                        //
                    }
                }
            }
            
            if let arr_yogasana = self.arr_Data?.yogasana {
                for inner in arr_yogasana {
                    self.dataSource.append(Suggestion_Data.init(key: .yogasana, title: inner?.name, placeholder: "", type: .yogasana, identifier: .recommendations_value, favid: inner?.favorite_id ?? ""))
                    
                    //
                    guard let str_SelectedName = inner?.name else { return }
                    self.selection_default(name: str_SelectedName, key: .yogasana)
                    //
                }
            }
            
            
            if let arr_meditation = self.arr_Data?.meditation {
                for inner in arr_meditation {
                    self.dataSource.append(Suggestion_Data.init(key: .meditation, title: inner?.name, placeholder: "", type: .meditation, identifier: .recommendations_value, favid: inner?.favorite_id ?? ""))
                    
                    //
                    guard let str_SelectedName = inner?.name else { return }
                    self.selection_default(name: str_SelectedName, key: .meditation)
                    //
                }
                
            }
            
            if let arr_pranayam = self.arr_Data?.pranayam {
                for inner in arr_pranayam {
                    self.dataSource.append(Suggestion_Data.init(key: .pranayam, title: inner?.name, placeholder: "", type: .pranayam, identifier: .recommendations_value, favid: inner?.favorite_id ?? ""))
                    
                    //
                    guard let str_SelectedName = inner?.name else { return }
                    self.selection_default(name: str_SelectedName, key: .pranayam)
                    //
                }
            }
            
            if let arr_kriya = self.arr_Data?.kriya {
                for inner in arr_kriya {
                    self.dataSource.append(Suggestion_Data.init(key: .kriya, title: inner?.name, placeholder: "", type: .kriya, identifier: .recommendations_value, favid: inner?.favorite_id ?? ""))
                    
                    //
                    guard let str_SelectedName = inner?.name else { return }
                    self.selection_default(name: str_SelectedName, key: .kriya)
                    //
                    
                }
            }
            
            
            if let arr_mudra = self.arr_Data?.mudra {
                for inner in arr_mudra {
                    self.dataSource.append(Suggestion_Data.init(key: .mudra, title: inner?.name, placeholder: "", type: .mudra, identifier: .recommendations_value, favid: inner?.favorite_id ?? ""))
                    
                    //
                    guard let str_SelectedName = inner?.name else { return }
                    self.selection_default(name: str_SelectedName, key: .mudra)
                    //
                }
                
                
            }
            
            
            if let arr_panchkarma = self.arr_Data?.panchkarma {
                for inner in arr_panchkarma {
                    self.dataSource.append(Suggestion_Data.init(key: .panchkarma_suggestions, title: inner?.name, placeholder: "", type: .panchkarma, identifier: .recommendations_value, favid: inner?.favorite_id ?? ""))
                    
                    //
                    guard let str_SelectedName = inner?.name else { return }
                    self.selection_default(name: str_SelectedName, key: .panchkarma_suggestions)
                    //
                }
            }
        }
        
        self.dataSource.append(Suggestion_Data.init(key: .other, title: "Submit", placeholder: "", type: .other, identifier: .button))
        self.tbl_View.reloadData()
    }

    func selection_default(name: String, key: RegistationKey = .other) {
        if let arr_SelectedValue = self.dic_Value[key.rawValue] as? [String] {
            var arr_sValue = arr_SelectedValue
            if let indx = arr_sValue.firstIndex(of: name) {
            }
            else {
                arr_sValue.append(name)
            }
            self.dic_Value[key.rawValue] = arr_sValue
        }
        else {
            let arr_sValue = [name]
            self.dic_Value[key.rawValue] = arr_sValue
        }
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

        if identifierType == .single_header {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderTitleTableCell", for: indexPath) as! HeaderTitleTableCell
            cell.selectionStyle = .none
            cell.lbl_Title.text = str_title
            
            return cell
        }
        else if identifierType == .recommendations_value {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "KriyaMudraDataTableCell", for: indexPath) as! KriyaMudraDataTableCell
            cell.selectionStyle = .none
            cell.view_Base.layer.borderWidth = 1
            cell.view_Base.layer.cornerRadius = 12
            cell.view_Base.layer.borderColor = UIColor.init(hex: "EEEEEE").cgColor
            
            cell.constraint_view_Base_bottom.constant = 8
            cell.constraint_view_Base_leaing.constant = 20
            cell.constraint_view_Base_trelling.constant = 20
            cell.constraint_lbl_Title_leading.constant = 20
            cell.constraint_lbl_Title_trelling.constant = 20
            
            let str_Title = self.dataSource[indexPath.row].title ?? ""
            cell.lbl_Title.text = str_Title
            
            if let arr_SelectedValue = self.dic_Value[str_key.rawValue] as? [String] {
                let arr_sValue = arr_SelectedValue
                if let indx = arr_sValue.firstIndex(of: str_Title) {
                    cell.img_icon.image = UIImage.init(named: "icon_selected")
                }
                else {
                    cell.img_icon.image = UIImage.init(named: "icon_unselected")
                }
            }
            else {
                cell.img_icon.image = UIImage.init(named: "icon_unselected")
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = self.dataSource[indexPath.row].key ?? RegistationKey.other
        let identifierType = self.dataSource[indexPath.row].identifier
    
        if identifierType == .recommendations_value {
            guard let currentCell = self.tbl_View.cellForRow(at: indexPath) as? KriyaMudraDataTableCell else {
                return
            }
            guard let str_SelectedTitle = self.dataSource[indexPath.row].title else { return }
            if let arr_SelectedValue = self.dic_Value[type.rawValue] as? [String] {
                var arr_sValue = arr_SelectedValue
                if let indx = arr_sValue.firstIndex(of: str_SelectedTitle) {
                    arr_sValue.remove(at: indx)
                    currentCell.img_icon.image = UIImage.init(named: "icon_unselected")
                }
                else {
                    arr_sValue.append(str_SelectedTitle)
                    currentCell.img_icon.image = UIImage.init(named: "icon_selected")
                }
                self.dic_Value[type.rawValue] = arr_sValue
            }
            else {
                let arr_sValue = [str_SelectedTitle]
                self.dic_Value[type.rawValue] = arr_sValue
                currentCell.img_icon.image = UIImage.init(named: "icon_selected")
            }
        }
    }
}
