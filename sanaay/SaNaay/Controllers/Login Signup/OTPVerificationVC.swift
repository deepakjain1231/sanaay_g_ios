//
//  OTPVerificationVC.swift
//  Sanaay
//
//  Created by Deepak Jain on 12/08/22.
//

protocol delegate_resend_otp {
    func api_call_resendOTP(_ success: Bool)
}


import UIKit
import SVPinView
import FirebaseAuth

class OTPVerificationVC: UIViewController, UITextFieldDelegate {

    var is_newUser = false
    var timer = Timer()
    var remainingSeconds = 59
    var strMobileNo = ""
    var strCountryCode = ""
    var str_enteredOTP = ""
    var verificationID = ""
    var isButtonEnable = false
    var delegate: delegate_resend_otp?
    
    @IBOutlet weak var pinView: SVPinView!
    @IBOutlet weak var lbl_topText: UILabel!
    @IBOutlet weak var lbl_bottomText: UILabel!
    @IBOutlet weak var btn_Next: UIControl!
    @IBOutlet weak var btn_Resend: UIButton!
    @IBOutlet weak var constraint_view_Bottom: NSLayoutConstraint!
    private let viewModel: RegisterViewModel = RegisterViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.isButtonEnable = false
        self.setUpLabel()
        configurePinView()
        self.setTimer()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
        
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
        self.pinView.becomeFirstResponderAtIndex = 0
        self.pinView.font = UIFont.AppFontMedium(18)
        self.pinView.borderLineColor = AppColor.app_BorderGrayColor
        self.pinView.activeBorderLineColor = AppColor.app_BorderGrayColor
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
        
    @objc func keyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.constraint_view_Bottom.constant = keyboardSize.size.height/2
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        self.constraint_view_Bottom.constant = 0
        self.view.layoutIfNeeded()
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
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColor.app_GreenColor, range: termrange)
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
            self.navigationController?.popViewController(animated: true)
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


    // MARK: - UIButton Action
    @IBAction func btn_Resend_Action(_ sender: UIButton) {
        self.remainingSeconds = 59
        self.btn_Resend.isHidden = true
        self.setTimer()
        self.delegate?.api_call_resendOTP(true)
    }
    
    @IBAction func btn_Next_Action(_ sender: UIControl) {
        self.timer.invalidate()
        self.view.endEditing(true)
        if self.isButtonEnable {
            self.callApiforVerifyOTP()
        }
    }
        
}


extension OTPVerificationVC {
    
    func callApiforVerifyOTP() {
        if Connectivity.isConnectedToInternet {
            //Firebase OTP verification
            
            ShowProgressHud(message: AppMessage.plzWait)
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: str_enteredOTP)

            Auth.auth().signIn(with: credential) { (authResult, error) in
                DispatchQueue.main.async(execute: {
                    DismissProgressHud()
                })
               if let _ = error {
                    // let authError = error as NSError
                    Utils.showAlertWithTitleInController("Error", message: "Failed to validate OTP, please try again.", controller: self)
                    return
                }

                self.doProcessAfterOTPVerificationDone()

            }
        } else {
            Utils.showAlertWithTitleInController(AppMessage.appName, message: AppMessage.no_internet, controller: self)
        }
    }
    
    
    func doProcessAfterOTPVerificationDone() {
        // User is signed in
        kUserDefaults.set(true, forKey: AppMessage.USER_LOGIN)
        if self.is_newUser {
            //Go To Register Screen
            let objregister = Story_Main.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
            objregister.str_mobile = self.strMobileNo
            objregister.str_country_code = self.strCountryCode
            self.navigationController?.pushViewController(objregister, animated: true)
        }
        else {
            if getUserDetail()?.clinic == nil {
                //Go To Add Clicnic Screen
                let obj = Story_Main.instantiateViewController(withIdentifier: "Register2VC") as! Register2VC
                self.navigationController?.pushViewController(obj, animated: true)
            }
            else {
                //Go To Home Screen
                let obj = Story_Dashboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                self.navigationController?.pushViewController(obj, animated: true)
            }
        }
    }

}
