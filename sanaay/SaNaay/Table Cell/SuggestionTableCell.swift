//
//  SuggestionTableCell.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 18/06/23.
//

import UIKit

class SuggestionTableCell: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var view_TextFieldBg: UIView!
    @IBOutlet weak var txt_View: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
}
