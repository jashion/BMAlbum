//
//  BMAlbumListController.h
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/6.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BMAlbumListDelegate;

@interface BMAlbumListController : UIViewController

@property (nonatomic, weak) id<BMAlbumListDelegate> delegate;

@end

@protocol BMAlbumListDelegate <NSObject>

- (void)handleDismissWithAlbumList: (BMAlbumListController *)albumList images: (NSArray *)images;

@end

