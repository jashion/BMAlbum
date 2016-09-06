//
//  UIView+Addition.m
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/6.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import "UIView+Addition.h"

@implementation UIView (Addition)

- (void)setOriginalX:(CGFloat)originalX {
    CGRect frame = self.frame;
    frame.origin.x = originalX;
    self.frame = frame;
}

- (CGFloat)originalX {
    return self.frame.origin.x;
}

- (void)setOriginalY:(CGFloat)originalY {
    CGRect frame = self.frame;
    frame.origin.y = originalY;
    self.frame = frame;
}

- (CGFloat)originalY {
    return self.origin.y;
}

- (void)setRightX:(CGFloat)rightX {
    CGRect frame = self.frame;
    frame.origin.x = rightX - [self width];
    self.frame = frame;
}

- (CGFloat)rightX {
    return [self originalX] + [self width];
}

- (void)setBottomY:(CGFloat)bottomY {
    CGRect frame = self.frame;
    frame.origin.y = bottomY - [self height];
    self.frame = frame;
}

- (CGFloat)bottomY {
    return [self originalY] + [self height];
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setCenterX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)centerY {
    return self.center.y;
}

- (void)setOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)size {
    return self.frame.size;
}

@end
