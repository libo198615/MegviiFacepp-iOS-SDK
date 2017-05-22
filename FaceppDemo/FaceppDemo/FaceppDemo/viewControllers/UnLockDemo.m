//
//  UnLockDemo.m
//  FaceppDemo
//
//  Created by Li Bo on 2017/5/16.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "UnLockDemo.h"
#import "MGFaceHeader.h"

#define MGColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface UnLockDemo ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoBtn;
@property (weak, nonatomic) IBOutlet UIButton *unlockBtn;
@property (weak, nonatomic) IBOutlet UIWebView *webView;


@end

@implementation UnLockDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:MG_success_unlock_count]) {
        _label.text = [NSString stringWithFormat:@"成功解锁次数: %ld",[[NSUserDefaults standardUserDefaults] integerForKey:MG_success_unlock_count]];
    } else {
        _label.text = @"成功解锁次数：0";
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:MG_success_unlock_count];
    }
    
    _takePhotoBtn.layer.masksToBounds = YES;
    _takePhotoBtn.layer.cornerRadius = 7;
    _takePhotoBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    _takePhotoBtn.backgroundColor = MGColorFromRGB(0x21a9e3);
    _unlockBtn.layer.masksToBounds = YES;
    _unlockBtn.layer.cornerRadius = 7;
    _unlockBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    _unlockBtn.userInteractionEnabled = NO;
    _unlockBtn.backgroundColor = [UIColor grayColor];
    _unlockBtn.backgroundColor = MGColorFromRGB(0xc3c3c3);
    
    [self loadGif];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UIImage *image = [self getImage];
    if (image) {
        _imageView.image = image;
        _unlockBtn.userInteractionEnabled = YES;
        _unlockBtn.backgroundColor = MGColorFromRGB(0x21a9e3);
    }
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:MG_success_unlock_count];
    _label.text = [NSString stringWithFormat:@"成功解锁次数: %ld",count];
    _webView.hidden = _imageView.image ? YES : NO;
}

- (void)loadGif{
    NSData *data = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"scan" ofType:@"gif"]];
    [_webView loadData:data MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    _webView.scalesPageToFit = YES;
    _webView.backgroundColor = [UIColor clearColor];
    
}

- (UIImage *)getImage{
    UIImage *image = nil;
    
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *dataPath = [documentPath stringByAppendingPathComponent:MG_old_image_data];
    
    NSData *imageData = [NSData dataWithContentsOfFile:dataPath];
    image = [UIImage imageWithData:imageData];
    return image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
