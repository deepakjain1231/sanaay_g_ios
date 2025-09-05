//
//  AddNewYoga.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 07/07/23.
//

import UIKit

class AddNewYoga: UITableViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var txt_addNew: UITextField!
    @IBOutlet weak var btn_Add: UIControl!
    
    var didTappedonAddNew: ((UIControl)->Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func btn_addNew_Action(_ sender: UIControl) {
        self.didTappedonAddNew?(sender)
    }
}
