//
//  NotificationTableViewCell.swift
//  Yogie
//
//  Created by Erica Y Stevens on 5/11/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    //should show whenever someone takes an action on your profile, but should also list when a connection makes a change to his/her profile (OR starts a new challenge, can be used as a prompt to get user to join challenge or start their own)

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Lazy Instantiation
    
    lazy var userImageView: UIImageView = {
        //Could be replaced by icon denoting activity type
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    lazy var usernameLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var activityLabel: UILabel = {
        //i.e. liked, commented, shared, followed, unfollowed, replied to comment
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var targetObjectLabel: UILabel = {
        //i.e. your post, their profile Picture, you
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

}
