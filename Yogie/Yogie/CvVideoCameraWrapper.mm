//
//  CvVideoCameraWrapper.m
//  
//
//  Created by Erica Y Stevens on 5/3/17.
//
//
#import <opencv2/opencv.hpp> //adding this allows you to use OpenCV functions in this class
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/imgcodecs/ios.h> //There is a convenience function inside this file called 'UIImageToMat' that will do the uiimage to cv::mat conversion

#import "OpenCVWrapper.h"
#import "CvVideoCameraWrapper.h"

//@interface CvVideoCameraWrapper () <CvVideoCameraDelegate>
//{
//}
//@end
//
//@implementation CvVideoCameraWrapper
//{
//    UIViewController * viewController;
//    UIImageView * imageView;
//    CvVideoCamera * videoCamera;
//}
//
//-(id)initWithController:(UIViewController*)c andImageView:(UIImageView*)iv
//{
//    viewController = c;
//    imageView = iv;
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    imageView.clipsToBounds = YES;
//
//    videoCamera = [[CvVideoCamera alloc] initWithParentView:imageView];
//
//    // ... set up the camera
//
//
//        videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
//        videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetMedium;
//        videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
//        videoCamera.defaultFPS = 30;
//        videoCamera.grayscaleMode = YES;
//        videoCamera.delegate = self;
//
//        [videoCamera start];
//
//    return self;
//}
//
//
//// This #ifdef ... #endif is not needed except in special situations
//#ifdef __cplusplus
//+ (UIImage *)processImage:(UIImage *)image
//{
//    //Convert UIImage to cv::Mat
//    cv::Mat imageMat;
//    UIImageToMat(image, imageMat);
//
//    // Do some OpenCV stuff with the image
//    if (imageMat.channels() == 1) return image;
//
//    //Otherwise, convert it to grayscale using the OpenCV Function cv::cvtColor
//    cv::Mat grayMat; // create a cv::Mat named grayMat that will hold the grayscale representation of the image
//    cv::cvtColor(imageMat, grayMat, CV_BGR2GRAY);
//
//
////    const char* str = [@"TestText" cStringUsingEncoding: NSUTF8StringEncoding];
////    cv::putText(imageMat, str, cv::Point(100, 100), CV_FONT_HERSHEY_PLAIN, 2.0, cv::Scalar(0, 0, 255));
//    //may need to get and return a copy of ImageMat
//    //Convert back into uiimage and return
//    return MatToUIImage(imageMat);
//
//}
//#endif
//
//@end
