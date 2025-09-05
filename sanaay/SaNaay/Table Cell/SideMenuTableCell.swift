//
//  SideMenuTableCell.swift
//  Cotasker
//
//  Created by Zignuts Technolab on 01/11/19.
//  Copyright © 2019 Pearl Inc. All rights reserved.
//

import UIKit

class SideMenuTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var img_Icon: UIImageView!
    @IBOutlet weak var lbl_Underline: UILabel!
    @IBOutlet weak var constraint_view_TOP: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_BOTTOM: NSLayoutConstraint!
    @IBOutlet weak var constrint_img_Icon_Height: NSLayoutConstraint!
    @IBOutlet weak var constrint_img_Icon_Trelling: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
