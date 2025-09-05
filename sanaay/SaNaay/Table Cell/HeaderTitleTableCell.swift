//
//  HeaderTitleTableCell.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 07/07/23.
//

import UIKit

class HeaderTitleTableCell: UITableViewCell {

    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var constraint_lbl_Title_Top: NSLayoutConstraint!
    @IBOutlet weak var constraint_lbl_Title_Bottom: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
