//
//  CustomeCollectionViewCell.m
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/4.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import "CustomeCollectionViewCell.h"

@implementation CustomeCollectionViewCell
{
    UIImageView *photoView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame: frame]) {
        photoView = [[UIImageView alloc] init];
        photoView.frame = self.bounds;
        photoView.clipsToBounds = YES;
        photoView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview: photoView];
    }
    return self;
}

- (void)setupImage: (UIImage *)image {
    if (!image) {
        return;
    }
    
    photoView.image = image;
}

@end
