//
//  ViewController.swift
//  Yogie
//
//  Created by Erica Y Stevens on 4/22/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import MobileCoreServices
import Firebase


class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var openCVVersionLabel: UILabel!
    
    var imagePicker = UIImagePickerController()
    
//    let cameraSession = AVCaptureSession() //create capture session
//    var captureDevice: AVCaptureDevice? //check capture device availability
//    var previewLayer: AVCaptureVideoPreviewLayer? //to add video inside of container

    @IBOutlet weak var addGrayscaleButton: UIButton!
    @IBOutlet weak var choosePhotoFromLibraryButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func choosePhotoWIthImagePicker(_ sender: UIButton) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makeImageGray(_ sender: UIButton) {
        self.imageView.image = OpenCVWrapper.makeImageGray(imageView.image)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
         UIApplication.shared.isStatusBarHidden = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout(_:)))
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = [kUTTypeImage as String]
        
        
        self.addGrayscaleButton.backgroundColor = .clear
        self.addGrayscaleButton.layer.cornerRadius = 5
        self.addGrayscaleButton.layer.borderWidth = 1
        self.addGrayscaleButton.layer.borderColor = UIColor.black.cgColor
        
        self.choosePhotoFromLibraryButton.backgroundColor = .clear
        self.choosePhotoFromLibraryButton.layer.cornerRadius = 5
        self.choosePhotoFromLibraryButton.layer.borderWidth = 1
        self.choosePhotoFromLibraryButton.layer.borderColor = UIColor.black.cgColor
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UIApplication.shared.isStatusBarHidden = true
    }
    


    func handleLogout(_ sender: UIBarButtonItem) {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = SignInRegisterViewController()
        self.present(loginController, animated: true, completion: nil)
    }

    // MARK: ImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
}


