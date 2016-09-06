//
//  PhotoDisplay.h
//  BMImagePickerDemo
//
//  Created by jashion on 16/8/31.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoDisplay : UIView

@property (nonatomic, copy) void(^hideBlockHandle)();

- (instancetype)initWithBGView: (UIView *)bgView photo: (UIImage *)photo photoFrame: (CGRect)photoFrame;
- (void)show;

@end
