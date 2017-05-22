//
//  UnLock.m
//  FaceppDemo
//
//  Created by Li Bo on 2017/5/16.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "UnLock.h"
#import "MGFaceppCommon.h"
#import "MGFacepp.h"
#import <AVFoundation/AVFoundation.h>
#import <MGBaseKit/MGBaseKit.h>
#import "MarkVideoViewController.h"
#import "MGDetect.h"
#import "MGAliyunOSS.h"
#import "MGFaceHeader.h"

@interface UnLock () <MGDetectDelegate>
@property (nonatomic, strong) MGDetect *detect;
@property (nonatomic, strong) MGAliyunOSS *aliyun;
@property (nonatomic, strong) UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation UnLock

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _detect = [[MGDetect alloc] init];
    _detect.delegate = self;
    [_detect startRecording];
    
    
    _imageview = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _imageview.image = [UIImage imageNamed:@"lock"];
    [self.view addSubview:_imageview];
    [self.view sendSubviewToBack:_imageview];
}

- (void)detectFinishedWithImage:(UIImage *)image{
    dispatch_async(dispatch_get_main_queue(), ^{
        _label.hidden = YES;
    });
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:MG_success_unlock_count];
    count ++;
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:MG_success_unlock_count];
    _imageview.image = [UIImage imageNamed:@"unlock"];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"恭喜" message:@"解锁成功" preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *action = [UIAlertAction actionWithTitle:@"上传图像" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self.navigationController popViewControllerAnimated:YES];
//        [self uploadData:UIImageJPEGRepresentation(image, 1)];
//    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
        [self uploadData:UIImageJPEGRepresentation(image, 1)];
    }];
//    [vc addAction:action];
    [vc addAction:cancel];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)uploadData:(NSData *)data {
    if (!data) {
        return;
    }
    if (!_aliyun) {
        _aliyun = [[MGAliyunOSS alloc] init];
    }
    
    [_aliyun uploadData:data];
}



- (void)dealloc{
    [_detect stopRecording];
    NSLog(@"dealloc %@",self);
}

@end
