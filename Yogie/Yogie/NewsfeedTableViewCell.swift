//
//  NewsfeedTableViewCell.swift
//  Yogie
//
//  Created by Erica Y Stevens on 5/7/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
protocol NewsfeedCellProtocol: class {
    func segueToUserProfileFrom(row: Int)
//    
//    func toggleNamaskarCountIn(path: IndexPath)
    
    func toggleCommentsViewIn(row: Int)
    
    func sharePostIn(row: Int)
}

class NewsfeedTableViewCell: UITableViewCell {
    
    weak var delegate: NewsfeedCellProtocol?
    var row: Int?
//    var path: IndexPath!

    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var postCreatorInfoContainerView: UIView!
    
    @IBOutlet weak var engagementButtonsContainerView: UIView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var segueToUserProfileButton: UIButton!
    
    @IBAction func segueToUserProfile(_ sender: AnyObject) {
        guard let row = row else { return }
        delegate?.segueToUserProfileFrom(row: row)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = .black
        userProfileImageView.layer.cornerRadius = 25.5
        userProfileImageView.layer.masksToBounds = false
        userProfileImageView.clipsToBounds = true
        
        usernameLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightThin)
        timestampLabel.font = UIFont.systemFont(ofSize: 13, weight: UIFontWeightThin)
      
        setupViewHierarchy()
        configureConstraints()
    }

    func setupViewHierarchy() {
        self.engagementButtonsContainerView.addSubview(namaskarUpvoteButtonContainerView)
        self.engagementButtonsContainerView.addSubview(commentButtonContainerView)
        self.engagementButtonsContainerView.addSubview(shareButtonContainerView)
        
        namaskarUpvoteButtonContainerView.addSubview(namaskarUpvoteButton)
        namaskarUpvoteButtonContainerView.addSubview(namaskarUpvoteCountLabel)
        
        commentButtonContainerView.addSubview(commentButton)
        commentButtonContainerView.addSubview(commentButtonTitleLabel)
        commentButton.addSubview(leftSeparatorView)
        commentButton.addSubview(rightSeparatorView)
        commentButtonContainerView.addSubview(toggleCommentsViewOverlayButton)
        commentButtonContainerView.bringSubview(toFront: toggleCommentsViewOverlayButton)
        
        shareButtonContainerView.addSubview(shareButton)
        shareButtonContainerView.addSubview(shareButtonTitleLabel)
        shareButtonContainerView.addSubview(sharePostOverlayButton)
        shareButtonContainerView.addSubview(sharePostOverlayButton)
        
        self.contentView.addSubview(cellSeparatorView)
    }
    
    func configureConstraints() {
        let _ = [
            engagementButtonsContainerView.widthAnchor.constraint(equalTo: postImageView.widthAnchor),
            engagementButtonsContainerView.heightAnchor.constraint(equalToConstant: 45),
            engagementButtonsContainerView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            engagementButtonsContainerView.topAnchor.constraint(equalTo: postImageView.bottomAnchor),
            engagementButtonsContainerView.bottomAnchor.constraint(equalTo: cellSeparatorView.topAnchor),


            namaskarUpvoteButtonContainerView.widthAnchor.constraint(equalTo: engagementButtonsContainerView.widthAnchor, multiplier: 1/3),
            namaskarUpvoteButtonContainerView.heightAnchor.constraint(equalTo: engagementButtonsContainerView.heightAnchor),
            namaskarUpvoteButtonContainerView.leadingAnchor.constraint(equalTo: engagementButtonsContainerView.leadingAnchor),
            namaskarUpvoteButtonContainerView.centerYAnchor.constraint(equalTo: engagementButtonsContainerView.centerYAnchor),
            
//            updateNamaskarOverlayButton.widthAnchor.constraint(equalTo: namaskarUpvoteButtonContainerView.widthAnchor),
//            updateNamaskarOverlayButton.heightAnchor.constraint(equalTo: namaskarUpvoteButtonContainerView.heightAnchor),
//            updateNamaskarOverlayButton.leadingAnchor.constraint(equalTo: namaskarUpvoteButtonContainerView.leadingAnchor),
//            updateNamaskarOverlayButton.centerYAnchor.constraint(equalTo: namaskarUpvoteButtonContainerView.centerYAnchor),
//            
            namaskarUpvoteButton.widthAnchor.constraint(equalToConstant: 32),
            namaskarUpvoteButton.heightAnchor.constraint(equalToConstant: 32),
            namaskarUpvoteButton.centerYAnchor.constraint(equalTo: engagementButtonsContainerView.centerYAnchor),
            namaskarUpvoteButton.leadingAnchor.constraint(equalTo: namaskarUpvoteButtonContainerView.leadingAnchor, constant: 8.0),
            
            namaskarUpvoteCountLabel.widthAnchor.constraint(equalTo: namaskarUpvoteButtonContainerView.widthAnchor, multiplier: 0.5),
            namaskarUpvoteCountLabel.centerYAnchor.constraint(equalTo: namaskarUpvoteButton.centerYAnchor),
            namaskarUpvoteCountLabel.trailingAnchor.constraint(equalTo: namaskarUpvoteButtonContainerView.trailingAnchor, constant: -8.0),
            namaskarUpvoteCountLabel.leadingAnchor.constraint(equalTo: namaskarUpvoteButton.trailingAnchor, constant: 4.0),
            
            commentButtonContainerView.widthAnchor.constraint(equalTo: namaskarUpvoteButtonContainerView.widthAnchor),
            commentButtonContainerView.heightAnchor.constraint(equalTo: namaskarUpvoteButtonContainerView.heightAnchor),
            commentButtonContainerView.leadingAnchor.constraint(equalTo: namaskarUpvoteButtonContainerView.trailingAnchor),
            commentButtonContainerView.centerYAnchor.constraint(equalTo: namaskarUpvoteButtonContainerView.centerYAnchor),
            
            leftSeparatorView.widthAnchor.constraint(equalToConstant: 0.5),
            leftSeparatorView.heightAnchor.constraint(equalTo: commentButtonContainerView.heightAnchor, multiplier: 0.4),
            leftSeparatorView.leadingAnchor.constraint(equalTo: commentButtonContainerView.leadingAnchor),
            leftSeparatorView.centerYAnchor.constraint(equalTo: commentButtonTitleLabel.centerYAnchor),
            
            
            rightSeparatorView.widthAnchor.constraint(equalToConstant: 0.5),
            rightSeparatorView.heightAnchor.constraint(equalTo: commentButtonContainerView.heightAnchor, multiplier: 0.4),
            rightSeparatorView.trailingAnchor.constraint(equalTo: commentButtonContainerView.trailingAnchor),
            rightSeparatorView.centerYAnchor.constraint(equalTo: commentButtonTitleLabel.centerYAnchor),
            
            
            toggleCommentsViewOverlayButton.widthAnchor.constraint(equalTo: commentButtonContainerView.widthAnchor),
            toggleCommentsViewOverlayButton.heightAnchor.constraint(equalTo: commentButtonContainerView.heightAnchor),
            toggleCommentsViewOverlayButton.leadingAnchor.constraint(equalTo: commentButtonContainerView.leadingAnchor),
            toggleCommentsViewOverlayButton.centerYAnchor.constraint(equalTo: commentButtonContainerView.centerYAnchor),
            
            commentButton.widthAnchor.constraint(equalToConstant: 32),
            commentButton.heightAnchor.constraint(equalToConstant: 32),
            commentButton.centerYAnchor.constraint(equalTo: commentButtonTitleLabel.centerYAnchor),
            commentButton.leadingAnchor.constraint(equalTo: commentButtonContainerView.leadingAnchor, constant: 4.0),
            
            commentButtonTitleLabel.widthAnchor.constraint(equalTo: commentButtonContainerView.widthAnchor, multiplier: 0.6),
            commentButtonTitleLabel.centerYAnchor.constraint(equalTo: namaskarUpvoteCountLabel.centerYAnchor),
            commentButtonTitleLabel.leadingAnchor.constraint(equalTo: commentButton.trailingAnchor, constant: 4.0),
            commentButtonTitleLabel.trailingAnchor.constraint(equalTo: commentButtonContainerView.trailingAnchor, constant: -4.0),
            
            shareButtonContainerView.widthAnchor.constraint(equalTo: namaskarUpvoteButtonContainerView.widthAnchor),
            shareButtonContainerView.heightAnchor.constraint(equalTo: namaskarUpvoteButtonContainerView.heightAnchor),
            shareButtonContainerView.leadingAnchor.constraint(equalTo: commentButtonContainerView.trailingAnchor),
            shareButtonContainerView.centerYAnchor.constraint(equalTo: namaskarUpvoteButtonContainerView.centerYAnchor),
            
            sharePostOverlayButton.widthAnchor.constraint(equalTo: shareButtonContainerView.widthAnchor),
            sharePostOverlayButton.heightAnchor.constraint(equalTo: shareButtonContainerView.heightAnchor),
            sharePostOverlayButton.leadingAnchor.constraint(equalTo: shareButtonContainerView.leadingAnchor),
            sharePostOverlayButton.centerYAnchor.constraint(equalTo: shareButtonContainerView.centerYAnchor),
            
            shareButton.widthAnchor.constraint(equalToConstant: 32),
            shareButton.heightAnchor.constraint(equalToConstant: 32),
            shareButton.centerYAnchor.constraint(equalTo: shareButtonTitleLabel.centerYAnchor),
            shareButton.leadingAnchor.constraint(equalTo: shareButtonContainerView.leadingAnchor, constant: 8.0),
            
            shareButtonTitleLabel.widthAnchor.constraint(equalTo: shareButtonContainerView.widthAnchor, multiplier: 0.5),
            shareButtonTitleLabel.centerYAnchor.constraint(equalTo: namaskarUpvoteCountLabel.centerYAnchor),
            shareButtonTitleLabel.leadingAnchor.constraint(equalTo: shareButton.trailingAnchor, constant: 4.0),
            shareButtonTitleLabel.trailingAnchor.constraint(equalTo: shareButtonContainerView.trailingAnchor, constant: -8.0),
            
            cellSeparatorView.widthAnchor.constraint(equalTo: self.contentView.widthAnchor),
            cellSeparatorView.heightAnchor.constraint(equalToConstant: 10),
            cellSeparatorView.topAnchor.constraint(equalTo: engagementButtonsContainerView.bottomAnchor),
            cellSeparatorView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            cellSeparatorView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
            
            ].map{$0.isActive = true}
    }
    
    lazy var namaskarUpvoteButtonContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    lazy var commentButtonContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    lazy var shareButtonContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    lazy var leftSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return view
    }()
    
    lazy var rightSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return view
    }()
    
    lazy var cellSeparatorView: UIView = {
       let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.YogieTheme.darkPrimaryColor.withAlphaComponent(0.4)
        return view
    }()
    
    lazy var namaskarUpvoteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = false
        button.clipsToBounds = true
        button.contentMode = .scaleAspectFit
        button.setImage(#imageLiteral(resourceName: "Namaste"), for: .normal)
        return button
    }()
    
    lazy var namaskarUpvoteCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
        label.adjustsFontSizeToFitWidth = true
        label.text = "356,962"
        label.textAlignment = .left
        return label
    }()
    
    lazy var commentButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        var commentIcon = UIImage(named: "commentIcon")
        commentIcon = commentIcon?.withRenderingMode(.alwaysTemplate)
        button.setImage(commentIcon, for: .normal)
        button.tintColor = UIColor.YogieTheme.primaryColor
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    lazy var commentButtonTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "Comment"
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        return label
    }()
    
    lazy var shareButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        var shareIcon = UIImage(named: "shareIcon")
        shareIcon = shareIcon?.withRenderingMode(.alwaysTemplate)
        button.setImage(shareIcon, for: .normal)
        button.tintColor = UIColor.YogieTheme.primaryColor
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    lazy var shareButtonTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "Share"
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        return label
    }()
    

    lazy var updateNamaskarOverlayButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
//        button.addTarget(self, action: #selector(updateNamaskarCountForPost(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var toggleCommentsViewOverlayButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(toggleCommentsView(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var sharePostOverlayButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(sharePost(_:)), for: .touchUpInside)
        return button
    }()
    
//    func updateNamaskarCountForPost(_ sender: UIButton) {
//        //guard let row = row else { return }
//        delegate?.toggleNamaskarCountIn(path: path)
//    }
    
    func toggleCommentsView(_ sender: UIButton) {
        guard let row = row else { return }
        delegate?.toggleCommentsViewIn(row: row)
    }
    
    func sharePost(_ sender: UIButton) {
        guard let row = row else { return }
        delegate?.sharePostIn(row: row)
    }
}
