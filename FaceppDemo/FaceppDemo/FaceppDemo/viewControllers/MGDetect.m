//
//  MGDetect.m
//  FaceppDemo
//
//  Created by Li Bo on 2017/5/17.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "MGDetect.h"
#import <MGBaseKit/MGBaseKit.h>
#import "MGFacepp.h"
#import "MGFaceHeader.h"
#import <CoreMotion/CoreMotion.h>
#import "MGFaceModelArray.h"

@interface MGDetect () <MGVideoDelegate>
@property (nonatomic, strong) MGFacepp *markManager;
@property (nonatomic, strong) MGVideoManager *videoManager;
@property (nonatomic, strong) dispatch_queue_t detectQueue;

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic, assign) int orientation;
@property (nonatomic, assign) BOOL unLocked;
@property (nonatomic, assign) BOOL isDetecting;
@end

@implementation MGDetect

- (instancetype)init{
    if (self = [super init]) {
        _detectQueue = dispatch_queue_create("com.megvii.detect", DISPATCH_QUEUE_SERIAL);
        
    }
    return self;
}

- (void)startRecording{
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:KMGFACEMODELNAME ofType:@""];
    NSData *modelData = [NSData dataWithContentsOfFile:modelPath];
    
    _markManager = [[MGFacepp alloc] initWithModel:modelData
                                      faceppSetting:^(MGFaceppConfig *config) {
                                          //                                                  config.minFaceSize = 100;
                                          //                                                  config.interval = 40;
                                          //                                                  config.orientation = 90;
                                          //                                                  config.oneFaceTracking = NO;
                                          //                                                  config.detectionMode = MGFppDetectionModeTrackingFast;
                                          //                                                  config.detectROI = MGDetectROIMake(0, 0, 0, 0);
                                          //                                                  config.pixelFormatType = PixelFormatTypeRGBA;
                                      }];
    
    AVCaptureDevicePosition device = AVCaptureDevicePositionFront;
    _videoManager = [MGVideoManager videoPreset:AVCaptureSessionPreset640x480
                                 devicePosition:device
                                    videoRecord:NO
                                     videoSound:NO];
    self.videoManager.videoDelegate = self;
    [self startMotionManager];
    [self.videoManager startRecording];
}

- (void)stopRecording{
    [self.motionManager stopAccelerometerUpdates];
    [self.videoManager stopRunning];
    [self.videoManager stopRceording];
}

- (void)startMotionManager{
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = 0.3f;
    
    AVCaptureDevicePosition devicePosition = [self.videoManager devicePosition];
    
    NSOperationQueue *motionQueue = [[NSOperationQueue alloc] init];
    [motionQueue setName:@"com.megvii.gryo"];
    [self.motionManager startAccelerometerUpdatesToQueue:motionQueue
                                             withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
                                                 
                                                 if (fabs(accelerometerData.acceleration.z) > 0.7) {
                                                     self.orientation = 90;
                                                 }else{
                                                     
                                                     if (AVCaptureDevicePositionBack == devicePosition) {
                                                         if (fabs(accelerometerData.acceleration.x) < 0.4) {
                                                             self.orientation = 90;
                                                         }else if (accelerometerData.acceleration.x > 0.4){
                                                             self.orientation = 180;
                                                         }else if (accelerometerData.acceleration.x < -0.4){
                                                             self.orientation = 0;
                                                         }
                                                     }else{
                                                         if (fabs(accelerometerData.acceleration.x) < 0.4) {
                                                             self.orientation = 90;
                                                         }else if (accelerometerData.acceleration.x > 0.4){
                                                             self.orientation = 0;
                                                         }else if (accelerometerData.acceleration.x < -0.4){
                                                             self.orientation = 180;
                                                         }
                                                     }
                                                     
                                                     if (accelerometerData.acceleration.y > 0.6) {
                                                         self.orientation = 270;
                                                     }
                                                 }
                                             }];

}



#pragma mark - video delegate
-(void)MGCaptureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    if (_isDetecting) {
        return;
    }
    _isDetecting = YES;
    @synchronized(self) {
        [self detectSampleBuffer:sampleBuffer];
    }
}

- (void)MGCaptureOutput:(AVCaptureOutput *)captureOutput error:(NSError *)error{
    if (error.code == 101) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_message2", nil)
                                                            message:NSLocalizedString(@"alert_message2", nil)
                                                           delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_message3", nil)
                                                  otherButtonTitles:nil, nil];
        [alertView show];
    }
    
}

- (void)detectSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    UIImage *image = [self convertToImage:sampleBuffer];
    
    CMSampleBufferRef detectSampleBufferRef = NULL;
    CMSampleBufferCreateCopy(kCFAllocatorDefault, sampleBuffer, &detectSampleBufferRef);
    
    /* 进入检测人脸专用线程 */
    dispatch_async(_detectQueue, ^{
        if (_unLocked) {
            return;
        }
        @autoreleasepool {
            
            if ([self.markManager getFaceppConfig].orientation != self.orientation) {
                [self.markManager updateFaceppSetting:^(MGFaceppConfig *config) {
                    config.orientation = self.orientation;
                }];
            }
            
            MGImageData *imageData = [[MGImageData alloc] initWithSampleBuffer:detectSampleBufferRef];
            [self.markManager beginDetectionFrame];
            
            NSArray *tempArray = [self.markManager detectWithImageData:imageData];
            MGFaceModelArray *faceModelArray = [[MGFaceModelArray alloc] init];
            faceModelArray.faceArray = [NSMutableArray arrayWithArray:tempArray];
            
            if (faceModelArray.count >= 1) {
                MGFaceInfo *faceInfo = faceModelArray.faceArray[0];
                // 获取人脸数据
                [self.markManager GetFeatureData:faceInfo];
                NSData *newData = faceInfo.featureData;
                
                NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
                NSString *dataPath = [documentPath stringByAppendingPathComponent:MG_old_feature_data];
                NSData *oldData = [NSData dataWithContentsOfFile:dataPath];
                
                if (newData && oldData) {
                    float result = [self.markManager faceCompareWithFeatureData:oldData featureData2:newData];
                    if (result > 73.433985873578123) {
                        _unLocked = YES;
                        [self stopRecording];
                        if ([_delegate respondsToSelector:@selector(detectFinishedWithImage:)]) {
                            [_delegate detectFinishedWithImage:image];
                        }
                        [self.markManager endDetectionFrame];
                    }
                }
                
            }
            
            [self.markManager endDetectionFrame];
        }
        _isDetecting = NO;
        CFRelease(detectSampleBufferRef);
    });
}

- (UIImage *)convertToImage:(CMSampleBufferRef)sampleBuffer{
    CVImageBufferRef buffer;
    buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    CVPixelBufferLockBaseAddress(buffer, 0);
    uint8_t *base;
    size_t width, height, bytesPerRow;
    base = (uint8_t *)CVPixelBufferGetBaseAddress(buffer);
    width = CVPixelBufferGetWidth(buffer);
    height = CVPixelBufferGetHeight(buffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    
    CGColorSpaceRef colorSpace;
    CGContextRef cgContext;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    CGImageRef cgImage;
    UIImage *image;
    cgImage = CGBitmapContextCreateImage(cgContext);
    image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);
    
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    return image;
}

- (void)dealloc{
    NSLog(@"dealloc %@",self);
    _markManager = nil;
    _videoManager = nil;
}




@end
