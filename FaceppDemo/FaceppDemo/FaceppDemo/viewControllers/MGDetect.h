//
//  MGDetect.h
//  FaceppDemo
//
//  Created by Li Bo on 2017/5/17.
//  Copyright © 2017年 megvii. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol MGDetectDelegate <NSObject>

- (void)detectFinishedWithImage:(UIImage *)image;

@end

@interface MGDetect : NSObject

@property (nonatomic, weak) id <MGDetectDelegate> delegate;

- (instancetype)init;

- (void)startRecording;
- (void)stopRecording;

@end
