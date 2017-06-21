//
//  ProfileTableViewCell.swift
//  Yogie
//
//  Created by Erica Y Stevens on 5/12/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var userPostImageView: UIImageView!
    
    weak var delegate: AsanaGoalCellProtocol?
    var row: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        self.contentView.backgroundColor = .black
        setupViewHierarchy()
        configureConstraints()
        
        userPostImageView.image = #imageLiteral(resourceName: "dummyFreeYogie")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    lazy var timestampLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.backgroundColor = UIColor.YogieTheme.primaryColor.withAlphaComponent(0.5)
        label.layer.cornerRadius = 16
        label.layer.masksToBounds = false
        label.clipsToBounds = true
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
        label.adjustsFontSizeToFitWidth = true
        label.text = "34 m"
        label.textAlignment = .center
        return label
    }()
    
    lazy var engagementButtonsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
    
    lazy var shareButtonContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
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
        label.text = "387,524"
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
    
    func setupViewHierarchy() {
        self.contentView.addSubview(engagementButtonsContainerView)
        
        userPostImageView.addSubview(timestampLabel)
        
        self.engagementButtonsContainerView.addSubview(namaskarUpvoteButtonContainerView)
        self.engagementButtonsContainerView.addSubview(commentButtonContainerView)
        self.engagementButtonsContainerView.addSubview(shareButtonContainerView)
        
        namaskarUpvoteButtonContainerView.addSubview(namaskarUpvoteButton)
        namaskarUpvoteButtonContainerView.addSubview(namaskarUpvoteCountLabel)
        
        commentButtonContainerView.addSubview(commentButton)
        commentButton.addSubview(leftSeparatorView)
        commentButton.addSubview(rightSeparatorView)
        commentButtonContainerView.addSubview(commentButtonTitleLabel)
        
        shareButtonContainerView.addSubview(shareButton)
        shareButtonContainerView.addSubview(shareButtonTitleLabel)
        
        self.contentView.addSubview(cellSeparatorView)
    }
    
    func configureConstraints() {
        let _ = [
            userPostImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            userPostImageView.bottomAnchor.constraint(equalTo: engagementButtonsContainerView.topAnchor),
            userPostImageView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            userPostImageView.widthAnchor.constraint(equalToConstant: 375),
            userPostImageView.heightAnchor.constraint(equalToConstant: 375),
            
            timestampLabel.widthAnchor.constraint(equalToConstant: 45),
            timestampLabel.heightAnchor.constraint(equalToConstant: 32),
            timestampLabel.topAnchor.constraint(equalTo: userPostImageView.topAnchor, constant: 12.0),
            timestampLabel.trailingAnchor.constraint(equalTo: userPostImageView.trailingAnchor, constant: -12.0),
            
            engagementButtonsContainerView.widthAnchor.constraint(equalTo: userPostImageView.widthAnchor),
            engagementButtonsContainerView.heightAnchor.constraint(equalToConstant: 45),
            engagementButtonsContainerView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            engagementButtonsContainerView.topAnchor.constraint(equalTo: userPostImageView.bottomAnchor),
            engagementButtonsContainerView.bottomAnchor.constraint(equalTo: cellSeparatorView.topAnchor),
            
            namaskarUpvoteButtonContainerView.widthAnchor.constraint(equalTo: engagementButtonsContainerView.widthAnchor, multiplier: 1/3),
            namaskarUpvoteButtonContainerView.heightAnchor.constraint(equalTo: engagementButtonsContainerView.heightAnchor),
            namaskarUpvoteButtonContainerView.leadingAnchor.constraint(equalTo: engagementButtonsContainerView.leadingAnchor),
            namaskarUpvoteButtonContainerView.centerYAnchor.constraint(equalTo: engagementButtonsContainerView.centerYAnchor),
            
            namaskarUpvoteButton.widthAnchor.constraint(equalToConstant: 30),
            namaskarUpvoteButton.heightAnchor.constraint(equalToConstant: 30),
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
    
    func toggleCommentsView(_ sender: UIButton) {
        guard let row = row else { return }
        delegate?.toggleCommentsViewInItem(row: row)
    }
    
    func sharePost(_ sender: UIButton) {
        guard let row = row else { return }
        delegate?.sharePostInItem(row: row)
    }

}
