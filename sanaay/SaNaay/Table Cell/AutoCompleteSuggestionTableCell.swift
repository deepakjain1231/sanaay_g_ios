//
//  AutoCompleteSuggestionTableCell.swift
//  Tavisa
//
//  Created by DEEPAK JAIN on 14/04/24.
//

import UIKit
import AlignedCollectionViewFlowLayout

class AutoCompleteSuggestionTableCell: UITableViewCell {

    var arr_SelectedItem = [String]()
    var arr_item = [[String: Any]]()
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var view_TextFieldBg: UIView!
    @IBOutlet weak var txt_suggestion: UITextField!
    @IBOutlet weak var btn_Add: UIButton!
    @IBOutlet weak var collection_view: DynamicCollectionView!
    @IBOutlet weak var collection_view_selected: DynamicCollectionView!
    @IBOutlet weak var constraint_collection_view_height: NSLayoutConstraint!
    @IBOutlet weak var constraint_selected_collection_view_height: NSLayoutConstraint!

    var didTappedonButtonAdd: ((UIButton)->Void)? = nil
    var didSelectedTag: (([String])->Void)? = nil
    
    
    var arr_data: [[String: Any]] = [[:]] {
        didSet {
            self.arr_item = arr_data
            self.collection_view.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                let get_height = self.collection_view.intrinsicContentSize.height
                self.constraint_collection_view_height.constant = get_height
            }
        }
    }
    
    var arr_selected_data: [String] = [] {
        didSet {
            self.arr_SelectedItem = arr_selected_data
            self.collection_view_selected.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                let get_height = self.collection_view_selected.intrinsicContentSize.height
                self.constraint_selected_collection_view_height.constant = get_height
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collection_view.delegate = self
        self.collection_view.dataSource = self
        self.collection_view_selected.delegate = self
        self.collection_view_selected.dataSource = self
        
        self.collection_view.register(UINib(nibName: "HomeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionCell")
        self.collection_view_selected.register(UINib(nibName: "HomeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionCell")
    }
    
    override func layoutIfNeeded() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            let get_height = self.collection_view.intrinsicContentSize.height
            self.constraint_collection_view_height.constant = get_height
            
            let get_height1 = self.collection_view_selected.intrinsicContentSize.height
            self.constraint_selected_collection_view_height.constant = get_height1
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func btn_Add_Action(_ sender: UIButton) {
        self.didTappedonButtonAdd?(sender)
    }
}


//MARK: - UICollectionView Delegate DataSource Method
extension AutoCompleteSuggestionTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collection_view {
            return self.arr_item.count
        }
        else {
            return self.arr_SelectedItem.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collection_view {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionCell", for: indexPath) as! HomeCollectionCell
            cell.view_Base.backgroundColor = .clear
            
            let strText = self.arr_item[indexPath.item]["tagname"] as? String ?? ""
            cell.lbl_Title.text = strText
            
            cell.lbl_Title.textColor = AppColor.app_GreenColor
            cell.view_Base.layer.borderColor = AppColor.app_GreenColor.cgColor
            
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionCell", for: indexPath) as! HomeCollectionCell
            cell.view_Base.backgroundColor = .clear
            
            let strText = self.arr_SelectedItem[indexPath.item]
            cell.lbl_Title.text = strText
            
            cell.lbl_Title.textColor = .white
            cell.view_Base.layer.borderColor = UIColor.clear.cgColor
            cell.view_Base.backgroundColor = AppColor.app_GreenColor.withAlphaComponent(0.7)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var strText = ""
        if collectionView == self.collection_view {
            strText = self.arr_item[indexPath.item]["tagname"] as? String ?? ""
        }
        else {
            strText = self.arr_SelectedItem[indexPath.item]
        }
            
        var getWidth = strText.widthOfString(usingFont: UIFont.AppFontRegular(14))
        getWidth = getWidth + 25
        return CGSize.init(width: getWidth, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var strText = ""
        if collectionView == self.collection_view {
            strText = self.arr_item[indexPath.item]["tagname"] as? String ?? ""
        }
        else {
            strText = self.arr_SelectedItem[indexPath.item]
        }
        self.arr_SelectedItem.append(strText)
        self.didSelectedTag!(self.arr_SelectedItem)
    }
}


class DynamicCollectionView: UICollectionView {
  override func layoutSubviews() {
    super.layoutSubviews()
    if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
        self.invalidateIntrinsicContentSize()
     }
  }

   override var intrinsicContentSize: CGSize {
    return collectionViewLayout.collectionViewContentSize
   }
}
