//
//  GenderTableCell.swift
//  SaNaay
//
//  Created by Deepak Jain on 16/06/24.
//

import UIKit

class GenderTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_male: UILabel!
    @IBOutlet weak var lbl_female: UILabel!
    @IBOutlet weak var img_male: UIImageView!
    @IBOutlet weak var img_female: UIImageView!
    @IBOutlet weak var btn_male: UIControl!
    @IBOutlet weak var btn_female: UIControl!
    @IBOutlet weak var lbl_Title: UILabel!
    
    var didTapped_onMale: ((UIControl)->Void)? = nil
    var didTapped_onFeMale: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func btn_male_action(_ sender: UIControl) {
        self.didTapped_onMale?(sender)
    }
    
    @IBAction func btn_female_action(_ sender: UIControl) {
        self.didTapped_onFeMale?(sender)
    }
}
