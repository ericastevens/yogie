//
//  CVCameraViewController.swift
//  Yogie
//
//  Created by Erica Y Stevens on 5/1/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit

class CVCameraViewController: UIViewController {

   
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var takePicButton2: UIButton!
    
    @IBAction func takePic2(_ sender: UIButton) {
        self.cvCameraWrapper.takePicture()
        previewImageView.image = self.cvCameraWrapper.addPreviewImage()
    }
    @IBOutlet weak var previewImageView: UIImageView!
    
    @IBOutlet weak var testLayerView: UIView!
    
    @IBOutlet weak var toggleCameraButton: UIButton!
    
    @IBAction func toggleCameras(_ sender: UIButton) {
       self.cvCameraWrapper.toggleFrontBackCameras()
        
    }
    
     var cvCameraWrapper: CvVideoCameraWrapper!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureImageViewConstraints()
        self.cvCameraWrapper = CvVideoCameraWrapper(controller: self, andImageView: self.imageView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showFullScreenImage(_:)))
        previewImageView.isUserInteractionEnabled = true
        previewImageView.addGestureRecognizer(tapGesture)
    
        testLayerView.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        imageView.bringSubview(toFront: testLayerView)
        testLayerView.bringSubview(toFront: takePicButton2)
        
        var toggleCameraIcon = UIImage(named: "switch_camera-512")
        toggleCameraIcon = toggleCameraIcon?.withRenderingMode(.alwaysTemplate)
        toggleCameraButton.setImage(toggleCameraIcon, for: .normal)
        toggleCameraButton.tintColor = UIColor.YogieTheme.accentColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
     //stop camera when view disappears
    }
   
    
    func showFullScreenImage(_ sender: UITapGestureRecognizer) {
        print("SHOW FULL IMAGE")
        
        let imageView = sender.view as! UIImageView
        
        let uploadImageDetailVC = UploadFreebieViewController()
        uploadImageDetailVC.imageToUploadImageView.image = imageView.image
        let uploadImageNavVC = UINavigationController(rootViewController: uploadImageDetailVC)
        present(uploadImageNavVC, animated: true)
        
    }

    func dismissFullScreenImagePreview(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    func configureImageViewConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let _ = [
            imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: self.view.frame.size.width),
            imageView.heightAnchor.constraint(equalToConstant: self.view.frame.size.height)
            ].map{ $0.isActive = true }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = true
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
