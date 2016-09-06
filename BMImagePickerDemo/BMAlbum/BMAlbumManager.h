//
//  BMAlbumManager.h
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/5.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BMAlbumDataModel.h"
#import "BMAlbumPhotoModel.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "BMAlbumGlobalDefine.h"

typedef void(^didFinishPhotoHandle)(UIImage *resultImage);
typedef void(^didFinishPhotoInfoHandle)(UIImage *resultImage, NSDictionary *info);
typedef void(^didFinishPhotoInfoWithDegradHandle)(UIImage *resultImage, NSDictionary *info, BOOL isDegraded);
typedef void(^didFinishLivePhotoInfoWithDegradHandle)(PHLivePhoto *livePhoto, NSDictionary *info);

@interface BMAlbumManager : NSObject

@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;

+ (BMAlbumManager *)sharedInstance;
- (BOOL)authorizationStatusAuthoried;

- (void)getAllAlbumsWithVideo: (BOOL)allowPickingVideo completion: (void(^)(NSArray<BMAlbumDataModel *> *albums,  NSMutableArray *fetchResults, NSMutableArray *phAssetCollections))completion;
- (void)getPosterImageWithBMAlbumDataModel: (BMAlbumDataModel *)model completion: (didFinishPhotoHandle)completion;
- (void)getThumbnailWithAsset: (id)asset completion: (didFinishPhotoHandle)completion;
- (void)getFullScreenImageWithAsset: (id)asset completion: (didFinishPhotoHandle)completion;
- (void)getOriginalImageWithAsset: (id)asset completion: (didFinishPhotoInfoHandle)completion;
- (void)getPhotoWithAsset: (id)asset completion: (didFinishPhotoInfoWithDegradHandle)completion;
- (void)getLivePhotoWithAsset: (id)asset completion: (didFinishLivePhotoInfoWithDegradHandle)completion;
- (void)getVideoWithAsset: (id)asset completion: (void(^)(AVPlayerItem *playerItem, NSDictionary *info))completion;

- (void)getAssetsWithFetchResult: (id)resultGroup allowPickingVideo: (BOOL)allowPickingVideo completion: (void(^)(NSArray<BMAlbumPhotoModel *> *assets))completion;

- (void)createAlbumWithTitle:(NSString *)title completion: (void(^)(id assetGroup))completion;
- (void)saveImageWithAlbum: (id)album image: (UIImage *)image completion: (void(^)(BOOL success))completion;

- (void)addAsset: (UIImage *)image completion: (void(^)(NSURL *assetURL))completion;
- (void)getAssetWithUrl: (NSURL *)url completion: (void(^)(ALAsset *asset))completion;

+ (void)collectionMediaTypeWithAsset: (id)asset completion: (void(^)(BMAlbumModelMediaType type))completion;

@end
