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
typedef void(^didFinishGIFInfoWithDegradHandle)(NSArray<UIImage *> *images, NSDictionary *info);

@interface BMAlbumManager : NSObject

@property (nonatomic, strong) PHCachingImageManager *cachingImageManager;

+ (BMAlbumManager *)sharedInstance;
- (BOOL)authorizationStatusAuthoried;

- (BMImageType)imageTypeWithAsset: (id)asset;

//获取本地相册
- (void)allAlbumsWithVideo: (BOOL)allowPickingVideo completion: (void(^)(NSArray<BMAlbumDataModel *> *albums,  NSMutableArray *fetchResults, NSMutableArray *phAssetCollections))completion;
//获取一个相册里面的资源
- (void)assetsFromFetchResult: (id)resultGroup allowPickingVideo: (BOOL)allowPickingVideo completion: (void(^)(NSArray<BMAlbumPhotoModel *> *assets))completion;

//获取图片
- (void)posterImageWithAlbum: (id)album width: (CGFloat)width completion: (didFinishPhotoHandle)completion;
- (void)thumbnailWithAsset: (id)asset width: (CGFloat)width completion: (didFinishPhotoHandle)completion;
- (void)fullScreenImageWithAsset: (id)asset completion: (didFinishPhotoHandle)completion;
- (void)originalImageWithAsset: (id)asset completion: (didFinishPhotoInfoHandle)completion;
- (void)photoWithAsset: (id)asset width: (CGFloat)width completion: (didFinishPhotoInfoWithDegradHandle)completion;
- (void)fullScreenImageWithAsset: (id)asset imageCompletion: (didFinishPhotoInfoHandle)imageCompletion gifCompletion: (didFinishGIFInfoWithDegradHandle)gifCompletion;

//获取LivePhoto(也属于图片类型)
- (void)livePhotoWithAsset: (id)asset completion: (didFinishLivePhotoInfoWithDegradHandle)completion;
//获取视频
- (void)getVideoWithAsset: (id)asset completion: (void(^)(AVPlayerItem *playerItem, NSDictionary *info))completion;
//创建相册
- (void)createAlbumWithTitle:(NSString *)title completion: (void(^)(id assetGroup))completion;
//存储图片
- (void)saveImageToAlbum: (id)album image: (UIImage *)image completion: (void(^)(BOOL success))completion;

+ (void)collectionMediaTypeWithAsset: (id)asset completion: (void(^)(BMAlbumModelMediaType type))completion;

@end
