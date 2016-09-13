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

@property (nonatomic, copy) void (^singleTapBlock)();    //整个页面单点击事件回调
@property (nonatomic, copy) void (^doubleTapBlock)();    //整个页面双点击事件回调
@property (nonatomic, copy) void (^videoPlayBlock)();    //视频开始播放时回调
@property (nonatomic, copy) void (^videoPauseBlock)();    //视频开始暂停（不是停止）时回调
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) PHLivePhotoView *livePhotoView;
@property (nonatomic, assign) BOOL played;    //该标识主要是解决，当视频已经开始播放时，下面工具栏按钮播放的显示和隐藏

- (void)setPhotoModel: (BMAlbumPhotoModel *)model;
- (void)playLivePhoto: (BOOL)play;
- (void)handleVideoPlay;
- (void)resetAllStatus;
- (void)livePhotoBadgeAnimationWithMoved: (BOOL)moved;

@end
