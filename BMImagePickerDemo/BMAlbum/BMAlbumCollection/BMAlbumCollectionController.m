//
//  BMAlbumCollectionController.m
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/6.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import "BMAlbumCollectionController.h"
#import "AlbumCollectionCell.h"
#import "BMAlbumManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BMPhotoPickerController.h"
#import "UICollectionView+Convenience.h"
#import "BMAlbumGlobalDefine.h"
#import "BMAlbumPhotoModel.h"
#import "BMIndicator.h"
#import "NSIndexSet+Convenience.h"
#import "BMAlbumNavigationController.h"
#import "Utils.h"

#define itemWith        ((CGRectGetWidth(self.view.frame) - 25) / 4)
#define itemHeight      ((CGRectGetWidth(self.view.frame) - 25) / 4)
#define AssetGridThumbnailSize CGSizeMake(itemWith, itemHeight)

@interface BMAlbumCollectionController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver, BMPhotoPickerDelegate>

@property (nonatomic, strong) UICollectionView *albumPhotosCollection;
@property (nonatomic, strong) NSMutableArray *albumPhotos;
@property (nonatomic, strong) NSMutableArray *selectedPhotos;
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, assign) CGRect previousPreheatRect;
@property (nonatomic, strong) UIButton *preView;
@property (nonatomic, strong) UIButton *confirm;
@property (nonatomic, strong) UILabel *photoNum;
@property (nonatomic, strong) UIImageView *photoNumBackground;
@property (nonatomic, assign) BOOL isHideToolBar;

@end

@implementation BMAlbumCollectionController

#pragma mark - LifeCycle
{
    CGSize imageSize;
    NSUInteger selectedPhotoNum;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self resetCachedAssets];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.selectedPhotos = @[].mutableCopy;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = self.albumModel.albumName;
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize: 17], NSForegroundColorAttributeName : [UIColor blackColor]};
    if (![self.phAssetCollection isKindOfClass: [PHAssetCollection class]] || [(PHAssetCollection *)self.phAssetCollection canPerformEditOperation: PHCollectionEditOperationAddContent]) {
        [self configureNavigationButton];
    }
    [self configureAlbumPhotosCollection];
    [self configureToolBar];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver: self];
    
    __weak typeof(self) weakSelf = self;
    [BMAlbumManager collectionMediaTypeWithAsset: self.albumModel.assetResult completion:^(BMAlbumModelMediaType type) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (type != BMAlbumModelMediaTypePhoto) {
            strongSelf.isHideToolBar = YES;
            strongSelf.navigationController.toolbarHidden = YES;
        } else {
            strongSelf.isHideToolBar = NO;
            strongSelf.navigationController.toolbarHidden = NO;
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    
    [self updateCachedAssets];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver: self];
    
    self.navigationController.toolbarHidden = YES;
}

#pragma mark - Configure

- (void)configureNavigationButton {
    UIButton *cancelButton = [UIButton buttonWithType: UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0, 0, 40, 44);
    cancelButton.titleLabel.font = [UIFont systemFontOfSize: 16];
    [cancelButton setTitle: @"添加" forState: UIControlStateNormal];
    [cancelButton setTitleEdgeInsets: UIEdgeInsetsMake(0, 0, 0, - 10)];
    [cancelButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
    [cancelButton addTarget: self action: @selector(addAsset:) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: cancelButton];
}

- (void)configureAlbumPhotosCollection {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 5;
    flowLayout.minimumInteritemSpacing = 5;
    flowLayout.itemSize = AssetGridThumbnailSize;
    flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    
    self.albumPhotosCollection = [[UICollectionView alloc] initWithFrame: self.view.bounds collectionViewLayout: flowLayout];
    self.albumPhotosCollection.backgroundColor = [UIColor whiteColor];
    self.albumPhotosCollection.dataSource = self;
    self.albumPhotosCollection.delegate = self;
    self.albumPhotosCollection.scrollsToTop = YES;
    self.albumPhotosCollection.alwaysBounceVertical = YES;
    [self.albumPhotosCollection registerClass: [AlbumCollectionCell class] forCellWithReuseIdentifier: NSStringFromClass([AlbumCollectionCell class])];
    [self.view addSubview: self.albumPhotosCollection];
}

- (void)configureToolBar {
    self.preView = [UIButton buttonWithType: UIButtonTypeCustom];
    self.preView.frame = CGRectMake(10, 0, 60, 44);
    self.preView.titleLabel.font = [UIFont systemFontOfSize: 16];
    [self.preView setTitleColor: [UIColor lightGrayColor] forState: UIControlStateNormal];
    [self.preView setTitle: @"预览" forState: UIControlStateNormal];
    [self.preView addTarget: self action: @selector(previewAction:) forControlEvents: UIControlEventTouchUpInside];
    self.preView.enabled = NO;
    [self.navigationController.toolbar addSubview: self.preView];

    self.confirm = [UIButton buttonWithType: UIButtonTypeCustom];
    self.confirm.frame = CGRectMake(self.view.frame.size.width - 60, 0, 60, 44);
    self.confirm.titleLabel.font = [UIFont systemFontOfSize: 16];
    [self.confirm setTitle: @"完成" forState: UIControlStateNormal];
    [self.confirm setTitleColor: [UIColor colorWithRed:0.586 green:0.719 blue:0.515 alpha:1.000] forState: UIControlStateNormal];
    [self.confirm addTarget: self action: @selector(confirm:) forControlEvents: UIControlEventTouchUpInside];
    self.confirm.enabled = NO;
    [self.navigationController.toolbar addSubview: self.confirm];
    
    UIImage *image = [UIImage imageNamed:@"CheckNum"];
    imageSize = image.size;
}

#pragma mark - Private Methods

- (void)showPhotoNum: (NSUInteger)num {
    if (num <= 0) {
        if (self.photoNumBackground.superview) {
            [self.photoNumBackground removeFromSuperview];
        }
        
        if (self.photoNum.superview) {
            [self.photoNum removeFromSuperview];
        }
        
        self.confirm.enabled = NO;
        self.preView.enabled = NO;
        [self.confirm setTitleColor: [UIColor lightGrayColor] forState: UIControlStateNormal];
        [self.preView setTitleColor: [UIColor lightGrayColor] forState: UIControlStateNormal];
        return;
    }
    
    if (!self.photoNumBackground.superview) {
        [self.navigationController.toolbar addSubview: self.photoNumBackground];
    }
    
    if (!self.photoNum.superview) {
        [self.navigationController.toolbar addSubview: self.photoNum];
    }
    
    self.photoNum.text = [NSString stringWithFormat: @"%ld", num];
    self.photoNumBackground.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration: 0.5 delay: 0 usingSpringWithDamping: 0.6 initialSpringVelocity: 1.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.photoNumBackground.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {}];
    self.confirm.enabled = YES;
    self.preView.enabled = YES;
    [self.confirm setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
    [self.preView setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
}

#pragma mark - Asset Caching

- (void)resetCachedAssets {
    [self.imageManager stopCachingImagesForAllAssets];
    self.previousPreheatRect = CGRectZero;
}

- (void)updateCachedAssets {
    BOOL isViewVisible = [self isViewLoaded] && [[self view] window] != nil;
    if (!isViewVisible) {
        return;
    }
    
    //The preheat window is twice the height of the visible rect.
    CGRect preheatRect = self.albumPhotosCollection.bounds;
    preheatRect = CGRectInset(preheatRect, 0, - 0.5 * CGRectGetHeight(preheatRect));
    
    //Check if the collection view is showing an area that is significantly different to the last preheat area.
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    if (delta > CGRectGetHeight(self.albumPhotosCollection.bounds) / 3.f) {
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect: self.previousPreheatRect andRect: preheatRect removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self.albumPhotosCollection applyIndexPathsInRect: removedRect];
            [removedIndexPaths addObjectsFromArray: indexPaths];
        } addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self.albumPhotosCollection applyIndexPathsInRect: addedRect];
            [addedIndexPaths addObjectsFromArray: indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths: addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths: removedIndexPaths];
        
        //Update the assets the PHCachingImageManager is caching.
        [self.imageManager startCachingImagesForAssets: assetsToStartCaching
                                            targetSize: AssetGridThumbnailSize
                                           contentMode: PHImageContentModeAspectFill
                                               options: nil];
        [self.imageManager stopCachingImagesForAssets: assetsToStopCaching
                                           targetSize: AssetGridThumbnailSize
                                          contentMode: PHImageContentModeAspectFill
                                              options: nil];
        //Store the preheat rect to compare against in the future.
        self.previousPreheatRect = preheatRect;
    }
}

- (void)computeDifferenceBetweenRect: (CGRect)oldRect andRect: (CGRect)newRect removedHandler: (void(^)(CGRect removedRect))removedHandler addedHandler: (void(^)(CGRect addedRect))addedHandler {
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxX(oldRect);
        CGFloat oldMinY = CGRectGetMidY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
        
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}

- (NSArray *)assetsAtIndexPaths: (NSArray *)indexPaths {
    if (indexPaths.count == 0) {
        return nil;
    }
    
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity: indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        BMAlbumPhotoModel *model = self.albumPhotos[indexPath.item];
        PHAsset *asset = model.asset;
        [assets addObject: asset];
    }
    return assets;
}

#pragma mark - Load Data

- (void)loadData {
    BMAlbumNavigationController *bmNav = (BMAlbumNavigationController *)self.navigationController;
    [[BMAlbumManager sharedInstance] getAssetsWithFetchResult: self.albumModel.assetResult allowPickingVideo: bmNav.allowSelectVideo completion:^(NSArray<BMAlbumPhotoModel *> *results) {
        if (results) {
            [self.albumPhotos addObjectsFromArray: results];
            [self.albumPhotosCollection reloadData];
            [self.albumPhotosCollection scrollToItemAtIndexPath: [NSIndexPath indexPathForRow: (self.albumPhotos.count - 1) inSection: 0] atScrollPosition: UICollectionViewScrollPositionBottom animated: NO];
        }
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.albumPhotos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: NSStringFromClass([AlbumCollectionCell class]) forIndexPath: indexPath];
    __block BMAlbumPhotoModel *model = self.albumPhotos[indexPath.item];
    [cell setPhotoModel: model];
    __weak typeof(self) weakSelf = self;
    cell.selectPhoto = ^(UIButton *checkButton){
        __strong typeof(weakSelf) strongSelf = weakSelf;
        BMAlbumNavigationController *bmNav = (BMAlbumNavigationController *)self.navigationController;
        if(checkButton.selected) {
            if (selectedPhotoNum >= bmNav.maxImagesCount) {
                [checkButton setImage: [UIImage imageNamed:@"CheckOut"] forState: UIControlStateNormal];
                checkButton.selected = NO;
                if (iOS8Later) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: nil message: [NSString stringWithFormat: @"你最多只能选择%ld张照片", bmNav.maxImagesCount] delegate: self cancelButtonTitle: @"我知道了" otherButtonTitles: nil, nil];
                    [alertView show];
#pragma clang diagnostic pop
                } else {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle: nil message: [NSString stringWithFormat: @"你最多只能选择%ld张照片", bmNav.maxImagesCount] preferredStyle: UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: @"我知道了" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
                    [alert addAction: cancelAction];
                    [self presentViewController: alert animated: YES completion: NULL];
                }
            } else {
                model.isSelected = YES;
                selectedPhotoNum = selectedPhotoNum + 1;
                [self.selectedPhotos addObject: model];
            }
        } else {
            model.isSelected = NO;
            selectedPhotoNum = selectedPhotoNum <= 0? 0 : selectedPhotoNum - 1;
            [self.selectedPhotos removeObject: model];
        }
        [strongSelf showPhotoNum: selectedPhotoNum];
    };
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    BMPhotoPickerController *photoPicker = [[BMPhotoPickerController alloc] init];
    photoPicker.photoAssets = self.isHideToolBar ? @[self.albumPhotos[indexPath.row]] : self.albumPhotos;
    photoPicker.startingIndex = indexPath.row;
    photoPicker.selectedPhotos = self.selectedPhotos;
    photoPicker.bmPhotoPickerDelegate = self;
    photoPicker.reloadPhotos = ^(NSUInteger photoNum){
        selectedPhotoNum = photoNum;
        [self showPhotoNum: photoNum];
        [self.albumPhotosCollection reloadData];
    };
    photoPicker.isHideTopCheck = self.isHideToolBar;
    [self.navigationController pushViewController: photoPicker animated: YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateCachedAssets];
}

#pragma mark - BMPhotoPickerDelegate

- (void)handleDismissWithImages:(NSArray *)images {
    if (self.albumCollectionDelegate && [self.albumCollectionDelegate respondsToSelector: @selector(handleDismissWithImages:)]) {
        [self.albumCollectionDelegate handleDismissWithImages: images];
    }
}

#pragma mark - Event response

- (void)cancel {
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
}

- (void)addAsset: (id)sender {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(200, 200), NO, [UIScreen mainScreen].scale);
    [[Utils randomColor] setFill];
    UIRectFill(CGRectMake(0, 0, 200, 200));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [[BMAlbumManager sharedInstance] saveImageWithAlbum: self.phAssetCollection image: image completion:^(BOOL success) {
        if (success) {
            NSLog(@"创建成功");
        }
    }];
}

- (void)previewAction: (id)sender {
    BMPhotoPickerController *photoPicker = [[BMPhotoPickerController alloc] init];
    photoPicker.photoAssets = [self.selectedPhotos mutableCopy];
    photoPicker.startingIndex = 0;
    photoPicker.selectedPhotos = self.selectedPhotos;
    photoPicker.bmPhotoPickerDelegate = self;
    photoPicker.reloadPhotos = ^(NSUInteger photoNum){
        selectedPhotoNum = photoNum;
        [self showPhotoNum: photoNum];
        [self.albumPhotosCollection reloadData];
    };
    [self.navigationController pushViewController: photoPicker animated: YES];
}

- (void)confirm: (id)sender {
    if (self.albumCollectionDelegate && [self.albumCollectionDelegate respondsToSelector: @selector(handleDismissWithImages:)]) {
        if (self.selectedPhotos.count == 0) {
            [self.navigationController dismissViewControllerAnimated: YES completion: nil];
            return;
        }
        
        [BMIndicator startIndicatorWithType: BMIndicatorTypeDefault];
        NSMutableArray *tempPhotos = @[].mutableCopy;
        NSMutableArray *resultPhotos = @[].mutableCopy;
        NSMutableArray *indexArray = @[].mutableCopy;
        __block NSInteger number = 0;
        for (NSInteger index = 0; index < self.selectedPhotos.count; index++) {
            BMAlbumPhotoModel *model = self.selectedPhotos[index];
            [[BMAlbumManager sharedInstance] getPhotoWithAsset: model.asset completion:^(UIImage *resultImage, NSDictionary *info, BOOL isDegraded) {
                if (isDegraded) {
                    return;
                }
                
                [tempPhotos addObject: resultImage];
                [indexArray addObject: [NSString stringWithFormat: @"%ld", index]];
                number++;
                if (number == self.selectedPhotos.count) {
                    NSMutableDictionary *photoSortDic = @{}.mutableCopy;
                    for (NSInteger sortIndex = 0; sortIndex < self.selectedPhotos.count; sortIndex++) {
                        [photoSortDic setObject: tempPhotos[sortIndex] forKey: indexArray[sortIndex]];
                    }
                    
                    NSArray *photoKeys = [photoSortDic allKeys];
                    photoKeys = [photoKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                        NSComparisonResult result = [obj1 compare: obj2];
                        return result == NSOrderedDescending;
                    }];
                    
                    for (NSString *indexStr in photoKeys) {
                        [resultPhotos addObject: [photoSortDic objectForKey: indexStr]];
                    }
                    
                    [BMIndicator stopIndicator];
                    [self.albumCollectionDelegate handleDismissWithImages: resultPhotos];
                    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
                }
            }];
        }
    } else {
        [self.navigationController dismissViewControllerAnimated: YES completion: nil];
    }
}

#pragma mark - Custom Accessor

- (NSMutableArray *)albumPhotos {
    if (!_albumPhotos) {
        _albumPhotos = [[NSMutableArray alloc] init];
    }
    return _albumPhotos;
}

- (PHCachingImageManager *)imageManager {
    if (!_imageManager) {
        _imageManager = [[PHCachingImageManager alloc] init];
    }
    return _imageManager;
}

- (UIImageView *)photoNumBackground {
    if (!_photoNumBackground) {
        _photoNumBackground = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"CheckNum"]];
        _photoNumBackground.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
        _photoNumBackground.center = CGPointMake(self.view.frame.size.width - 60 - imageSize.width * 0.5 + 10, 22);
    }
    return _photoNumBackground;
}

- (UILabel *)photoNum {
    if (!_photoNum) {
        CGPoint photoNumCenter = CGPointMake(self.view.frame.size.width - 60 - imageSize.width * 0.5 + 10, 22);
        _photoNum = [[UILabel alloc] init];
        _photoNum.bounds = CGRectMake(0, 0, imageSize.width, imageSize.height);
        _photoNum.center = photoNumCenter;
        _photoNum.textColor = [UIColor whiteColor];
        _photoNum.textAlignment = NSTextAlignmentCenter;
        _photoNum.font = [UIFont systemFontOfSize: 16];
    }
    return _photoNum;
}

#pragma mark - Photo Notification

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    PHFetchResultChangeDetails *collectionChanges = [changeInstance changeDetailsForFetchResult: self.albumModel.assetResult];
    if (!collectionChanges) {
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.albumModel.assetResult = [collectionChanges fetchResultAfterChanges];
        BMAlbumNavigationController *bmNav = (BMAlbumNavigationController *)self.navigationController;
        [[BMAlbumManager sharedInstance] getAssetsWithFetchResult: self.albumModel.assetResult allowPickingVideo: bmNav.allowSelectVideo completion:^(NSArray<BMAlbumPhotoModel *> *results) {
            if (results) {
                [self.albumPhotos removeAllObjects];
                [self.selectedPhotos removeAllObjects];
                [self.albumPhotos addObjectsFromArray: results];
                
                if (!collectionChanges.hasIncrementalChanges || collectionChanges.hasMoves) {
                    [self.albumPhotosCollection reloadData];
                } else {
                    [self.albumPhotosCollection performBatchUpdates:^{
                        NSIndexSet *removeIndexes = [collectionChanges removedIndexes];
                        if (removeIndexes.count > 0) {
                            [self.albumPhotosCollection deleteItemsAtIndexPaths: [removeIndexes bm_indexPathsFromIndexsWithSection: 0]];
                        }
                        
                        NSIndexSet *insertIndexes = [collectionChanges insertedIndexes];
                        if (insertIndexes.count > 0) {
                            [self.albumPhotosCollection insertItemsAtIndexPaths: [insertIndexes bm_indexPathsFromIndexsWithSection: 0]];
                        }
                        
                        NSIndexSet *changeIndexes = [collectionChanges changedIndexes];
                        if (changeIndexes.count > 0) {
                            [self.albumPhotosCollection reloadItemsAtIndexPaths: [changeIndexes bm_indexPathsFromIndexsWithSection: 0]];
                        }
                    } completion: NULL];
                }
                [self resetCachedAssets];
            }
        }];
    });
}

@end
