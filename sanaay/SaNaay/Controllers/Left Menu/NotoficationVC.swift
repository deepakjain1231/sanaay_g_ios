//
//  NotoficationVC.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 17/06/23.
//

import UIKit

class NotoficationVC: UIViewController {

    var arr_Notification_Data = [NotificationListDataResponse?]()
    @IBOutlet weak var tbl_view: UITableView!
    @IBOutlet weak var view_NoDataBG: UIView!
    private let viewModel: RegisterViewModel = RegisterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view_NoDataBG.isHidden = true
        
        //Register Table Cell
        self.tbl_view.register(nibWithCellClass: NotificationTableCell.self)
        
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
extension NotoficationVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Notification_Data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableCell", for: indexPath) as! NotificationTableCell
        cell.selectionStyle = .none
        
        let dic_detail = self.arr_Notification_Data[indexPath.row]
        cell.lbl_title.text = dic_detail?.noti_title ?? ""
        cell.lbl_subtitle.text = dic_detail?.noti_body ?? ""

        let data_value = dic_detail?.created_at ?? ""
        let dateformat = DateFormatter()
        dateformat.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let datee = dateformat.date(from: data_value) {
            dateformat.dateFormat = "dd MMM yyyy, hh:mm a"
            cell.lbl_date.text = dateformat.string(from: datee)
        }
        
        let seen_by_receiver = dic_detail?.seen_by_receiver ?? ""
        if seen_by_receiver == "0" {
            cell.view_Base.backgroundColor = UIColor.init(hex: "FFF4FF")
        }
        else {
            cell.view_Base.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic_detail = self.arr_Notification_Data[indexPath.row]
        
        if dic_detail?.noti_type == kPushNotification_Type.kAppointment.rawValue {
            
            let str_date = dic_detail?.appointment_date ?? ""
            
            if let stackVCs = self.navigationController?.viewControllers {
                if let activeSubVC = stackVCs.first(where: { type(of: $0) == HomeVC.self }) {
                    self.navigationController?.popToViewController(activeSubVC, animated: true)
                }
            }
        }
        else if dic_detail?.noti_type == kPushNotification_Type.kReschedule.rawValue {
            if let stackVCs = self.navigationController?.viewControllers {
                if let activeSubVC = stackVCs.first(where: { type(of: $0) == HomeVC.self }) {
                    self.navigationController?.popToViewController(activeSubVC, animated: true)
                }
            }
        }
        else if dic_detail?.noti_type == kPushNotification_Type.kCancel_appointment.rawValue {
            if let stackVCs = self.navigationController?.viewControllers {
                if let activeSubVC = stackVCs.first(where: { type(of: $0) == HomeVC.self }) {
                    self.navigationController?.popToViewController(activeSubVC, animated: true)
                }
            }
        }
        else if dic_detail?.noti_type == kPushNotification_Type.kvikriti_result.rawValue ||
                    dic_detail?.noti_type == kPushNotification_Type.kAssessment.rawValue {
            let str_patient_id = dic_detail?.sender_id ?? ""
            
            if let stackVCs = self.navigationController?.viewControllers {
                if let activeSubVC = stackVCs.first(where: { type(of: $0) == HomeVC.self }) {
                    self.navigationController?.popToViewController(activeSubVC, animated: true)
                }
            }
        }
        
        
       
        
    }
}


