//
//  LoginOptionVC.swift
//  Sanaay
//
//  Created by Deepak Jain on 12/08/22.
//

import UIKit

class LoginOptionVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    @IBAction func btn_Login_Action(_ sender: UIControl) {
        //Go To Login Screen
        let objLogin = Story_Main.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(objLogin, animated: true)
    }
    
    @IBAction func btn_Register_Action(_ sender: UIControl) {
        //Go To Register Screen
        let objRegister = Story_Main.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
        self.navigationController?.pushViewController(objRegister, animated: true)
    }
}
