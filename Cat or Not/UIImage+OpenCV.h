//
//  Mugslide
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

#pragma mark -

@interface UIImage (OpenCV)

+ (UIImage *)imageFromCVMat:(cv::Mat)mat;

- (cv::Mat)cvMatRepresentationColor;
- (cv::Mat)cvMatRepresentationGray;

@end
