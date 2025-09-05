//
//  NoteDoctorTableCell.swift
//  Tavisa_Patient
//
//  Created by DEEPAK JAIN on 20/04/24.
//

import UIKit

class NoteDoctorTableCell: UITableViewCell {
    
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var txt_note: UITextView!
    
    var didTapped_onClickNote: ((UIButton)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    @IBAction func btn_click_Note_action(_ sender: UIButton) {
        self.didTapped_onClickNote?(sender)
    }
}

