//
//  OpenCVWrapper.h
//  Yogie
//
//  Created by Erica Y Stevens on 4/22/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface OpenCVWrapper : NSObject

//Define OpenCV interface here

//A function that gets the OpenCV Version
+(NSString *) openCVVersionString;

//This function adds grayscale to an image. It takes a UIImage as a parameter, and also returns a UIImage
+(UIImage *) addGrayScaleToImage:(UIImage *) image;

@end
