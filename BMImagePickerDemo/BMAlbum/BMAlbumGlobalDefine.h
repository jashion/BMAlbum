//
//  BMAlbumGlobalDefine.h
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/15.
//  Copyright © 2016年 BMu. All rights reserved.
//

#ifndef BMAlbumGlobalDefine_h
#define BMAlbumGlobalDefine_h

#define AlbumListCellHeight 70.0

typedef NS_ENUM(NSUInteger, BMAlbumModelMediaType) {
    BMAlbumModelMediaTypePhoto      = 0,
    BMAlbumModelMediaTypeLivePhoto  = 1,
    BMAlbumModelMediaTypeVideo      = 2,
    BMAlbumModelMediaTypeAudio      = 3
};

#define iOS7Later       ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later       ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later       ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later     ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)
#define iOS9_2Later     ([UIDevice currentDevice].systemVersion.floatValue >= 9.2f)
#define iOS9_3Later     ([UIDevice currentDevice].systemVersion.floatValue >= 9.3f)
#define iOS10Later      ([UIDevice currentDevice].systemVersion.floatValue >= 10.0f)

#endif /* BMAlbumGlobalDefine_h */
