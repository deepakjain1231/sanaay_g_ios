//
//  ContsctUsVC.swift
//  Tavisa_Patient
//
//  Created by DEEPAK JAIN on 21/03/24.
//

import UIKit
import MessageUI

class ContsctUsVC: UIViewController, UITextFieldDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate {

    var textviewPlaceholderMsg = "Enter your message here"
    @IBOutlet weak var txt_sub: UITextField!
    @IBOutlet weak var txt_message: UITextView!
    @IBOutlet weak var btn_submit: UIControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.txt_sub.delegate = self
        self.txt_sub.addDoneToolbar()
        self.txt_message.delegate = self
        self.txt_message.addDoneToolbar()
        self.txt_message.textColor = .lightGray
        self.txt_message.text = self.textviewPlaceholderMsg
        
        self.txt_sub.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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
    
    @IBAction func btn_Submit_Action(_ sender: UIButton) {
        let recipientEmail = "info.sanaay@ayurythm.com"
        let subject = self.txt_sub.text ?? ""
        let body = self.txt_message.text ?? ""
        
        // Show default mail composer
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recipientEmail])
            mail.setSubject(subject)
            mail.setMessageBody(body, isHTML: false)
            
            present(mail, animated: true)
            
            // Show third party email composer if default Mail app is not present
        } else if let emailUrl = createEmailUrl(to: recipientEmail, subject: subject, body: body) {
            UIApplication.shared.open(emailUrl)
        }
        
    }
    
    func createEmailUrl(to: String, subject: String, body: String) -> URL? {
        let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
        
        return gmailUrl
    }
            
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    // MARK: - UITextField Delegate
    @objc func textFieldDidChange(_ textfield: UITextField) {
        self.checkSubmitEnable()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.checkSubmitEnable()
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UITextView Delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if let strText = textView.text {
            if strText == self.textviewPlaceholderMsg {
                textView.text = ""
                self.txt_message.textColor = .black
            }
        }
        self.checkSubmitEnable()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let strText = textView.text {
            if strText == self.textviewPlaceholderMsg {
                textView.text = ""
                self.txt_message.textColor = .black
            }
        }
        self.checkSubmitEnable()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let strText = textView.text {
            if strText == self.textviewPlaceholderMsg || strText == "" {
                textView.text = self.textviewPlaceholderMsg
                self.txt_message.textColor = .lightGray
            }
        }
        self.checkSubmitEnable()
    }
    
    func checkSubmitEnable() {
        var is_check = false
        if (self.txt_sub.text ?? "").trimed() == "" {
            is_check = false
        }
        else {
            is_check = true
        }
        
        if (self.txt_message.text ?? "").trimed() == "" || (self.txt_message.text ?? "") == self.textviewPlaceholderMsg {
            is_check = false
        }
        else {
            is_check = true
        }
        
        
        if is_check {
            self.btn_submit.backgroundColor = AppColor.app_GreenColor
            self.btn_submit.isUserInteractionEnabled = true
        }
        else {
            self.btn_submit.backgroundColor = UIColor.lightGray
            self.btn_submit.isUserInteractionEnabled = false
        }
    }
}
