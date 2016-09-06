//
//  Utils.m
//  BMImagePickerDemo
//
//  Created by jashion on 16/9/5.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import "Utils.h"
#import "StringUtils.h"

@implementation Utils

+ (CGFloat)calculateHeightWithContent: (NSString *)content width: (CGFloat)width font: (UIFont *)font{
    if ([StringUtils isEmpty: content]) {
        return 0.f;
    }
    CGFloat height = [content boundingRectWithSize: CGSizeMake(width, MAXFLOAT) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes: @{NSFontAttributeName : font} context: nil].size.height;
    return height;
}

+ (CGFloat)calculateWidthWithContent: (NSString *)content height: (CGFloat)height font: (UIFont *)font{
    if ([StringUtils isEmpty: content]) {
        return 0.f;
    }
    
    CGFloat width = [content boundingRectWithSize: CGSizeMake(MAXFLOAT, height) options: NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes: @{NSFontAttributeName : font} context: nil].size.height;
    return width;
}

+ (UIColor *)randomColor {
    int red = arc4random() % 256;
    int green = arc4random() % 256;
    int blue = arc4random() % 256;
    [UIColor colorWithRed:0.227 green:0.369 blue:0.098 alpha:1.000];
    return RGB(red, green, blue);
}
@end
