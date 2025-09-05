//
//  AddHealthComplainTableCell.swift
//  SaNaay
//
//  Created by DEEPAK JAIN on 07/07/24.
//

import UIKit
import AlignedCollectionViewFlowLayout

class AddHealthComplainTableCell: UITableViewCell {

    var type_tag = kSearchTypeTag.kNone
    var arr_Tag = [[String: Any]]()
    var arr_Selected_Tag = [[String: Any]]()
    @IBOutlet weak var view_Base: UIView!
    @IBOutlet weak var lbl_Title: UILabel!
    @IBOutlet weak var txt_field: UITextField!
    @IBOutlet weak var btn_Add: UIButton!
    @IBOutlet weak var tag_collectionView: UICollectionView!
    @IBOutlet weak var selected_tag_collectionView: UICollectionView!
    @IBOutlet weak var constraint_collection_view_height: NSLayoutConstraint!
    @IBOutlet weak var constraint_selected_tag_collection_view_height: NSLayoutConstraint!
    
    var didTappedAdd: ((UIButton)->Void)? = nil
    var completation_selected_tag: (([String: Any], kSearchTypeTag)->Void)? = nil
    var completation_removed_tag: (([[String: Any]], kSearchTypeTag)->Void)? = nil
    
    var arr_data: [[String: Any]] = [[:]] {
        didSet {
            self.arr_Tag = arr_data
            self.tag_collectionView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                let get_height = self.tag_collectionView.intrinsicContentSize.height
                self.constraint_collection_view_height.constant = self.arr_Tag.count == 0 ? 0 : get_height
                self.layoutIfNeeded()
            }
        }
    }
    
    var arr_selected_data: [[String: Any]] = [[:]] {
        didSet {
            self.arr_Selected_Tag = arr_selected_data
            self.selected_tag_collectionView.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                let get_height = self.selected_tag_collectionView.intrinsicContentSize.height
                self.constraint_selected_tag_collection_view_height.constant = self.arr_Selected_Tag.count == 0 ? 0 : get_height
                self.layoutIfNeeded()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.tag_collectionView.delegate = self
        self.tag_collectionView.dataSource = self
        
        self.selected_tag_collectionView.delegate = self
        self.selected_tag_collectionView.dataSource = self
        
        let alignedFlowLayout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left,
                                                                verticalAlignment: .top)
        self.tag_collectionView.collectionViewLayout = alignedFlowLayout
        
        
        let alignedFlowLayout1 = AlignedCollectionViewFlowLayout(horizontalAlignment: .left,
                                                                verticalAlignment: .top)
        self.selected_tag_collectionView.collectionViewLayout = alignedFlowLayout1
        
        
        //Register Collection Cell
        self.tag_collectionView.register(UINib.init(nibName: "HomeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionCell")
        self.selected_tag_collectionView.register(UINib.init(nibName: "HomeCollectionCell", bundle: nil), forCellWithReuseIdentifier: "HomeCollectionCell")
    }
    
    override func layoutIfNeeded() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            let get_height = self.tag_collectionView.intrinsicContentSize.height
            self.constraint_collection_view_height.constant = get_height
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - UIButton Action
    @IBAction func btn_Add_Action(_ sender: UIButton) {
        self.didTappedAdd?(sender)
    }
    
}


//MARK: - UIColletion Delegagte Datasource Method
extension AddHealthComplainTableCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.selected_tag_collectionView {
            return self.arr_Selected_Tag.count
        }
        return self.arr_Tag.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionCell", for: indexPath) as! HomeCollectionCell
        
        if collectionView == self.selected_tag_collectionView {
            cell.lbl_Title.textColor = .white
            cell.btn_remove.isHidden = false
            cell.view_Base.backgroundColor = AppColor.app_GreenColor
            cell.lbl_Title.text = self.arr_Selected_Tag[indexPath.row]["tagname"] as? String ?? ""
            
            
            cell.didTappedonRemove = { (sender) in
                self.arr_Selected_Tag.remove(at: indexPath.row)
                self.completation_removed_tag?(self.arr_Selected_Tag, self.type_tag)
            }
        }
        else {
            cell.btn_remove.isHidden = true
            cell.lbl_Title.textColor = .black
            cell.view_Base.backgroundColor = UIColor.init(hex: "ECFFF1")
            cell.lbl_Title.text = self.arr_Tag[indexPath.row]["tagname"] as? String ?? ""
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var extra_width: CGFloat = 0
        var strText = ""
        if collectionView == self.selected_tag_collectionView {
            extra_width = 28
            strText = self.arr_Selected_Tag[indexPath.item]["tagname"] as? String ?? ""
        }
        else {
            strText = self.arr_Tag[indexPath.item]["tagname"] as? String ?? ""
        }

        var getWidth = strText.widthOfString(usingFont: UIFont.AppFontRegular(14))
        getWidth = getWidth + 25 + extra_width
        return CGSize.init(width: getWidth, height: 35)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.selected_tag_collectionView {
        }
        else {
            let get_height = self.tag_collectionView.intrinsicContentSize.height
            self.constraint_collection_view_height.constant = self.arr_Tag.count == 0 ? 0 : get_height
            self.layoutIfNeeded()

            let dic_tag = self.arr_Tag[indexPath.row]
            self.completation_selected_tag?(dic_tag, self.type_tag)
        }
    }
}


