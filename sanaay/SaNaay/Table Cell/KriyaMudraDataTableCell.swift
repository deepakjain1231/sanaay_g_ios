//
//  KriyaMudraDataTableCell.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 07/07/23.
//

import UIKit

class KriyaMudraDataTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var img_icon: UIImageView!
    
    @IBOutlet weak var constraint_lbl_Title_leading: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_Base_leaing: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_Base_bottom: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_Base_trelling: NSLayoutConstraint!
    @IBOutlet weak var constraint_lbl_Title_trelling: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
