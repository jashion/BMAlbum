//
//  BMAlbumNavigationController.m
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/5.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import "BMAlbumNavigationController.h"
#import "BMAlbumListController.h"

@interface BMAlbumNavigationController ()<BMAlbumListDelegate>

@property (nonatomic ,strong) BMAlbumListController *albumListController;

@end

@implementation BMAlbumNavigationController

- (instancetype)initWithMaxImagesCount: (NSInteger)maxImagesCount delegate: (id<BMAlbumNavigationControllerDelegate>)delegate {
    _albumListController = [[BMAlbumListController alloc] init];
    if (self = [super initWithRootViewController: _albumListController]) {
        _maxImagesCount = maxImagesCount;
        _albumListController.delegate = self;
        self.bmAlbumDelegate = delegate;
    }
    return self;
}

#pragma mark - BMAlbumListDelegate

- (void)handleDismissWithAlbumList:(BMAlbumListController *)albumList images:(NSArray *)images {
    if (self.bmAlbumDelegate && [self.bmAlbumDelegate respondsToSelector: @selector(handleDismissWithAlbumNav:images:)]) {
        [self.bmAlbumDelegate handleDismissWithAlbumNav: self images: images];
    }
    [self dismissViewControllerAnimated: YES completion: nil];
}

@end
