//
//  CurrentBalTableCell.swift
//  SaNaay Wellness
//
//  Created by DEEPAK JAIN on 22/10/23.
//

import UIKit

class CurrentBalTableCell: UITableViewCell {

    @IBOutlet weak var view_kapha: UIView!
    @IBOutlet weak var view_pitta: UIView!
    @IBOutlet weak var view_vata: UIView!
    @IBOutlet weak var lbl_kapha: UILabel!
    @IBOutlet weak var lbl_pitta: UILabel!
    @IBOutlet weak var lbl_vata: UILabel!
    
    @IBOutlet weak var lbl_kapha_cloud: UILabel!
    @IBOutlet weak var lbl_pitta_cloud: UILabel!
    @IBOutlet weak var lbl_vata_cloud: UILabel!
    
    @IBOutlet weak var img_aggravation: UIImageView!
    @IBOutlet weak var lbl_aggravation: UILabel!
    @IBOutlet weak var lbl_aggravation_cloud: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.view_kapha.backgroundColor = .clear
        self.view_pitta.backgroundColor = .clear
        self.view_vata.backgroundColor = .clear
//        self.view_kapha.layer.cornerRadius = 10
//        self.view_pitta.layer.cornerRadius = 10
//        self.view_vata.layer.cornerRadius = 10
//        self.view_kapha.layer.borderWidth = 1
//        self.view_pitta.layer.borderWidth = 1
//        self.view_vata.layer.borderWidth = 1
        
//        self.view_kapha.layer.borderColor = UIColor.init(hex: "#6CC068").cgColor//#BDD630, #FFDC30
//        self.view_pitta.layer.borderColor = UIColor.init(hex: "#FC0000").cgColor//#EB711F, #FFCB2A
//        self.view_vata.layer.borderColor = UIColor.init(hex: "#3C91E6").cgColor//#BC68C0, #3C91E6
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
