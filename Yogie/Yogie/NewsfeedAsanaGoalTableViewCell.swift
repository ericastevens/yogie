//
//  NewsfeedAsanaGoalTableViewCell.swift
//  Yogie
//
//  Created by Erica Y Stevens on 5/22/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

//https://ashfurrow.com/blog/putting-a-uicollectionview-in-a-uitableviewcell-in-swift/

protocol NewsfeedAsanaGoalCellProtocol: class {
    func segueToUserProfileFrom(row: Int)
    func toggleCommentsViewInItem(row: Int)
    func sharePostInItem(row: Int)
}

class NewsfeedAsanaGoalTableViewCell: UITableViewCell {
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postCreatorInfoContainerView: UIView!
    @IBOutlet weak var segueToUserProfileButton: UIButton!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var asanaProgressionCollectionView: UICollectionView!
    @IBOutlet weak var asanaCVLayout: UICollectionViewFlowLayout!
    @IBAction func segueToUserProfile(_ sender: UIButton) {
        guard let row = row else { return }
        delegate?.segueToUserProfileFrom(row: row)
    }

    weak var delegate: NewsfeedAsanaGoalCellProtocol?
    var row: Int?
    
    var collectionViewOffset: CGFloat {
        get {
            return asanaProgressionCollectionView.contentOffset.x
        }
        set {
            asanaProgressionCollectionView.contentOffset.x = newValue
        }
    }
    
    lazy var cellSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.YogieTheme.darkPrimaryColor.withAlphaComponent(0.4)
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .black
        userProfileImageView.layer.cornerRadius = 25.5
        userProfileImageView.layer.masksToBounds = false
        userProfileImageView.clipsToBounds = true
        
        usernameLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin)
        timestampLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightThin)
        
        asanaProgressionCollectionView.register(AsanaGoalTitleCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "NewsfeedAsanaGoalTitleHeader")
        asanaCVLayout.sectionHeadersPinToVisibleBounds = true
        addSeparatorViewToHierarchy()
    }
    
    func addSeparatorViewToHierarchy() {
        self.contentView.addSubview(cellSeparatorView)
        
        let _ = [
            cellSeparatorView.heightAnchor.constraint(equalToConstant: 10),
            cellSeparatorView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
            cellSeparatorView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            cellSeparatorView.topAnchor.constraint(equalTo: asanaProgressionCollectionView.bottomAnchor),
            cellSeparatorView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            cellSeparatorView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            cellSeparatorView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
            ].map{$0.isActive = true}
    }

    func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
        
        asanaProgressionCollectionView.dataSource = dataSourceDelegate
        asanaProgressionCollectionView.delegate = dataSourceDelegate
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
