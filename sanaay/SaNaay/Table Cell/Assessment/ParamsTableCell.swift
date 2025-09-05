//
//  ParamsTableCell.swift
//  SaNaay Wellness
//
//  Created by DEEPAK JAIN on 22/10/23.
//

import UIKit

protocol SparshnaResultParamListCellDelegate {
    func showInfoOfParam(at index: Int)
}

class ParamsTableCell: UITableViewCell {

    var resultParams = [SparshnaResultParamModel]()
    
    let maxCellHeight: CGFloat = 140
    @IBOutlet weak var collect_view: UICollectionView!
    @IBOutlet weak var constraint_collect_viewHeight: NSLayoutConstraint!
    var delegate: SparshnaResultParamListCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //Register Collection Cell
        self.collect_view.register(UINib(nibName: "ResultParamCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ResultParamCollectionCell")

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    func configureUI(resultParams: [SparshnaResultParamModel]) {
        self.resultParams = resultParams
        self.collect_view.reloadData()
    }
        
    @objc func infoBtnPressed(sender: UIButton) {
        delegate?.showInfoOfParam(at: sender.tag)
    }
}

extension ParamsTableCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.resultParams.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (screenWidth - 46)/2, height: self.maxCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ResultParamCollectionCell", for: indexPath) as? ResultParamCollectionCell else {
            return UICollectionViewCell()
        }
        let paramData = self.resultParams[indexPath.item]
        cell.paramData = paramData
        cell.infoBtn.tag = indexPath.row
        cell.infoBtn.removeTarget(self, action: nil, for: .touchUpInside)
        cell.infoBtn.addTarget(self, action: #selector(infoBtnPressed(sender:)), for: .touchUpInside)
        
        return cell
    }
}

//class DynamicCollectionView: UICollectionView {
//  override func layoutSubviews() {
//    super.layoutSubviews()
//    if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
//        self.invalidateIntrinsicContentSize()
//     }
//  }
//
//   override var intrinsicContentSize: CGSize {
//    return collectionViewLayout.collectionViewContentSize
//   }
//}
