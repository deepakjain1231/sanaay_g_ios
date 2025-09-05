//
//  SelectAggravationDialouge.swift
//  SaNaay
//
//  Created by Deepak Jain on 21/07/24.
//

protocol delegate_selection_Action {
    func aggravation_Action(_ isClicked: Bool, aggravation_type: String)
}


import UIKit

class SelectAggravationDialouge: UIViewController {

    var int_selection = 0
    var str_aggravation_doctor = ""
    var str_aggravation_sanaay = ""
    var delegate: delegate_selection_Action?
    @IBOutlet weak var view_main: UIView!
    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_byDoctor: UILabel!
    @IBOutlet weak var btn_byDoctor: UIControl!
    @IBOutlet weak var img_byDoctor: UIImageView!
    
    @IBOutlet weak var lbl_bySaNaaY: UILabel!
    @IBOutlet weak var btn_bySaNaaY: UIControl!
    @IBOutlet weak var img_bySaNaaY: UIImageView!
    
    @IBOutlet weak var btn_Done: UIControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupData()
        self.btn_Done.isUserInteractionEnabled = false
        self.btn_Done.backgroundColor = AppColor.app_TextGrayColor
        self.view_main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.view.backgroundColor = .clear
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
    
    func setupData() {
        self.lbl_byDoctor.text = "Vikriti by Doctor (\(self.str_aggravation_doctor.capitalized))"
        self.lbl_bySaNaaY.text = "Vikriti by SaNaaY (\(self.str_aggravation_sanaay.capitalized))"
    }

    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view_main.transform = .identity
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
    
    func clkToClose(_ is_Action: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view_main.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()

            if self.int_selection == 1 {
                self.delegate?.aggravation_Action(true, aggravation_type: self.str_aggravation_doctor)
            }
            else {
                self.delegate?.aggravation_Action(true, aggravation_type: self.str_aggravation_sanaay)
            }
            
        }
    }
      

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func btn_byDoctor_action(_ sender: UIControl) {
        self.int_selection = 1
        self.img_byDoctor.image = UIImage.init(named: "radio_button_checked")
        self.img_bySaNaaY.image = UIImage.init(named: "radio_button_unchecked")
        self.btn_Done.isUserInteractionEnabled = true
        self.btn_Done.backgroundColor = AppColor.app_GreenColor
    }
    
    @IBAction func btn_bySaNaaY_action(_ sender: UIControl) {
        self.int_selection = 2
        self.img_bySaNaaY.image = UIImage.init(named: "radio_button_checked")
        self.img_byDoctor.image = UIImage.init(named: "radio_button_unchecked")
        self.btn_Done.isUserInteractionEnabled = true
        self.btn_Done.backgroundColor = AppColor.app_GreenColor
    }
    
    @IBAction func btn_Done_action(_ sender: UIControl) {
        self.clkToClose(true)
    }
    
    @IBAction func btn_close_action(_ sender: UIControl) {
        self.clkToClose(false)
    }

}
