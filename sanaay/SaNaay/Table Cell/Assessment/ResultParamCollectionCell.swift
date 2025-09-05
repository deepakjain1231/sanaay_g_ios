//
//  ResultParamCollectionCell.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 03/12/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

class ResultParamCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var view_BaseBG: UIView!
    
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var subtitleL: UILabel!
    @IBOutlet weak var kpvDisplayValueL: UILabel!
    @IBOutlet weak var paramIconIV: UIImageView!
    @IBOutlet weak var kpvIconIV: UIImageView!
    @IBOutlet weak var infoBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.view_BaseBG.layer.borderWidth = 1
        self.view_BaseBG.layer.borderColor = UIColor(red: 0.667, green: 0.667, blue: 0.667, alpha: 1).cgColor
    }

    var paramData : SparshnaResultParamModel? {
        didSet {
            guard let paramData = paramData else { return }
            
            titleL.text = paramData.title
            subtitleL.text = paramData.subtitle2
            kpvDisplayValueL.text = paramData.paramDisplayValue
            paramIconIV.image = paramData.paramIcon
            
            kpvIconIV.isHidden = false
            switch paramData.paramKPVValue {
            case .KAPHA:
                kpvIconIV.image = #imageLiteral(resourceName: "Kapha_n")
            case .PITTA:
                kpvIconIV.image = #imageLiteral(resourceName: "Pitta_n")
            case .VATA:
                kpvIconIV.image = #imageLiteral(resourceName: "Vata_n")
            default:
                kpvIconIV.isHidden = true
            }
        }
    }
}
