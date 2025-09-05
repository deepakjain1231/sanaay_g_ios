//
//  DetailedResultVC.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 07/07/23.
//

import UIKit

class DetailedResultVC: UIViewController {

    var arr_Ids = [Int]()
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var tbl_View: UITableView!
    
    var isFromCameraView = false
    var resultDic: [String: Any] = [String: Any]()
    var arr_result = [[String: Any]]()
    var resultParams = [SparshnaResultParamModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.lbl_Title.text = "Detailed Result"
        
        if #available(iOS 15.0, *) {
            self.tbl_View.sectionHeaderTopPadding = 0.0
        } else {
            // Fallback on earlier versions
        }
        
        self.tbl_View.reloadData()
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
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: UITableView Delegates and Datasource Method

extension DetailedResultVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.resultParams.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 12 : 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 450//indexPath.row == 1 ? getParamListCellHeight() : 450
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let indx = self.arr_Ids.firstIndex(of: indexPath.row) {
            self.arr_Ids.remove(at: indx)
        }
        else {
            self.arr_Ids.append(indexPath.row)
        }
        self.tbl_View.reloadData()
    }

}

