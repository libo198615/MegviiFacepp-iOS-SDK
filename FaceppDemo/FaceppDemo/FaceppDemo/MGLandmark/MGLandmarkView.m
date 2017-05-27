//
//  MGLandmarkView.m
//  FaceppDemo
//
//  Created by Li Bo on 2017/5/27.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "MGLandmarkView.h"
#import <QuartzCore/QuartzCore.h>

@interface MGLandmarkView ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation MGLandmarkView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_imageView];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [self drawCircle];
}



- (void)drawCircle
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //画大圆并填充颜
    UIColor*aColor = [UIColor colorWithRed:1 green:0.0 blue:0 alpha:1];
    CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
    CGContextSetLineWidth(context, 3.0);//线的宽度
    CGContextAddArc(context, 250, 140, 40, 0, 2*M_PI, 0); //添加一个圆
    CGContextDrawPath(context, kCGPathFillStroke); //绘制路径加填充
}

- (UIImage *)imageWithUIView:(UIView *)view{
    UIGraphicsBeginImageContext(view.bounds.size);
    CGContextRef currnetContext = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:currnetContext];
    // 从当前context中创建一个改变大小后的图片
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    return image;
}

- (void)saveImage:(UIImage *)image{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *dataPath = [documentPath stringByAppendingPathComponent:@"image"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:dataPath contents:nil attributes:nil];
    
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:dataPath atomically:NO];
}


- (void)setImage:(UIImage *)image{
    _imageView.image = image;
    [self setNeedsDisplay];
}

@end
