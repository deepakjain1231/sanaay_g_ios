//
//  HomeCollectionCell.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 19/06/23.
//

import UIKit

class HomeCollectionCell: UICollectionViewCell {

    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var btn_remove: UIButton!
    @IBOutlet weak var constraint_btn_remove_height: NSLayoutConstraint!
    
    var didTappedonRemove: ((UIButton)->Void)? = nil
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btn_remove.isHidden = true
    }

    
    // MARK: - UIButton Action
    @IBAction func btn_Action(_ sender: UIButton) {
        self.didTappedonRemove?(sender)
    }
}
