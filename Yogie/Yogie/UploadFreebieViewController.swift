//
//  UploadYogieViewController.swift
//  Yogie
//
//  Created by Erica Y Stevens on 5/9/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import Firebase

class UploadFreebieViewController: UIViewController {
    
    // MARK: Stored Properties
    
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var storageRef: StorageReference!
    var databaseReference: DatabaseReference!
    var user: User?
    
    lazy var imageToUploadImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    // MARK: View Life Cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
        self.navigationController?.navigationBar.barTintColor = UIColor.YogieTheme.darkPrimaryColor
        self.navigationController?.navigationBar.tintColor = UIColor.YogieTheme.accentColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewHierarchy()
        configureConstraints()
        configureNavigationBar()
        checkForLoggedInUser()
        
       
    }
    
    // MARK: View Heirarchy & Constraints
    
    func configureConstraints() {
        let _ = [
            imageToUploadImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            imageToUploadImageView.heightAnchor.constraint(equalToConstant: 375),
            imageToUploadImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            imageToUploadImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
            ].map{ $0.isActive = true }
    }
    
    func setupViewHierarchy() {
        self.view.addSubview(imageToUploadImageView)
    }
    
    // MARK: General Helper Methods
    
    func dismissVC(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configureNavigationBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissVC(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upload", style: .plain, target: self, action: #selector(uploadYogieToDatabase(_:)))
    }
    
    // MARK: Firebase Helper Methods
    
    func checkForLoggedInUser() {
        _authHandle = Auth.auth().addStateDidChangeListener({ (auth: Auth?, user: User?) in
            if let activeUser = user {
                self.user = activeUser
            }
        })
    }
    
    func uploadYogieToDatabase(_ sender: UIBarButtonItem) {
        // When a user uploads a freebie, it should go into the following refs:
        // newsfeed (newsfeedRef)
        // user's profile timeline (freebiePostRef)
        
        guard let user = self.user else { return }
       
        databaseReference = Database.database().reference(fromURL: "https://yogie-ae904.firebaseio.com/")
        let newsfeedRef = databaseReference.child("newsfeed")
        let usersRef = databaseReference.child("users")
       
        
        let userRef = usersRef.child(user.uid)
        let userPostsRef = userRef.child("posts")
        
        let freebiePostRef = userPostsRef.childByAutoId()
        let newsfeedPostRef = newsfeedRef.child("\(freebiePostRef.key)")
        
        storageRef = Storage.storage().reference(forURL: "gs://yogie-ae904.appspot.com/")
        print("IMAGE UPLOAD KEY: \(freebiePostRef.key)")
        let imagesStorageRef = storageRef.child("images/\(freebiePostRef.key)")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        metadata.cacheControl = "public,max-age=300"
        
        if let imageData = UIImageJPEGRepresentation(imageToUploadImageView.image!, 0.6) {
            imagesStorageRef.putData(imageData, metadata: metadata, completion: { (metadata, error) in
                if error != nil {
                    print(error)
                    return
                }
            })
        }
 
        let newsfeedPostDict: [String:Any] = ["type": PostType.freebie.rawValue,
                                              "timestamp": NSDate.timeIntervalSinceReferenceDate,
                                              "postedBy": "\(user.uid)" ] //get @ username instead of userID
        newsfeedPostRef.setValue(newsfeedPostDict)
        
        let userTimelinePostDict: [String:Any] = ["type" : PostType.freebie.rawValue,
        "timestamp": NSDate.timeIntervalSinceReferenceDate]

        
        freebiePostRef.setValue(userTimelinePostDict) { (error, ref) in
            if error != nil {
                print(error)
                return
            }
            self.dismiss(animated: true, completion: nil)
        
        }
    }
    
}
