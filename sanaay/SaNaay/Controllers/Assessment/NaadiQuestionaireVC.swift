//
//  NaadiQuestionaireVC.swift
//  SaNaay
//
//  Created by DEEPAK JAIN on 20/07/24.
//

import UIKit
import Alamofire

class NaadiQuestionaireVC: UIViewController {

    var str_Type = ""
    var indx_section = 1
    var arr_Answers = [[String: Any]]()
    var arr_Question = [[String: Any]]()
    var arr_All_Answers = [[String: Any]]()
    var arr_All_NaadiQuestion = [[String: Any]]()
    @IBOutlet weak var tbl_View: UITableView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var lbl_Header: UILabel!
    @IBOutlet weak var lbl_Question_Count: UILabel!
    @IBOutlet weak var progressbar: UIProgressView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.lbl_Question_Count.text = "\(self.indx_section)/5"
        self.lbl_Header.text = self.str_Type.capitalized
        self.progressbar.layer.cornerRadius = 8
        self.progressbar.transform = self.progressbar.transform.scaledBy(x: 1, y: 1)
        self.progressbar.progress = (1.0/5.0)*Float(self.indx_section)
        self.progressbar.layer.cornerRadius = 5
        self.progressbar.clipsToBounds = true
        self.progressbar.layer.sublayers?[1].cornerRadius = 8
        self.progressbar.subviews[1].clipsToBounds = true

        
        //Register Table Cell
        self.tbl_View.register(nibWithCellClass: NaddiQuestionTableCell.self)
        self.tbl_View.register(nibWithCellClass: RegisterButtonTableCell.self)
        
        if self.indx_section == 1 {
            self.getQuestionsFromServer()
        }
        else {
            self.manageSection()
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
    
    //MARK: - UIButton Action
    @IBAction func btn_Back_Action(_ sender: UIButton) {
        var is_screenBack = false
        if let stackVCs = self.navigationController?.viewControllers {
            if let activeSubVC = stackVCs.first(where: { type(of: $0) == VikratiResultVC.self }) {
                is_screenBack = true
                self.navigationController?.popToViewController(activeSubVC, animated: true)
            }
        }
        
        if is_screenBack == false {
            self.navigationController?.popViewController(animated: true)
        }
    }

}

//MARK: - API Call
extension NaadiQuestionaireVC {
    
    func getQuestionsFromServer () {
        
        if Connectivity.isConnectedToInternet {
            ShowProgressHud(message: AppMessage.plzWait)
            
            let urlString = BASE_URL + APIEndpoints.get_Naadi_questions.rawValue
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
                    self.arr_All_NaadiQuestion = arrQuestions
                    self.str_Type = "immediate expression"
                    self.lbl_Header.text = self.str_Type.capitalized
                    self.manageSection()
                    
                    
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
}

//MARK: - UICollectionView Delegate DataSource Method
extension NaadiQuestionaireVC: UITableViewDelegate, UITableViewDataSource {
    
    func manageSection() {
        self.arr_Question.removeAll()
        if self.arr_All_NaadiQuestion.count != 0 {
            for dic_question in self.arr_All_NaadiQuestion {
                if (dic_question["type"] as? String ?? "").lowercased() == self.str_Type {
                    self.arr_Question.append(dic_question)
                }
            }
        }
        self.arr_Question.append(["type" : "button"])
        
        self.tbl_View.reloadData()
     
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arr_Question.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let str_type = self.arr_Question[indexPath.row]["type"] as? String ?? ""
        if str_type == "button" {
            let cell = tableView.dequeueReusableCell(withClass: RegisterButtonTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            cell.btn_Title.text = "Continue"
            
            if self.arr_Answers.count == (self.arr_Question.count - 1) {
                cell.btn_Register.isUserInteractionEnabled = true
                cell.btn_Register.backgroundColor = AppColor.app_GreenColor
            }
            else {
                cell.btn_Register.isUserInteractionEnabled = false
                cell.btn_Register.backgroundColor = AppColor.app_grayColorDot
            }
            
            cell.didTapped_onRegister = { (sender) in
                self.btn_continue_action()
            }
            
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withClass: NaddiQuestionTableCell.self, for: indexPath)
            cell.selectionStyle = .none
            
            let str_question = self.arr_Question[indexPath.row]["question"] as? String ?? ""
            let str_question_id = self.arr_Question[indexPath.row]["question_id"] as? String ?? ""
            cell.lbl_question.text = "\(indexPath.row + 1). \(str_question)"
            
            let arr_options = self.arr_Question[indexPath.row]["options"] as? [[String: Any]] ?? [[:]]
            if arr_options.count != 0 {
                cell.view_answer_option_1.isHidden = true
                cell.view_answer_option_2.isHidden = true
                cell.view_answer_option_3.isHidden = true
                cell.view_answer_option_4.isHidden = true
                cell.view_answer_option_5.isHidden = true
                cell.view_answer_option_6.isHidden = true
                cell.view_answer_option_7.isHidden = true
                
                var intindx = 0
                for dic_option in arr_options {
                    let str_answer = dic_option["answer"] as? String ?? ""
                    let str_answer_id = dic_option["answer_id"] as? String ?? ""
                    if intindx == 0 {
                        cell.lbl_answer_option_1.text = str_answer
                        cell.view_answer_option_1.isHidden = false
                        cell.view_answer_option_1.accessibilityHint = str_question_id
                        cell.view_answer_option_1.accessibilityValue = str_answer_id
                        self.setselected_image(q_id: str_question_id,
                                               a_id: str_answer_id,
                                               img: cell.img_answer_option_1)
                    }
                    else if intindx == 1 {
                        cell.lbl_answer_option_2.text = str_answer
                        cell.view_answer_option_2.isHidden = false
                        cell.view_answer_option_2.accessibilityHint = str_question_id
                        cell.view_answer_option_2.accessibilityValue = str_answer_id
                        self.setselected_image(q_id: str_question_id,
                                               a_id: str_answer_id,
                                               img: cell.img_answer_option_2)
                    }
                    else if intindx == 2 {
                        cell.lbl_answer_option_3.text = str_answer
                        cell.view_answer_option_3.isHidden = false
                        cell.view_answer_option_3.accessibilityHint = str_question_id
                        cell.view_answer_option_3.accessibilityValue = str_answer_id
                        self.setselected_image(q_id: str_question_id,
                                               a_id: str_answer_id,
                                               img: cell.img_answer_option_3)
                    }
                    else if intindx == 3 {
                        cell.lbl_answer_option_4.text = str_answer
                        cell.view_answer_option_4.isHidden = false
                        cell.view_answer_option_4.accessibilityHint = str_question_id
                        cell.view_answer_option_4.accessibilityValue = str_answer_id
                        self.setselected_image(q_id: str_question_id,
                                               a_id: str_answer_id,
                                               img: cell.img_answer_option_4)
                    }
                    else if intindx == 4 {
                        cell.lbl_answer_option_5.text = str_answer
                        cell.view_answer_option_5.isHidden = false
                        cell.view_answer_option_5.accessibilityHint = str_question_id
                        cell.view_answer_option_5.accessibilityValue = str_answer_id
                        self.setselected_image(q_id: str_question_id,
                                               a_id: str_answer_id,
                                               img: cell.img_answer_option_5)
                    }
                    else if intindx == 5 {
                        cell.lbl_answer_option_6.text = str_answer
                        cell.view_answer_option_6.isHidden = false
                        cell.view_answer_option_6.accessibilityHint = str_question_id
                        cell.view_answer_option_6.accessibilityValue = str_answer_id
                        self.setselected_image(q_id: str_question_id,
                                               a_id: str_answer_id,
                                               img: cell.img_answer_option_6)
                    }
                    else if intindx == 6 {
                        cell.lbl_answer_option_7.text = str_answer
                        cell.view_answer_option_7.isHidden = false
                        cell.view_answer_option_7.accessibilityHint = str_question_id
                        cell.view_answer_option_7.accessibilityValue = str_answer_id
                        self.setselected_image(q_id: str_question_id,
                                               a_id: str_answer_id,
                                               img: cell.img_answer_option_7)
                    }
                    intindx += 1
                }
            }
            
            
            //Button action
            cell.didTappedOption_1 = { (sender) in
                self.setansewer(ques_id: str_question_id, ans_id: sender.accessibilityValue ?? "")
            }
            
            cell.didTappedOption_2 = { (sender) in
                self.setansewer(ques_id: str_question_id, ans_id: sender.accessibilityValue ?? "")
            }
            
            cell.didTappedOption_3 = { (sender) in
                self.setansewer(ques_id: str_question_id, ans_id: sender.accessibilityValue ?? "")
            }
            
            cell.didTappedOption_4 = { (sender) in
                self.setansewer(ques_id: str_question_id, ans_id: sender.accessibilityValue ?? "")
            }
            
            cell.didTappedOption_5 = { (sender) in
                self.setansewer(ques_id: str_question_id, ans_id: sender.accessibilityValue ?? "")
            }
            
            cell.didTappedOption_6 = { (sender) in
                self.setansewer(ques_id: str_question_id, ans_id: sender.accessibilityValue ?? "")
            }
            
            cell.didTappedOption_7 = { (sender) in
                self.setansewer(ques_id: str_question_id, ans_id: sender.accessibilityValue ?? "")
            }
            //*************************************//
            
            return cell
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func setansewer(ques_id: String, ans_id: String) {
        let dic_answer = ["question_id": ques_id, "answer_id": ans_id]
        if let indx = self.arr_Answers.firstIndex(where: { dic in
            return (dic["question_id"] as? String ?? "") == ques_id
        }) {
            self.arr_Answers.remove(at: indx)
        }

        self.arr_Answers.append(dic_answer)
        self.tbl_View.reloadData()
    }
    
    func setselected_image(q_id: String, a_id: String, img: UIImageView) {
        if let indx = self.arr_Answers.firstIndex(where: { dic in
            return (dic["question_id"] as? String ?? "") == q_id && (dic["answer_id"] as? String ?? "") == a_id
        }) {
            img.image = UIImage.init(named: "radio_button_checked")
        }
        else {
            img.image = UIImage.init(named: "radio_button_unchecked")
        }
    }
    
    func btn_continue_action() {
        
        //add ans in all ans
        for ans in self.arr_Answers {
            self.arr_All_Answers.append(ans)
        }
        //*************************//
        
        
        if self.indx_section == 5 {
            debugPrint("All Question Done")
            let vc = SelectAggaravationVC.instantiate(fromAppStoryboard: .Assessment)
            vc.arr_All_Answers = self.arr_All_Answers
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else {
            var sttrtype = ""
            self.indx_section += 1

            if self.indx_section == 2 {
                sttrtype = "superficial expression"
            }
            else if self.indx_section == 3 {
                sttrtype = "deep expression"
            }
            if self.indx_section == 4 {
                sttrtype = "subdosha level"
            }
            if self.indx_section == 5 {
                sttrtype = "dhatu"
            }
            
            
            let obj = Story_Assessment.instantiateViewController(withIdentifier: "NaadiQuestionaireVC") as! NaadiQuestionaireVC
            obj.str_Type = sttrtype
            obj.indx_section = self.indx_section
            obj.arr_All_Answers = self.arr_All_Answers
            obj.arr_All_NaadiQuestion = self.arr_All_NaadiQuestion
            self.navigationController?.pushViewController(obj, animated: true)
            
        }
    }
}
