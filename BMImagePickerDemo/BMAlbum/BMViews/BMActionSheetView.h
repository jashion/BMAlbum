//
//  BMActionSheetView.h
//  BMImagePickerDemo
//
//  Created by jashion on 16/8/18.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  BMActionSheetViewDelegate;

@interface BMActionSheetView : UIView

@property (nonatomic, weak) id<BMActionSheetViewDelegate> delegate;
@property (nonatomic, assign) NSInteger maxImagesCount;
@property (nonatomic, assign) BOOL allowSelectVideo;
@property (nonatomic, assign) BOOL allowSelectOriginalPhoto;

- (instancetype)initWithController: (UIViewController *)controller;
- (void)showActionSheet;

@end

@protocol BMActionSheetViewDelegate <NSObject>

- (void)hanleDismissWithBMActionSheetView: (BMActionSheetView *)actionSheetView images: (NSArray *)images;

@end
