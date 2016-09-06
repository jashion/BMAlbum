//
//  BMAlbumCollectionController.h
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/6.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMAlbumDataModel.h"

@protocol BMAlbumCollectionDelegate;

@interface BMAlbumCollectionController : UIViewController

@property (nonatomic, strong) id phAssetCollection;
@property (nonatomic, strong) BMAlbumDataModel *albumModel;
@property (nonatomic, weak) id<BMAlbumCollectionDelegate> albumCollectionDelegate;

@end

@protocol BMAlbumCollectionDelegate <NSObject>

- (void)handleDismissWithImages: (NSArray *)images;

@end
