//
//  FrameExtractor.swift
//  Yogie
//
//  Created by Erica Y Stevens on 5/2/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import AVFoundation

protocol FrameExtractorDelegate: class {
    func captured(image: UIImage)
}

/*
 This class does the following:
    1. Accesses the camera
    2. Camera should be customizable (front/back camera, orientation, quality)
    3. SHOULD RETURN EVERY FRAME AS UIIMAGE FROM CAMERA FEED
 */


class FrameExtractor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    let captureSession = AVCaptureSession() //coordinates the flow of data from the input to the output
    
    /*
     Some of the things we are going to do with the session must take place asynchronously. Because we don’t want to block the main thread, we need to create a serial queue that will handle the work related to the session. To create a serial queue, let’s use DispatchQueue initializer and name it session queue. We will add a reference to this queue as an attribute at the beginning of the FrameExtractor class, so that we can access it later and suspend or resume it when need be. (The name we give to that queue is just a way to track it later. If you happen to create two queues with the same label, they would still remain two different queues)
     */
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    private var permissionGranted = false
    private let position = AVCaptureDevicePosition.front
    private let quality = AVCaptureSessionPresetMedium
    private let context = CIContext()
    
    weak var delegate: FrameExtractorDelegate?
    
    override init() {
        super.init()
        checkPermission()
        sessionQueue.async { [unowned self] in
            self.configureSession()
            self.captureSession.startRunning()
        }
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
        case .authorized:
            permissionGranted = true
        case .notDetermined:
            requestPermission()
        default:
            permissionGranted = false
        }
        
        
    }
    
    func requestPermission() {
        // Because the call to requestAccess is asynchronous (on an arbitrary dispatch queue), we need to suspend the session queue and resume it once we get a result from the user
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
            })
        
    }
    
    func configureSession() {
        guard permissionGranted else { return }
        captureSession.sessionPreset = quality
        guard let captureDevice = selectCaptureDevice() else { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.beginConfiguration()
        
        //Check if the capture device input can be added to the session, and add it
        guard captureSession.canAddInput(captureDeviceInput) else { return }
        captureSession.addInput(captureDeviceInput)
        
        //Now, to intercept each frame. The class AVCaptureVideoDataOutput processes uncompressed frames from the video being captured.
        
                //The way AVCaptureVideoDataOutput works is by having a delegate object it can send each frame to. Our FrameExtractor class can perfectly be this delegate and receive those frames.
        let videoOutput = AVCaptureVideoDataOutput()
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer")) //Specifies a serial queue on which each frame will be processed. (The other two functions are on a different queue)
        
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        
        guard let connection = videoOutput.connection(withMediaType: AVMediaTypeVideo) else { return }
        guard connection.isVideoOrientationSupported else { return }
        guard connection.isVideoMirroringSupported else { return }
        connection.videoOrientation = .portrait
        connection.isVideoMirrored = position == .front
        captureSession.commitConfiguration()
        
    }
    
    func selectCaptureDevice() -> AVCaptureDevice? {
        
        let discovery = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified) as AVCaptureDeviceDiscoverySession
        
        return discovery.devices.filter{
            $0.hasMediaType(AVMediaTypeVideo) && $0.position == position
        }.first
        //Now that we have a valid capture device, we can try to create an instance of AVCaptureDevice Input -> This is a class that manipulates in a concrete way the data captured by the camera
    }
    
    private func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        print("Got a frame!")
        guard let uiImage = self.imageFromSampleBuffer(sampleBuffer) else { return }
        DispatchQueue.main.async { [unowned self] in
            self.delegate?.captured(image: uiImage)
        }
    }
    
}
