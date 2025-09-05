//
//  PatientResultListVC.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 24/03/24.
//

import UIKit

class PatientResultListVC: UIViewController {

    @IBOutlet weak var lbl_title: UILabel!
    @IBOutlet weak var lbl_completed: UILabel!
    @IBOutlet weak var view_result1: UIView!
    @IBOutlet weak var view_result2: UIView!
    @IBOutlet weak var view_result3: UIView!
    
    var strPatientName = ""
    var dic_response: PatientListDataResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.lbl_title.text = "\(self.strPatientName) results"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_result_Action(_ sender: UIButton) {
    }
}
