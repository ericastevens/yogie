//
//  AsanaGoalTableViewCell.swift
//  Yogie
//
//  Created by Erica Y Stevens on 5/13/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

protocol AsanaGoalCellProtocol: class {
    func segueToUserProfileFrom(row: Int)
    //
    //    func toggleNamaskarCountIn(path: IndexPath)
    
    func toggleCommentsViewInItem(row: Int)
    
    func sharePostInItem(row: Int)
}

class AsanaGoalTableViewCell: UITableViewCell {
    
    @IBOutlet weak var asanaProgressionCollectionView: UICollectionView!
    
    @IBOutlet weak var asanaCVLayout: UICollectionViewFlowLayout!
    
    weak var delegate: AsanaGoalCellProtocol?
    var row: Int?
  
    var collectionViewOffset: CGFloat {
        get {
            return asanaProgressionCollectionView.contentOffset.x
        }
        
        set {
            asanaProgressionCollectionView.contentOffset.x = newValue
        }
    }
    
   

    
    override func awakeFromNib() {
        super.awakeFromNib()
        asanaProgressionCollectionView.register(AsanaGoalTitleCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "AsanaGoalTitleHeader")
        asanaCVLayout.sectionHeadersPinToVisibleBounds = true
    }
    
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
        
        asanaProgressionCollectionView.delegate = dataSourceDelegate
        asanaProgressionCollectionView.dataSource = dataSourceDelegate
        asanaProgressionCollectionView.tag = row
        DispatchQueue.main.async {
            self.asanaProgressionCollectionView.reloadData()
        }
    }
    
    func toggleCommentsView(_ sender: UIButton) {
        guard let row = row else { return }
        delegate?.toggleCommentsViewInItem(row: row)
    }
    
    func sharePost(_ sender: UIButton) {
        guard let row = row else { return }
        delegate?.sharePostInItem(row: row)
    }
}
