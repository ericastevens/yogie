////
////  RecrodingViewController.swift
////  Yogie
////
////  Created by Erica Y Stevens on 4/25/17.
////  Copyright © 2017 C4Q. All rights reserved.
////
//
//import UIKit
//import CoreMedia
//import AVFoundation
//import Firebase
//
//class RecordingViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
//    //should take pictures (when cv recognizes mudra), not record 
//    @IBOutlet weak var imageView: UIImageView!
//
//    @IBOutlet weak var previewView: UIView!
//    @IBOutlet weak var recordButton: UIButton!
//    @IBOutlet weak var toggleButton: UIButton!
//    
//    @IBOutlet weak var toggleButtonsContainerView: UIView!
//    @IBOutlet weak var recordButtonsContainerView: UIView!
//
//    let stillImageOutput = AVCapturePhotoOutput()
//
//    @IBAction func toggleButtonPressed(_ sender: UIButton) {
//        self.switchCameraInput()
//    }
//    
//
//
//    @IBAction func recordButtonPressed(_ sender: UIButton) {
//        
//        let settings = AVCapturePhotoSettings()
//        
//        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
//        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
//                             kCVPixelBufferWidthKey as String: 160,
//                             kCVPixelBufferHeightKey as String: 160]
//        settings.previewPhotoFormat = previewFormat
//        self.stillImageOutput.capturePhoto(with: settings, delegate: self)
//    }
//    
//    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
//        if let error = error {
//            print(error.localizedDescription)
//        }
//        
//        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
//            print("image: \(UIImage(data: dataImage)?.size)")
//        }
//    }
//    
//    let captureSession = AVCaptureSession()
//     private let sessionQueue = DispatchQueue(label: "session queue")
//    private let context = CIContext()
//    
//    var videoCaptureDevice: AVCaptureDevice?
//    var previewLayer: AVCaptureVideoPreviewLayer?
//    var movieFileOutput = AVCaptureMovieFileOutput()
//    
//    var outputFileLocation: URL?
//    
//    
//    var cvCameraWrapper: CvVideoCameraWrapper!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//     
//    
//        self.initializeCamera()
//        self.cvCameraWrapper = CvVideoCameraWrapper(controller: self, andImageView: self.imageView)
//        
//        recordButton.bounds.size = CGSize(width: 64, height: 64)
//        recordButton.layer.cornerRadius = recordButton.bounds.size.width / 2
//        recordButton.clipsToBounds = true
//        recordButton.backgroundColor = UIColor.red.withAlphaComponent(0.8)
//        
//        toggleButton.setImage(#imageLiteral(resourceName: "switch_camera-512"), for: .normal) //TODO: Flip image according to device.position (front or back camera)
//        toggleButton.tintColor = UIColor.YogieTheme.accentColor
//        // Do any additional setup after loading the view.
//        recordButtonsContainerView.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
//        toggleButtonsContainerView.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
//       
//        previewView.addSubview(imageView)
//        imageView.addSubview(toggleButtonsContainerView)
//        imageView.addSubview(recordButtonsContainerView)
//        imageView.bringSubview(toFront: toggleButton)
//        imageView.bringSubview(toFront: recordButton)
//        
//    
//    }
//    
//  
//    
//    override func viewWillLayoutSubviews() {
//        self.setVideoOrientation()
//    }
//    
//    // MARK: Main
//    
//    func setVideoOrientation() {
//        if let connection = self.previewLayer?.connection {
//            if connection.isVideoOrientationSupported {
//                connection.videoOrientation = self.currentVideoOrientation()
//                self.previewLayer?.frame = self.view.bounds
//            }
//        }
//    }
//    
//    func initializeCamera() {
//        self.captureSession.sessionPreset = AVCaptureSessionPresetMedium
//        
//        let discovery = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified) as AVCaptureDeviceDiscoverySession
//        
//        for device in discovery.devices as [AVCaptureDevice] {
//            //if device supports video
//            if device.hasMediaType(AVMediaTypeVideo) {
//                if device.position == AVCaptureDevicePosition.back {
//                    self.videoCaptureDevice = device
//                }
//            }
//        }
//        
//        if videoCaptureDevice != nil {
//            //Add device to capture session
//            do {
//                try self.captureSession.addInput(AVCaptureDeviceInput(device: videoCaptureDevice)) //this only captures video, audio captured at this point
//                
//                if let audioInput = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio) {
//                    try self.captureSession.addInput(AVCaptureDeviceInput(device: audioInput))
//                }
//                
//                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
//                
//                self.previewView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
//                self.previewView.layer.insertSublayer(previewLayer!, below: self.recordButton.layer)
//        
//                
//                self.previewLayer?.frame = self.previewView.frame
//                
//                self.setVideoOrientation()
//                
//                let videoOutput = AVCaptureVideoDataOutput()
//                
//                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer")) //Specifies a serial queue on which each frame will be processed. (The other two functions are on a different queue)
//                
//                guard captureSession.canAddOutput(videoOutput) else { return }
//                captureSession.addOutput(videoOutput)
//
////                self.captureSession.addOutput(self.movieFileOutput)
//                
//                self.captureSession.startRunning()
//            } catch {
//                print(error)
//            }
//        }
//    }
//    private func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
//        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
//        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
//        
//        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
//        return UIImage(cgImage: cgImage)
////        return UIImage(cgImage: cgImage, scale: 1.0, orientation: self.imageOrientation!)
//    }
//    
//    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
//        print("Got a frame!")
//        guard let uiImage = self.imageFromSampleBuffer(sampleBuffer) else { return }
//        DispatchQueue.main.async { /*[unowned self] in */
////            self.delegate?.captured(image: uiImage)
//            self.imageView.image = uiImage
////            CvVideoCameraWrapper.processImage(uiImage)
////                self.cvCameraWrapper.processImage(uiImage) //when processImage is declared as an instance method, it returns nil and crashes. When declared as a class method, it goes through the method but does not change anything (i.e. grayscale) possibly because no cvCamera exists without an instance.
//
//        }
//
//    }
//    
////    var imageOrientation: UIImageOrientation?
//    
//    func switchCameraInput() {
//        self.captureSession.beginConfiguration()
//        
//        var existingConnection: AVCaptureDeviceInput!
//        
//        for connection in self.captureSession.inputs {
//            let input = connection as! AVCaptureDeviceInput
//            if input.device.hasMediaType(AVMediaTypeVideo) {
//                existingConnection = input
//            }
//        }
//        
//        self.captureSession.removeInput(existingConnection)
//        
//        var newCamera: AVCaptureDevice!
//        
//        if let oldCamera = existingConnection {
//            if oldCamera.device.position == .back {
//                newCamera = self.cameraWith(position: .front)
//            } else {
//                if oldCamera.device.position == .front {
//                    newCamera = self.cameraWith(position: .back)
//                }
//            }
//        }
//        
//        var newInput: AVCaptureDeviceInput!
//        
//        do {
//            newInput = try AVCaptureDeviceInput(device: newCamera)
//            self.captureSession.addInput(newInput)
//        } catch {
//            print(error)
//        }
//        self.captureSession.commitConfiguration()
//    }
//    
//    // MARK: Helper Functions
//    
//    func currentVideoOrientation() -> AVCaptureVideoOrientation {
//        //This method checks the current orientation of the device
//        
//        //AVCaptureVideoOrientation is not necessarily the same as current device orientation
//        var videoOrientation: AVCaptureVideoOrientation!
//        
//        
//        let orientation: UIDeviceOrientation = UIDevice.current.orientation
//        
//        switch orientation {
//        case .portrait:
//            videoOrientation = .portrait
////            imageOrientation = self.setImageOrientationBasedOnCaptureVideo(.portrait)
//            break
//        case .landscapeLeft:
//            videoOrientation = .landscapeRight
////            imageOrientation = self.setImageOrientationBasedOnCaptureVideo(.landscapeRight)
//            break
//        case .landscapeRight:
//            videoOrientation = .landscapeLeft
////            imageOrientation = self.setImageOrientationBasedOnCaptureVideo(.landscapeLeft)
//            break
//        case .portraitUpsideDown:
//            videoOrientation = .portraitUpsideDown
////            imageOrientation = self.setImageOrientationBasedOnCaptureVideo(.portraitUpsideDown)
//            break
//        default:
//            videoOrientation = .portrait
////            imageOrientation = .right
//        }
//        
//        return videoOrientation
//    }
//    
//    func setImageOrientationBasedOnCaptureVideo(_ orientation: UIDeviceOrientation) -> UIImageOrientation {
//        var imageOrientation: UIImageOrientation!
//        
//        switch orientation {
//        case .portrait:
//            imageOrientation = .right
//        case .landscapeLeft:
//            imageOrientation = .up
//        case .landscapeRight:
//            imageOrientation = .down
//        case .portraitUpsideDown:
//            imageOrientation = .left
//        default:
//            imageOrientation = .right
//        }
//        
//        return imageOrientation
//    }
//    
//    func videoFileLocation() -> String {
//        return NSTemporaryDirectory().appending("videoFile.mov")
//    }
//    
//    func updateRecordingButtonTitle() {
//        if !self.movieFileOutput.isRecording {
//            recordButton.bounds.size = CGSize(width: 56, height: 56)
//            recordButton.layer.cornerRadius = 5
//            recordButton.backgroundColor = UIColor.YogieTheme.redAccentColor
//        }
//    }
//    
//    func maxRecordingLength() -> CMTime {
//        let seconds: Int64 = 10
//        let preferredTimeScale: Int32 = 1
//        return CMTimeMake(seconds, preferredTimeScale)
//    }
//    
//    func cameraWith(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
//        let discovery = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified) as AVCaptureDeviceDiscoverySession
//        
//        for device in discovery.devices as [AVCaptureDevice] {
//            if device.position == position {
//                return device
//            }
//        }
//        return nil
//    }
//    
//    // MARK: AVCaptureFileOutputRecordingDelegate
//    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
//        self.outputFileLocation = outputFileURL
//        self.performSegue(withIdentifier: "VideoPreview", sender: nil)
//    }
//    
//    
//     // MARK: - Navigation
//     
//     // In a storyboard-based application, you will often want to do a little preparation before navigation
//     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//     // Get the new view controller using segue.destinationViewController.
//     // Pass the selected object to the new view controller.
//        
//        let preview = segue.destination as! VideoPreviewViewController
//        preview.fileLocation = self.outputFileLocation
//     }
//    
//
//}
