//
//  BMAlbumPhotoModel.m
//  BMImagePickerDemo
//
//  Created by jashion on 16/8/30.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import "BMAlbumPhotoModel.h"

@implementation BMAlbumPhotoModel

+ (instancetype)modelWithAsset: (id)asset type: (BMAlbumModelMediaType)type {
    BMAlbumPhotoModel *model = [[BMAlbumPhotoModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    return model;
}

+ (instancetype)modelWithAsset: (id)asset type: (BMAlbumModelMediaType)type timeLength: (NSString *)timeLength {
	BMAlbumPhotoModel *model = [BMAlbumPhotoModel modelWithAsset: asset type: type];
    model.timeLength = timeLength;
    return model;
}

@end
