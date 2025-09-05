//
//  EditPrakritiVC.swift
//  SaNaay
//
//  Created by DEEPAK JAIN on 02/08/24.
//

import UIKit

class EditPrakritiVC: UIViewController {

    var is_screenType = ScreenType.prakriti_doctor
    @IBOutlet weak var lbl_navHeader: UILabel!
    @IBOutlet weak var lbl_aggravation: UILabel!
    @IBOutlet weak var lbl_prakriti_sanaay: UILabel!
    @IBOutlet weak var lbl_prakriti_doctor: UILabel!
    @IBOutlet weak var img_prakriti_sanaay: UIImageView!
    @IBOutlet weak var img_prakriti_doctor: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.lbl_aggravation.text = "Patient's Prakriti is \(appDelegate.dic_patient_response?.prakriti ?? "")"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_Prakriti_SaNaaY_Action(_ sender: UIControl) {
        UIView.animate(withDuration: 0.3) {
            self.is_screenType = ScreenType.prakriti_sanaay
            self.img_prakriti_sanaay.image = UIImage.init(named: "icon_selected")
            self.img_prakriti_doctor.image = UIImage.init(named: "icon_unselected")
        }
    }
    
    @IBAction func btn_Prakriti_Doctor_Action(_ sender: UIControl) {
        UIView.animate(withDuration: 0.3) {
            self.is_screenType = ScreenType.prakriti_doctor
            self.img_prakriti_doctor.image = UIImage.init(named: "icon_selected")
            self.img_prakriti_sanaay.image = UIImage.init(named: "icon_unselected")
        }
    }
    
    @IBAction func btn_Continue_Action(_ sender: UIControl) {
        if self.is_screenType == ScreenType.prakriti_sanaay {
            let obj = Story_Assessment.instantiateViewController(withIdentifier: "PrakritiQuestionVC") as! PrakritiQuestionVC
            obj.screenFrom = ScreenType.edit_prakriti
            self.navigationController?.pushViewController(obj, animated: true)
        }
        else {
            let vc = PredictedPrakritiVC.instantiate(fromAppStoryboard: .Dashboard)
            vc.screenFrom = ScreenType.edit_prakriti
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}
