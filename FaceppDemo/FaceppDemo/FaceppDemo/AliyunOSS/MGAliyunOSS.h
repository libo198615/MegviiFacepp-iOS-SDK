//
//  MGAliyunOSS.h
//  FaceppDemo
//
//  Created by Li Bo on 2017/5/17.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MGAliyunOSS : NSObject

//@property (nonatomic, assign) BOOL uploading;

- (instancetype)init;

//- (void)uploadFilePath:(NSString *)path;

- (void)uploadData:(NSData *)data;

- (void)uploadData:(NSData *)data old:(BOOL)old;

@end
