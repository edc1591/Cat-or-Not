//
//  Mugslide
//  Copyright © 2016 Evan Coleman. All rights reserved.
//

#import "FaceDetector.h"

#import "UIImage+OpenCV.h"

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

using namespace cv;

@interface FaceDetector ()

@property (nonatomic) CascadeClassifier humanDetector;
@property (nonatomic) CascadeClassifier catDetector;

@end

#pragma mark -

@implementation FaceDetector

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        NSString *humanCascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2" ofType:@"xml"];
        NSString *catCascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalcatface" ofType:@"xml"];
        
        _humanDetector = CascadeClassifier([humanCascadePath cStringUsingEncoding:NSUTF8StringEncoding]);
        _catDetector = CascadeClassifier([catCascadePath cStringUsingEncoding:NSUTF8StringEncoding]);
    }
    return self;
}

- (void)processImage:(cv::Mat &)image {
    CGFloat const scale = [[UIScreen mainScreen] scale];
    
    Mat gray, smallImg(cvRound(image.rows / scale), cvRound(image.cols / scale), CV_8UC1);
    cvtColor(image, gray, COLOR_BGR2GRAY);
    resize(gray, smallImg, smallImg.size(), 0, 0, INTER_LINEAR);
    equalizeHist(smallImg, smallImg);
    
    vector<cv::Rect> cats;
    vector<cv::Rect> humans;
    
    self.catDetector.detectMultiScale(smallImg, cats, 1.3, 10, 0, cv::Size(40, 40));
    self.humanDetector.detectMultiScale(smallImg, humans, 1.3, 10, 0, cv::Size(40, 40));
    
    Scalar blueColor = CV_RGB(0, 0, 255);
    Scalar greenColor = CV_RGB(0, 255, 0);
    
    for (vector<cv::Rect>::const_iterator r = cats.begin(); r != cats.end(); r++) {
        BOOL shouldDraw = true;
        
        for (vector<cv::Rect>::const_iterator s = humans.begin(); s != humans.end(); s++) {
            int x_tl = max(r->x, s->x);
            int y_tl = max(r->y, s->y);
            int x_br = min(r->x + r->width, s->x + s->width);
            int y_br = min(r->y + r->height, s->y + s->height);
            
            shouldDraw = !(x_tl < x_br && y_tl < y_br);
        }
        
        if (!shouldDraw) continue;
        
        rectangle(image,
                  cvPoint(cvRound(r->x * scale), cvRound(r->y * scale)),
                  cvPoint(cvRound((r->x + r->width - 1) * scale), cvRound((r->y + r->height - 1) * scale)),
                  blueColor, 1, 8, 0);
        putText(image, "Cat", cvPoint(cvRound(r->x * scale), cvRound(r->y * scale)),
                FONT_HERSHEY_SIMPLEX, 0.55, CV_RGB(0, 0, 255), 2);
    }
    
    for (vector<cv::Rect>::const_iterator r = humans.begin(); r != humans.end(); r++) {
        rectangle(image,
                  cvPoint(cvRound(r->x * scale), cvRound(r->y * scale)),
                  cvPoint(cvRound((r->x + r->width - 1) * scale), cvRound((r->y + r->height - 1) * scale)),
                  greenColor, 1, 8, 0);
        putText(image, "Human", cvPoint(cvRound(r->x * scale), cvRound(r->y * scale)),
                FONT_HERSHEY_SIMPLEX, 0.55, CV_RGB(0, 0, 255), 2);
    }
}

@end
