//
//  RegisterButtonTableCell.swift
//  Sanaay
//
//  Created by Deepak Jain on 18/08/22.
//

import UIKit

class RegisterButtonTableCell: UITableViewCell {

    @IBOutlet weak var btn_Title: UILabel!
    @IBOutlet weak var btn_Register: UIControl!
    @IBOutlet weak var constraint_btn_Register_TOP: NSLayoutConstraint!
    @IBOutlet weak var constraint_btn_Register_Height: NSLayoutConstraint!
    @IBOutlet weak var constraint_btn_Register_Bottom: NSLayoutConstraint!
    
    @IBOutlet weak var constraint_btn_Register_Left: NSLayoutConstraint!
    @IBOutlet weak var constraint_btn_Register_Right: NSLayoutConstraint!
    
    var didTapped_onRegister: ((UIButton)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func btn_Register_Action(_ sender: UIButton) {
        self.didTapped_onRegister?(sender)
    }
    
}
