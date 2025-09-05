//
//  AppointmentHomeTableCell.swift
//  SaNaay
//
//  Created by DEEPAK JAIN on 17/07/24.
//

import UIKit

class AppointmentHomeTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Name: UILabel!
    @IBOutlet weak var lbl_Time: UILabel!
    
    @IBOutlet weak var view_ButtonBG: UIView!
    @IBOutlet weak var btn_Download: UIControl!
    @IBOutlet weak var btn_Reschedule: UIControl!
    @IBOutlet weak var btn_RetestNow: UIControl!
    @IBOutlet weak var constraint_view_ButtonBG_Top: NSLayoutConstraint!
    
    var didTappedonDownload: ((UIControl)->Void)? = nil
    var didTappedonReschedule: ((UIControl)->Void)? = nil
    var didTappedonRetest: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func btn_download_Action(_ sender: UIControl) {
        self.didTappedonDownload?(sender)
    }
    
    
    @IBAction func btn_reschedule_Action(_ sender: UIControl) {
        self.didTappedonReschedule?(sender)
    }
    
    
    @IBAction func btn_retestNow_Action(_ sender: UIControl) {
        self.didTappedonRetest?(sender)
    }
    
}
