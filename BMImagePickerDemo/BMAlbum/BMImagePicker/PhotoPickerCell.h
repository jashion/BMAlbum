//
//  PhotoPickerCell.h
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/7.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMAlbumPhotoModel.h"
#import <PhotosUI/PhotosUI.h>

@interface PhotoPickerCell : UICollectionViewCell

@property (nonatomic, copy) void (^singleTapBlock)();
@property (nonatomic, copy) void (^doubleTapBlock)();
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) PHLivePhotoView *livePhotoView;

- (void)setPhotoModel: (BMAlbumPhotoModel *)model;
- (void)playLivePhoto: (BOOL)play;
- (void)resetAllStatus;

@end
