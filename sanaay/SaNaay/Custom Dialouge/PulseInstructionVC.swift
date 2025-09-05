//
//  PulseInstructionVC.swift
//  Tavisa_Patient
//
//  Created by DEEPAK JAIN on 29/06/23.
//

import UIKit

protocol delegate_Pulse_DoneAction {
    func doneClicked_Action(_ isClicked: Bool)
}

class PulseInstructionVC: UIViewController {

    var delegate: delegate_Pulse_DoneAction?
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_Text: UILabel!
    @IBOutlet weak var btn_close: UIControl!
    @IBOutlet weak var img_icon: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupLabel()
        self.view_Base.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.view.backgroundColor = .clear
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
    
    func setupLabel() {
        self.lbl_Text.setBulletListedAttributedText(stringList: ["Place your finger on device", "Remove your finger after the test is done"], paragraphSpacing: 4)
    }
        
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view_Base.transform = .identity
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
    
    func clkToClose(_ is_Action: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.view_Base.transform = CGAffineTransform.init(scaleX: 0.001, y: 0.001)
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()

            if is_Action {
                self.delegate?.doneClicked_Action(true)
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

    
    @IBAction func btn_Close_Action(_ sender: UIControl) {
        if sender.tag == 111 {
            self.clkToClose(false)
        }
        else {
            self.clkToClose(true)
        }
    }
}
