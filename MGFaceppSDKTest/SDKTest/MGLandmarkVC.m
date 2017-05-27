//
//  MGLandmarkVC.m
//  MGFaceppSDKTest
//
//  Created by Li Bo on 2017/5/27.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "MGLandmarkVC.h"

@interface MGLandmarkVC ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation MGLandmarkVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.image = _image;
    [self.view addSubview:_imageView];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"保存到相册" style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)save{
    //保存图片至相册
    UIImageWriteToSavedPhotosAlbum(_image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

#pragma mark 图片保存完毕的回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInf{
    NSLog(@"%@",error);
    if (!error) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"保存失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
