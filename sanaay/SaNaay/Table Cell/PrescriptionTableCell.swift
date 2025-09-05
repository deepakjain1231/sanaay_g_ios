//
//  PrescriptionTableCell.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 14/04/24.
//

import UIKit

class PrescriptionTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var view_TextFieldBg: UIView!
    @IBOutlet weak var lbl_added_prescription: UILabel!
    @IBOutlet weak var btn_Add: UIButton!

    var didTappedonButtonAdd: ((UIButton)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_Add_Action(_ sender: UIButton) {
        self.didTappedonButtonAdd?(sender)
    }
    
}
