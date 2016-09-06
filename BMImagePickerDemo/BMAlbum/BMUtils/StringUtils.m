//
//  StringUtils.m
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/9.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import "StringUtils.h"

@implementation StringUtils

+ (BOOL)isEmpty: (NSString *)originStr {
    if (!originStr) {
        return YES;
    }
    
    if ([originStr isEqual: [NSNull null]]) {
        return YES;
    }
    
    if ([[originStr stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]] isEqualToString: @""]) {
        return YES;
    }
    
    return NO;
}

@end
