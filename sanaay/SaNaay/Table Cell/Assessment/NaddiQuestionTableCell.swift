//
//  NaddiQuestionTableCell.swift
//  SaNaay
//
//  Created by DEEPAK JAIN on 20/07/24.
//

import UIKit

class NaddiQuestionTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_question: UILabel!
    
    @IBOutlet weak var stack_answer: UIStackView!
    
    @IBOutlet weak var lbl_answer_option_1: UILabel!
    @IBOutlet weak var lbl_answer_option_2: UILabel!
    @IBOutlet weak var lbl_answer_option_3: UILabel!
    @IBOutlet weak var lbl_answer_option_4: UILabel!
    @IBOutlet weak var lbl_answer_option_5: UILabel!
    @IBOutlet weak var lbl_answer_option_6: UILabel!
    @IBOutlet weak var lbl_answer_option_7: UILabel!
    
    @IBOutlet weak var img_answer_option_1: UIImageView!
    @IBOutlet weak var img_answer_option_2: UIImageView!
    @IBOutlet weak var img_answer_option_3: UIImageView!
    @IBOutlet weak var img_answer_option_4: UIImageView!
    @IBOutlet weak var img_answer_option_5: UIImageView!
    @IBOutlet weak var img_answer_option_6: UIImageView!
    @IBOutlet weak var img_answer_option_7: UIImageView!
    
    @IBOutlet weak var view_answer_option_1: UIControl!
    @IBOutlet weak var view_answer_option_2: UIControl!
    @IBOutlet weak var view_answer_option_3: UIControl!
    @IBOutlet weak var view_answer_option_4: UIControl!
    @IBOutlet weak var view_answer_option_5: UIControl!
    @IBOutlet weak var view_answer_option_6: UIControl!
    @IBOutlet weak var view_answer_option_7: UIControl!
    
    var didTappedOption_1: ((UIControl)->Void)? = nil
    var didTappedOption_2: ((UIControl)->Void)? = nil
    var didTappedOption_3: ((UIControl)->Void)? = nil
    var didTappedOption_4: ((UIControl)->Void)? = nil
    var didTappedOption_5: ((UIControl)->Void)? = nil
    var didTappedOption_6: ((UIControl)->Void)? = nil
    var didTappedOption_7: ((UIControl)->Void)? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btn_Option_1(_ sender: UIControl) {
        self.didTappedOption_1?(sender)
    }
    
    @IBAction func btn_Option_2(_ sender: UIControl) {
        self.didTappedOption_2?(sender)
    }
    
    @IBAction func btn_Option_3(_ sender: UIControl) {
        self.didTappedOption_3?(sender)
    }
    
    @IBAction func btn_Option_4(_ sender: UIControl) {
        self.didTappedOption_4?(sender)
    }
    
    @IBAction func btn_Option_5(_ sender: UIControl) {
        self.didTappedOption_5?(sender)
    }
    
    @IBAction func btn_Option_6(_ sender: UIControl) {
        self.didTappedOption_6?(sender)
    }
    
    @IBAction func btn_Option_7(_ sender: UIControl) {
        self.didTappedOption_7?(sender)
    }
    
}
