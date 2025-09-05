//
//  OTPDialogVC.swift
//  HourOnEarth
//
//  Created by DEEPAK JAIN on 10/03/23.
//  Copyright © 2023 AyuRythm. All rights reserved.
//

import UIKit
import SVPinView
import Alamofire
import FirebaseAuth


class OTPDialogVC: UIViewController {

    var timer = Timer()
    var remainingSeconds = 59
    var strMobileNo = ""
    var strCountryCode = ""
    var str_enteredOTP = ""
    var verificationID = ""
    var isButtonEnable = false
    var delegate: delegateDoneAction?
    var super_vc = UIViewController()
    var screenFrom = ScreenType.none
    @IBOutlet weak var pinView: SVPinView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lbl_topText: UILabel!
    @IBOutlet weak var lbl_bottomText: UILabel!
    @IBOutlet weak var btn_Next: UIControl!
    @IBOutlet weak var btn_Resend: UIButton!
    @IBOutlet weak var view_Main: UIView!
    @IBOutlet weak var constraint_viewMain_Bottom: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.isButtonEnable = false
        self.btn_Next.backgroundColor = AppColor.app_BorderGrayColor
        
        self.setUpLabel()
        self.configurePinView()
        
        if self.screenFrom == .add_patient {
        }
        else {
            self.generateOTPFromServer()
        }
        
        self.constraint_viewMain_Bottom.constant = -UIScreen.main.bounds.size.height
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        self.perform(#selector(show_animation), with: nil, afterDelay: 0.1)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
        
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.constraint_viewMain_Bottom.constant = keyboardSize.size.height/2
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.constraint_viewMain_Bottom.constant = 0
        self.view.layoutIfNeeded()
    }
    
    func configurePinView() {
        self.pinView.style = .box
        self.pinView.pinLength = 6
        self.pinView.textColor = UIColor.black
        //self.pinView.interSpace = 5
        self.pinView.placeholder = ""
        self.pinView.fieldCornerRadius = 8
        self.pinView.activeFieldCornerRadius = 8
        self.pinView.borderLineThickness = 1
        self.pinView.keyboardType = .phonePad
        self.pinView.shouldSecureText = false
        self.pinView.allowsWhitespaces = false
        self.pinView.secureCharacter = "\u{25CF}"
        self.pinView.activeBorderLineThickness = 1
        self.pinView.isContentTypeOneTimeCode = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.pinView.becomeFirstResponderAtIndex = 0
        }
        self.pinView.font = UIFont.AppFontMedium(18)
        self.pinView.borderLineColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1) //AAAAAA
        self.pinView.activeBorderLineColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1) //AAAAAA
        self.pinView.fieldBackgroundColor = .clear
        self.pinView.activeFieldBackgroundColor = .clear
        
        self.pinView.pinInputAccessoryView = { () -> UIView in
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
            doneToolbar.barStyle = UIBarStyle.default
            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(dismissKeyboard))
            
            var items = [UIBarButtonItem]()
            items.append(flexSpace)
            items.append(done)
            
            doneToolbar.items = items
            doneToolbar.sizeToFit()
            return doneToolbar
        }()
        
        self.pinView.didFinishCallback = didFinishEnteringPin(pin:)
        self.pinView.didChangeCallback = { pin in
            self.str_enteredOTP = pin
            if pin.count >= 6 {
                self.isButtonEnable = true
                self.btn_Next.backgroundColor = AppColor.app_GreenColor
            }
            else {
                self.isButtonEnable = false
                self.btn_Next.backgroundColor = AppColor.app_BorderGrayColor
            }
        }
    }
    
    @objc func dismissKeyboard() {
            self.view.endEditing(false)
        }

    func didFinishEnteringPin(pin:String) {
        self.str_enteredOTP = pin
    }
    
    @objc func show_animation() {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.constraint_viewMain_Bottom.constant = 0
            self.view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            self.view.layoutIfNeeded()
        }) { (success) in
        }
    }
    
    func clkToClose(_ action: Bool = false) {
        UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.timer.invalidate()
            self.constraint_viewMain_Bottom.constant = -UIScreen.main.bounds.size.height
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
    
    func setTimer() {
        self.timer.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        print("Remaining Second:========\(self.remainingSeconds)")
        self.lbl_bottomText.text = self.timeFormatted(self.remainingSeconds) // will show timer
        if self.remainingSeconds != 0 {
            self.remainingSeconds -= 1  // decrease counter timer
        } else {
            self.timer.invalidate()
            self.setupBotttomText()
            self.btn_Resend.isHidden = false
        }
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        return String(format: "Didn’t receive OTP? Resend in %02d Sec", seconds)
    }
    
    func setupBotttomText() {
        let str_resend = "Didn’t receive OTP? Resend"
        let newText = NSMutableAttributedString.init(string: str_resend)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontMedium(15), range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColor.app_TextGrayColor, range: NSRange.init(location: 0, length: newText.length))
        let textRange = NSString(string: str_resend)
        
        let termrange = textRange.range(of: "Resend")
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontMedium(15), range: termrange)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColor.app_TextBlueColor, range: termrange)
        self.lbl_bottomText.attributedText = newText
    }

    func setUpLabel() {
        let str_enter_Number = "Please enter the OTP sent to \(self.strMobileNo)  Edit"
        let newText = NSMutableAttributedString.init(string: str_enter_Number)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontMedium(15), range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColor.app_TextGrayColor, range: NSRange.init(location: 0, length: newText.length))
        let textRange = NSString(string: str_enter_Number)
        
        let termrange = textRange.range(of: "Edit")
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontMedium(15), range: termrange)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColor.app_TextBlueColor, range: termrange)
        
        
        let mobilerange = textRange.range(of: self.strMobileNo)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontBold(15), range: mobilerange)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: mobilerange)

        self.lbl_topText.attributedText = newText
        
        
        self.lbl_topText.isUserInteractionEnabled = true
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnLabel(_ :)))
        self.lbl_topText.addGestureRecognizer(tapgesture)
    }

    //MARK:- tappedOnLabel
    @objc func tappedOnLabel(_ gesture: UITapGestureRecognizer) {
        guard let text = self.lbl_topText.text else { return }
        let register_Range = (text as NSString).range(of: "Edit")
        if gesture.didTapAttributedTextInLabel(label: self.lbl_topText, inRange: register_Range) {
            print("user tapped on Edit")
            self.clkToClose()
        }
    }
    

    //MARK: - UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: - Button Action
    @IBAction func btn_close(_ sender: UIButton) {
        self.clkToClose()
    }
    
    @IBAction func btn_edit_Action(_ sender: UIButton) {
        self.clkToClose()
    }

    // MARK: - UIButton Action
    @IBAction func btn_Resend_Action(_ sender: UIButton) {
        self.remainingSeconds = 59
        self.btn_Resend.isHidden = true
        self.generateOTPFromServer()
    }
    
    @IBAction func btn_Next_Action(_ sender: UIControl) {
        self.view.endEditing(true)
        if self.isButtonEnable {
            self.callApiforVerifyOTP()
        }
    }

}


extension OTPDialogVC {
    
    func callApiforVerifyOTP() {
        if Connectivity.isConnectedToInternet {
            //Firebase OTP generator
            ShowProgressHud(message: AppMessage.plzWait)
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: str_enteredOTP)

            Auth.auth().signIn(with: credential) { (authResult, error) in
                DispatchQueue.main.async(execute: {
                    DismissProgressHud()
                })
                if let _ = error {
                     //let authError = error as NSError
                    appDelegate.window?.rootViewController?.view.makeToast("Failed to validate OTP, please try again.")
                    return
                }
                self.clkToClose(true)
            }
        } else {
            appDelegate.window?.rootViewController?.view.makeToast(AppMessage.no_internet)
        }
    }
    
    func generateOTPFromServer() {
        self.setTimer()
        
        if Connectivity.isConnectedToInternet {
            //Firebase OTP generator
            ShowProgressHud(message: AppMessage.plzWait)

            let phone = self.strCountryCode + self.strMobileNo
            print("phone=",phone)
            PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { (verificationID, error) in
                DispatchQueue.main.async(execute: {
                    DismissProgressHud()
                })
                if let error = error {
                    print("### OTP error : ", error.localizedDescription)
                    appDelegate.window?.rootViewController?.view.makeToast(error.localizedDescription)
                    return
                }
                self.verificationID = verificationID ?? ""
            }
        }else {
            appDelegate.window?.rootViewController?.view.makeToast(AppMessage.no_internet)
        }
    }
}
