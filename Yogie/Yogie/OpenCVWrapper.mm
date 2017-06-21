//
//  OpenCVWrapper.m
//  Yogie
//
//  Created by Erica Y Stevens on 4/22/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"
#import <opencv2/imgcodecs/ios.h>

@implementation OpenCVWrapper

//C++ can be used in this class -> OpenCV Functions can be used here

+(NSString *) openCVVersionString
{
    return [NSString stringWithFormat: @"Open CV Version %s", CV_VERSION];
}

// MARK: Image Filters

+(UIImage *) addGrayScaleToImage:(UIImage *)image
{
    //Transform image into cv::Mat
    cv::Mat imageMat; //Creates a new instance of cv::Mat named imageMat
    UIImageToMat(image, imageMat);
    
    //If the imageMat has one channel, it is already gray; Just return image as-is
    if (imageMat.channels() == 1) return image;
    
    //Otherwise, transform it to gray using the opencv function cv::cvtColor
    cv::Mat grayMat; //will hold a gray copy of the original imageMat
    cv::cvtColor(imageMat, grayMat, CV_BGR2GRAY);
    
    //Transform grayMat to UIImage and return it
    return MatToUIImage(grayMat);
}

@end
