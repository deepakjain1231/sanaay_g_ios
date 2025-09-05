//
//  LeftSideMenuVC.swift
//  Cotasker
//
//  Created by Zignuts Technolab on 01/11/19.
//  Copyright © 2019 Pearl Inc. All rights reserved.
//

import UIKit
import SDWebImage


class LeftSideMenuVC: UIViewController {
    
    var superViewVC: UIViewController?
    @IBOutlet weak var viewMainBG: UIView!
    @IBOutlet weak var viewNavigationBG: UIView!
    @IBOutlet weak var viewInnerBG: UIView!
    @IBOutlet weak var tblView: UITableView!
    var arrSections:[[String:Any?]] = [[String:Any?]]()

    private let viewModel: RegisterViewModel = RegisterViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tblView.backgroundColor = UIColor.clear
        self.viewMainBG.frame = CGRect.init(x: -screenWidth, y: 0, width: screenWidth - 100, height: screenHeight)

        var TopAreHeight: CGFloat = 20
        if #available(iOS 11.0, *) {
            TopAreHeight = (appDelegate.window?.safeAreaInsets.top)!
            if TopAreHeight == 0 {
                TopAreHeight = TopAreHeight + 20
            }
        }
        
        self.tblView.isHidden = true
        self.viewNavigationBG.frame = CGRect.init(x: 0, y: TopAreHeight, width: screenWidth - 100, height: 15)
        self.viewInnerBG.frame = CGRect.init(x: 0, y: (TopAreHeight + 15), width: screenWidth - 100, height: (screenHeight - (TopAreHeight + 15)))
        self.tblView.frame = CGRect.init(x: 0, y: 0, width: screenWidth - 100, height: (screenHeight - (TopAreHeight + 15)))
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
        
        //Register Table Cell=============================================================//
        //Register Table cell
        self.tblView.register(nibWithCellClass: SideMenuHeaderTableCell.self)
        self.tblView.register(nibWithCellClass: SideMenuTableCell.self)
        //================================================================================//
        
        self.manageSections()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tblView.reloadData()
    }
        
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.viewMainBG.frame = CGRect.init(x: 0, y: 0, width: screenWidth - 100, height: screenHeight)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
                self.tblView.isHidden = false
            })
            self.view.layoutIfNeeded()
        }) { (success) in
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
    
    
    func removeFromParent(_isClickIndex: Bool, completion: @escaping ((Bool) -> Void)) {
        UIView.animate(withDuration: 0.3, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.viewMainBG.frame = CGRect.init(x: -screenWidth, y: 0, width: screenWidth, height: screenHeight)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                self.tblView.isHidden = true
            })
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            completion(_isClickIndex)
        }
    }
    
    
    // MARK: - UIButton Action
    @IBAction func clkToCloseMenu_Action(_ sender: UIButton) {
        self.removeFromParent(_isClickIndex: false, completion: { (animate) in
        })
    }
    
}

// MARK: - UITableView Delegate Datasource Method
extension LeftSideMenuVC: UITableViewDelegate, UITableViewDataSource {
    
    func manageSections() {
        arrSections.removeAll()
        arrSections.append(["key":"profile_Header", "title":"Profile", "img": "", "type": "profile"])
        arrSections.append(["key":"home", "title":"Home", "img": "icon_home", "type": "label"])
        
        arrSections.append(["key":"edit_clinic", "title":"Edit Clinic", "img": "icon_edit_clinic", "type": "label"])
        arrSections.append(["key":"patient", "title":"Patient list", "img": "icon_list", "type": "label"])
        
        //arrSections.append(["key":"appointment", "title":"Appointment", "img": "icon_notification", "type": "label"])
        
        
        //arrSections.append(["key":"change_language", "title":"Change Language", "img": "", "type": "normal_label"])
        arrSections.append(["key":"help", "title":"Help", "img": "", "type": "normal_label"])
        arrSections.append(["key":"contact_us", "title":"Contact us", "img": "", "type": "normal_label"])
        arrSections.append(["key":"about_us", "title":"About us", "img": "", "type": "normal_label"])
        
        arrSections.append(["key":"delete_account", "title":"Delete Account", "img": "icon_remove_user", "type": "normal_label"])
        arrSections.append(["key":"logout", "title":"Logout", "img": "icon_logout", "type": "normal_label"])
        self.tblView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrSections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let sectionDetail = arrSections[indexPath.row]
        let strKey = sectionDetail["key"] as? String ?? ""
        let strTitle = sectionDetail["title"] as? String ?? ""
        let str_Type = sectionDetail["type"] as? String ?? ""
        
        if str_Type == "profile" {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuHeaderTableCell") as! SideMenuHeaderTableCell
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            cell.lbl_Title.text = getUserDetail()?.doctor_name ?? ""
            cell.lbl_subTitle.text = getUserDetail()?.doctor_email ?? ""
            
            let strImgIcon = getUserDetail()?.doctor_icon ?? ""
            cell.img_profile.sd_setImage(with: URL.init(string: strImgIcon), placeholderImage: UIImage.init(named: "icon_default"), progress: nil)

            
            cell.didTappedonEditProfile = { (sender) in
                //Go To Edit Screen
                let obj = Story_Main.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
                self.superViewVC?.navigationController?.pushViewController(obj, animated: true)
                self.removeFromParent(_isClickIndex: true) { (animated) in
                }
            }
            
            return cell
        }
        else if str_Type == "normal_label" {
            let cell: SideMenuTableCell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableCell") as! SideMenuTableCell
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            cell.view_Base.backgroundColor = UIColor.clear
            
            cell.lbl_Underline.isHidden = true
            cell.constraint_view_TOP.constant = 12
            cell.constraint_view_BOTTOM.constant = 12
            cell.lbl_Title.text = strTitle
            cell.img_Icon.image = nil
            cell.constrint_img_Icon_Height.constant = 0
            cell.constrint_img_Icon_Trelling.constant = 0
            
            if strKey == "logout" {
                cell.lbl_Title.font = UIFont.AppFontSemiBold(16)
                cell.lbl_Title.textColor = UIColor.systemPink//.init(hex: "#E6007D")
            }
            else {
                cell.lbl_Title.font = UIFont.AppFontRegular(14)
                cell.lbl_Title.textColor = UIColor.init(hex: "#111111")
            }
            
            
            return cell
        }
        else {
            let cell: SideMenuTableCell = tableView.dequeueReusableCell(withIdentifier: "SideMenuTableCell") as! SideMenuTableCell
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            cell.view_Base.backgroundColor = UIColor.clear
            
            cell.lbl_Title.text = strTitle
            let strImage = sectionDetail["img"] as? String ?? ""
            cell.img_Icon.image = UIImage.init(named: strImage)
            
            if strTitle == "Home" || strTitle == "Help" {
                cell.lbl_Underline.isHidden = true
                cell.constraint_view_TOP.constant = 25
                cell.constraint_view_BOTTOM.constant = 12
            }
            else if strTitle == "Edit Clinic" || strTitle == "Patient list" || strTitle == "Appointment" {
                cell.lbl_Underline.isHidden = false
                cell.constraint_view_TOP.constant = 12
                cell.constraint_view_BOTTOM.constant = 25
            }
            else {
                cell.lbl_Underline.isHidden = true
                cell.constraint_view_TOP.constant = 12
                cell.constraint_view_BOTTOM.constant = 12
            }
            
            

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let viewFooter = UIView()
        viewFooter.sizeToFit()
        viewFooter.backgroundColor = .clear
        viewFooter.isUserInteractionEnabled = false
        return viewFooter
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == (tableView.numberOfSections - 1) {
            return 0
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sectionDetail = arrSections[indexPath.row]
        let selectedKey = sectionDetail["key"] as? String ?? ""
        self.tblView.reloadData()
        
        if selectedKey == "edit_clinic" {
            //self.delegate?.did_selected(true, selectedKey: selectedKey, selectedTitle: selectedTitle)
            let obj = Story_Main.instantiateViewController(withIdentifier: "Register2VC") as! Register2VC
            obj.screenFrom = .edit_profile
            self.superViewVC?.navigationController?.pushViewController(obj, animated: true)
            self.removeFromParent(_isClickIndex: true) { (animated) in
            }
        }
        else if selectedKey == "home" {
            //self.delegate?.did_selected(true, selectedKey: selectedKey, selectedTitle: selectedTitle)
            self.removeFromParent(_isClickIndex: true) { (animated) in
            }
        }
        else if selectedKey == "patient" {
            //Go To Patient List Screen
            let obj = Story_Dashboard.instantiateViewController(withIdentifier: "PatientListVC") as! PatientListVC
            self.superViewVC?.navigationController?.pushViewController(obj, animated: true)
            self.removeFromParent(_isClickIndex: true) { (animated) in
            }
        }
        else if selectedKey == "notification" {
            //Go To Patient List Screen
            let obj = Story_Dashboard.instantiateViewController(withIdentifier: "NotoficationVC") as! NotoficationVC
            self.superViewVC?.navigationController?.pushViewController(obj, animated: true)
            self.removeFromParent(_isClickIndex: true) { (animated) in
            }
        }
        else if selectedKey == "contact_us" {
            //Go To Contact us Screen
            let obj = Story_Dashboard.instantiateViewController(withIdentifier: "ContsctUsVC") as! ContsctUsVC
            self.superViewVC?.navigationController?.pushViewController(obj, animated: true)
            self.removeFromParent(_isClickIndex: true) { (animated) in
            }
        }
        else if selectedKey == "about_us" {
            //Go To Patient List Screen
            let obj = Story_Main.instantiateViewController(withIdentifier: "HowRegisterVC") as! HowRegisterVC
            obj.strTitle = "About Us"
            obj.screenFrom = .about_us
            self.superViewVC?.navigationController?.pushViewController(obj, animated: true)

            self.removeFromParent(_isClickIndex: true) { (animated) in
            }
        }
        else if selectedKey == "terms_condition" {
            //Go To Terms Condition Screen
            let obj = Story_Main.instantiateViewController(withIdentifier: "HowRegisterVC") as! HowRegisterVC
            obj.strTitle = "Terms & Condition"
            obj.screenFrom = .is_termsCondition
            self.superViewVC?.navigationController?.pushViewController(obj, animated: true)

            self.removeFromParent(_isClickIndex: true) { (animated) in
            }
        }
        else if selectedKey == "privacy_policy" {
            //Go To Privacy Policy
            let obj = Story_Main.instantiateViewController(withIdentifier: "HowRegisterVC") as! HowRegisterVC
            obj.strTitle = "Privacy Policy"
            obj.screenFrom = .is_privacy
            self.superViewVC?.navigationController?.pushViewController(obj, animated: true)

            self.removeFromParent(_isClickIndex: true) { (animated) in
            }
        }
        else if selectedKey == "help" {
            //Go To FAQ Screen
            let obj = Story_Dashboard.instantiateViewController(withIdentifier: "FaqVC") as! FaqVC
            self.superViewVC?.navigationController?.pushViewController(obj, animated: true)
            self.removeFromParent(_isClickIndex: true) { (animated) in
            }
        }
        else if selectedKey == "delete_account" {
            self.removeFromParent(_isClickIndex: true) { (animated) in
            }
            showDeleteAccountWarningAlert()
        }
        else if selectedKey == "logout" {
            self.removeFromParent(_isClickIndex: true) { (animated) in
            }
            appDelegate.AlertLogOut()
        }
        else {
            self.removeFromParent(_isClickIndex: true) { (animated) in
            }
        }
    }
}



//MARK: - Delete Accont
extension LeftSideMenuVC {
    
    func showDeleteAccountWarningAlert() {
        let title = "Delete Account"
        let message = "This will delete all the records and information associated with the account. Data cannot be retrieved again."
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "No", style: .default))
        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
            self.showDeleteAccountComfirmationAlert()
        }))
        self.superViewVC?.present(alertController, animated: true, completion: nil)
    }
    
    func showDeleteAccountComfirmationAlert() {
        let message = "Are you sure you want to delete your account?"
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "No", style: .default))
        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
            self.callDeleteAccountAPI()
        }))
        self.superViewVC?.present(alertController, animated: true, completion: nil)
    }
    
    func processAccountDelete(message: String) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
            clearDataOnLogout()
            appDelegate.app_setLogin()
        }))
        self.superViewVC?.present(alertController, animated: true, completion: nil)
    }
    
    func callDeleteAccountAPI() {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            
            let urlString = BASE_URL + APIEndpoints.delete_Doctor.rawValue
                ServiceCustom.shared.requestURL(urlString, Method: .post, parameters: nil) { responsee, isSuccess, errorrr, status in
                    DismissProgressHud()
                    if let isSuccess = responsee?["status"] as? String, isSuccess == "success" {
                        let strMsg = responsee?["message"] as? String ?? ""
                        DismissProgressHud()
                        self.processAccountDelete(message: strMsg)
                    }
                }
        
        }else {
            DismissProgressHud()
            Utils.showAlert(withMessage: AppMessage.no_internet)
        }
        
        
        
        //        self.showActivityIndicator()
        //        let params = ["language_id" : Utils.getLanguageId()] as [String : Any]
        //        doAPICall(endPoint: .DeleteMyAccount, parameters: params, headers: Utils.apiCallHeaders) { [weak self] isSuccess, status, message, responseJSON in
        //            if isSuccess {
        //                self?.hideActivityIndicator()
        //                self?.processAccountDelete(message: message)
        //            } else {
        //                self?.hideActivityIndicator()
        //                self?.showAlert(title: status, message: message)
        //            }
        //        }
    }

}
