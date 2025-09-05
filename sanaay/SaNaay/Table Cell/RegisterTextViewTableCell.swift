//
//  RegisterTextViewTableCell.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 03/04/24.
//

import UIKit

class RegisterTextViewTableCell: UITableViewCell {
    
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var view_TextViewBg: UIView!
    @IBOutlet weak var txt_View: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

