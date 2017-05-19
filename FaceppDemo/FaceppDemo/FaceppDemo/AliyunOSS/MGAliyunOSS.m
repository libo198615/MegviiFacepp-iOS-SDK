//
//  MGAliyunOSS.m
//  FaceppDemo
//
//  Created by Li Bo on 2017/5/17.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import "MGAliyunOSS.h"
#import <AliyunOSSiOS/OSSService.h>
#import <UIKit/UIKit.h>
#import "MGFaceHeader.h"

NSString * const AccessKey = @"R99XwKdeCOTgk1PL";
NSString * const SecretKey = @"H4vRvPGsSdONZ1qFOoXn9Tg6fjLU7G";
NSString * const endPoint = @"https://oss-cn-hangzhou.aliyuncs.com";
NSString * const multipartUploadKey = @"multipartUploadObject";
NSString * const bucket = @"livenessdetect";

OSSClient *client;
static dispatch_queue_t OSSClientQueue;

@implementation MGAliyunOSS

- (instancetype)init{
    if (self = [super init]) {
        
        NSString *endpoint = @"http://oss-cn-hangzhou.aliyuncs.com";
        // 明文设置secret的方式建议只在测试时使用，更多鉴权模式参考后面链接给出的官网完整文档的`访问控制`章节
        id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:AccessKey
                                                                                                                secretKey:SecretKey];

        client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
    }
    return self;
}

// 异步上传
- (void)uploadData:(NSData *)data {
//    if (_uploading) {
//        return;
//    } else {
//        _uploading = YES;
//    }
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    
    // required fields
    
    
    
    put.bucketName = bucket;
    put.objectKey = [self fileName];
    put.uploadingData = data;
    
    // optional fields
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
//    put.contentType = @"";
//    put.contentMd5 = @"";
//    put.contentEncoding = @"";
//    put.contentDisposition = @"";
    
    OSSTask * putTask = [client putObject:put];
    
    [putTask continueWithBlock:^id(OSSTask *task) {
        NSLog(@"objectKey: %@", put.objectKey);
        if (!task.error) {
            NSLog(@"upload object success!");
        } else {
            NSLog(@"upload object failed, error: %@" , task.error);
        }
        return nil;
    }];
}

- (NSString *)fileName{
    // [Android/iOS]_[系统版本号]_[上传日期YYMMDDhhmmss]_[随机6个字符]_[用户id].jpg
    NSString *version = [[UIDevice currentDevice] systemVersion];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *string = [[NSString alloc]init];
    for (int i = 0; i < 6; i++) {
        int number = arc4random() % 36;
        if (number < 10) {
            int figure = arc4random() % 10;
            NSString *tempString = [NSString stringWithFormat:@"%d", figure];
            string = [string stringByAppendingString:tempString];
        }else {
            int figure = (arc4random() % 26) + 97;
            char character = figure;
            NSString *tempString = [NSString stringWithFormat:@"%c", character];
            string = [string stringByAppendingString:tempString];
        }
    }
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] stringForKey:MG_user_name];
    if (!userName) {
        userName = @"000";
    }
    NSString *folderName = [strDate substringWithRange:NSMakeRange(2, 6)];
    return [NSString stringWithFormat:@"RGBLite_images/%@/iOS_%@_%@_%@_%@.jpg",folderName,version,strDate,string,userName];
}

@end
