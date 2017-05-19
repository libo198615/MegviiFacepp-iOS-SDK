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
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation UnLock

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _detect = [[MGDetect alloc] init];
    _detect.delegate = self;
    [_detect startRecording];
    
    [self loadGif];
}

- (void)detectFinishedWithImage:(UIImage *)image{
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:MG_success_unlock_count];
    count ++;
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:MG_success_unlock_count];
    
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
    [self presentViewController:vc animated:YES completion:nil];
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


- (void)loadGif{
    NSData *data = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"scan" ofType:@"gif"]];
    [_webView loadData:data MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    _webView.scalesPageToFit = YES;
    _webView.backgroundColor = [UIColor clearColor];
}


- (void)dealloc{
    [_detect stopRecording];
    NSLog(@"dealloc %@",self);
}

@end
