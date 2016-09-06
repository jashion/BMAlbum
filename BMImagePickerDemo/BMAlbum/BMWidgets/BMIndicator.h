//
//  BMIndicator.h
//  BMImagePickerDemo
//
//  Created by jashion on 16/9/1.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BMIndicatorType) {
    BMIndicatorTypeDefault      =    0,
    BMIndicatorTypeBlack        =    1,
    BMIndicatorTypeWhite        =    2   //==BMIndicatorTypeDefault
};

@interface BMIndicator : UIView

+ (void)startIndicatorWithType: (BMIndicatorType)type;
+ (void)stopIndicator;

@end
