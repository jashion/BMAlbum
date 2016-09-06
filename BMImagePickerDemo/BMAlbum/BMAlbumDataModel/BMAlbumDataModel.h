//
//  BMAlbumDataModel.h
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/6.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BMAlbumDataModel : NSObject

@property (nonatomic, strong) NSString *albumName;
@property (nonatomic, assign) NSInteger imagesCount;
@property (nonatomic, strong) id assetResult;

@end
