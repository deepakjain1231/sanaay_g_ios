//
//  LoginVC.swift
//  Sanaay
//
//  Created by Deepak Jain on 12/08/22.
//

import UIKit
import FirebaseAuth
import AuthenticationServices

class LoginVC: UIViewController, UITextFieldDelegate, countryPickDelegate, AuthUIDelegate {
    
    private var strAlready_account = "Don’t have an account? Register"
    private var strUnderLineText = "Register"

    var is_newUser = false
    var verificationID = ""
    var str_Mobile = ""
    var str_CountryCode = ""
    var str_SelectedCountry = Country(code: "", name: "", phoneCode: "")
    @IBOutlet weak var lbl_countryCode: UILabel!
    @IBOutlet weak var txt_Mobile: UITextField!
    @IBOutlet weak var lbl_regisrerText: UILabel!
    @IBOutlet weak var btn_Next: UIControl!
    @IBOutlet weak var btn_CountryCode: UIControl!
    @IBOutlet weak var constraint_view_Bottom: NSLayoutConstraint!
    private let viewModel: RegisterViewModel = RegisterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.txt_Mobile.delegate = self
        self.txt_Mobile.addDoneToolbar()
        self.setUpLabel()
        
        if let countryCode = (Locale.current as NSLocale).object(forKey: .countryCode) as? String {
            print(countryCode)
            let arr_country =  SMCountry.shared.getAllCountry(withreload: true)
            if let objCounty = arr_country.filter({ dic_country in
                return (dic_country.code ?? "") == countryCode
            }) as? [Country] {
                self.str_SelectedCountry = objCounty.first!
                self.lbl_countryCode.text = objCounty.first?.phoneCode ?? "+91"
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
//        self.txt_Mobile.text = "9998880002"
//        self.lbl_countryCode.text = "+91"
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    func setUpLabel() {
        let newText = NSMutableAttributedString.init(string: strAlready_account)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontMedium(15), range: NSRange.init(location: 0, length: newText.length))
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColor.app_TextGrayColor, range: NSRange.init(location: 0, length: newText.length))
        let textRange = NSString(string: strAlready_account)
        let termrange = textRange.range(of: strUnderLineText)
        newText.addAttribute(NSAttributedString.Key.font, value: UIFont.AppFontMedium(15), range: termrange)
        newText.addAttribute(NSAttributedString.Key.foregroundColor, value: AppColor.app_TextBlueColor, range: termrange)
        self.lbl_regisrerText.attributedText = newText
        
        
        self.lbl_regisrerText.isUserInteractionEnabled = true
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(tappedOnLabel(_ :)))
        self.lbl_regisrerText.addGestureRecognizer(tapgesture)
    }
    
    //MARK:- tappedOnLabel
    @objc func tappedOnLabel(_ gesture: UITapGestureRecognizer) {
        guard let text = self.lbl_regisrerText.text else { return }
        let register_Range = (text as NSString).range(of: strUnderLineText)
        if gesture.didTapAttributedTextInLabel(label: self.lbl_regisrerText, inRange: register_Range) {
            print("user tapped on Register")
            //Go To Register Screen
            let objregister = Story_Main.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
            self.navigationController?.pushViewController(objregister, animated: true)
        }
    }
    
    //MARK: - UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txt_Mobile {
            if string == "0" && (textField.text ?? "").trimed().count == 0 {
                return false
            }
            else {
                let currentString: NSString = textField.text! as NSString
                let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
                let ACCEPTABLE_NUMBERS = "1234567890"
                let cs = NSCharacterSet(charactersIn: ACCEPTABLE_NUMBERS).inverted
                let filtered = string.components(separatedBy: cs).joined(separator: "")
                if string != filtered {
                    return false
                }
                return newString.length <= 10
            }
        }
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
    @IBAction func btn_CountryCode_Action(_ sender: UIControl) {
        self.view.endEditing(true)
        let objDialouge = CountrySelectionVC(nibName:"CountrySelectionVC", bundle:nil)
        objDialouge.delegate = self
        self.addChild(objDialouge)
        objDialouge.view.frame = CGRect.init(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview((objDialouge.view)!)
        objDialouge.didMove(toParent: self)
    }
    
    
    @IBAction func btn_Next_Action(_ sender: UIControl) {
        self.view.endEditing(true)
        self.str_Mobile = self.txt_Mobile.text ?? ""
        self.str_CountryCode = self.lbl_countryCode.text ?? ""
        
        if self.str_Mobile == "" {
            self.view.makeToast("Please enter mobile number.")
            return
        }
        if self.str_Mobile.count != 10 {
            self.view.makeToast("Please enter correct mobile number.")
            return
        }
        
        self.callAPIforLoginDoctor()
        
    }
    
    @IBAction func btn_Register_Action(_ sender: UIControl) {
        self.view.endEditing(true)
        self.goToRegisterScreen()
    }
    
    //MARK: - Country Selection
    func selectCountry(screenFrom: String, is_Pick: Bool, selectedCountry: Country?) {
        if is_Pick {
            self.lbl_countryCode.text = selectedCountry?.phoneCode
            self.txt_Mobile.becomeFirstResponder()
        }
    }
 
    
    func goToRegisterScreen() {
        //Go To Register Screen
        let objRegister = Story_Main.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
        objRegister.str_mobile = self.txt_Mobile.text ?? ""
        objRegister.str_country_code = self.lbl_countryCode.text ?? ""
        self.navigationController?.pushViewController(objRegister, animated: true)
    }
}

//MARK: - API CALL
extension LoginVC: delegate_resend_otp {
    
    func callAPIforLoginDoctor() {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            
            let params = ["mobile": self.str_Mobile]
            
            self.viewModel.login_doctor(body: params, endpoint: APIEndpoints.LoginDoctor) { status, result, error in
                switch status {
                case .loading:
                    break
                case .success:
                    DismissProgressHud()
                    if result?.status == "success" {
                        guard let dic_result = result?.data else {
                            return
                        }
                        guard let dataaa = result?.data else {
                            return
                        }
                        self.is_newUser = false
                        self.generateOTPFromServer()

                        setUserDataInUserDefault(dataaa)
                        kUserDefaults.set(dataaa.token ?? "", forKey: AppMessage.Authorise_Token)
                        
                    }
                    else {
                        DismissProgressHud()
                        self.is_newUser = true
                        let str_msg = result?.message ?? "Doctor not registered"
                        
                        let alertController = UIAlertController(title: "", message: str_msg , preferredStyle: .alert)

                        let action_tryAgain = UIAlertAction(title: "Try again", style: .default) { actionn in
                            self.txt_Mobile.text = ""
                        }
                        
                        let actionsign_up = UIAlertAction(title: "Sign up", style: .default) { actionn in
                            self.goToRegisterScreen()
                        }

                        alertController.addAction(action_tryAgain)
                        alertController.addAction(actionsign_up)
                        self.present(alertController, animated: true)
                        
                        
                        //self.generateOTPFromServer()
                    }
                    break
                case .error:
                    DismissProgressHud()
                    break
                }
            }
        }else {
            DismissProgressHud()
            self.view.makeToast(AppMessage.no_internet)
        }
    }
    
    func generateOTPFromServer() {
        if Connectivity.isConnectedToInternet {
            //Firebase OTP generator
            ShowProgressHud(message: AppMessage.plzWait)
            let phone = (self.lbl_countryCode.text ?? "") + (self.txt_Mobile.text ?? "")
            print("phone=",phone)
            
            PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: self) { verificationID, error in
                DispatchQueue.main.async(execute: {
                    DismissProgressHud()
                })
                if let error = error {
                    print("### OTP error : ", error.localizedDescription)
                    Utils.showAlertWithTitleInController("Error", message: "Please enter valid mobile number.", controller: self)
                    return
                }
                self.verificationID = verificationID ?? ""
                
                var is_verification_screen = false
                if let stackVCs = self.navigationController?.viewControllers {
                    if let activeSubVC = stackVCs.first(where: { type(of: $0) == OTPVerificationVC.self }) {
                        is_verification_screen = true
                        (activeSubVC as? OTPVerificationVC)?.verificationID = self.verificationID
                    }
                }
                
                if is_verification_screen == false {
                    self.goToOTPVC()
                }

            }
        }else {
            Utils.showAlertWithTitleInController(AppMessage.appName, message: AppMessage.no_internet, controller: self)
        }
    }
    
    
    func goToOTPVC() {
        //Go To Next Screen
        let objVerification = Story_Main.instantiateViewController(withIdentifier: "OTPVerificationVC") as! OTPVerificationVC
        objVerification.delegate = self
        objVerification.verificationID = self.verificationID
        objVerification.strMobileNo = self.str_Mobile
        objVerification.is_newUser = self.is_newUser
        objVerification.strCountryCode = self.str_CountryCode
        self.navigationController?.pushViewController(objVerification, animated: true)
    }
    
    func api_call_resendOTP(_ success: Bool) {
        if success {
            self.generateOTPFromServer()
        }
    }
}
