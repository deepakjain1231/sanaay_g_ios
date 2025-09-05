//
//  ResultBottomTableCell.swift
//  SaNaay Wellness
//
//  Created by DEEPAK JAIN on 22/10/23.
//

import UIKit

class ResultBottomTableCell: UITableViewCell {

    var didTappedButton: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - UIButton Action
    @IBAction func btn_Action(_ sender: UIControl) {
        self.didTappedButton?(sender)
    }
}
