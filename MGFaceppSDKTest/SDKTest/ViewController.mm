//
//  ViewController.m
//  SDKTest
//
//  Created by 张英堂 on 2017/1/10.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "ViewController.h"
#import "../../MGFacepp/MGFacepp/MGFacepp.h"
#import "../../MGFacepp/MGFacepp/MGFaceppConfig.h"
#import "../../MGFacepp/MGFacepp/MGFaceppCommon.h"
#import "../../MGFacepp/MGFacepp/MGAlgorithmInfo.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MGLandmarkVC.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) MGFacepp *markManager;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:KMGFACEMODELNAME ofType:KMGFACEMODELTYPE];
    NSData *modelData = [NSData dataWithContentsOfFile:modelPath];
    
    MGAlgorithmInfo *sdkInfo = [MGFacepp getSDKAlgorithmInfoWithModel:modelData];
    
    NSLog(@"\n************\nSDK 功能列表: %@\n是否需要联网授权: %d\n版本号:%@\n过期时间:%@ \n************", sdkInfo.SDKAbility, sdkInfo.needNetLicense, sdkInfo.version, sdkInfo.expireDate);
    
    MGFacepp *facePP = [[MGFacepp alloc] initWithModel:modelData
                                         faceppSetting:^(MGFaceppConfig *config) {
                                             [config setOrientation:0];
                                             config.detectionMode = MGFppDetectionModeNormal;
                                         }];
    
    self.markManager = facePP;
    
    
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    _imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    _imagePickerController.allowsEditing = NO;
    
//    [self drawLandmark];
}

#pragma mark 从摄像头获取图片或视频
- (IBAction)selectImageFromCamera{
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    //相机类型（拍照、录像...）字符串需要做相应的类型转换
    _imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    _imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    
    //设置摄像头模式（拍照，录制视频）为录像模式
    _imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    [self presentViewController:_imagePickerController animated:YES completion:nil];
}

#pragma mark 从相册获取图片或视频
- (IBAction)selectImageFromAlbum{
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:_imagePickerController animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate
//该代理方法仅适用于只选取图片时
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    NSLog(@"选择完毕----image:%@-----info:%@",image,editingInfo);
}

//适用获取所有媒体资源，只需判断资源类型
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    //判断资源类型
    UIImage *image;
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
         image = info[UIImagePickerControllerOriginalImage];

        //保存图片至相册
//        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);

        
    } else {
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if (image) {
            MGLandmarkVC *vc = [[MGLandmarkVC alloc] init];
            vc.image = [self drawLandmark:image];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }];
}



- (UIImage *)drawLandmark:(UIImage *)image{
    UIImageOrientation oldOrientation = image.imageOrientation;
    image = [UIImage imageWithCGImage:[image CGImage]
                                scale:[image scale]
                          orientation:UIImageOrientationUp];
    
    MGImageData *imageData = [[MGImageData alloc] initWithImage:image];
    
    [self.markManager beginDetectionFrame];
    
    NSArray *faceArray = [self.markManager detectWithImageData:imageData];
    NSMutableArray *points = [NSMutableArray array];
    for (MGFaceInfo *faceInfo in faceArray) {
        [self.markManager GetGetLandmark:faceInfo isSmooth:NO pointsNumber:106];
        [points addObjectsFromArray:faceInfo.points];
    }
    
    
    if (faceArray.count == 0) {
        NSLog(@"未检测到人脸");
    }
    
    [self.markManager endDetectionFrame];
    
    image = [self imageByDrawingCircleOnImage:image points:points];
    
    image = [UIImage imageWithCGImage:[image CGImage]
                                scale:[image scale]
                          orientation:oldOrientation];
    return image;
}


- (void)drawLandmark{
    UIImage *image = [UIImage imageNamed:@"background"];
    
   
    image = [UIImage imageWithCGImage:[image CGImage]
                        scale:[image scale]
                  orientation: UIImageOrientationUp];

    
    
    MGImageData *imageData = [[MGImageData alloc] initWithImage:image];
    
    [self.markManager beginDetectionFrame];
    
    NSArray *faceArray = [self.markManager detectWithImageData:imageData];
    NSMutableArray *points = [NSMutableArray array];
    for (MGFaceInfo *faceInfo in faceArray) {
        [self.markManager GetGetLandmark:faceInfo isSmooth:NO pointsNumber:106];
        [points addObjectsFromArray:faceInfo.points];
    }
    
    
    if (faceArray.count == 0) {
        NSLog(@"未检测到人脸");
    }
    
    [self.markManager endDetectionFrame];
    
    image = [self imageByDrawingCircleOnImage:image points:points];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
    [self.view addSubview:imageView];
    
}

- (UIImage *)imageByDrawingCircleOnImage:(UIImage *)image points:(NSArray *)points
{
    if (points.count == 0) {
        return image;
    }
    // begin a graphics context of sufficient size
    UIGraphicsBeginImageContext(image.size);
    
    // draw original image into the context
    [image drawAtPoint:CGPointZero];
    
    // get the context for CoreGraphics
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // set stroking color and draw circle
    [[UIColor redColor] setFill];
    
    // draw circle
    for (NSValue *value in points) {
        CGPoint point = value.CGPointValue;
        NSLog(@"%f,%f",point.y,point.x);
        CGContextFillEllipseInRect(ctx, CGRectMake(point.x, point.y, 10, 10));
    }
    
    // make image out of bitmap context
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // free the context
    UIGraphicsEndImageContext();
    return retImage;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
