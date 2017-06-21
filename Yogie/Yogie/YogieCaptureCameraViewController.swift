//
//  YogieCaptureCameraViewController.swift
//  Yogie
//
//  Created by Erica Y Stevens on 5/20/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import AVFoundation

class YogieCaptureCameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: Outlets
    
    @IBOutlet weak var currentSelectedModeLabel: UILabel!
    @IBOutlet weak var previewLayer: VideoPreviewView!
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var takeYogieButton: UIButton!
    @IBOutlet weak var toggleCameraPositionButton: UIButton!
    @IBOutlet weak var cameraActionButtonsContainerView: UIView!
    @IBOutlet weak var toggleFreebieJourneySegmentedControl: UISegmentedControl!
    
    // MARK: Action Methods
    
    @IBAction func uploadModeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            print("Freebie Mode Selected")
            currentSelectedModeLabel.text = "Freebie Mode"
        case 1:
            print("Journey Mode Selected")
            currentSelectedModeLabel.text = "Journey Mode"
        default:
            break
        }
    }
    
    @IBAction func captureYogie(_ sender: UIButton) {
        captureYogie = true
    }
    
    @IBAction func toggleCameraPosition(_ sender: UIButton) {
        print("TOGGLE CAMERA")
    }
    
    // MARK: Store Properties
    
    let session = AVCaptureSession()
//    private let sessionQueue = DispatchQueue(label: "session queue", attributes: [], target: nil)
    var device: AVCaptureDevice!
    var cameraOutput = AVCaptureVideoDataOutput()
    var captureYogie = false
    
    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCamera()
        enableTapGestureForCapturedImage()
        configureSettingsButtonAppearances()
        configureSegmentedControlAppearance()
        configureSelectedModeLabel()
       
        
        cameraActionButtonsContainerView.backgroundColor = UIColor.YogieTheme.primaryColor.withAlphaComponent(0.4)
    }
    
    override func viewWillLayoutSubviews() {
        capturedImageView.layer.cornerRadius = 8
        capturedImageView.clipsToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        previewLayer.updateVideoOrientationForDeviceOrientation()
    }
    
    
    // MARK: General Helper Methods
    
    func enableTapGestureForCapturedImage() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showFullScreenImage(_:)))
        capturedImageView.isUserInteractionEnabled = true
        capturedImageView.addGestureRecognizer(tapGesture)
    }
    
    func showFullScreenImage(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        if imageView.image != nil {
            switch toggleFreebieJourneySegmentedControl.selectedSegmentIndex {
            case 0:
                let uploadImageDetailVC = UploadFreebieViewController()
                uploadImageDetailVC.imageToUploadImageView.image = imageView.image
                let uploadImageNavVC = UINavigationController(rootViewController: uploadImageDetailVC)
                present(uploadImageNavVC, animated: true)
            case 1:
                let uploadImageDetailVC = UploadJourneyStepViewController()
                uploadImageDetailVC.imageToUploadImageView.image = imageView.image
                let uploadImageNavVC = UINavigationController(rootViewController: uploadImageDetailVC)
                present(uploadImageNavVC, animated: true)
            default:
                break
            }
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    func configureSettingsButtonAppearances() {
        var toggleCameraIcon = UIImage(named: "switch_camera-512")
        toggleCameraIcon = toggleCameraIcon?.withRenderingMode(.alwaysTemplate)
        toggleCameraPositionButton.setImage(toggleCameraIcon, for: .normal)
        toggleCameraPositionButton.tintColor = UIColor.YogieTheme.accentColor
        
    }
    
    func configureSelectedModeLabel() {
        currentSelectedModeLabel.textColor = UIColor.YogieTheme.accentColor
        currentSelectedModeLabel.textAlignment = .center
        currentSelectedModeLabel.font = UIFont.systemFont(ofSize: 9, weight: UIFontWeightThin)
        switch toggleFreebieJourneySegmentedControl.selectedSegmentIndex {
        case 0:
            print("Freebie Mode Selected")
            currentSelectedModeLabel.text = "Freebie Mode"
        case 1:
            print("Journey Mode Selected")
            currentSelectedModeLabel.text = "Journey Mode"
        default:
            break
        }
    }
    
    func configureSegmentedControlAppearance() {
        let attr = NSDictionary(object: UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin), forKey: NSFontAttributeName as NSCopying)
        toggleFreebieJourneySegmentedControl.setTitleTextAttributes(attr as [NSObject : AnyObject] , for: .normal)
        toggleFreebieJourneySegmentedControl.layer.masksToBounds = true
        toggleFreebieJourneySegmentedControl.layer.cornerRadius = 5
        toggleFreebieJourneySegmentedControl.layer.borderWidth = 0.5
        toggleFreebieJourneySegmentedControl.layer.borderColor = UIColor.white.cgColor.copy(alpha: 0.0)
    }
    
    // MARK: AVCaptureSession Helper Methods
    
    func configureCamera() {
        session.sessionPreset = AVCaptureSessionPresetPhoto // specifies imge quality/resolution
        
        setDefaultCaptureDevice()
    }
    

    func setDefaultCaptureDevice() {
        if let availableDevices = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .back).devices {
            self.device = availableDevices.first!
            self.beginSession()
        }
    }
    
    func beginSession() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: device) //triggers camera permission
            session.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        self.previewLayer.videoPreviewLayer.session = session
        self.previewLayer.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        session.startRunning()
        
        cameraOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)]
        cameraOutput.alwaysDiscardsLateVideoFrames = true
        
        guard session.canAddOutput(cameraOutput) else { return }
        session.addOutput(cameraOutput)
        
        session.commitConfiguration()
        
        let yogieQueue = DispatchQueue(label: "YogieCaptureQueue")
        cameraOutput.setSampleBufferDelegate(self, queue: yogieQueue)
    }
    
    
    
    //MARK: AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if captureYogie {
            captureYogie = false
            self.getImageFromSampleBuffer(buffer: sampleBuffer)
        }
    }

    func getImageFromSampleBuffer(buffer: CMSampleBuffer) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                DispatchQueue.main.async {
                    self.capturedImageView.image = UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
                }
            }
        }
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
