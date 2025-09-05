//
//  PrakritiQuestionVC.swift
//  SaNaay Wellness
//
//  Created by DEEPAK JAIN on 22/10/23.
//

import UIKit
import Alamofire
import SDWebImage

class PrakritiQuestionVC: UIViewController {

    var int_patienID = 29
    var screenFrom = ScreenType.none
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_count: UILabel!
    @IBOutlet weak var btn_left_arrow: UIButton!
    @IBOutlet weak var btn_right_arrow: UIButton!
    @IBOutlet weak var img_Question: UIImageView!
    @IBOutlet weak var collect_View: UICollectionView!
    
    var dic_AllData = [String: Any]()
    var arrAllQuestions:[[String: Any]] = [[String: Any]]()
    var arrQuestions:[[String: Any]] = [[String: Any]]()
    var arrAnswers:[[String: String]] = [[String: String]]()
    var dicAnswers:[Int: Int] = [Int: Int]()
    var arrCompletedQuestions: [[String: Any]] = [[String: Any]]()
    
    var arrAnswersKapha:[Int] = [Int]()
    var arrAnswersVata:[Int] = [Int]()
    var arrAnswersPitha:[Int] = [Int]()
    
    var currentQuestionIndex = 0
    var isCompletedQuestions = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.lbl_Title.text = "Prakriti"
        self.btn_left_arrow.isHidden = true
        self.btn_right_arrow.isHidden = true
        self.collect_View.register(UINib.init(nibName: "PrakritiQuestionCollectionCell", bundle: nil), forCellWithReuseIdentifier: "PrakritiQuestionCollectionCell")
        
        self.getQuestionsFromServer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    //MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btn_left_Action(_ sender: UIButton) {
        if self.currentQuestionIndex > 0 {
            self.currentQuestionIndex -= 1
            if self.currentQuestionIndex  == 0 {
                self.btn_left_arrow.isHidden = true
            }
            self.btn_right_arrow.isHidden = false
            self.lbl_count.text = "\(self.currentQuestionIndex + 1)/\(self.arrAllQuestions.count)"
            self.collect_View.scrollToItem(at: IndexPath.init(row: self.currentQuestionIndex, section: 0), at: .centeredHorizontally, animated: true)
        }
        else {
            self.btn_left_arrow.isHidden = true
        }
    }
    
    @IBAction func btn_right_Action(_ sender: UIButton) {
        self.currentQuestionIndex += 1
        self.btn_left_arrow.isHidden = false
        self.collect_View.scrollToItem(at: IndexPath.init(row: currentQuestionIndex, section: 0), at: .centeredHorizontally, animated: true)
        self.lbl_count.text = "\(self.currentQuestionIndex + 1)/\(self.arrAllQuestions.count)"
        
        if self.currentQuestionIndex >= self.arrQuestions.count - 1 {
            self.btn_right_arrow.isHidden = true
            return
        }
    }
}

extension PrakritiQuestionVC {
    func getQuestionsFromServer () {
        
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)

            let urlString = BASE_URL + APIEndpoints.get_prakriti_questions.rawValue
            let params = ["language_id" : "1"] as [String : Any]
            
            Alamofire.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default, headers: Utils.apiCallHeaders).validate().responseJSON(queue: DispatchQueue.main, options: JSONSerialization.ReadingOptions.allowFragments)  { [weak self] response in
                guard let `self` = self else {
                    return
                }
                DismissProgressHud()
                switch response.result {
                case .success(let value):
                    print(response)
                    guard let dicResponse = (value as? Dictionary<String,AnyObject>) else {
                        DispatchQueue.main.async(execute: {
                            DismissProgressHud()
                        })
                        return
                    }
                    
                    if dicResponse["status"] as? String == "error" {
                        DispatchQueue.main.async(execute: {
                            DismissProgressHud()
                            Utils.showAlertOkController(title: "", message: (dicResponse["message"] as? String ?? ""), buttons: ["Ok"]) { success in
                            }
                        })
                        return
                    }
                    
                    DispatchQueue.main.async(execute: {
                        DismissProgressHud()
                    })
                    let arrQuestions = dicResponse["data"] as? [[String: Any]] ?? [[:]]

                    let sortedQuestions = arrQuestions.sorted(by: { (dic1, dic2) -> Bool in
                        let questionID1 = Int((dic1["id"] as? String ?? "0")) ?? 0
                        let questionID2 = Int((dic2["id"] as? String ?? "0")) ?? 0
                        return questionID1 < questionID2
                    })
                    self.arrAllQuestions = sortedQuestions
                    if !self.arrAllQuestions.isEmpty {
                        self.updateData()
                    }
                case .failure(let error):
                    print(error)
                    Utils.showAlertWithTitleInControllerWithCompletion(AppMessage.appName, message: error.localizedDescription, okTitle: "Ok", controller: self) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                DispatchQueue.main.async(execute: {
                    DismissProgressHud()
                })
            }
        } else {
            Utils.showAlertWithTitleInControllerWithCompletion(AppMessage.appName, message: AppMessage.no_internet, okTitle: "Ok", controller: self) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func callAPIforSubmitPrakriti(prakriti: String, presentage: String) {
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            let urlString = BASE_URL + APIEndpoints.Ksubmit_prakritiQuestion.rawValue
            
            let params = ["patient_id": self.int_patienID,
                          "language_id": 1,
                          "prakriti_type": 2,
                          "prakriti_value": prakriti,
                          "prakriti_percentage": presentage,
                          "prakriti_answers": self.arrAnswers.jsonStringRepresentation ?? ""] as [String : Any]

            debugPrint("Perameters=========>>\(params)")
            
            Alamofire.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default,headers: Utils.apiCallHeaders).responseJSON  { response in
                switch response.result {
                    
                case .success(let values):
                    print(response)
                    guard let dicResponse = (values as? Dictionary<String,AnyObject>) else {
                        DispatchQueue.main.async(execute: {
                            DismissProgressHud()
                        })
                        return
                    }
                    
                    if dicResponse["status"] as? String == "error" {
                        DispatchQueue.main.async(execute: {
                            DismissProgressHud()
                            Utils.showAlertOkController(title: "", message: (dicResponse["message"] as? String ?? ""), buttons: ["Ok"]) { success in
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                        return
                    }
                    
                    debugPrint(dicResponse)
                    
                    if self.screenFrom == .edit_prakriti {
                        if let stackVCs = self.navigationController?.viewControllers {
                            if let activeSubVC = stackVCs.first(where: { type(of: $0) == PatientHistoryVC.self }) {
                                (activeSubVC as? PatientHistoryVC)?.callAPIforPatientHistoryList()
                                self.navigationController?.popToViewController(activeSubVC, animated: true)
                            }
                            if let activeSubVC = stackVCs.first(where: { type(of: $0) == PatientListVC.self }) {
                                (activeSubVC as? PatientListVC)?.is_update_details = true
                                (activeSubVC as? PatientListVC)?.callAPIforPatientList()
                            }
                        }
                        self.navigationController?.popViewController(animated: true)
                    }
                    else {
                        let vc = VikratiResultVC.instantiate(fromAppStoryboard: .Dashboard)
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    
                    
                    

                case .failure(let error):
                    Utils.showAlertWithTitleInController("", message: error.localizedDescription, controller: self)
                }
                DispatchQueue.main.async(execute: {
                    DismissProgressHud()
                })
            }
        }else {
            Utils.showAlertWithTitleInController("", message: AppMessage.no_internet, controller: self)
        }
    }

    func postQuestionsData(value: String, answers: String, score: String) {
//        if Utils.isConnectedToNetwork() {
//            Utils.startActivityIndicatorInView(self.view, userInteraction: false)
//            let urlString = kBaseNewURL + endPoint.save_userDetails.rawValue
//            var params = ["user_prakriti": value, "answers": answers, "score": score]
//            params.addPrakritiResultFinalValue()
//
//            AF.request(urlString, method: .post, parameters: params, encoding:URLEncoding.default,headers: headers).responseJSON  { response in
//
//                switch response.result {
//
//                case .success(let values):
//                    print(response)
//                    guard let dic = (values as? [String: Any]) else {
//                        return
//                    }
//                    if (dic["status"] as? String ?? "") == "Sucess" {
//                        let newValue = Utils.parseValidValue(string: value)
//                        kUserDefaults.set(newValue, forKey: RESULT_PRAKRITI)
//                        self.clearSavedData()
//                        kUserDefaults.giftClaimedPrakritiQuestionIndices = []
//                        if !self.isFromOnBoarding {
//                            self.navigationController?.isNavigationBarHidden = false
//                        }
//                        /*
//                        let storyBoard = UIStoryboard(name: "PrakritiResult", bundle: nil)
//                        let objDescription = storyBoard.instantiateViewController(withIdentifier: "PrakritiResult") as! PrakritiResult
//                        objDescription.isRegisteredUser = !kSharedAppDelegate.userId.isEmpty
//                        self.navigationController?.pushViewController(objDescription, animated: true)
//                        */
        
        let newValue = Utils.parseValidValue(string: value)
        //kUserDefaults.set(newValue, forKey: RESULT_PRAKRITI)
        
        //let storyBoard = UIStoryboard(name: "SparshnaResult", bundle: nil)
        //let objVC = storyBoard.instantiateViewController(withIdentifier: "PrakritiResultVC") as! PrakritiResultVC
        //objVC.dic_AllData = self.dic_AllData
        //self.navigationController?.pushViewController(objVC, animated: true)
//
//                    } else {
//                        Utils.showAlertWithTitleInController(APP_NAME, message: (dic["Message"] as? String ?? ""), controller: self)
//                    }
//
//                case .failure(let error):
//                    Utils.showAlertWithTitleInController(APP_NAME, message: error.localizedDescription, controller: self)
//                }
//                DispatchQueue.main.async(execute: {
//                    Utils.stopActivityIndicatorinView(self.view)
//                })
//            }
//        }else {
//            Utils.showAlertWithTitleInController(APP_NAME, message: NO_NETWORK, controller: self)
//        }
    }
    
    
}


extension PrakritiQuestionVC {
        
    func updateData() {
        self.manageSection()
    }
    
    func clearSavedData() {
        //kUserDefaults.set(nil, forKey: kPrakritiAnswers)
        //kUserDefaults.set(nil, forKey: kSkippedQuestions)
    }
}


//MARK: UITableView Delegates and Datasource Method

extension PrakritiQuestionVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func manageSection() {
        self.arrQuestions.removeAll()
        if arrAllQuestions.count != 0 {
            self.arrQuestions.append(self.arrAllQuestions[0])
        }
        self.collect_View.reloadData()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.arrQuestions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PrakritiQuestionCollectionCell", for: indexPath) as! PrakritiQuestionCollectionCell

        let questionID = Int((self.arrQuestions[indexPath.row]["question_id"] as? String ?? "0")) ?? 0
        let str_img_question = self.arrQuestions[indexPath.row]["image"] as? String ?? ""
        self.img_Question.sd_setImage(with: URL(string: str_img_question), placeholderImage: nil)

        cell.btn_Option1.addTarget(self, action: #selector(btn_option_1_Clicked(sender:)), for: .touchUpInside)
        cell.btn_Option1.tag = currentQuestionIndex
        cell.btn_Option1.accessibilityLabel = "\(0)"
        cell.btn_Option1.accessibilityValue = "\(questionID)"

        cell.btn_Option2.addTarget(self, action: #selector(btn_option_2_Clicked(sender:)), for: .touchUpInside)
        cell.btn_Option2.tag = currentQuestionIndex
        cell.btn_Option2.accessibilityLabel = "\(1)"
        cell.btn_Option2.accessibilityValue = "\(questionID)"
        
        cell.btn_Option3.addTarget(self, action: #selector(btn_option_3_Clicked(sender:)), for: .touchUpInside)
        cell.btn_Option3.tag = currentQuestionIndex
        cell.btn_Option3.accessibilityLabel = "\(2)"
        cell.btn_Option3.accessibilityValue = "\(questionID)"
        
        cell.btn_Option4.addTarget(self, action: #selector(btn_option_4_Clicked(sender:)), for: .touchUpInside)
        cell.btn_Option4.tag = currentQuestionIndex
        cell.btn_Option4.accessibilityLabel = "\(3)"
        cell.btn_Option4.accessibilityValue = "\(questionID)"
          
        cell.lbl_Option1.textColor = .black
        cell.lbl_Option2.textColor = .black
        cell.lbl_Option3.textColor = .black
        cell.lbl_Option4.textColor = .black
        cell.btn_Option1.backgroundColor = UIColor.init(hex: "E5F4E4")
        cell.btn_Option2.backgroundColor = UIColor.init(hex: "E5F4E4")
        cell.btn_Option3.backgroundColor = UIColor.init(hex: "E5F4E4")
        cell.btn_Option4.backgroundColor = UIColor.init(hex: "E5F4E4")

        cell.lbl_Question.text = self.arrQuestions[indexPath.row]["question"] as? String ?? ""
        
        var btn_Option_ID_1 = ""
        var btn_Option_ID_2 = ""
        var btn_Option_ID_3 = ""
        var btn_Option_ID_4 = ""
        if let optionsArray = self.arrQuestions[indexPath.row]["options"] as? [[String: Any]], optionsArray.count >= 4 {
            let sortedOptions = optionsArray.sorted(by: { (dic1, dic2) -> Bool in
                let optionId1 = Int((dic1["id"] as? String ?? "0")) ?? 0
                let optionId2 = Int((dic2["id"] as? String ?? "0")) ?? 0
                return optionId1 < optionId2
            })
            btn_Option_ID_1 = sortedOptions[0]["id"] as? String ?? ""
            btn_Option_ID_2 = sortedOptions[1]["id"] as? String ?? ""
            btn_Option_ID_3 = sortedOptions[2]["id"] as? String ?? ""
            btn_Option_ID_4 = sortedOptions[3]["id"] as? String ?? ""
                
            cell.lbl_Option1.text = sortedOptions[0]["qoption"] as? String ?? ""
            cell.lbl_Option2.text = sortedOptions[1]["qoption"] as? String ?? ""
            cell.lbl_Option3.text = sortedOptions[2]["qoption"] as? String ?? ""
            cell.lbl_Option4.text = sortedOptions[3]["qoption"] as? String ?? ""
            
            cell.btn_Option1.accessibilityHint = btn_Option_ID_1
            cell.btn_Option2.accessibilityHint = btn_Option_ID_2
            cell.btn_Option3.accessibilityHint = btn_Option_ID_3
            cell.btn_Option4.accessibilityHint = btn_Option_ID_4
        }
            
        if let getIndx = self.arrAnswers.firstIndex(where: { dic_ans in
            return Int(dic_ans["question_id"] ?? "") ?? 0 == questionID
        }) {
            let str_ansID = self.arrAnswers[getIndx]["answer_id"] ?? ""
            if str_ansID == btn_Option_ID_1 {
                cell.lbl_Option1.textColor = .white
                cell.btn_Option1.backgroundColor = AppColor.app_GreenColor
            } else if str_ansID == btn_Option_ID_2 {
                cell.lbl_Option2.textColor = .white
                cell.btn_Option2.backgroundColor = AppColor.app_GreenColor
            } else if str_ansID == btn_Option_ID_3 {
                cell.lbl_Option3.textColor = .white
                cell.btn_Option3.backgroundColor = AppColor.app_GreenColor
            }else if str_ansID == btn_Option_ID_4 {
                cell.lbl_Option4.textColor = .white
                cell.btn_Option4.backgroundColor = AppColor.app_GreenColor
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    @objc func btn_option_1_Clicked(sender: UIControl) {
        self.click_answer_selection_update(sender)
    }
    
    @objc func btn_option_2_Clicked(sender: UIControl) {
        self.click_answer_selection_update(sender)
    }
    
    @objc func btn_option_3_Clicked(sender: UIControl) {
        self.click_answer_selection_update(sender)
    }
    
    @objc func btn_option_4_Clicked(sender: UIControl) {
        self.click_answer_selection_update(sender)
    }
    
    func click_answer_selection_update(_ sender: UIControl) {
        let questionID = sender.accessibilityValue ?? ""
        let answer_ID = sender.accessibilityHint ?? ""
        let answer_Points = sender.accessibilityLabel ?? ""
        if let getIndx = self.arrAnswers.firstIndex(where: { dic_ans in
            return (dic_ans["question_id"] ?? "") == questionID
        }) {
            self.dicAnswers[Int(questionID) ?? 0] = Int(answer_Points)
            self.arrAnswers[getIndx]["answer_id"] = answer_ID
            self.collect_View.reloadData()

            if self.arrAnswers.count == arrQuestions.count {
                moveToNextAccount()
            }
            return
        }
        
        self.dicAnswers[Int(questionID) ?? 0] = Int(answer_Points)
        
        let dic_new = ["question_id": questionID, "answer_id": answer_ID]
        self.arrAnswers.append(dic_new)
            
        moveToNextAccount()
    }
    
    func moveToNextAccount() {
        DispatchQueue.main.async {
            guard self.currentQuestionIndex + 1 < self.arrAllQuestions.count else {
                self.currentQuestionIndex += 1
                self.collect_View.reloadData()
                
                if self.currentQuestionIndex == self.arrAllQuestions.count {
                    self.calculateResult()
                }
                
                return
            }
            self.currentQuestionIndex += 1
            self.btn_left_arrow.isHidden = false
            self.arrQuestions.append(self.arrAllQuestions[self.currentQuestionIndex])
            self.collect_View.reloadData()
            self.collect_View.scrollToItem(at: IndexPath.init(row: self.arrQuestions.count - 1, section: 0), at: .centeredHorizontally, animated: true)
            self.lbl_count.text = "\(self.currentQuestionIndex + 1)/\(self.arrAllQuestions.count)"
        }
    }
    
    
    func calculateResult() {
        //MARK:- 1 to 10 10 to 20 and 20 to 30
        let kaphaQuestions = Array(self.arrAllQuestions[0..<5])
        for question in kaphaQuestions {
            let questionID = Int((question["question_id"] as? String ?? "0")) ?? 0
            if let value = dicAnswers[questionID] {
                arrAnswersKapha.append(value)
            }
        }
        
        let pittaQuestions = Array(self.arrAllQuestions[5..<10])
        for question in pittaQuestions {
            let questionID = Int((question["question_id"] as? String ?? "0")) ?? 0
            if let value = dicAnswers[questionID] {
                arrAnswersPitha.append(value)
            }
        }
        
        let vataQuestions = Array(self.arrAllQuestions[10..<15])
        for question in vataQuestions {
            let questionID = Int((question["question_id"] as? String ?? "0")) ?? 0
            if let value = dicAnswers[questionID] {
                arrAnswersVata.append(value)
            }
        }
        
        
        let totalKaphAnswered: Double = Double(arrAnswersKapha.reduce(0, { x, y  in
            x + y
        }))
        
        let totalPithaAnswered: Double = Double(arrAnswersPitha.reduce(0, { x, y  in
            x + y
        }))
        
        let totalVataAnswered: Double = Double(arrAnswersVata.reduce(0, { x, y  in
            x + y
        }))
        
        let total = totalPithaAnswered + totalKaphAnswered + totalVataAnswered
        
        guard total != 0 else {
            Utils.showAlertWithTitleInControllerWithCompletion("Error", message: "Please retake the test and answer as accurately as possible.", okTitle: "Ok", controller: self) {
                self.clearSavedData()
                self.navigationController?.popToRootViewController(animated: true)
            }
            return
        }
        
        let percentPitha = totalPithaAnswered * 100.0/total
        
        let percentKapha = totalKaphAnswered * 100.0/total
        
        let percentVata =  totalVataAnswered * 100.0/total
        //KPV
        let result = "[" + "\"\(percentKapha.roundToOnePlace)\",\"\(percentPitha.roundToOnePlace)\",\"\(percentVata.roundToOnePlace)\"" + "]"
        
        let k_Prensetange = Int(percentKapha.rounded(.up))
        let p_Prensetange = Int(percentPitha.rounded(.up))
        let v_Prensetange = 100 - k_Prensetange - p_Prensetange
        let currentPraktitiStatus = Utils.getCustom_Prakriti(k_cout: k_Prensetange, p_cout: p_Prensetange, v_cout: v_Prensetange)

        self.callAPIforSubmitPrakriti(prakriti: currentPraktitiStatus.rawValue, presentage: result)
    }
    
}
