//
//  SideMenuHeaderTableCell.swift
//  Sanaay
//
//  Created by Deepak Jain on 18/08/22.
//

import UIKit

class SideMenuHeaderTableCell: UITableViewCell {

    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var img_profile: UIImageView!
    
    var didTappedonEditProfile: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func btn_editProfile_Action(_ sender: UIControl) {
        self.didTappedonEditProfile?(sender)
    }
}
