//
//  SignInRegisterViewController.swift
//  Yogie
//
//  Created by Erica Y Stevens on 4/27/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth


class SignInRegisterViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    
    var user: User?
    var databaseReference: DatabaseReference!
    
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.YogieTheme.primaryColor

        setupViewHierarchy()
        configureConstraints()
        configureFirebase()
        configureTextFields()
    }
    
    // MARK: Configuration
    
    func configureTextFields() {
        userNameInputTextField.delegate = self
        emailInputTextField.delegate = self
        passwordInputTextField.delegate = self
    }
    
    // MARK: Firebase
    
    func configureFirebase() {
        databaseReference = Database.database().reference(fromURL: "https://yogie-ae904.firebaseio.com/")
    }

    // MARK: View Hierarchy & Constraints
    
    func setupViewHierarchy() {
        self.view.addSubview(yogieTitleLabel)
        self.view.addSubview(userInputsContainerView)
        self.view.addSubview(loginRegisterButton)
        self.view.addSubview(loginRegisterSegmentedControl)
        userInputsContainerView.addSubview(userNameInputTextField)
        userInputsContainerView.addSubview(emailInputTextField)
        userInputsContainerView.addSubview(passwordInputTextField)
        userInputsContainerView.addSubview(nameSeparatorView)
        userInputsContainerView.addSubview(emailSeparatorView)
    }
    
    
    var inputsContainerHeightConstraint: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    func configureConstraints() {
        
        inputsContainerHeightConstraint = userInputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        nameTextFieldHeightAnchor = userNameInputTextField.heightAnchor.constraint(equalTo: userInputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor = emailInputTextField.heightAnchor.constraint(equalTo: userInputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor =  passwordInputTextField.heightAnchor.constraint(equalTo: userInputsContainerView.heightAnchor, multiplier: 1/3)
        
        
        let _ = [
    
        yogieTitleLabel.topAnchor.constraint(equalTo: self.topLayoutGuide.topAnchor, constant: 18),
        yogieTitleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: userInputsContainerView.topAnchor, constant: -12),
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: userInputsContainerView.widthAnchor),
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36),
        
        userInputsContainerView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        userInputsContainerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        userInputsContainerView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -24),
        inputsContainerHeightConstraint!,
        
        loginRegisterButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 45),
        loginRegisterButton.topAnchor.constraint(equalTo: userInputsContainerView.bottomAnchor, constant: 12),
        loginRegisterButton.widthAnchor.constraint(equalTo: userInputsContainerView.widthAnchor),
        
        userNameInputTextField.widthAnchor.constraint(equalTo: userInputsContainerView.widthAnchor, constant: -24),
        userNameInputTextField.topAnchor.constraint(equalTo: userInputsContainerView.topAnchor),
        userNameInputTextField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        nameTextFieldHeightAnchor!,
        
        nameSeparatorView.widthAnchor.constraint(equalTo: self.userInputsContainerView.widthAnchor),
        nameSeparatorView.heightAnchor.constraint(equalToConstant: 1),
        nameSeparatorView.bottomAnchor.constraint(equalTo: emailInputTextField.topAnchor),
        nameSeparatorView.leftAnchor.constraint(equalTo: userInputsContainerView.leftAnchor),
        
        emailInputTextField.widthAnchor.constraint(equalTo: userNameInputTextField.widthAnchor),
        emailTextFieldHeightAnchor!,
        emailInputTextField.topAnchor.constraint(equalTo: nameSeparatorView.bottomAnchor),
        emailInputTextField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
        
        emailSeparatorView.widthAnchor.constraint(equalTo: self.userInputsContainerView.widthAnchor),
        emailSeparatorView.heightAnchor.constraint(equalToConstant: 1),
        emailSeparatorView.topAnchor.constraint(equalTo: emailInputTextField.bottomAnchor),
        emailSeparatorView.leftAnchor.constraint(equalTo: userInputsContainerView.leftAnchor),
        
        passwordInputTextField.widthAnchor.constraint(equalTo: userNameInputTextField.widthAnchor),
        passwordTextFieldHeightAnchor!,
        passwordInputTextField.topAnchor.constraint(equalTo: emailInputTextField.bottomAnchor),
        passwordInputTextField.bottomAnchor.constraint(equalTo: userInputsContainerView.bottomAnchor),
        passwordInputTextField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ].map{ $0.isActive = true }
    }
    
    // MARK: Lazy Instantiation
    
    lazy var yogieTitleLabel: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Yogie"
        label.textAlignment = .center
        label.textColor = UIColor.YogieTheme.accentColor
        label.font = UIFont(name: "Sacramento-Regular", size: 90)
        return label
    }()
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
       let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = .white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(toggleLoginRegisterButton(_:)), for: .valueChanged)
        return sc
    }()
    
    func toggleLoginRegisterButton(_ sender: UISegmentedControl) {
        let title = sender.titleForSegment(at: sender.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        //Change height of inputs container view depending on selected index
        inputsContainerHeightConstraint?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100 : 150
        
        nameTextFieldHeightAnchor?.isActive = false
    
        //Adjust sizes of imput text fields
        nameTextFieldHeightAnchor = userNameInputTextField.heightAnchor.constraint(equalTo: userInputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        userNameInputTextField.placeholder = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? "" : "Username"
        userNameInputTextField.text = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? "" : userNameInputTextField.text
        nameTextFieldHeightAnchor?.isActive = true
        
        emailTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailInputTextField.heightAnchor.constraint(equalTo: userInputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor = passwordInputTextField.heightAnchor.constraint(equalTo: userInputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    lazy var userInputsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.YogieTheme.secondaryColor.withAlphaComponent(0.5)
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Register", for: .normal)
        button.backgroundColor = UIColor.YogieTheme.darkPrimaryColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleLoginRegister(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var userNameInputTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocapitalizationType = .none
        tf.placeholder = "Username"
        tf.backgroundColor = .clear
        return tf
    }()
    
    lazy var emailInputTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocapitalizationType = .none
        tf.placeholder = "Email"
        tf.backgroundColor = .clear
        tf.keyboardType = UIKeyboardType.emailAddress
        return tf
    }()
    
    lazy var passwordInputTextField: UITextField = {
       let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.autocapitalizationType = .none
        tf.placeholder = "Password"
        tf.backgroundColor = .clear
        tf.isSecureTextEntry = true
        return tf
    }()
    
    lazy var nameSeparatorView: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.darkText.withAlphaComponent(0.2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.darkText.withAlphaComponent(0.2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: Target Action Methods
    func handleLoginRegister(_ sender: UIButton) {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            loginExistingUser()
        } else {
            registerNewUser()
        }
    }
    
    func loginExistingUser() {
        guard let email = emailInputTextField.text, let password = passwordInputTextField.text else {
            print("Invalid Form")
            return
        }
        if email != "" && password.characters.count >= 6 {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print("Error logging user in")
            }
            
            self.presentMainApp()
        })
        }
    }
    
    func registerNewUser() {
        guard let email = emailInputTextField.text, let password = passwordInputTextField.text, let userName = userNameInputTextField.text else {
            return
        }
        if email == "" {
            let alertController = UIAlertController(title: "Missing Email", message: "Please enter valid email to register with Yogie", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
        } else if password.characters.count < 6 {
            let alertController = UIAlertController(title: "Invalid Password", message: "Password must be longer than 6 characters", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)

        } else if userName == "" {
            let alertController = UIAlertController(title: "Missing Username", message: "Please enter valid username to continue", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alertController.addAction(okayAction)
            self.present(alertController, animated: true, completion: nil)
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print("Error Creating User: \(error!)\n")
                let alertController = UIAlertController(title: "Error Creating User", message: "\(error!.localizedDescription)", preferredStyle: .alert)
                let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                alertController.addAction(okayAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            //save user to database
            let usersRef = self.databaseReference.child("users")
            
            guard let uid = user?.uid else { return }
            
            let userRef = usersRef.child(uid)
            let values = ["username" : userName,
                          "email" : email]
        
            
            userRef.updateChildValues(values, withCompletionBlock: { (err, ref) in
                if err != nil {
                    print("\(err!)")
                }
                self.presentMainApp()
            })
        })
    }
    
    func presentMainApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let feedTVC = storyboard.instantiateViewController(withIdentifier: "NewsfeedVC") as! NewsfeedTableViewController
        let profileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileTVC") as! ProfileTableViewController
        let takeFreeYogieVC = storyboard.instantiateViewController(withIdentifier: "CameraVC") as! YogieCaptureCameraViewController

        let feedNavTVC = UINavigationController(rootViewController: feedTVC)
            
        let tabBarController = UITabBarController()
        
        let controllers = [feedNavTVC, takeFreeYogieVC, profileVC,] //should be feed, take yogie, challenges
        tabBarController.viewControllers = controllers
        tabBarController.tabBar.barTintColor = UIColor.YogieTheme.darkPrimaryColor
        tabBarController.tabBar.tintColor = .white
        
        tabBarController.tabBar.isTranslucent = true
        
        var profileIcon = UIImage(named: "userProfileIcon44x44")
        profileIcon = profileIcon?.withRenderingMode(.alwaysTemplate)
        
        profileVC.tabBarItem = UITabBarItem(title: nil, image: profileIcon, tag: 2)
        profileVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        var takeYogieIcon = UIImage(named: "takeYogieIcon_40x40")
        takeYogieIcon = takeYogieIcon?.withRenderingMode(.alwaysTemplate)
        
        takeFreeYogieVC.tabBarItem = UITabBarItem(title: nil, image: takeYogieIcon, tag: 1)
        takeFreeYogieVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        var haumIcon = UIImage(named: "haumIcon_75x75")
        haumIcon = haumIcon?.withRenderingMode(.alwaysTemplate)
        
        
        feedNavTVC.tabBarItem = UITabBarItem(title: nil, image: haumIcon, tag: 0)
        feedNavTVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            
        self.present(tabBarController, animated: true)
    }
    
    // MARK: UITextFieldDelegate Methods
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("TextField did end editing method called\(textField.text)")
    }
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
}
