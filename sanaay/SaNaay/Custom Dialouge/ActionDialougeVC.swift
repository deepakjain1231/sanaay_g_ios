//
//  ActionDialougeVC.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 19/06/23.
//

protocol delegateDoneAction {
    func doneClicked_Action(_ isClicked: Bool, fromScreen: ScreenType, str_type: String)
}

import UIKit

class ActionDialougeVC: UIViewController {

    var delegate: delegateDoneAction?
    var screenFrom = ScreenType.none
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_subTitle: UILabel!
    @IBOutlet weak var btn_dontCancel: UIControl!
    @IBOutlet weak var btn_Cancel: UIControl!
    @IBOutlet weak var lbl_dontCancel: UILabel!
    @IBOutlet weak var lbl_Cancel: UILabel!
    @IBOutlet weak var constraint_view_Bottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setUpLabel()

        self.constraint_view_Bottom.constant = -UIScreen.main.bounds.size.height
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
    }
    
    func setUpLabel() {
        
    }

    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_view_Bottom.constant = 0
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
    
    func clkToClose(_ action: Bool = false) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_view_Bottom.constant = -UIScreen.main.bounds.size.height
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.view.layoutIfNeeded()
        }) { (success) in
            self.willMove(toParent: nil)
            self.view.removeFromSuperview()
            self.removeFromParent()
            
            if action {
                self.delegate?.doneClicked_Action(true, fromScreen: self.screenFrom, str_type: "")
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

    @IBAction func btn_cancel_Action(_ sender: UIControl) {
        self.clkToClose(true)
    }
    
    @IBAction func btn_Dontcancel_Action(_ sender: UIControl) {
        self.clkToClose()
    }
}
