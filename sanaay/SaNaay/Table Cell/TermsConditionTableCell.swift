//
//  TermsConditionTableCell.swift
//  SaNaay
//
//  Created by DEEPAK JAIN on 15/06/24.
//

import UIKit

class TermsConditionTableCell: UITableViewCell {

    var strprivacyText = "By proceeding with registration. you agree to our terms & conditions and privacy policy"
    
    @IBOutlet var view_Base: UIView!
    @IBOutlet var img_check: UIImageView!
    @IBOutlet weak var txt_terms_condition: UITextView!
    
    var didTapped_onTermsCondition: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupTermsConditionText() {
        //MARK: - Common URLS

        let attributedString = NSMutableAttributedString(string: self.strprivacyText, attributes: [.font: UIFont.AppFontMedium(13), .foregroundColor: UIColor.black, .kern: -0.41])

        let textRange = NSString(string: self.strprivacyText)
        let highlight_range = textRange.range(of: "terms & conditions")
        let highlight_range1 = textRange.range(of: "privacy policy")
        attributedString.addAttribute(.foregroundColor, value: AppColor.app_GreenColor, range: highlight_range)
        attributedString.addAttribute(.foregroundColor, value: AppColor.app_GreenColor, range: highlight_range1)
        
        attributedString.addAttribute(.link, value: kTermsAndCondition, range: highlight_range)
        attributedString.addAttribute(.link, value: kPrivacyPolicy, range: highlight_range1)
        
        self.txt_terms_condition?.attributedText = attributedString
    }
    
    
    @IBAction func btn_TermsCondition_action(_ sender: UIControl) {
        self.didTapped_onTermsCondition?(sender)
    }
}
