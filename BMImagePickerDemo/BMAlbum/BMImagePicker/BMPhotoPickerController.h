//
//  BMPhotoPickerController.h
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/7.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PhotosUI/PhotosUI.h>

@protocol BMPhotoPickerDelegate;

@interface BMPhotoPickerController : UIViewController <PHLivePhotoViewDelegate>

@property (nonatomic, strong) NSArray *photoAssets;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;
@property (nonatomic, assign) NSUInteger startingIndex;
@property (nonatomic, assign) BOOL hideNavigationBar;
@property (nonatomic, copy) void(^reloadPhotos)(NSUInteger photoNum);
@property (nonatomic, weak) id<BMPhotoPickerDelegate> bmPhotoPickerDelegate;
@property (nonatomic, assign) BOOL isHideTopCheck;

@end

@protocol BMPhotoPickerDelegate <NSObject>

- (void)handleDismissWithImages: (NSArray *)images;

@end
