//
//  MenualAssessmentTableCell.swift
//  SaNaay
//
//  Created by DEEPAK JAIN on 12/07/24.
//

import UIKit

class MenualAssessmentTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var lbl_skip: UILabel!
    @IBOutlet weak var lbl_yes: UILabel!
    @IBOutlet weak var btn_skip: UIControl!
    @IBOutlet weak var btn_yes: UIControl!
    
    var didTappedYesButton: ((UIControl)->Void)? = nil
    var didTappedSkipButton: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - UIButton Action
    @IBAction func btn_skip_Action(_ sender: UIControl) {
        self.didTappedSkipButton?(sender)
    }
    
    @IBAction func btn_yes_Action(_ sender: UIControl) {
        self.didTappedYesButton?(sender)
    }
    
}
