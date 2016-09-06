//
//  Utils.h
//  BMImagePickerDemo
//
//  Created by jashion on 16/9/5.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define RGBA(r, g, b, a) [UIColor colorWithRed: (r) / 255.f green: (g) / 255.f blue: (b) / 255.f  alpha: a]
#define RGB(r, g, b) RGBA(r, g, b, 1.0)

@interface Utils : NSObject

+ (CGFloat)calculateHeightWithContent: (NSString *)content width: (CGFloat)width font: (UIFont *)font;
+ (CGFloat)calculateWidthWithContent: (NSString *)content height: (CGFloat)height font: (UIFont *)font;
+ (UIColor *)randomColor;

@end
