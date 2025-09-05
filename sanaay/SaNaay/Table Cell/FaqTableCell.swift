//
//  FaqTableCell.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 07/06/24.
//

import UIKit

class FaqTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Question: UILabel!
    @IBOutlet weak var view_Desc: UIView!
    @IBOutlet weak var lbl_answer: UILabel!
    @IBOutlet weak var img_arrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
