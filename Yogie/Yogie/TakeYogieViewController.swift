//
//  ImageCaptureTestViewController.swift
//  Yogie
//
//  Created by Erica Y Stevens on 4/30/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import AVFoundation


class TakeYogieViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    var captureSession : AVCaptureSession!
    var cameraOutput : AVCapturePhotoOutput!
    var previewLayer : AVCaptureVideoPreviewLayer!
//    var cvCameraWrapper : CvVideoCameraWrapper!

    @IBOutlet weak var takeYogieButton: UIButton!
    @IBOutlet weak var toggleCamerasButton: UIButton!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var previewViewWidthAnchorConstraint: NSLayoutConstraint!
    @IBOutlet weak var cameraControlsContainerView: UIView!
    @IBOutlet weak var capturedImage: UIImageView!
    
    @IBAction func takePhoto(_ sender: UIButton) {
        
    
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            kCVPixelBufferWidthKey as String: 160,
            kCVPixelBufferHeightKey as String: 160
        ]
        settings.previewPhotoFormat = previewFormat
        cameraOutput.capturePhoto(with: settings, delegate: self)
    }
    @IBAction func toggleFrontBackCamera(_ sender: UIButton) {
        switchCameraInput()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
//        self.cvCameraWrapper = CvVideoCameraWrapper(controller: self, andImageView: nil)
        
        toggleCamerasButton.setImage(#imageLiteral(resourceName: "switch_camera-512"), for: .normal)
        toggleCamerasButton.tintColor = UIColor.YogieTheme.accentColor
        
        takeYogieButton.setImage(#imageLiteral(resourceName: "tumblr_inline_mqnqyciHzO1qz4rgp"), for: .normal)
        takeYogieButton.tintColor = .red
        
        cameraControlsContainerView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto

        cameraOutput = AVCapturePhotoOutput()
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        if let input = try? AVCaptureDeviceInput(device: device) {
            if (captureSession.canAddInput(input)) {
               captureSession.addInput(input)
                if (captureSession.canAddOutput(cameraOutput)) {
                    captureSession.addOutput(cameraOutput)
                    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                    previewLayer.frame = previewView.bounds
                    previewView.layer.addSublayer(previewLayer)
                    captureSession.startRunning()
                }
            } else {
                print("issue here : captureSesssion.canAddInput")
            }
        } else {
            print("some problem here")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        self.setVideoOrientation()
        

    }
    
    func setVideoOrientation() {
        if let connection = self.previewLayer?.connection {
            if connection.isVideoOrientationSupported {
                connection.videoOrientation = self.currentVideoOrientation()
                self.previewLayer?.frame = self.view.bounds
            }
        }
    }

    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        //This method checks the current orientation of the device
        
        //AVCaptureVideoOrientation is not necessarily the same as current device orientation
        var videoOrientation: AVCaptureVideoOrientation!
        
        let orientation: UIDeviceOrientation = UIDevice.current.orientation
        
        switch orientation {
        case .portrait:
            videoOrientation = .portrait
            break
        case .landscapeLeft:
            videoOrientation = .landscapeRight
            break
        case .landscapeRight:
            videoOrientation = .landscapeLeft
            break
        case .portraitUpsideDown:
            videoOrientation = .portraitUpsideDown
            break
        default:
            videoOrientation = .portrait
        }
        
        return videoOrientation
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput,  didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?,  previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings:  AVCaptureResolvedPhotoSettings, bracketSettings:   AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print("error occure : \(error.localizedDescription)")
        }
        
        if  let sampleBuffer = photoSampleBuffer,
            let previewBuffer = previewPhotoSampleBuffer,
            let dataImage =  AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer:  sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            print(UIImage(data: dataImage)?.size as Any)
            
            let dataProvider = CGDataProvider(data: dataImage as CFData)
            let cgImageRef: CGImage! = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            let image = UIImage(cgImage: cgImageRef, scale: 1.0, orientation: UIImageOrientation.right)
            
            self.capturedImage.image = image
        } else {
            print("some error here")
        }
    }
    
    func switchCameraInput() {
        self.captureSession.beginConfiguration()
        
        var existingConnection: AVCaptureDeviceInput!
        
        for connection in self.captureSession.inputs {
            let input = connection as! AVCaptureDeviceInput
            if input.device.hasMediaType(AVMediaTypeVideo) {
                existingConnection = input
            }
        }
        
        self.captureSession.removeInput(existingConnection)
        
        var newCamera: AVCaptureDevice!
        
        if let oldCamera = existingConnection {
            if oldCamera.device.position == .back {
                newCamera = self.cameraWith(position: .front)
            } else {
                if oldCamera.device.position == .front {
                    newCamera = self.cameraWith(position: .back)
                }
            }
        }
        
        var newInput: AVCaptureDeviceInput!
        
        do {
            newInput = try AVCaptureDeviceInput(device: newCamera)
            self.captureSession.addInput(newInput)
        } catch {
            print(error)
        }
        self.captureSession.commitConfiguration()
    }

    func cameraWith(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let discovery = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified) as AVCaptureDeviceDiscoverySession
        
        for device in discovery.devices as [AVCaptureDevice] {
            if device.position == position {
                return device
            }
        }
        return nil
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
