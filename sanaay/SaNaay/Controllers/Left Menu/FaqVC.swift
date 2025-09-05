//
//  FaqVC.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 07/06/24.
//

import UIKit
import Alamofire

class FaqVC: UIViewController {

    var arr_selectedOpen = [[String: Any]]()
    var arr_Data = [[String: Any]]()
    @IBOutlet weak var tbl_View: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Register Table Cell
        self.tbl_View.register(nibWithCellClass: FaqTableCell.self)
        
        self.setFaqData()
    }
    
    func setFaqData() {
        self.arr_Data.removeAll()
        self.arr_Data.append(["id": "1", "title": "Is SaNaaY affordable?", "desc": "We have kept the price low enough that it is affordable."])
        self.arr_Data.append(["id": "2", "title": "What is the scientific principle behind SaNaaY?", "desc": "It works on the principle of pulse plethysmography (PPG). From the PPG we record seven vital signs, vega, tala, bala, akruti matra, akruti tanaav, kathinya and gati, and convert it to Kapha, Pitta and Vata."])
        self.arr_Data.append(["id": "3", "title": "Can I enter my Naadi observation manually?", "desc": "In addition to using the Sahaj Naadi Yantra, doctors have option to enter their own naadi observations"])
        self.arr_Data.append(["id": "4", "title": "Can I record Prakriti?", "desc": "Yes, you can record the Prakriti based on our questionnaire. Alternatively, you can manually enter your Prakriti."])
        self.arr_Data.append(["id": "5", "title": "How can I share my report to patient?", "desc": "Report can be printed or shared electronically via whatsapp, sms, etc."])
        self.arr_Data.append(["id": "6", "title": "Can I customize the report?", "desc": "Doctors can generate reports using our database of food, yoga, meditation, pranayam, kriya, mudra etc. They also have an option to customize information manually and override our suggestions."])
        
        self.arr_Data.append(["id": "111", "title": "Privacy Policy", "desc": ""])
        self.arr_Data.append(["id": "112", "title": "Terms & Conditions", "desc": ""])
        
        self.tbl_View.reloadData()
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
}


//MARK: - UITableView Delegste Datasourcr Method
extension FaqVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FaqTableCell", for: indexPath) as! FaqTableCell
        cell.selectionStyle = .none
        
        let dic_detail = self.arr_Data[indexPath.row]
        let str_id = dic_detail["id"] as? String ?? ""
        let str_question = dic_detail["title"] as? String ?? ""
        let str_answer = dic_detail["desc"] as? String ?? ""
        cell.lbl_Question.text = str_question
        
        if str_id == "111" || str_id == "112" {
            cell.lbl_answer.text = ""
            cell.view_Desc.isHidden = true
            cell.lbl_Question.textColor = UIColor.black
            cell.lbl_Question.font = UIFont.AppFontSemiBold(16)
            cell.img_arrow.image = UIImage.init(named: "arrow_right_gray")
        }
        else {
            cell.lbl_Question.font = UIFont.AppFontRegular(14)
            cell.lbl_Question.textColor = AppColor.app_GreenColor
            
            if let indx = self.arr_selectedOpen.firstIndex(where: { dic in
                return (dic["id"] as? String ?? "") == str_id
            }) {
                cell.lbl_answer.text = str_answer
                cell.view_Desc.isHidden = false
                cell.img_arrow.image = UIImage.init(named: "arrow_down")
            }
            else {
                cell.lbl_answer.text = ""
                cell.view_Desc.isHidden = true
                cell.img_arrow.image = UIImage.init(named: "icon_arrow_black")
            }
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic_detail = self.arr_Data[indexPath.row]
        let str_id = dic_detail["id"] as? String ?? ""
        if str_id == "111" {
            let obj = Story_Main.instantiateViewController(withIdentifier: "HowRegisterVC") as! HowRegisterVC
            obj.strTitle = "Privacy Policy"
            obj.screenFrom = .is_privacy
            self.navigationController?.pushViewController(obj, animated: true)
        }
        else if str_id == "112" {
            let obj = Story_Main.instantiateViewController(withIdentifier: "HowRegisterVC") as! HowRegisterVC
            obj.strTitle = "Terms & Condition"
            obj.screenFrom = .is_termsCondition
            self.navigationController?.pushViewController(obj, animated: true)
        }
        else {
            if let indx = self.arr_selectedOpen.firstIndex(where: { dic in
                return (dic["id"] as? String ?? "") == str_id
            }) {
                self.arr_selectedOpen.remove(at: indx)
            }
            else {
                self.arr_selectedOpen.append(dic_detail)
            }
            self.tbl_View.reloadRows(at: [indexPath], with: .none)
        }
    }
    
}

