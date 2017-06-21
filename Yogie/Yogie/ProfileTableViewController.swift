//
//  ProfileTableViewController.swift
//  Yogie
//
//  Created by Erica Y Stevens on 5/12/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import MobileCoreServices
import Firebase

struct ProfileStretchyHeader {
    let headerHeight: CGFloat = 250
    let headerCut: CGFloat = 0 // play around with this value to see to test different effects
}

class ProfileTableViewController: UITableViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: Outlets
    
    @IBOutlet weak var stretchyImageView: UIImageView!
    
    // MARK: Stored Properties
    
    var headerView: UIView!
    var newHeaderLayer: CAShapeLayer!
    var profilePhotoImagePicker = UIImagePickerController()
    var coverPhotoImagePicker = UIImagePickerController()
    var storedOffsets = [Int: CGFloat]()
    var namaskarOffered = false
    let timestampLabels = ["2w", "3w", "1m"]
    let userAsanaGoals: [[String:[UIImage]]] = [
        ["Dancer Pose" : [#imageLiteral(resourceName: "Dancer3"), #imageLiteral(resourceName: "Dancer2"), #imageLiteral(resourceName: "Dancer1")]],
        ["Wheel Pose" : [#imageLiteral(resourceName: "beyYoga2"), #imageLiteral(resourceName: "beyYoga2"), #imageLiteral(resourceName: "beyYoga2")]],
        ["Backbend" : [#imageLiteral(resourceName: "Backbend3"), #imageLiteral(resourceName: "Backbend2"), #imageLiteral(resourceName: "Backbend1")]]
    ]
    var asanaGoalImages: [UIImage]!
    
    fileprivate var _refHandle: DatabaseHandle!
    var databaseReference: DatabaseReference!
    var usersReference: DatabaseReference!
    var storageReference: StorageReference!
    var user: User?
    var currentLoggedInUser: YogieUser?
    var postedByUserId: String?
    var userPosts = [Post]()
    
    
    // MARK: View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserObject()
        updateView()
        configureProfileStretchyHeader()
        configureStretchyHeaderViewHeirarchy()
        configureStretchyHeaderConstraints()
        configureImagePicker()
        getUserPostsFromDatabase()
        self.refreshControl?.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        self.refreshControl?.tintColor = UIColor.YogieTheme.accentColor
    }
    
    override func viewWillLayoutSubviews() {
        setNewView()
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setNewView()
    }
    
    // MARK: Firebase Helper Methods
    
    func getUserObject() {
        guard let firUser = Auth.auth().currentUser else {return}
        createUserFrom(firUser.uid, completion: { (user) in
            self.currentLoggedInUser = user
            self.user = firUser
        })
    }
    
    func logoutUser(_ sender: UIButton) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                let loginController = SignInRegisterViewController()
                self.present(loginController, animated: true, completion: nil)
            }
            catch let error as NSError {
                print("ERROR \(error.localizedDescription)")
            }
        }
    }
    
    func createUserFrom(_ uid: String, completion: @escaping (YogieUser) -> ())  {
        databaseReference = Database.database().reference(fromURL: "https://yogie-ae904.firebaseio.com/")
        let usersRef = databaseReference.child("users")
        
        _refHandle = usersRef.observe(.childAdded, with: { (snapshot) in
            print("USERS SNAPSHOT: \(snapshot)")
            print("SNAPSHOT KEY: \(snapshot.key)")
            
            if snapshot.key == uid {
                if let userInfoDict = snapshot.value as? [String:Any] {
                    if let email = userInfoDict["email"] as? String {
                        if let username = userInfoDict["username"] as? String {
                            let user = YogieUser(email: email, username: username)
                            completion(user)
                        }
                    }
                }
            }
            
        })
    }
    
    func getPostImageFromStorage(_ key: String, completion: @escaping (UIImage) -> ()) {
        
        storageReference = Storage.storage().reference(forURL: "gs://yogie-ae904.appspot.com/").child("images/").child("\(key)")
        
       
        storageReference.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
            if error != nil {
                print("ERROR DOWNLOADING IMAGE: \(error!.localizedDescription)")
                return
            }
            if let postImage = UIImage(data: data!) {
                completion(postImage)
            }
            }.resume()
    }
    
    func getUserPostsFromDatabase() {
        databaseReference = Database.database().reference(fromURL: "https://yogie-ae904.firebaseio.com/")
        
        usersReference = databaseReference.child("users")
        
        _refHandle = usersReference.observe(.value, with: { (snapshot) in
            
            guard let thisUser = self.user else { return }
            
            if let userInfoDict = snapshot.value as? [String:Any] {
                for (key, value) in userInfoDict {
                    print("KEY: \(key), VALUE: \(value)")
                    if key == thisUser.uid {
                        
                        if let userDetails = value as? [String:Any] {
                            print("THIS USER'S DETAILS: \(userDetails)")
                            if let userPostsDict = userDetails["posts"] as? [String:Any] {
                                
                                
                                print("ALL USER POSTS: \(userPostsDict)")
                                for (key, value) in userPostsDict {
                                    print("Key: \(key), Value: \(value)")
                                    if let postMetadata = value as? [String:Any] {
                                    if let timestamp = postMetadata["timestamp"] as? Double {
                                        if let type = postMetadata["type"] as? String {
                                            self.getPostImageFromStorage(key, completion: { (image) in
                                                
                                                let imageTimestampTuple = (timestamp, image)
                                                var imageTimestampTupleArr = [(Double,UIImage)]()
                                                imageTimestampTupleArr.append(imageTimestampTuple)
                                                let userPost = Post(type: type, imageData: imageTimestampTupleArr, user: self.currentLoggedInUser!, timestamp: timestamp, asanaTitle: nil)
                                               
                    
                                                self.userPosts.append(userPost)
                                                DispatchQueue.main.async {
                                                    self.tableView.reloadData()
                                                }
                                            })
                                        }
                                    }
                                }
                                }
                            }
                        }
                    }
                }
            }
        })
    }
    
    func refreshData(_ sender: UIRefreshControl) {
        databaseReference = Database.database().reference(fromURL: "https://yogie-ae904.firebaseio.com/")
        
        usersReference = databaseReference.child("users")
        _refHandle = usersReference.observe(.childAdded, with: { (snapshot) in
            guard let thisUser = self.user else { return }
            self.userPosts = [Post]()
            if let userInfoDict = snapshot.value as? [String:Any] {
                for (key, value) in userInfoDict {
                    print("KEY: \(key), VALUE: \(value)")
                    if key == thisUser.uid {
                        
                        if let userDetails = value as? [String:Any] {
                            print("THIS USER'S DETAILS: \(userDetails)")
                            if let userPostsDict = userDetails["posts"] as? [String:Any] {
                                
                                
                                print("ALL USER POSTS: \(userPostsDict)")
                                for (key, value) in userPostsDict {
                                    print("Key: \(key), Value: \(value)")
                                    if let postMetadata = value as? [String:Any] {
                                        if let timestamp = postMetadata["timestamp"] as? Double {
                                            if let type = postMetadata["type"] as? String {
                                                self.getPostImageFromStorage(key, completion: { (image) in
                                                    let imageTimestampTuple = (timestamp, image)
                                                    var imageTimestampTupleArr = [(Double,UIImage)]()
                                                    imageTimestampTupleArr.append(imageTimestampTuple)
                                                    let userPost = Post(type: type, imageData: imageTimestampTupleArr, user: self.currentLoggedInUser!, timestamp: timestamp, asanaTitle: nil)
                                                    self.userPosts.append(userPost)
                                                    DispatchQueue.main.async {
                                                        self.tableView.reloadData()
                                                    }
                                                })
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
        
        self.refreshControl?.endRefreshing()
    }
    
    
    // MARK: Target Action Methods
    
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
    
    // MARK: Image Picker Helper Methods
    
    func configureImagePicker() {
        profilePhotoImagePicker.delegate = self
        profilePhotoImagePicker.sourceType = .savedPhotosAlbum
        profilePhotoImagePicker.allowsEditing = false
        profilePhotoImagePicker.mediaTypes = [kUTTypeImage as String]
        
        coverPhotoImagePicker.delegate = self
        coverPhotoImagePicker.sourceType = .savedPhotosAlbum
        coverPhotoImagePicker.allowsEditing = false
        coverPhotoImagePicker.mediaTypes = [kUTTypeImage as String]
    }
    
    func chooseNewProfilePicFromPhotoLibraryOrCamera(_ sender: UITapGestureRecognizer) {
        
        let alertController = UIAlertController(title: "Choose Photo Source", message: nil, preferredStyle: .alert)
        
        let chooseFromPhotoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            print("Should go to user photos from here")
            self.present(self.profilePhotoImagePicker, animated: true, completion: nil)
        }
        let takePhotoWithCameraAction = UIAlertAction(title: "Use Camera", style: .default) { (action) in
            print("Should go to user camera")
            self.dismiss(animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(chooseFromPhotoLibraryAction)
        alertController.addAction(takePhotoWithCameraAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func updateCoverPhoto(_ sender: UILongPressGestureRecognizer) {
        
        let alertController = UIAlertController(title: "Update Cover Photo?", message: nil, preferredStyle: .alert)
        
        let chooseFromPhotoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            print("Should go to user photos from here")
            self.present(self.coverPhotoImagePicker, animated: true, completion: nil)
        }
        let takePhotoWithCameraAction = UIAlertAction(title: "Use Camera", style: .default) { (action) in
            print("Should go to user camera")
            self.dismiss(animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(chooseFromPhotoLibraryAction)
        alertController.addAction(takePhotoWithCameraAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: Stretchy Header Helper Methods
    
    func configureProfileStretchyHeader() {
        stretchyImageView.image = #imageLiteral(resourceName: "dummyCoverPhoto")
        stretchyImageView.isUserInteractionEnabled = true
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(updateCoverPhoto(_:)))
        stretchyImageView.addGestureRecognizer(longPressRecognizer)
        
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
        stretchyImageView.addSubview(logoutButton)
        
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
        stretchyImageView.bringSubview(toFront: stretchyImageView)
        stretchyImageView.bringSubview(toFront: logoutButton)
    }
    
    func configureStretchyHeaderConstraints() {
        let _ = [
            stretchyImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            
            logoutButton.trailingAnchor.constraint(equalTo: stretchyImageView.trailingAnchor, constant: -8),
            logoutButton.topAnchor.constraint(equalTo:stretchyImageView.topAnchor, constant: 8.0),
            
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
            followingQuantityLabel.topAnchor.constraint(equalTo: followingTitleLabel.bottomAnchor)
            ].map{$0.isActive = true}
    }
    
    func updateView() {
        tableView.backgroundColor = UIColor.YogieTheme.darkPrimaryColor
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.addSubview(headerView)
        
        newHeaderLayer = CAShapeLayer()
        newHeaderLayer.fillColor = UIColor.black.cgColor
        headerView.layer.mask = newHeaderLayer
        
        let newHeight = ProfileStretchyHeader().headerHeight - ProfileStretchyHeader().headerCut / 2
        
        tableView.contentInset = UIEdgeInsets(top: newHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -newHeight)
        
        setNewView()
    }
    
    func setNewView() {
        let newHeight = ProfileStretchyHeader().headerHeight - ProfileStretchyHeader().headerCut / 2
        
        var getHeaderFrame = CGRect(x: 0, y: -newHeight, width: tableView.bounds.width, height: ProfileStretchyHeader().headerHeight)
        
        if tableView.contentOffset.y < newHeight {
            getHeaderFrame.origin.y = tableView.contentOffset.y
            getHeaderFrame.size.height = -tableView.contentOffset.y + ProfileStretchyHeader().headerCut / 2
        }
        
        headerView.frame = getHeaderFrame
        
        let cutDirection = UIBezierPath()
        cutDirection.move(to: CGPoint(x: 0, y: 0))
        cutDirection.addLine(to: CGPoint(x: getHeaderFrame.width, y: 0))
        cutDirection.addLine(to: CGPoint(x: getHeaderFrame.width, y: getHeaderFrame.height))
        cutDirection.addLine(to: CGPoint(x: 0, y: getHeaderFrame.height - StretchyHeader().headerCut))
        
        //        cutDirection.move(to: CGPoint(x: 0, y: 0))
        //        cutDirection.addLine(to: CGPoint(x: getHeaderFrame.width, y: 0))
        //        cutDirection.addLine(to: CGPoint(x: getHeaderFrame.width, y: getHeaderFrame.height))
        //        cutDirection.addLine(to:  CGPoint(x: getHeaderFrame.width / 2, y: getHeaderFrame.height - 55))
        //        cutDirection.addLine(to: CGPoint(x: 0, y: getHeaderFrame.height - ProfileStretchyHeader().headerCut))
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
    
    // MARK: Lazy Instantiation
    
    lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("LOGOUT", for: .normal)
        button.addTarget(self, action: #selector(logoutUser(_:)), for: .touchUpInside)
        button.setTitleColor(UIColor.YogieTheme.accentColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightThin)
        button.isHidden = true  
        return button
    }()
    
    lazy var userProfileImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.image = #imageLiteral(resourceName: "DummyUserProfile")
        iv.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(chooseNewProfilePicFromPhotoLibraryOrCamera(_:)))
        iv.addGestureRecognizer(tapGesture)
        return iv
    }()
    
    lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "ERICA S."
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
        label.text = "213"
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
        label.text = "84"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 34, weight: UIFontWeightThin)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightThin)
        label.textColor = UIColor.YogieTheme.accentColor
        label.textAlignment = .center
        return label
    }()
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if picker == profilePhotoImagePicker {
            if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                userProfileImageView.image = selectedImage
            }
            dismiss(animated: true, completion: nil)
        }
        
        if picker == coverPhotoImagePicker {
            if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
                stretchyImageView.image = selectedImage
            }
            dismiss(animated: true, completion: nil)
        }
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
    
    // MARK: Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let userPostsSortedByDate = self.userPosts.sorted() { $0.timestamp > $1.timestamp}
        return userPosts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                if indexPath.row % 2 == 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "UserAsanaGoalTVCell", for: indexPath) as! AsanaGoalTableViewCell
        
                    cell.delegate = self
                    cell.row = indexPath.row
        
                    return cell
                } else  {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileTableViewCell
        cell.delegate = self
        cell.row = indexPath.row
        
//        let userPostsSortedByDate = self.userPosts.sorted() { $0.timestamp > $1.timestamp}
        let post = userPosts[indexPath.row]
        cell.namaskarUpvoteButton.tag = indexPath.row
        cell.namaskarUpvoteButton.addTarget(self, action: #selector(toggleNamaskar(_:)), for: .touchUpInside)
        
        if let imageInfoTuple = post.imageData.first {
            
                cell.userPostImageView.image = imageInfoTuple.1
                
                let timeInterval = TimeInterval(imageInfoTuple.0)
                let dateFromTimeInterval = NSDate(timeIntervalSinceReferenceDate: timeInterval)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "M/d/yy"
                let postDateString = dateFormatter.string(from: dateFromTimeInterval as Date)
                
                cell.timestampLabel.text = postDateString
            
        }
        
        
        
        return cell
        }
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
}

extension ProfileTableViewController: AsanaGoalCellProtocol {
    
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

