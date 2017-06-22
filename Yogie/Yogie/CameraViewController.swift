//
//  CameraViewController.swift
//  Yogie
//
//  Created by Erica Y Stevens on 5/15/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

//https://developer.apple.com/library/content/documentation/AudioVideo/Conceptual/PhotoCaptureGuide/
//https://developer.apple.com/videos/play/wwdc2016/501/

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate {
    
    // MARK: Stored Properties
    
    var session = AVCaptureSession()
    let settings = AVCapturePhotoSettings()
    let photoOutput = AVCapturePhotoOutput()
    var captureDevice: AVCaptureDevice?
    var isCaptureSessionConfigured = false
    var photoSampleBuffer: CMSampleBuffer?
    var previewPhotoSampleBuffer: CMSampleBuffer?
    var livePhotoMovieURL: URL?
    
    // MARK: Outlets

    @IBOutlet weak var previewLayer: VideoPreviewView!
    @IBOutlet weak var takeYogieButton: UIButton!
    
    // MARK: Actions
    
    @IBAction func takeYogie(_ sender: UIButton) {
        guard photoOutput.isLivePhotoCaptureEnabled else { return }

        self.configureCaptureSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
//        photoOutput.isLivePhotoCaptureEnabled = true //should be run before .startRunning() is called
        print("IS LIVE PHOTO CAPTURE SUPPORTED: \(photoOutput.isLivePhotoCaptureSupported)")
        print(settings.availablePreviewPhotoPixelFormatTypes)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
        if isCaptureSessionConfigured {
            if !session.isRunning {
                session.startRunning()
            }
        } else {
            //First time: request access, configure session and start it
            self.checkCameraAuthorization { authorized in
                guard authorized  else {
                    print("Permission to use camera denied.") //TODO: Show alert indicating inability to take and upload selfies. Go to setting to change permissions.
                    return
                }
                self.configureCaptureSession({ (success) in
                    guard success else { return }
                    self.isCaptureSessionConfigured = true
                    self.session.startRunning()
                    DispatchQueue.main.async {
                        self.previewLayer.updateVideoOrientationForDeviceOrientation()
                    }
                })
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    // MARK: General Methods
    
    // MARK: Configuration
    
    func configurePhotoOutputProperties() {
        //should be configured before capture session is started bc it would involve reconfiguration
        photoOutput.isLivePhotoCaptureEnabled = true
        photoOutput.isLivePhotoCaptureSuspended = false
        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.isLivePhotoAutoTrimmingEnabled = true
    }
    
    func configureCaptureSession(_ completion: ((_ success: Bool) -> Void)) {
        var success = false
        defer { completion(success) } // Ensure all exit paths call completion handler
        
        //Get video input for the default camera (front)
        captureDevice = defaultDevice()
        guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
            print("Unable to obtain video input for defualt camera")
            return
        }
        
        //Create and configure the photo output
        self.configurePhotoOutputProperties()
        
        //Make sure inputs/outputs can be added to the session 
        guard self.session.canAddInput(videoInput) else { return }
        guard self.session.canAddOutput(self.photoOutput) else { return }
        
        //Configure Session
        self.session.beginConfiguration()
        self.session.sessionPreset = AVCaptureSessionPresetPhoto //Live Photo Capture is only supported with this preset
        self.session.addInput(videoInput)
        self.session.addOutput(self.photoOutput)
        self.session.commitConfiguration()
        
        self.previewLayer.session = session
        self.previewLayer.videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect
        success = true
    }
    
    func configureCaptureSettings() {
       // Before taking a photo, you need to tell the photo output what kind of picture you want to take, and what format you expect to receive the captured image in
        settings.isHighResolutionPhotoEnabled = true
        settings.flashMode = .auto
    }
    
    func defaultDevice() -> AVCaptureDevice {
        if let device = AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType.builtInDuoCamera, mediaType: AVMediaTypeVideo, position: .front) {
            return device
        } else {
            let device = AVCaptureDevice.defaultDevice(withDeviceType: AVCaptureDeviceType.builtInWideAngleCamera, mediaType: AVMediaTypeVideo, position: .front)
            return device!
        }
    }
    
    // MARK: Authorization Helper Methods
    
    func checkCameraAuthorization(_ completionHandler: @escaping ((_ authorized: Bool) -> Void)) {
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            //The user has previously granted access to the camera.
            completionHandler(true)
            
        case .notDetermined:
            // The user has not yet been presented with the option to grant video access so request access.
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { success in
                completionHandler(success)
            })
            
        case .denied:
            // The user has previously denied access.
            completionHandler(false)
            
        case .restricted:
            // The user doesn't have the authority to request access e.g. parental restriction.
            completionHandler(false)
        }
    }
    
    func checkPhotoLibraryAuthorization(_ completionHandler: @escaping ((_ authorized: Bool) -> Void)) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            // The user has previously granted access to the photo library.
            completionHandler(true)
            
        case .notDetermined:
            // The user has not yet been presented with the option to grant photo library access so request access.
            PHPhotoLibrary.requestAuthorization({ status in
                completionHandler((status == .authorized))
            })
            
        case .denied:
            // The user has previously denied access.
            completionHandler(false)
            
        case .restricted:
            // The user doesn't have the authority to request access e.g. parental restriction.
            completionHandler(false)
        }
    }

    // MARK: Live Photo Delegate Methods
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        guard error == nil, let photoSampleBuff = photoSampleBuffer else {
            print("Error capturing live photo: \(error!)")
            return
        }
        
        self.photoSampleBuffer = photoSampleBuff
        self.previewPhotoSampleBuffer = previewPhotoSampleBuffer
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL, duration: CMTime, photoDisplay photoDisplayTime: CMTime, resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        guard error == nil else {
            print("Error capturing live photo: \(error!)")
            return
        }
        
        self.livePhotoMovieURL = outputFileURL
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishRecordingLivePhotoMovieForEventualFileAt outputFileURL: URL, resolvedSettings: AVCaptureResolvedPhotoSettings) {
        
    }
    
    
    
    //Occurs last. This is the point at which we handle the results of the photo capture
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishCaptureForResolvedSettings resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        guard error == nil else {
            print("Error in capture process: \(error!)")
            return
        }
        
        if let photoSampleBuff = self.photoSampleBuffer,
            let previewSampleBuff = self.previewPhotoSampleBuffer,
            let livePhotoURL = self.livePhotoMovieURL {
                 saveLivePhotoToPhotoLibrary(photoSampleBuff, previewSampleBuff: previewSampleBuff, livePhotoMovieURL: livePhotoURL, completion: { (success, error) in
                    if error != nil {
                        print("Error saving to library")
                    }
                    
                    print("Successfuly saved")
                 })
        }
        
    }
    
    func saveLivePhotoToPhotoLibrary(_ photoSampleBuff: CMSampleBuffer,
                                     previewSampleBuff: CMSampleBuffer,
                                     livePhotoMovieURL: URL,
                                     completion: ((_ success: Bool, _ error: Error?) -> Void)?) {
        self.checkPhotoLibraryAuthorization { (authorized) in
            guard authorized else {
                print("Permission to access photo library denied")
                completion?(false, nil)
                return
            }
            
            guard let jpegData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuff, previewPhotoSampleBuffer: previewSampleBuff) else {
                print("Unable to create JPEG data")
                completion?(false, nil)
                return
            }
            
            PHPhotoLibrary.shared().performChanges({ 
                let creationRequest = PHAssetCreationRequest.forAsset()
                let creationOptions = PHAssetResourceCreationOptions()
                creationOptions.shouldMoveFile = true
                creationRequest.addResource(with: PHAssetResourceType.photo, data: jpegData, options: creationOptions)
                creationRequest.addResource(with: PHAssetResourceType.pairedVideo, fileURL: livePhotoMovieURL, options: creationOptions)
                }, completionHandler: completion)
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
