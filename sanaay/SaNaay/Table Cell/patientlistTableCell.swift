//
//  patientlistTableCell.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 17/06/23.
//

import UIKit

class patientlistTableCell: UITableViewCell {

    @IBOutlet weak var lbl_Name: UILabel!
    @IBOutlet weak var lbl_LastVisited: UILabel!
    
    @IBOutlet weak var lbl_Aggravation: UILabel!
    @IBOutlet weak var lbl_Aggravation_Title: UILabel!
    @IBOutlet weak var view_Aggravation_BG: UIView!
    @IBOutlet weak var img_Aggravation: UIImageView!
        
    @IBOutlet weak var btn_delete: UIButton!

    var didTappedonDelete: ((UIButton)->Void)? = nil

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    
    @IBAction func btn_delete_Action(_ sender: UIButton) {
        self.didTappedonDelete?(sender)
    }
    
    
}
