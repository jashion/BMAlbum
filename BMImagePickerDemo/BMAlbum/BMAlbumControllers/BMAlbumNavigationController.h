//
//  BMAlbumNavigationController.h
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/5.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BMAlbumNavigationControllerDelegate;

@interface BMAlbumNavigationController : UINavigationController

@property (nonatomic, weak) id<BMAlbumNavigationControllerDelegate> bmAlbumDelegate;
@property (nonatomic, assign) NSInteger maxImagesCount;
@property (nonatomic, assign) BOOL allowSelectVideo;
@property (nonatomic, assign) BOOL allowSelectOriginalPhoto;

/**
 *  initMethod
 *
 *  @param maxImagesCount 选择图片的最大数量
 *  @param delegate       BMAlbumNavigationControllerDelegate
 *
 *  @return  BMAlbumNavigationController
 */
- (instancetype)initWithMaxImagesCount: (NSInteger)maxImagesCount delegate: (id<BMAlbumNavigationControllerDelegate>)delegate;

@end

@protocol BMAlbumNavigationControllerDelegate <NSObject>

- (void)handleDismissWithAlbumNav: (BMAlbumNavigationController *)albumNav images: (NSArray *)images;

@end
