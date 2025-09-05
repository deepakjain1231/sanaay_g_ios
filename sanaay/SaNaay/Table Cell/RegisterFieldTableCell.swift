//
//  RegisterFieldTableCell.swift
//  Sanaay
//
//  Created by Deepak Jain on 18/08/22.
//

import UIKit

class RegisterFieldTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var view_TextFieldBg: UIView!
    @IBOutlet weak var txt_Field: UITextField!
    @IBOutlet weak var txt_Field_Mobile: UITextField!
    @IBOutlet weak var lbl_countryCode: UILabel!
    @IBOutlet weak var view_countryBG: UIView!
    @IBOutlet weak var constraint_lbl_Title_TOP: NSLayoutConstraint!
    @IBOutlet weak var constraint_view_TextFieldBg_Height: NSLayoutConstraint!
    
    @IBOutlet weak var lbl_bottomText: UILabel!
    @IBOutlet weak var btn_location: UIControl!
    @IBOutlet weak var img_arrow_down: UIImageView!
    @IBOutlet weak var view_HideMobile: UIControl!
    @IBOutlet weak var img_HideMobile: UIImageView!
    
    
    var didTappedCountry: ((UIControl)->Void)? = nil
    var didTappedLocation: ((UIControl)->Void)? = nil
    var didTappedHideMobile: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btn_location.isHidden = true
        self.view_countryBG.isHidden = true
        self.txt_Field_Mobile.isHidden = true
        self.img_arrow_down.isHidden = true
        self.view_HideMobile.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - UIButton Action
    @IBAction func btn_CountryCode_Action(_ sender: UIControl) {
        self.didTappedCountry?(sender)
    }
    
    @IBAction func btn_Location_Action(_ sender: UIControl) {
        self.didTappedLocation?(sender)
    }
    
    @IBAction func btn_HideMobile_Action(_ sender: UIControl) {
        self.didTappedHideMobile?(sender)
    }
    
}
