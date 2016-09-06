//
//  BMIndicator.m
//  BMImagePickerDemo
//
//  Created by jashion on 16/9/1.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import "BMIndicator.h"

@interface BMIndicator ()

@property (nonatomic, strong) UIActivityIndicatorView *activeIndicator;
@property (nonatomic, strong) UIView *indicatorContainer;
@property (nonatomic, assign) BMIndicatorType type;

@end

@implementation BMIndicator

+ (void)startIndicatorWithType: (BMIndicatorType)type {
    [BMIndicator stopIndicator];
    BMIndicator *indicator = [[BMIndicator alloc] initWithFrame: [UIScreen mainScreen].bounds type: (BMIndicatorType)type];
    indicator.backgroundColor = [UIColor clearColor];
    [[UIApplication sharedApplication].keyWindow addSubview: indicator];
    [UIView animateWithDuration: 0.2 animations:^{
        [UIColor colorWithWhite: 0 alpha: 0.5];
    }];
}

+ (void)stopIndicator {
	UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    for (UIView *subView in keyWindow.subviews) {
        if ([subView isKindOfClass: [BMIndicator class]]) {
            BMIndicator *bmIndicator = (BMIndicator *)subView;
            [bmIndicator.activeIndicator stopAnimating];
            [UIView animateWithDuration: 0.3 animations:^{
                bmIndicator.backgroundColor = [UIColor clearColor];
            } completion:^(BOOL finished) {
                [bmIndicator removeFromSuperview];
            }];
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame type: (BMIndicatorType)type{
    self = [super initWithFrame: frame];
    if (self) {
        _type = type;
        
        _indicatorContainer = [UIView new];
        _indicatorContainer.bounds = CGRectMake(0, 0, 80, 80);
        _indicatorContainer.center = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
        _indicatorContainer.backgroundColor = type == BMIndicatorTypeDefault ? [UIColor whiteColor] : [UIColor blackColor];
        _indicatorContainer.layer.cornerRadius = 4;
        _indicatorContainer.layer.masksToBounds = YES;
        [self addSubview: _indicatorContainer];
        
        _activeIndicator = [[UIActivityIndicatorView alloc] initWithFrame: CGRectMake(0, 0, 40, 40)];
        _activeIndicator.center = CGPointMake(40, 40);
        _activeIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        _activeIndicator.color = type == BMIndicatorTypeDefault ? [UIColor blackColor] : [UIColor whiteColor];
        [_activeIndicator startAnimating];
        [_indicatorContainer addSubview: _activeIndicator];
    }
    return self;
}

@end
