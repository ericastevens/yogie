//
//  UploadJourneyStepViewController.swift
//  Yogie
//
//  Created by Erica Y Stevens on 5/22/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import Firebase

class UploadJourneyStepViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Stored Properties
    
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var storageRef: StorageReference!
    var databaseReference: DatabaseReference!
    var user: User?
    
    // MARK: View Life Cycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
        self.navigationController?.navigationBar.barTintColor = UIColor.YogieTheme.redAccentColor
        self.navigationController?.navigationBar.tintColor = UIColor.YogieTheme.accentColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForLoggedInUser()
        setupViewHierarchy()
        configureConstraints()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissVC(_:)))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upload", style: .plain, target: self, action: #selector(uploadYogieToDatabase(_:)))
        
        enterAsanaTitleTextField.delegate = self
    }
    
    // MARK: View Hierarchy and Constraints
    
    func setupViewHierarchy() {
        self.view.addSubview(imageToUploadImageView)
        self.view.addSubview(enterAsanaTitleTextField)
    }
    
    func configureConstraints() {
        let _ = [
            enterAsanaTitleTextField.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.8),
            enterAsanaTitleTextField.heightAnchor.constraint(equalToConstant: 50),
            enterAsanaTitleTextField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            enterAsanaTitleTextField.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: -12),
            enterAsanaTitleTextField.bottomAnchor.constraint(equalTo: imageToUploadImageView.topAnchor, constant: 12),
            
            imageToUploadImageView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            imageToUploadImageView.heightAnchor.constraint(equalToConstant: 375),
            imageToUploadImageView.topAnchor.constraint(equalTo: enterAsanaTitleTextField.bottomAnchor),
            imageToUploadImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
            ].map{ $0.isActive = true }
    }

    // MARK: General Helper Methods
    
    func dismissVC(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
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
        guard let asanaTitle = enterAsanaTitleTextField.text else {return}
        if asanaTitle != "" {
            print("SHOULD UPLOAD HERE")
            guard let user = self.user else { return }
            
            databaseReference = Database.database().reference(fromURL: "https://yogie-ae904.firebaseio.com/")
            let newsfeedRef = databaseReference.child("newsfeed")
            let usersRef = databaseReference.child("users")
            
            let userRef = usersRef.child(user.uid)
            let userPostsRef = userRef.child("posts")
            
            let postRef = userPostsRef.childByAutoId()
            let newsfeedPostRef = newsfeedRef.child("\(postRef.key)")
            
            storageRef = Storage.storage().reference(forURL: "gs://yogie-ae904.appspot.com/")
            print("IMAGE UPLOAD KEY: \(postRef.key)")
            let imagesStorageRef = storageRef.child("images/\(postRef.key)")
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            metadata.cacheControl = "public,max-age=300"
            
            if let imageData = UIImageJPEGRepresentation(imageToUploadImageView.image!, 0.6) {
                
                imagesStorageRef.putData(imageData, metadata: metadata, completion: { (metadata: StorageMetadata?, error: Error?) in
                    if error != nil {
                        print(error!)
                        return
                    }
                })
            }
            
            let timestamp = NSDate.timeIntervalSinceReferenceDate
            
            let newsfeedPostDict: [String:Any] = ["type": PostType.journey.rawValue,
                                                  "timestamp": timestamp,
                                                  "postedBy": "\(user.uid)",
                                                  "asana": "\(asanaTitle)"]
            newsfeedPostRef.setValue(newsfeedPostDict)
            
            let userTimelinePostDict: [String:Any] = ["type" : PostType.journey.rawValue,
                                                      "timestamp": timestamp,
                                                      "asana": "\(asanaTitle)"]
            
        
            postRef.setValue(userTimelinePostDict) { (error: Error?, ref: DatabaseReference?) in
                if error != nil {
                    print(error!)
                    return
                }
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: Lazy Instantiation
    
    lazy var imageToUploadImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    lazy var enterAsanaTitleTextField: UITextField = {
       let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocapitalizationType = .words
        tf.placeholder = "Enter Asana Title"
        tf.textColor = UIColor.YogieTheme.accentColor
        tf.backgroundColor = UIColor.YogieTheme.primaryColor
        tf.textAlignment = .center
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    // MARK: UITextFieldDelegate Methods
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else { return }
        print("TextField did end editing method called\(text)")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
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
