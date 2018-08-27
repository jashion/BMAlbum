# BMAlbum
这是一个上传本地照片，视频和LivePhoto的组件。
### 前言
今年五月份进的新公司，接手的第一个新项目，里面我主要负责发帖，具体是图文，不包括视频。由于时间紧急，开发时间只有3天，实际上包括开发，测试和修复BUG，用了差不多3周的时间，第一周开发完成基本功能，后面两周测试和修复BUG,由于当时没有做过相册相关的功能，也因为时间紧急，所以，使用了一个[第三方的库](https://github.com/zhuochenming/ImagePickerController)，大家可以去看一下，写的比较全面。后来，项目完成之后，终于有时间，静下心慢慢研究iOS的图片框架了，个人对于不懂的东西，好奇心和求知欲还是比较强的。[Demo](https://github.com/jashion/BMAlbum)

### 一.iOS8以前的AssetsLibrary框架
我感觉，AssetsLibrary框架还是比较好用的，不过iOS9以后就被弃用了，使用iOS8出来的Photos框架，相比于AssetsLibrary更为强大，效率更高。具体的[文档](https://developer.apple.com/library/ios/documentation/AssetsLibrary/Reference/ALAssetsLibrary_Class/)可以去苹果官方浏览，这里只详述自己研究的一些东西。<p>
AssetsLibrary框架只有6个文件，非常简洁：

```
//该文件主要作用是引进头文件
AssetsLibrary.h 

//所有照片和视频的集合
ALAssetsLibrary.h  

//代表一张图片或者一个视频的元数据
ALAsset.h  

//代表ALAsset对象包含的一些数据，比如：url，filename等等。
ALAssetRepresentation.h

//过滤器：1.图片 2.视频 3.全部
ALAssetsFilter.h

//assets的集合，比如：相册
ALAssetsGroup.h
```

下面讲解主要用到的一些操作：<br \>
1.iPhone手机在获取本地相册和视频的时候，需要得到本人的许可认证，所以，第一步是获取判断，认证状态。<br \>

```
//ALAuthorizationStatusNotDetermined  //用户还没做出选择
//ALAuthorizationStatusRestricted  	  //用户受到某些限制，不能自己决定，比如：家长控制
//ALAuthorizationStatusDenied	      //用户明确否决
//ALAuthorizationStatusAuthorized     //用户认证通过

[ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized
//判断状态是否是准许，如果允许则可以获取本地相册，否则，不能获取，则可以提示需要用户做什么操作才能打开本地相册
```

2.获取本地相册，以及相册相关的一些信息，比如：缩略图，相册名称等等。

```
//1.获取相册
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;  //ALAssetsLibrary实例必须被controller强引用或者是实例变量，不然会报错

[self.assetsLibrary enumerateGroupsWithTypes: ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];  //过滤器，只获取图片
[group setAssetsFilter: onlyPhotosFilter];

if ([group numberOfAssets] > 0) {    //当group＝nil是就是遍历完全部相册
[albumsArray addObject: [self modelWithAssetResult: group name: [group valueForProperty: ALAssetsGroupPropertyName]]];
} else {
completion(albumsArray);
}
//*stop=NO(停止遍历照片数组)
} failureBlock:^(NSError *error) {
NSString *errorMessage = nil;
switch ([error code]) {    //错误代码的处理
case ALAssetsLibraryAccessUserDeniedError:
case ALAssetsLibraryAccessGloballyDeniedError:
errorMessage = @"The user has declined access to it.";
break;

default:
errorMessage = @"Reason unknow.";
break;
}
NSLog(@"%@", errorMessage);
}];

//说一下Group Type
ALAssetsGroupSavedPhotos  //Camera Roll
ALAssetsGroupPhotoStream  //My Photo Stream
ALAssetsGroupAll				//All  available group
//剩下的类型可以去看文档

//2.获取相册的缩略图
ALAssetsGroup *group = (ALAssetsGroup *)model.assetResult;
CGImageRef posterImageRef = [group posterImage];
UIImage *posterImage = [UIImage imageWithCGImage: posterImageRef];

//3.遍历相册获取每一个相片或者视频的asset
//有3个遍历相册的方法，其中Result代表一张照片或者一个视频，stop是停止遍历的标识，默认为NO，如果stop=YES，则停止下一次的遍历

//(1).顺序遍历，同步遍历
[self.albumGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
if (result) {
[self.albumPhotos addObject: result];
}
}];

//(2).并发遍历或者逆序遍历
//NSEnumerationConcurrent: 并发不保证顺序
//NSEnumerationReverse: 逆序遍历
[self.albumGroup enumerateAssetsWithOptions: NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
if (result) {
[self.albumPhotos addObject: result];
}
}];

//(3).可选择遍历的位置和并发或者逆序遍历
//获取0～9下标的照片
NSRange range = {0, 10};
[self.albumGroup enumerateAssetsAtIndexes: [NSIndexSet indexSetWithIndexesInRange: range] options: NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
if (result) {
[self.albumPhotos addObject: result];
}
}];

//获取下标为10的照片
NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex: 9];
[self.albumGroup enumerateAssetsAtIndexes: indexSet options: NSEnumerationConcurrent usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
if (result) {
[self.albumPhotos addObject: result];
}
}];

//4.获取照片的缩略图
ALAsset *asset = self.albumPhotos[indexPath.row];
CGImageRef thumdnailImageRef = [asset thumbnail];  //[asset aspectRatioThumbnail]

//5.获取照片
ALAsset *photoAsset = (ALAsset *)asset;
ALAssetRepresentation *assetRepresentation = [photoAsset defaultRepresentation];    //ALAssetRepresentation获取asset的一些相关的参数，一个asset可以拥有多个ALAssetRepresentation
CGImageRef photoRef = [assetRepresentation fullScreenImage];    //fullScreenImage全屏照片，包含编辑过的信息，是一张缩略图；
CGImageRef photoRef = [assetRepresentation fullResolutionImage]    //fullResolutionImage图片原图，不包含编辑过的信息，是一张高清图，加载比较慢
//- (CGImageRef)CGImageWithOptions:(NSDictionary *)options  根据参数获取图片，当options=nil则和fullResolutiongImage等同

//如果是fullScreenImage，可以使用下面两种方法获取图片，但建议使用第二种，因为有些照片有旋转方向问题，旋转方向选择默认UIImageOrientationUp类型就好
//如果是fullResolutionImage，旋转方向使用assetRepresentation.orientation，则显示出来的图片就不会有旋转方向问题
UIImage *resultImage = [UIImage imageWithCGImage: photoRef];
UIImage *resultImage = [UIImage imageWithCGImage: photoRef
scale: [assetRepresentation scale]
orientation: UIImageOrientationUp];

//6.其它方法
//创建相册
- (void)addAssetsGroupAlbumWithName:(NSString *)name resultBlock:(ALAssetsLibraryGroupResultBlock)resultBlock failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock；

//保存照片或视频到相册(保存在Camera Roll和My Photo Stream)
- (void)writeImageToSavedPhotosAlbum:(CGImageRef)imageRef orientation:(ALAssetOrientation)orientation completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock 
- (void)writeImageToSavedPhotosAlbum:(CGImageRef)imageRef metadata:(NSDictionary *)metadata completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock 
- (void)writeImageDataToSavedPhotosAlbum:(NSData *)imageData metadata:(NSDictionary *)metadata completionBlock:(ALAssetsLibraryWriteImageCompletionBlock)completionBlock 

- (void)writeVideoAtPathToSavedPhotosAlbum:(NSURL *)videoPathURL completionBlock:(ALAssetsLibraryWriteVideoCompletionBlock)completionBlock

//相册内容改变的通知
ALAssetsLibraryChangedNotification

//添加到相应的相册，可以在获取该相册的ALAssetsGroup，调用addAsset方法
- (BOOL)addAsset:(ALAsset *)asset    //不过没有找到将一张图片变成asset的方法，只能先保存在Camera Roll/My Photo Stream然后获得该图片的asset再保存在特定的相册，不过由于是同一个asset，所以，一旦删除一个，所有相册中的这张图片都会被删除

```

3.据说是一些坑点

- ALAssetsLibrary实例必须被controller强引用或者是实例变量，不然会报错。(已亲自试验，会报错。)<br \>

- AssetsLibrary 遵循写入优先原则。([原帖出处](http://kayosite.com/ios-development-and-detail-of-photo-framework.html)，没有试验过。)<br \>
AssetsLibrary 读取资源的过程中，有任何其它的进程（不一定是同一个 App）在保存资源时，就会收到 ALAssetsLibraryChangedNotification，让用户自行中断读取操作。最常见的就是读取 fullResolutionImage 时，这时候再在别的进程写入，由于读取 fullResolutionImage 耗时较长，很容易就会 exception。

- 开启 Photo Stream 容易导致 exception。([原帖出处](http://kayosite.com/ios-development-and-detail-of-photo-framework.html)，没有试验过。)<br \>
如果用户开启了共享照片流（Photo Stream），共享照片流会以 mstreamd 的方式“偷偷”执行，当有人把相片写入 Camera Roll 时，它就会自动保存到 Photo Stream Album 中，如果用户刚好在读取，那就跟上面说的一样产生 exception 了。由于共享照片流是用户决定是否要开启的，所以开发者无法改变，但是可以通过下面的接口在需要保护的时刻关闭监听共享照片流产生的频繁通知信息。<br \>
保护措施：

```
[ALAssetsLibrary disableSharedPhotoStreamsSupport];  //禁止图片共享
```


### 二.iOS8以后，使用更为强大的Photos框架
Photos框架包括两个库Photos和PhotoUI，而PhotoUI主要是用来显示iOS9新增的Photo类型，LivePhoto说白了就是苹果新增的GIF,不过只能在iphone6以后发布的机型拍摄LivePhoto，下面也会介绍到这个新的图片类型。Let's begin!
Photos库比ALAssetLibrary库复杂很多，相对的，功能强大很多，下面简述一下各个文件的作用：
##### Tips: 升级iOS10之后，需要把在plist文件中添加所用的隐私权限，比如本应用：获取相机权限，获取本地相册权限，获取本地视频权限等等，不然后Crash掉，没得商量，苹果依然霸道如初。
#### 1.Interacting with the Photos Library(与Photos库的交互)
```
PHPhotoLibrary
\\获取系统相册授权以及监听系统相册的变化，包括创建，删除和编辑
\\由于PHAsset,PHAssetCollection和PHCollectionList是不可变对象
\\所以，系统在该文件提供了一个修改系统相册资源的Block
```
#### 2.Retrieving and Examining Assets(检索，获取和审查Assets)
```
PHAsset
\\代表系统的一个图片，视频或者Live Photo

PHAssetCollection
\\代表一组Photos asset，比如：系统相册里的时刻一个分类，用户创建的相册或者智能相册

PHCollectionList
\\代表一组包含一个或者多个Photos asset collection，比如：时刻里的年或者包含用户创建的一个或者多个相册

PHCollection
\\一个抽象类，是PHAssetCollection和PHColletionList的父类

PHObject
\\Photos model objects(assets和collections)的抽象类

PHFetchResult
\\包含assets或者collections有序的一系列集合

PHFetchOptions
\\option的集合，关于过滤，排序和管理Photos
```
#### 3.Loading Asset Content
```
PHImageManager
\\提供获取或生成预览的缩略图和原图或者视频的数据

PHCachingImageManager
\\提供获取或生成预览的缩略图和原图或者视频的数据
\\和PHImageManager不同之处在于可以缓存图片，并且如果有缓存则直接从缓存取数据

PHImageRequestQptions
\\获取图片的一些参数设置

PHVideoRequestOptions
\\获取视频的一些参数设置

PHLivePhotoRequestOptions
\\获取Live Photo的一些参数设置

PHLivePhoto
\\展示Live Photo(包含动作和声音的图片集合，和GIF差不多)
```
#### 4.Requesting Changes
```
PHAssetChangeRequest
\\在photo library change block里创建，删除，修改metadata或者编辑Photos asset的内容的request

PHAssetCollectionChangeRequest
\\在photo library change block里创建，删除或者修改Photos asset collection的request

PHCollectionListChangeRequest
\\在photo library change block里创建，删除或者修改Photos collection list的request

PHObjectPlaceholder
\\Photos asset和Photo collection的唯一资源占位符
```
#### 5.Editing Asset Content
```
PHContentEditingInput
\\一个提供编辑资源(image,video,Live Photo)信息的容器

PHContentEditingOutput
\\一个包含编辑资源(image,video,Live Photo)结果的容器

PHAdjustmentData
\\包含编辑资源的描述，可以允许恢复编辑之前的状态

PHContentEditingInputRequestOptions
\\编辑资源的options

PHLivePhotoEditingContext
\\Live Photo编辑的环境

PHLivePhotoFrame
\\一个Live Photo的frame

```
#### 6.Observing Changes(监听系统相册资源的改变)
```
PHPhotoLibraryChangeObserver
\\监听协议

PHChange
\\Photos library改变的描述

PHObjectChangeDetails
\\asset或者collection对象改变的描述

PHFetchResultChangeDetails
\\一系列asset或者collection对象改变的描述

```
#### 7.Working with Asset Resources
```
PHAssetResource
\\图片，视频和Live Photo在Photos library里的基础数据

PHAssetCreationRequest
\\使用基础数据创建新的Photos asset

PHAssetResourceCreationOptions
\\使用基础数据创建新的Photos asset的一些设置

PHAssetResourceManager
\\提供关于Photos asset基础数据的储存方法

PHAssetResourceRequestOptions
\\获取基础数据的一些设置

```
#### 8.Media Types and Subtypes
```
PHAssetMediaType
\\媒体类型，比如：图片，视频，LivePhoto

PHAssetMediaSubtype
\\asset media，比如：全景照片，截屏，延时拍摄，慢动作等等

```
#### 9.Structures
```
PHAssetBurstSelectionType
PHAssetSourceType
PHLivePhotoEditingOption
```
#### 10.Other Reference
```
Photos Constants
Photos Enumerations
Photos Data Types
```
#### 11.下面介绍和功能相关的实现代码
```
1.首先获取用户权限
[PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized
//判断用户是否允许获取本地相册
//和ALAsslibrary返回的状态一致，具体可以到PHPhotoLibrary头文件去查看

2.获取本地相册集合
//相册，在这里抽象成了文件夹的概念，使用PHAssetCollection来表示
//时刻使用PHCollectionList来表示
//PHCollection既可以表示一个相册或者一个时刻，可以表示多个相册的集合以及集合里面还可以嵌套文件夹
//获取相册有关的函数都在PHCollection头文件里面，感兴趣的可以去看一下
//这里只用到的相册部分

//获取职能相册，即系统创建的相册
PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType: PHAssetCollectionTypeSmartAlbum subtype: PHAssetCollectionSubtypeAlbumRegular options: nil];

//获取用户相册，即用户创建的相册，包括用户自己创建和App创建的相册
PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType: PHAssetCollectionTypeAlbum subtype: PHAssetCollectionSubtypeAlbumRegular | PHAssetCollectionSubtypeAlbumMyPhotoStream options: nil];

//PHAssetCollectionType有三种类型：
//PHAssetCollectionTypeAlbum相册（用户），PHAssetCollectionTypeSmartAlbum智能相册（系统），PHAssetCollectionTypeMoment时刻
//PHAssetCollectionSubType有很多类型，比如：视频，全景照片，自拍等等，具体什么类型代表哪个相册，有兴趣的自行去查看

3.获取相册里面的资源，包括照片和视频
//一张图片和一个视频都是使用PHAsset来表示

//option选择过滤
PHFetchOptions *option = [[PHFetchOptions alloc] init];
if (!allowPickingVideo) {
option.predicate = [NSPredicate predicateWithFormat: @"mediaType == %ld", PHAssetMediaTypeImage];    //过滤掉视频
}
option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey: @"creationDate" ascending: YES]];    //按照创建时间升序
PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection: albumCollection options: option];
PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions: option];    //获取所有资源

4.获取照片，LivePhoto或者视频
//Notice: LivePhoto也是属于图片类型

//获取图片需要指定大小
//如果指定的大小的高宽比和图片的高宽比不一致，则contentMode决定返回图片的尺寸
//contentMode有三种类型：
//PHImageContentModeAspectFit（等比例适应），PHImageContentModeAspectFill（等比例缩放适应），
PHImageContentModeDefault（默认，相当于第一种）
//可以设置为PHImageManagerMaximumSize大小，获取原图或者最大的图片尺寸，但是会忽略option里面的resizeMode的设置
//option相关选择过滤设置，比较重要的如下
//PHImageRequestOptionsDeliveryMode决定返回的图片质量
//networkAccessAllowed默认为NO，设为YES则可以通过网络从iClould下载图片
//synchronous是否为同步操作，默认为NO，如果设置为YES则，相关模式下只会返回一张图片
//回调里面的字典，包含这张图片相关的metaData，比如：滤镜，帖子什么的
[[PHImageManager defaultManager] requestImageForAsset: phAsset
targetSize: CGSizeMake(resultImageWidth, resultImageHeight)
contentMode: PHImageContentModeAspectFill
options: nil
resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
BOOL downloadFinished = (![[info objectForKey: PHImageCancelledKey] boolValue] && ![info objectForKey: PHImageErrorKey]);
if (downloadFinished && result) {
if (completion) {
completion(result, info, [[info objectForKey: PHImageResultIsDegradedKey] boolValue]);
}
}

// Download image from iCloud
if ([[info objectForKey: PHImageResultIsInCloudKey] boolValue] && !result) {
PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
option.networkAccessAllowed = YES;
[[PHImageManager defaultManager] requestImageDataForAsset: asset
options: option
resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
UIImage *resultImage = [UIImage imageWithData: imageData scale: [UIScreen mainScreen].scale];
if (resultImage && completion) {
completion(resultImage, info, [[info objectForKey: PHImageResultIsDegradedKey] boolValue]);
}
}];
}
}];

//LivePhoto也是照片
//LivePhoto需要PHLivePhotoView来呈现，具体怎么展现看Demo的代码
//其他和获取照片也差不多
PHLivePhotoRequestOptions *livePhotoOptions = [[PHLivePhotoRequestOptions alloc] init];
livePhotoOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
livePhotoOptions.networkAccessAllowed = YES;
livePhotoOptions.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info){
dispatch_async(dispatch_get_main_queue(), ^{
NSLog(@"livePhotoProgress: %lf", progress);
});
};

[[PHImageManager defaultManager] requestLivePhotoForAsset: phAsset targetSize: [UIScreen mainScreen].bounds.size contentMode: PHImageContentModeAspectFit options: livePhotoOptions resultHandler:^(PHLivePhoto * _Nullable livePhoto, NSDictionary * _Nullable info) {
if (!livePhoto) {
return ;
}

if (completion) {
completion(livePhoto, info);
}
}];

//获取视频
PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
options.networkAccessAllowed = YES;
options.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info) {
dispatch_async(dispatch_get_main_queue(), ^{
NSLog(@"videoProgress: %lf", progress);
});
};
[[PHImageManager defaultManager] requestPlayerItemForVideo: asset options: options resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
if (playerItem && completion) {
completion(playerItem, info);
}
}];

5.创建相册，储存图片或者视频，编辑图片，具体看Demo代码，这里就不在废话多说了
```
### 三.总结
这边文章很早就开始写了，断断续续写了几个月，一来工作有时忙没有时间，二来主要是自己懒。但是，总的来说，还是写完了，这也是极好的。
### 四.效果图

![屏幕快照 2016-09-25 18.20.32.PNG](http://upload-images.jianshu.io/upload_images/968977-65ee15a68756dd6d.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![屏幕快照 2016-09-25 18.20.55.PNG](http://upload-images.jianshu.io/upload_images/968977-911beee1582b0942.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![屏幕快照 2016-09-25 18.21.06.PNG](http://upload-images.jianshu.io/upload_images/968977-ce1f4d3c0f96683a.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![屏幕快照 2016-09-25 18.21.36.PNG](http://upload-images.jianshu.io/upload_images/968977-02023bfa3f58aa3c.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
