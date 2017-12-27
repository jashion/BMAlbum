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

+ (BMImageType)imageTypeWithData: (NSData *)imageData {
    if (!imageData || imageData.length <= 0) {
        return UnKnow;
    }
    uint8_t c;
    [imageData getBytes: &c length: 1];
    switch (c) {
        case 0xFF:
            return JPEG;
        case 0x89:
            return PNG;
        case 0x47:
            return GIF;
        case 0x49:
        case 0x4D:
            return TIFF;
        case 0x52:
        {
            if ([imageData length] < 12) {
                return UnKnow;
            }
            NSString *imageStr = [[NSString alloc] initWithData: [imageData subdataWithRange: NSMakeRange(0, 12)] encoding: NSASCIIStringEncoding];
            if ([imageStr hasPrefix: @"RIFF"] && [imageStr hasSuffix: @"WEBP"]) {
                return WEBP;
            }
            return UnKnow;
        }
        
        default:
            return UnKnow;
    }
}

@end
