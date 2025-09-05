//
//  FoodPreferenceTableCell.swift
//  SaNaay
//
//  Created by DEEPAK JAIN on 16/07/24.
//

import UIKit

class FoodPreferenceTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_Veg: UILabel!
    @IBOutlet weak var lbl_Egg: UILabel!
    @IBOutlet weak var lbl_NonVeg: UILabel!
    
    @IBOutlet weak var img_Veg: UIImageView!
    @IBOutlet weak var img_Egg: UIImageView!
    @IBOutlet weak var img_NonVeg: UIImageView!
    
    var didTappedVeg: ((UIControl)->Void)? = nil
    var didTappedEgg: ((UIControl)->Void)? = nil
    var didTappedNonVeg: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - UIButton Action
    @IBAction func btn_Veg_Action(_ sender: UIControl) {
        self.didTappedVeg?(sender)
    }
    
    @IBAction func btn_Egg_Action(_ sender: UIControl) {
        self.didTappedEgg?(sender)
    }
    
    @IBAction func btn_NonVeg_Action(_ sender: UIControl) {
        self.didTappedNonVeg?(sender)
    }
    
}
