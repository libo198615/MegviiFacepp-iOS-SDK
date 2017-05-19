//
//  UnLockDemo.m
//  FaceppDemo
//
//  Created by Li Bo on 2017/5/16.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "UnLockDemo.h"
#import "MGFaceHeader.h"

@interface UnLockDemo ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoBtn;
@property (weak, nonatomic) IBOutlet UIButton *unlockBtn;


@end

@implementation UnLockDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _unlockBtn.userInteractionEnabled = NO;
    _unlockBtn.backgroundColor = [UIColor grayColor];
    _takePhotoBtn.backgroundColor = [UIColor blueColor];
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:MG_success_unlock_count]) {
        _label.text = [NSString stringWithFormat:@"成功解锁次数: %ld",[[NSUserDefaults standardUserDefaults] integerForKey:MG_success_unlock_count]];
    } else {
        _label.text = @"成功解锁次数：0";
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:MG_success_unlock_count];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UIImage *image = [self getImage];
    if (image) {
        _imageView.image = image;
        _unlockBtn.userInteractionEnabled = YES;
        _unlockBtn.backgroundColor = [UIColor blueColor];
    }
    _label.text = [NSString stringWithFormat:@"成功解锁次数: %ld",[[NSUserDefaults standardUserDefaults] integerForKey:MG_success_unlock_count]];
    
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
