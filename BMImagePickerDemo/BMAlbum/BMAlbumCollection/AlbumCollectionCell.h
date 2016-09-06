//
//  AlbumCollectionCell.h
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/6.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMAlbumPhotoModel.h"

@interface AlbumCollectionCell : UICollectionViewCell

@property (nonatomic, strong) NSString *representedAssetIdentifier;
@property (nonatomic, copy) void(^selectPhoto)(UIButton *checkButton);
@property (nonatomic, strong) UIImageView *imageView;

- (void)setPhotoModel: (BMAlbumPhotoModel *)model;

@end
