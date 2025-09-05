//
//  HomeScreenAssessmentTableCell.swift
//  Tavisa_Patient
//
//  Created by DEEPAK JAIN on 29/06/23.
//

import UIKit

class HomeScreenAssessmentTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var img_icon: UIImageView!
    @IBOutlet weak var lbl_Text1: UILabel!
    @IBOutlet weak var lbl_Text2: UILabel!
    @IBOutlet weak var lbl_Text3: UILabel!

    @IBOutlet weak var btn_test_again: UIControl!
    @IBOutlet weak var btn_viewResult: UIControl!
    @IBOutlet weak var lbl_test_again: UILabel!
    @IBOutlet weak var lbl_view_result: UILabel!
    
    var didTapped_onTryNow: ((UIControl)->Void)? = nil
    var didTapped_onviewResult: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_TestAgain_Action(_ sender: UIControl) {
        self.didTapped_onTryNow?(sender)
    }
    
    @IBAction func btn_ViewResult_Action(_ sender: UIControl) {
        self.didTapped_onviewResult?(sender)
    }
}
