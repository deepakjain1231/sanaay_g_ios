//
//  SetProfileTableCell.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 14/06/23.
//

import UIKit

class SetProfileTableCell: UITableViewCell {

    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var img_profile: UIImageView!
    @IBOutlet weak var img_plus: UIImageView!
    @IBOutlet weak var btn_Profile: UIButton!
    
    var didTapped_onProfile: ((UIButton)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func btn_Profile_Action(_ sender: UIButton) {
        self.didTapped_onProfile?(sender)
    }
}
