//
//  HowRegisterVC.swift
//  Sanaay
//
//  Created by Deepak Jain on 18/08/22.
//

import UIKit
import WebKit

class HowRegisterVC: UIViewController {

    var strTitle = ""
    var screenFrom = ScreenType.none
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var wkwebview: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.lbl_Title.text = self.strTitle
        
        if self.screenFrom == .is_privacy {
            let request = URLRequest(url: URL(string: kPrivacyPolicy)!)
            wkwebview?.load(request)
        }
        else if self.screenFrom == .about_us {
            let request = URLRequest(url: URL(string: kAbout_Us)!)
            wkwebview?.load(request)
        }
        else if self.screenFrom == .is_termsCondition {
            let request = URLRequest(url: URL(string: kTermsAndCondition)!)
            wkwebview?.load(request)
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
    
    
    // MARK: - Navigation
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
