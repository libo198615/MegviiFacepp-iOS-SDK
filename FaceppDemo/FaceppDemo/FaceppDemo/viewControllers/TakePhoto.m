//
//  TakePhoto.m
//  FaceppDemo
//
//  Created by Li Bo on 2017/5/16.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "TakePhoto.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MGFacepp.h"
#import "MGFaceInfo.h"
#import "MGFaceHeader.h"
#import "MGAliyunOSS.h"

#define MGColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface TakePhoto () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic,strong) UIImagePickerController *imagePickerController;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) MGFacepp *markManager;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (nonatomic, strong) MGAliyunOSS *aliyun;

@end

@implementation TakePhoto

- (void)viewDidLoad {
    [super viewDidLoad];
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.delegate = self;
    _imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    _imagePickerController.allowsEditing = YES;
    
    [self selectImageFromCamera];
    
    
    NSString *modelPath = [[NSBundle mainBundle] pathForResource:KMGFACEMODELNAME ofType:@""];
    NSData *modelData = [NSData dataWithContentsOfFile:modelPath];
    
    MGFacepp *markManager = [[MGFacepp alloc] initWithModel:modelData
                                              faceppSetting:^(MGFaceppConfig *config) {
                                                  config.orientation = 0;
                                              }];
    self.markManager = markManager;
    _saveBtn.userInteractionEnabled = NO;
    _saveBtn.backgroundColor = [UIColor grayColor];
    _saveBtn.backgroundColor = MGColorFromRGB(0xc3c3c3);
    
    [_textField addTarget:self action:@selector(returnKey) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    _saveBtn.layer.masksToBounds = YES;
    _saveBtn.layer.cornerRadius = 7;
    _saveBtn.titleLabel.font = [UIFont systemFontOfSize:18];
}



- (void)returnKey{
    [_textField resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)detect:(UIImage *)image{
    MGImageData *imageData = [[MGImageData alloc] initWithImage:image];
    
    [self.markManager beginDetectionFrame];
    
    NSArray *faceArray = [self.markManager detectWithImageData:imageData];
    
    if (faceArray.count == 1) {
        MGFaceInfo *faceInfo = faceArray[0];
        [self.markManager GetGetLandmark:faceInfo isSmooth:YES pointsNumber:81];
    } else if (faceArray.count > 1) {
        _textField.text = @"只支持单张人脸";
    } else {
        _textField.text = @"未检测到人脸";
        [_saveBtn setTitle:@"重新录入" forState:UIControlStateNormal];
        _saveBtn.userInteractionEnabled = YES;
        _saveBtn.backgroundColor = MGColorFromRGB(0x21a9e3);
        _saveBtn.tag = 0;
    }
    [self.markManager endDetectionFrame];
    

    if (faceArray.count == 1) {
        MGFaceInfo *info1 = faceArray[0];
        NSLog(@"%@", NSStringFromCGRect(info1.rect));
        _saveBtn.userInteractionEnabled = YES;
        _saveBtn.tag = 1;
        _saveBtn.backgroundColor = MGColorFromRGB(0x21a9e3);
        
        NSString *userPhoneName = [[UIDevice currentDevice] name];
        _textField.text = userPhoneName;
        [[NSUserDefaults standardUserDefaults] setObject:userPhoneName forKey:MG_user_name];
    }
    _imageView.image = image;
}

- (void)showAlert{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"输入姓名" message:nil preferredStyle:UIAlertControllerStyleAlert];
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *tf = alertController.textFields.firstObject;
        if (tf.text.length > 0) {
            [[NSUserDefaults standardUserDefaults] setObject:tf.text forKey:MG_user_name];
            _textField.text = tf.text;
        }
    }]];
    
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    
    //定义第一个输入框；
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入姓名";
    }];
    
    [self presentViewController:alertController animated:true completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)selectImageFromCamera
{
    _saveBtn.userInteractionEnabled = NO;
    _saveBtn.backgroundColor = [UIColor grayColor];
    _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    //相机类型（拍照、录像...）字符串需要做相应的类型转换
    _imagePickerController.mediaTypes = @[(NSString *)kUTTypeImage];
    
    //设置摄像头模式（拍照，录制视频）为录像模式
    _imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    _imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    [self presentViewController:_imagePickerController animated:NO completion:nil];
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
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        UIImage *image = info[UIImagePickerControllerEditedImage];
        [self detect:image];

        
    }
    [self dismissViewControllerAnimated:YES completion:^{
        if (_saveBtn.userInteractionEnabled && _saveBtn.tag == 1) {
            [self showAlert];
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)saveBtnAction:(UIButton *)sender {
    if (sender.tag == 0) {
        [self selectImageFromCamera];
    } else {
        sender.userInteractionEnabled = NO;
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        NSString *dataPath = [documentPath stringByAppendingPathComponent:MG_old_image_data];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager createFileAtPath:dataPath contents:nil attributes:nil];
        
        NSData *data = UIImagePNGRepresentation(_imageView.image);
        [data writeToFile:dataPath atomically:NO];
        
        [self startDetect:_imageView.image];
        [self uploadData:UIImageJPEGRepresentation(_imageView.image, 1)];
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)startDetect:(UIImage *)image {
    MGImageData *imageData = [[MGImageData alloc] initWithImage:image];
    
    [self.markManager beginDetectionFrame];
    
    NSArray *faceArray = [self.markManager detectWithImageData:imageData];
    
    if (faceArray.count > 0) {
        MGFaceInfo *faceInfo = faceArray[0];
//        [self.markManager GetGetLandmark:faceInfo isSmooth:YES pointsNumber:81];
//        [self.markManager GetAttribute3D:faceInfo];
        [self.markManager GetFeatureData:faceInfo];
    } else {
        NSLog(@"no face");
    }
    [self.markManager endDetectionFrame];
    
    if (faceArray.count > 0) {
        MGFaceInfo *info1 = faceArray[0];
        NSData *featureData = info1.featureData;
        if (featureData) {
            NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
            NSString *dataPath = [documentPath stringByAppendingPathComponent:MG_old_feature_data];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager createFileAtPath:dataPath contents:nil attributes:nil];
            [featureData writeToFile:dataPath atomically:NO];
        }
    }
}


- (void)uploadData:(NSData *)data {
    if (!data) {
        return;
    }
    if (!_aliyun) {
        _aliyun = [[MGAliyunOSS alloc] init];
    }
    
    [_aliyun uploadData:data old:YES];
}


@end
