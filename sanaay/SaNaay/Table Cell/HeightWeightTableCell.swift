//
//  HeightWeightTableCell.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 17/06/23.
//

import UIKit

class HeightWeightTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var view_TextFieldBg: UIView!
    @IBOutlet weak var txt_Field: UITextField!
    @IBOutlet weak var btn1: UIControl!
    @IBOutlet weak var btn2: UIControl!
    @IBOutlet weak var lbl_btnTitle1: UILabel!
    @IBOutlet weak var lbl_btnTitle2: UILabel!
    
    @IBOutlet weak var stach_feet_inch: UIStackView!
    @IBOutlet weak var view_TxtField_FeetBg: UIView!
    @IBOutlet weak var txt_Field_feet: UITextField!
    
    @IBOutlet weak var view_TxtField_InchBg: UIView!
    @IBOutlet weak var txt_Field_inch: UITextField!
    
    
    var didTappedButton1: ((UIControl)->Void)? = nil
    var didTappedButton2: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - UIButton Action
    @IBAction func btn_1_Action(_ sender: UIControl) {
        self.didTappedButton1?(sender)
    }
    
    @IBAction func btn_2_Action(_ sender: UIControl) {
        self.didTappedButton2?(sender)
    }
    
}
