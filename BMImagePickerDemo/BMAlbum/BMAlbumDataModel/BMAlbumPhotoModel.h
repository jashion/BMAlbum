//
//  BMAlbumPhotoModel.h
//  BMImagePickerDemo
//
//  Created by jashion on 16/8/30.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BMAlbumGlobalDefine.h"

@interface BMAlbumPhotoModel : NSObject

@property (nonatomic, strong) id asset;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BMAlbumModelMediaType type;
@property (nonatomic, copy) NSString *timeLength;

+ (instancetype)modelWithAsset: (id)asset type: (BMAlbumModelMediaType)type;
+ (instancetype)modelWithAsset: (id)asset type: (BMAlbumModelMediaType)type timeLength: (NSString *)timeLength;

@end
