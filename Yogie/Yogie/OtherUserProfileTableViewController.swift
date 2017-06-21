//
//  FeedTableViewController.swift
//  Yogie
//
//  Created by Erica Y Stevens on 4/30/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import Firebase

struct StretchyHeader {
    let headerHeight: CGFloat = 250
    let headerCut: CGFloat = 0 // play around with this value to see to test different effects
}

class OtherUserProfileTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    let dummyData = [UIImage(named: "Yoga Movement Beyonce Knowles"), UIImage(named: "beyYoga2"), UIImage(named: "beyYoga3") ]
    
    // MARK: Outlets

    @IBOutlet weak var stretchyImageView: UIImageView!
    
    // MARK: Stored Properties
    
    var headerView: UIView!
    var newHeaderLayer: CAShapeLayer!
    var namaskarOffered = false
    var followedBySignedInUser = false
    let timestampLabels = ["2w", "3w", "1m"]
    let userAsanaGoals: [[String:[UIImage]]] = [
        ["Dancer Pose" : [#imageLiteral(resourceName: "Dancer3"), #imageLiteral(resourceName: "Dancer2"), #imageLiteral(resourceName: "Dancer1")]],
        ["Wheel Pose" : [#imageLiteral(resourceName: "beyYoga2"), #imageLiteral(resourceName: "beyYoga2"), #imageLiteral(resourceName: "beyYoga2")]],
        ["Backbend" : [#imageLiteral(resourceName: "Backbend3"), #imageLiteral(resourceName: "Backbend2"), #imageLiteral(resourceName: "Backbend1")]]
    ]
    var asanaGoalImages: [UIImage]!
    var storedOffsets = [Int: CGFloat]()
    
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.YogieTheme.darkPrimaryColor
      
        updateView()
        configureProfileStretchyHeader()
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillLayoutSubviews() {
        setNewView()
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNewView()
    }
    
    // MARK: Strechy Header Configuration
    
    func configureProfileStretchyHeader() {
        stretchyImageView.image = #imageLiteral(resourceName: "Beyonce")
        stretchyImageView.isUserInteractionEnabled = true
        
        self.addBlurEffectToBackgroundImage(self.stretchyImageView)
        self.configureStretchyHeaderViewHeirarchy()
        self.configureStretchyHeaderConstraints()
        self.makeUserProfileImageCircular()
    }
    func configureStretchyHeaderViewHeirarchy() {
        stretchyImageView.addSubview(userProfileImageView)
        stretchyImageView.addSubview(usernameLabel)
        stretchyImageView.addSubview(followersInfoContainerView)
        stretchyImageView.addSubview(followingInfoContainerView)
        stretchyImageView.addSubview(toggleFollowButton)
        stretchyImageView.addSubview(dismissVCButton)
        stretchyImageView.addSubview(sendMessageToUserButton)
        
        followersInfoContainerView.addSubview(followersTitleLabel)
        followersInfoContainerView.addSubview(followersQuantityLabel)
        
        followingInfoContainerView.addSubview(followingTitleLabel)
        followingInfoContainerView.addSubview(followingQuantityLabel)
        
        
        self.bringStretchyHeaderSubviewsToFront()
    }
    
    func bringStretchyHeaderSubviewsToFront() {
        stretchyImageView.bringSubview(toFront: usernameLabel)
        stretchyImageView.bringSubview(toFront: userProfileImageView)
        stretchyImageView.bringSubview(toFront: followersInfoContainerView)
        stretchyImageView.bringSubview(toFront: followingInfoContainerView)
        stretchyImageView.bringSubview(toFront: toggleFollowButton)
        stretchyImageView.bringSubview(toFront: dismissVCButton)
        stretchyImageView.bringSubview(toFront: stretchyImageView)
        stretchyImageView.bringSubview(toFront: sendMessageToUserButton)
    }
    
    func configureStretchyHeaderConstraints() {
        let _ = [
            stretchyImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            
            dismissVCButton.widthAnchor.constraint(equalToConstant: 32),
            dismissVCButton.heightAnchor.constraint(equalToConstant: 32),
            dismissVCButton.topAnchor.constraint(equalTo: stretchyImageView.topAnchor, constant: 8.0),
            dismissVCButton.leadingAnchor.constraint(equalTo: stretchyImageView.leadingAnchor, constant: 8.0),
            
            userProfileImageView.centerXAnchor.constraint(equalTo: stretchyImageView.centerXAnchor),
            userProfileImageView.centerYAnchor.constraint(equalTo: stretchyImageView.centerYAnchor),
            userProfileImageView.heightAnchor.constraint(equalToConstant: 128),
            userProfileImageView.widthAnchor.constraint(equalToConstant: 128),
            
            usernameLabel.centerXAnchor.constraint(equalTo: stretchyImageView.centerXAnchor),
            usernameLabel.bottomAnchor.constraint(equalTo: userProfileImageView.topAnchor, constant: -12),
            
            followersInfoContainerView.centerYAnchor.constraint(equalTo: userProfileImageView.centerYAnchor),
            followersInfoContainerView.trailingAnchor.constraint(equalTo: userProfileImageView.leadingAnchor, constant: -12),
            followersInfoContainerView.widthAnchor.constraint(equalToConstant: 64),
            followersInfoContainerView.heightAnchor.constraint(equalToConstant: 64),
            
            followersTitleLabel.widthAnchor.constraint(equalTo: followersInfoContainerView.widthAnchor),
            followersTitleLabel.heightAnchor.constraint(equalTo: followersInfoContainerView.heightAnchor, multiplier: 0.25),
            followersTitleLabel.centerXAnchor.constraint(equalTo: followersInfoContainerView.centerXAnchor),
            followersTitleLabel.topAnchor.constraint(equalTo: followersInfoContainerView.topAnchor),
            
            followersQuantityLabel.widthAnchor.constraint(equalTo: followersTitleLabel.widthAnchor),
            followersQuantityLabel.heightAnchor.constraint(equalTo: followersInfoContainerView.heightAnchor, multiplier: 0.75),
            followersQuantityLabel.centerXAnchor.constraint(equalTo: followersTitleLabel.centerXAnchor),
            followersQuantityLabel.topAnchor.constraint(equalTo: followersTitleLabel.bottomAnchor),
            
            followingInfoContainerView.centerYAnchor.constraint(equalTo: userProfileImageView.centerYAnchor),
            followingInfoContainerView.leadingAnchor.constraint(equalTo: userProfileImageView.trailingAnchor, constant: 12),
            followingInfoContainerView.widthAnchor.constraint(equalToConstant: 64),
            followingInfoContainerView.heightAnchor.constraint(equalToConstant: 64),
            
            followingTitleLabel.widthAnchor.constraint(equalTo: followingInfoContainerView.widthAnchor),
            followingTitleLabel.heightAnchor.constraint(equalTo: followingInfoContainerView.heightAnchor, multiplier: 0.25),
            followingTitleLabel.centerXAnchor.constraint(equalTo: followingInfoContainerView.centerXAnchor),
            followingTitleLabel.topAnchor.constraint(equalTo: followingInfoContainerView.topAnchor),
            
            followingQuantityLabel.widthAnchor.constraint(equalTo: followingTitleLabel.widthAnchor),
            followingQuantityLabel.heightAnchor.constraint(equalTo: followingInfoContainerView.heightAnchor, multiplier: 0.75),
            followingQuantityLabel.centerXAnchor.constraint(equalTo: followingTitleLabel.centerXAnchor),
            followingQuantityLabel.topAnchor.constraint(equalTo: followingTitleLabel.bottomAnchor),
            
            toggleFollowButton.widthAnchor.constraint(equalToConstant: 40),
            toggleFollowButton.heightAnchor.constraint(equalToConstant: 40),
            toggleFollowButton.centerXAnchor.constraint(equalTo: userProfileImageView.centerXAnchor, constant: -32),
            toggleFollowButton.topAnchor.constraint(equalTo: userProfileImageView.bottomAnchor, constant: 12),

            sendMessageToUserButton.widthAnchor.constraint(equalToConstant: 40),
            sendMessageToUserButton.heightAnchor.constraint(equalToConstant: 40),
            sendMessageToUserButton.centerXAnchor.constraint(equalTo: userProfileImageView.centerXAnchor, constant: 32),
            sendMessageToUserButton.topAnchor.constraint(equalTo: userProfileImageView.bottomAnchor, constant: 12)
            
            ].map{$0.isActive = true}

    }
    
    // MARK: Lazy Instantiation
    
    lazy var dismissVCButton: UIButton = {
       let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let dismissVCIconImage = UIImage(named: "icon-arrow_prev")?.withRenderingMode(.alwaysTemplate)
    
        button.setImage(dismissVCIconImage, for: .normal)
        button.tintColor = UIColor.white.withAlphaComponent(0.25)
        button.addTarget(self, action: #selector(dismissThisViewController(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var userProfileImageView: UIImageView = {
       let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "Beyonce")
        return iv
    }()
    
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "BEYONCE"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightThin)
        return label
    }()
    
    lazy var followersInfoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var followersTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Followers"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightThin)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var followersQuantityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1.2M"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 34, weight: UIFontWeightThin)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var followingInfoContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var followingTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Following"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightThin)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var followingQuantityLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "1.2K"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 34, weight: UIFontWeightThin)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var toggleFollowButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("+", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightThin)
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = .clear
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 20
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 4, right: 0)
        button.layer.masksToBounds = false
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(toggleFollower(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var sendMessageToUserButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        var sendMessageImage = UIImage(named: "chatBubble")
        sendMessageImage = sendMessageImage?.withRenderingMode(.alwaysTemplate)
        button.tintColor = .white
        button.setImage(sendMessageImage, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        button.setTitleColor(.white, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = false
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(sendMessageToUser(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightThin)
        label.textColor = UIColor.YogieTheme.accentColor
        label.textAlignment = .center
        return label
    }()
    
    // MARK: Genral Helper Methods
    
    func dismissThisViewController(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Firebase-Related Helper Methods
    
    func sendMessageToUser(_ snder: UIButton) {
        let tempController = TempChatViewController()
        present(tempController, animated: true, completion: nil)
    }
    
    func toggleNamaskar(_ sender: UIButton) {
        if sender.backgroundColor == .white {
            namaskarOffered = true
            DispatchQueue.main.async {
                sender.backgroundColor = UIColor.YogieTheme.darkPrimaryColor
            }
        } else {
            namaskarOffered = false
            DispatchQueue.main.async {
                sender.backgroundColor = .white
            }
        }
    }
    
    func toggleFollower(_ sender: UIButton) {
        if !followedBySignedInUser {
            toggleFollowButton.setTitle("-", for: .normal)
            followedBySignedInUser = true
        } else if followedBySignedInUser {
            toggleFollowButton.setTitle("+", for: .normal)
            followedBySignedInUser = false
        }
    }
    
    func handleLogout(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        let loginController = SignInRegisterViewController()
        self.present(loginController, animated: true, completion: nil)
    }
    
    // MARK: Stretchy Header Helper Methods
    
    func updateView() {
        tableView.backgroundColor = UIColor.YogieTheme.darkPrimaryColor
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.addSubview(headerView)
        
        newHeaderLayer = CAShapeLayer()
        newHeaderLayer.fillColor = UIColor.black.cgColor
        headerView.layer.mask = newHeaderLayer
        
        let newHeight = StretchyHeader().headerHeight - StretchyHeader().headerCut / 2
        
        tableView.contentInset = UIEdgeInsets(top: newHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -newHeight)
        
        setNewView()
    }
    
    func setNewView() {
        let newHeight = StretchyHeader().headerHeight - StretchyHeader().headerCut / 2
        
        var getHeaderFrame = CGRect(x: 0, y: -newHeight, width: tableView.bounds.width, height: StretchyHeader().headerHeight)
        
        if tableView.contentOffset.y < newHeight {
            getHeaderFrame.origin.y = tableView.contentOffset.y
            getHeaderFrame.size.height = -tableView.contentOffset.y + StretchyHeader().headerCut / 2
        }
        headerView.frame = getHeaderFrame
        
        let cutDirection = UIBezierPath()
        cutDirection.move(to: CGPoint(x: 0, y: 0))
        cutDirection.addLine(to: CGPoint(x: getHeaderFrame.width, y: 0))
        cutDirection.addLine(to: CGPoint(x: getHeaderFrame.width, y: getHeaderFrame.height))
        cutDirection.addLine(to: CGPoint(x: 0, y: getHeaderFrame.height - StretchyHeader().headerCut))
        newHeaderLayer.path = cutDirection.cgPath
    }
    
    // MARK: Visual Effect Helper Methods
    
    func makeUserProfileImageCircular() {
        userProfileImageView.layer.borderWidth = 2
        userProfileImageView.layer.borderColor = UIColor.white.cgColor
        userProfileImageView.layer.masksToBounds = false
        userProfileImageView.layer.cornerRadius = 64
        userProfileImageView.clipsToBounds = true
    }
    
    func addBlurEffectToBackgroundImage(_ imageView: UIImageView) {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.alpha = 0.75
        blurredEffectView.frame = imageView.bounds
        blurredEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        imageView.addSubview(blurredEffectView)
    }
    
    // MARK: UICollection View Data Source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let asanaGoalImagesDict = userAsanaGoals[collectionView.tag]
        
        for (_, value) in asanaGoalImagesDict {
            asanaGoalImages = value
            print("COUNT: \(asanaGoalImages.count)")
        }
        
        return asanaGoalImages.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = collectionView.dequeueReusableCell(withReuseIdentifier: "AsanaCVCell", for: indexPath) as! AsanaCollectionViewCell
        
        item.asanaImageView.image = asanaGoalImages[indexPath.item]
        item.timestampLabel.text = timestampLabels[indexPath.item]
        item.namaskarUpvoteButton.tag = indexPath.item
        item.namaskarUpvoteButton.addTarget(self, action: #selector(toggleNamaskar(_:)), for: .touchUpInside)
        return item
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 428)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "AsanaGoalTitleHeader", for: indexPath) as? AsanaGoalTitleCollectionReusableView
        
        let asanaGoalImagesDict = userAsanaGoals[collectionView.tag]
        
        var currentHeaderTitle = ""
        
        for (key, _) in asanaGoalImagesDict {
            currentHeaderTitle = key
        }
        return configureHeaderView(headerView!, with: currentHeaderTitle)
    }
    
    
    func configureHeaderView(_ headerView: UICollectionReusableView, with title: String) -> UICollectionReusableView {
        headerView.backgroundColor = UIColor.YogieTheme.darkPrimaryColor.withAlphaComponent(0.75)
        headerView.addSubview(headerLabel)
        headerLabel.text = "\(title) Journey"
        headerLabel.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        
        let _ = [
            headerLabel.widthAnchor.constraint(equalTo: headerView.heightAnchor),
            headerLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
            ].map {$0.isActive = true}
        return headerView
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        if indexPath.row % 2 == 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "OtherUserAsanaGoalTVCell", for: indexPath) as! OtherUserAsanaGoalTableViewCell
//            
//            cell.delegate = self
//            cell.row = indexPath.row
//            
//            return cell
//        } else  {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OtherUserProfileCell", for: indexPath) as! OtherUserProfileTableViewCell
        
        cell.namaskarUpvoteButton.tag = indexPath.row
        cell.namaskarUpvoteButton.addTarget(self, action: #selector(toggleNamaskar(_:)), for: .touchUpInside)

        cell.postImageView.image = dummyData[indexPath.row]
        
        return cell
//        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 428.5
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let asanaTVC = cell as? AsanaGoalTableViewCell else { return }
        asanaTVC.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        asanaTVC.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let asanaTVC = cell as? AsanaGoalTableViewCell else { return }
        storedOffsets[indexPath.row] = asanaTVC.collectionViewOffset
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension OtherUserProfileTableViewController: AsanaGoalCellProtocol {
    
    func segueToUserProfileFrom(row: Int) {
        let userProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "OtherUserProfileTVC") as! OtherUserProfileTableViewController
        
        self.present(userProfileVC, animated: true, completion: nil)
    }
    
    func toggleCommentsViewInItem(row: Int) {
        print("Toggle Comments View")
    }
    
    func sharePostInItem(row: Int) {
        print("Share post")
    }
}


