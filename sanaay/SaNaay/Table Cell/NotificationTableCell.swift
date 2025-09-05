//
//  NotificationTableCell.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 17/06/23.
//

import UIKit

class NotificationTableCell: UITableViewCell {

    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_subtitle: UILabel!
    @IBOutlet weak var img_icon: UIImageView!
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
