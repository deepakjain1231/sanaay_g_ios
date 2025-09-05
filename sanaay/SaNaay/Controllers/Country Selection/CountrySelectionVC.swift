//
//  CountrySelectionVC.swift
//  Sicretta
//
//  Created by Deepak Jain on 23/06/22.
//

import UIKit

protocol countryPickDelegate {
    func selectCountry(screenFrom: String, is_Pick: Bool, selectedCountry: Country?)
}

class CountrySelectionVC: UIViewController, UITextFieldDelegate {

    var delegate: countryPickDelegate?
    var is_screenFrom = ""
    var selectedValue = ""
    @IBOutlet weak var view_mainBG: UIView!
    @IBOutlet weak var viewInnerPopup: UIView!
    @IBOutlet weak var tblCountry: UITableView!
    @IBOutlet weak var viewPopupBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_mainBG_TOP: NSLayoutConstraint!
    
    var arrCountry = [Country]()
    var iscountryPicker = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //=====================Register Table Cell=====================//
        self.tblCountry.register(nibWithCellClass: CountryTableCell.self)
        //=============================================================//
        
        self.setupData()
        self.constraint_view_mainBG_TOP.constant = screenHeight
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
        
        
        self.tblCountry.tableFooterView = UIView(frame: .zero)
        
        arrCountry =  SMCountry.shared.getAllCountry(withreload: true)
        tblCountry.reloadData()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setupData() {
        
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_view_mainBG_TOP.constant = 65
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
    
    
    func clkToClose() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_view_mainBG_TOP.constant = screenHeight
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    
//    // MARK:- KEYBOARD METHODS
//    @objc func keyboardWillShow(notification: NSNotification) {
//        print("keyboardWillShow")
//        let userinfo:NSDictionary = (notification.userInfo as NSDictionary?)!
//        if let keybordsize = (userinfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            self.viewPopupBottomLayout.constant = keybordsize.height
//            self.view.layoutIfNeeded()
//        }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification){
//        print("keyboardWillHide")
//        self.viewPopupBottomLayout.constant = 0
//        self.view.layoutIfNeeded()
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - FUNCTIONS
    @IBAction func btnBack_Action(_ sender: UIButton) {
        self.clkToClose()
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}

extension CountrySelectionVC: UITableViewDelegate,UITableViewDataSource {
    
    func getfiltered() -> [Country]? {
        return arrCountry
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getfiltered()!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CountryTableCell = tableView.dequeueReusableCell(withIdentifier: "CountryTableCell") as! CountryTableCell
        cell.selectionStyle = .none

        let Country = getfiltered()![indexPath.row]
        cell.img_flag.image = Country.flag
        
        if iscountryPicker == true {
            cell.lbl_CountryName.text = Country.name ?? ""
            cell.lbl_CountryCode.text  = self.is_screenFrom != "" ? "" : Country.code
        }else{
            cell.lbl_CountryName.text = Country.name! + "(\(Country.code!))"
            cell.lbl_CountryCode.text  = self.is_screenFrom != "" ? "" : Country.phoneCode
        }
        
        cell.img_Seleced.image = self.selectedValue == Country.name! ? #imageLiteral(resourceName: "Successfully") : nil
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let Country = getfiltered()![indexPath.row]
        self.delegate?.selectCountry(screenFrom: self.is_screenFrom, is_Pick: true, selectedCountry: Country)
        self.clkToClose()
    }
    
}

