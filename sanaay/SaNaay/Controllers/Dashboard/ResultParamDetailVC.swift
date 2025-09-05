//
//  ResultParamDetailVC.swift
//  HourOnEarth
//
//  Created by Paresh Dafda on 04/12/20.
//  Copyright © 2020 AyuRythm. All rights reserved.
//

import UIKit

class ResultParamDetailVC: UIViewController {

    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var subtitleL: UILabel!
    @IBOutlet weak var shortDescriptionL: UILabel!
    @IBOutlet weak var valueRangeTitleL: UILabel!
    @IBOutlet weak var whatDoesThisMeanL: UILabel!
    @IBOutlet weak var whatDoesThisMeanSV: UIStackView!
    
    @IBOutlet weak var paramValue1: ParamValueRangeView!
    @IBOutlet weak var paramValue2: ParamValueRangeView!
    @IBOutlet weak var paramValue3: ParamValueRangeView!
    @IBOutlet weak var paramValue4: ParamValueRangeView!
    @IBOutlet weak var paramValue5: ParamValueRangeView!
    @IBOutlet weak var paramValuesSV: UIStackView!
    @IBOutlet weak var paramBMIOther2ValuesSV: UIStackView!
    
    var resultParam: SparshnaResultParamModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        guard let data = resultParam else { return }
        titleL.text = data.title
        subtitleL.text = data.subtitle2
        shortDescriptionL.text = data.shortDescription
        whatDoesThisMeanL.text = data.whatDoesMeans
        
        if data.whatDoesMeans.isEmpty {
            whatDoesThisMeanSV.isHidden = true
        }
        updateValueRangesAndSelectedValue()
    }
    
    func updateValueRangesAndSelectedValue() {
        guard let data = resultParam else { return }
        
        let paramValue = Int(data.paramStringValue) ?? 0
        paramValue1.isSelected = false
        paramValue2.isSelected = false
        paramValue3.isSelected = false
        paramValue4.isSelected = false
        paramValue5.isSelected = false
        
        switch data.paramType {
        case .bpm:
            paramValue1.titleL.text = "Below 70"
            paramValue1.image1.image = #imageLiteral(resourceName: "Kapha_n")
            
            paramValue2.titleL.text = "70-80"
            paramValue2.image1.image = #imageLiteral(resourceName: "Pitta_n")
            
            paramValue3.titleL.text = "Above 80"
            paramValue3.image1.image = #imageLiteral(resourceName: "Vata_n")
            
            if (paramValue < 70) {
                paramValue1.isSelected = true
            } else if (paramValue >= 70 && paramValue <= 80) {
                paramValue2.isSelected = true
            } else {
                paramValue3.isSelected = true
            }
            
        case .sp:
            paramValue1.titleL.text = "Below 90"
            paramValue1.image1.image = #imageLiteral(resourceName: "Kapha_n")
            
            paramValue2.titleL.text = "90-120"
            paramValue2.image1.image = #imageLiteral(resourceName: "Pitta_n")
            
            paramValue3.titleL.text = "Above 120"
            paramValue3.image1.image = #imageLiteral(resourceName: "Vata_n")
            
            if (paramValue < 90) {
                paramValue1.isSelected = true
            } else if (paramValue >= 90 && paramValue <= 120) {
                paramValue2.isSelected = true
            } else {
                paramValue3.isSelected = true
            }
            
        case .dp:
            paramValue1.titleL.text = "Below 60"
            paramValue1.image1.image = #imageLiteral(resourceName: "Kapha_n")
            
            paramValue2.titleL.text = "60-80"
            paramValue2.image1.image = #imageLiteral(resourceName: "Pitta_n")
            
            paramValue3.titleL.text = "Above 80"
            paramValue3.image1.image = #imageLiteral(resourceName: "Vata_n")
            
            if (paramValue < 60) {
                paramValue1.isSelected = true
            } else if (paramValue >= 60 && paramValue <= 80) {
                paramValue2.isSelected = true
            } else {
                paramValue3.isSelected = true
            }
            
        case .bala:
            paramValue1.titleL.text = "Below 30"
            paramValue1.image1.image = #imageLiteral(resourceName: "Kapha_n")
            
            paramValue2.titleL.text = "30-40"
            paramValue2.image1.image = #imageLiteral(resourceName: "Pitta_n")
            
            paramValue3.titleL.text = "Above 40"
            paramValue3.image1.image = #imageLiteral(resourceName: "Vata_n")
            
            if (paramValue < 30) {
                paramValue1.isSelected = true
            } else if (paramValue >= 30 && paramValue <= 40) {
                paramValue2.isSelected = true
            } else {
                paramValue3.isSelected = true
            }
            
        case .kath:
            paramValue1.titleL.text = "Below 210"
            paramValue1.image1.image = #imageLiteral(resourceName: "Kapha_n")
            
            paramValue2.titleL.text = "210-310"
            paramValue2.image1.image = #imageLiteral(resourceName: "Pitta_n")
            
            paramValue3.titleL.text = "Above 310"
            paramValue3.image1.image = #imageLiteral(resourceName: "Vata_n")
            
            if (paramValue < 210) {
                paramValue1.isSelected = true
            } else if (paramValue >= 210 && paramValue <= 310) {
                paramValue2.isSelected = true
            } else {
                paramValue3.isSelected = true
            }
            
        case .gati:
            paramValue1.titleL.text = "Hamsa"
            paramValue1.image1.image = #imageLiteral(resourceName: "Kapha_n")
            
            paramValue2.titleL.text = "Manduka"
            paramValue2.image1.image = #imageLiteral(resourceName: "Pitta_n")
            
            paramValue3.titleL.text = "Sarpa"
            paramValue3.image1.image = #imageLiteral(resourceName: "Vata_n")
            
            if data.paramStringValue == "Kapha" {
                paramValue1.isSelected = true
            } else if data.paramStringValue == "Pitta" {
                paramValue2.isSelected = true
            } else {
                paramValue3.isSelected = true
            }
            
        case .rythm:
            paramValue1.titleL.text = "Regular"
            paramValue1.image1.image = #imageLiteral(resourceName: "Kapha_n")
            paramValue1.image2.isHidden = false
            
            paramValue2.titleL.text = "Irregular"
            paramValue2.image1.image = #imageLiteral(resourceName: "Vata_n")
            
            paramValue3.isHidden = true
            
            if paramValue == 0 {
                paramValue2.isSelected = true
            } else {
                paramValue1.isSelected = true
            }
            
        case .o2r:
            paramValue1.titleL.text = "90-95"
            paramValue1.stringValue = "Borderline"
            paramValue2.titleL.text = "95-97"
            paramValue2.stringValue = "Normal"
            paramValue3.titleL.text = "Above 97"
            paramValue3.stringValue = "Good"
            
            if (paramValue >= 90 && paramValue <= 95) {
                paramValue1.isSelected = true
            } else if (paramValue >= 95 && paramValue <= 97) {
                paramValue2.isSelected = true
            } else {
                paramValue3.isSelected = true
            }
            
        case .bmi:
            paramValue1.titleL.text = "Below 18.5"
            paramValue1.stringValue = "Underweight"
            paramValue2.titleL.text = "18.5 - 24.9"
            paramValue2.stringValue = "Normal"
            paramValue3.isHidden = true
            paramValue4.titleL.text = "25 - 30"
            paramValue4.stringValue = "Overweight"
            paramValue5.titleL.text = "Above 30"
            paramValue5.stringValue = "Obese"
            paramBMIOther2ValuesSV.isHidden = false
            
            let doubleValue = Double(data.paramStringValue) ?? 0
            if (doubleValue <= 18.5) {
                paramValue1.isSelected = true
            } else if (doubleValue > 18.5 && doubleValue <= 24.9) {
                paramValue2.isSelected = true
            } else if (doubleValue > 25 && doubleValue <= 30) {
                paramValue4.isSelected = true
            } else {
                paramValue5.isSelected = true
            }
            
        case .bmr:
            paramValuesSV.isHidden = true
            valueRangeTitleL.text = "Value : " + data.paramStringValue
                
        default:
            print("unhandled cases come here")
        }
    }
    
    @IBAction func doneBtnPressed(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
