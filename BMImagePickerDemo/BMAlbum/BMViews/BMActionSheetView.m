//
//  BMActionSheetView.m
//  BMImagePickerDemo
//
//  Created by jashion on 16/8/18.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import "BMActionSheetView.h"
#import "BMActionSheet.h"
#import "PhotoFromLocal.h"
#import "BMAlbumNavigationController.h"

@interface BMActionSheetView ()<BMActionSheetDelegate, BMAlbumNavigationControllerDelegate>

@property (nonatomic, strong) UIViewController *controller;
@property (nonatomic, strong) PhotoFromLocal *photoFromLocal;

@end

@implementation BMActionSheetView

- (instancetype)initWithController: (UIViewController *)controller {
    self = [super init];
    if (self) {
        _controller = controller;
    }
    return self;
}

- (void)showActionSheet {
    BMActionSheet *actionSheet = [[BMActionSheet alloc] initWithTitle: @"BMu工作室" buttonTitles: @[@"小视频", @"拍照", @"相册"] cancelButtonTitle: @"取消"];
    actionSheet.delegate = self;
    [actionSheet showActionSheet];
}

#pragma mark - BMActionSheetDelegate

- (void)bmActionSheet:(BMActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [actionSheet dismissActionSheet];
    switch (buttonIndex) {
        case 0:
        {
            break;
        }
        case 1:
        {
            __weak typeof(self) weak_self = self;
            _photoFromLocal = [[PhotoFromLocal alloc] initWithController: _controller];
            [_photoFromLocal getPhotoFromType: FromCamera photoBlock:^(UIImage *image) {
                __strong typeof(weak_self) strong_self = weak_self;
                if (self.delegate && [self.delegate respondsToSelector: @selector(hanleDismissWithBMActionSheetView:images:)]) {
                    [self.delegate hanleDismissWithBMActionSheetView: strong_self images: @[image]];
                } else {
                    [self removeFromSuperview];
                }
            }];
            break;
        }
        
        case 2:
        {
            BMAlbumNavigationController *bmAlbumNav = [[BMAlbumNavigationController alloc] initWithMaxImagesCount: self.maxImagesCount delegate: self];
            bmAlbumNav.allowSelectVideo = self.allowSelectVideo;
            bmAlbumNav.allowSelectOriginalPhoto = self.allowSelectOriginalPhoto;
            [self.controller presentViewController: bmAlbumNav animated: YES completion: nil];
            break;
        }
        
        case 3:
        default:
            break;
    }
}

#pragma mark - BMAlbumNavigationControllerDelegate

- (void)handleDismissWithAlbumNav:(BMAlbumNavigationController *)albumNav images:(NSArray *)images {
    [albumNav dismissViewControllerAnimated: YES completion: nil];
    if (self.delegate && [self.delegate respondsToSelector: @selector(hanleDismissWithBMActionSheetView:images:)]) {
        [self.delegate hanleDismissWithBMActionSheetView: self images: images];
    } else {
        [self removeFromSuperview];
    }
}

@end
