//
//  CountryTableCell.swift
//  Sicretta
//
//  Created by Deepak Jain on 23/06/22.
//

import UIKit

class CountryTableCell: UITableViewCell {

    @IBOutlet weak var img_flag: UIImageView!
    @IBOutlet weak var lbl_CountryName: UILabel!
    @IBOutlet weak var lbl_CountryCode: UILabel!
    @IBOutlet weak var img_Seleced: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
