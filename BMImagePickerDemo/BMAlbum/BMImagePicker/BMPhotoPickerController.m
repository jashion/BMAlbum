//
//  BMPhotoPickerController.m
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/7.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import "BMPhotoPickerController.h"
#import "PhotoPickerCell.h"
#import "BMAlbumManager.h"
#import "BMIndicator.h"
#import <Photos/Photos.h>
#import "BMAlbumNavigationController.h"

#define lineSpace       20
#define kRect           [UIScreen mainScreen].bounds

@interface BMPhotoPickerController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *photoScrollView;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) UIButton *selectedPhoto;
@property (nonatomic, strong) UIButton *livePhotoPlayButton;

//ToolBar
@property (nonatomic, strong) UIView *photoToolBar;
@property (nonatomic, strong) UIButton *confirm;
@property (nonatomic, strong) UILabel *photoNum;
@property (nonatomic, strong) UIImageView *photoNumBackground;

@end

@implementation BMPhotoPickerController
{
    CGSize imageSize;
    NSUInteger selectedPhotoNum;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    _currentIndex = self.startingIndex;
    
    for (BMAlbumPhotoModel *model in self.photoAssets) {
        if (model.isSelected) {
            selectedPhotoNum++;
        }
    }
    
    if (!self.isHideTopCheck) {
        [self configureNavButton];
    }
    [self configurePhotoPickerCollection];
    [self configureToolBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear: animated];
    
    if (self.reloadPhotos) {
        self.reloadPhotos(selectedPhotoNum);
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver: self name: AVPlayerItemDidPlayToEndTimeNotification object: nil];
}

#pragma mark - Configure

- (void)configurePhotoPickerCollection {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = lineSpace;
    flowLayout.itemSize = CGSizeMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, lineSpace);
    
    self.photoScrollView = [[UICollectionView alloc] initWithFrame: CGRectMake(0, 0, CGRectGetWidth(self.view.frame) + lineSpace, CGRectGetHeight(self.view.frame)) collectionViewLayout: flowLayout];
    self.photoScrollView.backgroundColor = [UIColor blackColor];
    self.photoScrollView.dataSource = self;
    self.photoScrollView.delegate = self;
    self.photoScrollView.showsVerticalScrollIndicator = NO;
    self.photoScrollView.showsHorizontalScrollIndicator = NO;
    self.photoScrollView.pagingEnabled = YES;
    self.photoScrollView.bounces = YES;
    self.photoScrollView.scrollsToTop = NO;
    [self.photoScrollView setContentOffset: CGPointMake((CGRectGetWidth(self.view.frame) + lineSpace) * _currentIndex, 0) animated: NO];
    [self.photoScrollView registerClass: [PhotoPickerCell class] forCellWithReuseIdentifier: NSStringFromClass([PhotoPickerCell class])];
    [self.view addSubview: self.photoScrollView];
}

- (void)configureNavButton {
    UIImage *image = [UIImage imageNamed:@"CheckOut"];
    self.selectedPhoto = [UIButton buttonWithType: UIButtonTypeCustom];
    self.selectedPhoto.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    self.selectedPhoto.center = CGPointMake(self.view.frame.size.width - image.size.width, 22);
    [self.selectedPhoto setImage: image forState: UIControlStateNormal];
    [self.selectedPhoto addTarget: self action: @selector(selectPhoto:) forControlEvents: UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: self.selectedPhoto];
    
    BMAlbumPhotoModel *model = self.photoAssets[_currentIndex];
    [self showPhotoSeleted: model.isSelected showAnimation: NO];
}

- (void)configureToolBar {
    self.photoToolBar = [[UIView alloc] initWithFrame: CGRectMake(0, CGRectGetHeight(self.view.frame) - 44, CGRectGetWidth(self.view.frame), 44)];
    self.photoToolBar.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.75];
    [self.view addSubview: self.photoToolBar];
    
    self.confirm = [UIButton buttonWithType: UIButtonTypeCustom];
    self.confirm.frame = CGRectMake(self.view.frame.size.width - 60, 0, 60, 44);
    self.confirm.titleLabel.font = [UIFont systemFontOfSize: 16];
    [self.confirm setTitle: @"完成" forState: UIControlStateNormal];
    [self.confirm setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
    [self.confirm addTarget: self action: @selector(confirm:) forControlEvents: UIControlEventTouchUpInside];
    [self.photoToolBar addSubview: self.confirm];
    
    self.livePhotoPlayButton.center = CGPointMake(30, 22);
    [self.photoToolBar addSubview: self.livePhotoPlayButton];
    
    BMAlbumPhotoModel *model = self.photoAssets[_currentIndex];
    if (model.type == BMAlbumModelMediaTypeLivePhoto) {
        self.livePhotoPlayButton.hidden = NO;
    } else {
        self.livePhotoPlayButton.hidden = YES;
    }
    
    UIImage *image = [UIImage imageNamed:@"CheckNum"];
    imageSize = image.size;
    [self showPhotoNum: selectedPhotoNum];
}

#pragma mark - EventResponse

- (void)selectPhoto: (UIButton *)sender {
    BMAlbumNavigationController *bmNav = (BMAlbumNavigationController *)self.navigationController;
    if (selectedPhotoNum >= bmNav.maxImagesCount) {
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
        return;
    }
    [self showPhotoSeleted: !sender.selected showAnimation: YES];
    if (sender.selected) {
        selectedPhotoNum = selectedPhotoNum + 1;
        [self.selectedPhotos addObject: self.photoAssets[_currentIndex]];
    } else {
        selectedPhotoNum = selectedPhotoNum <= 0? 0 : selectedPhotoNum - 1;
        [self.selectedPhotos removeObject: self.photoAssets[_currentIndex]];
    }
    [self showPhotoNum: selectedPhotoNum];
}

- (void)showPhotoSeleted: (BOOL)isSelected showAnimation: (BOOL)isShow{
    if (isSelected) {
        [self.selectedPhoto setImage: [UIImage imageNamed:@"CheckIn"] forState: UIControlStateNormal];
    } else {
        [self.selectedPhoto setImage: [UIImage imageNamed:@"CheckOut"] forState: UIControlStateNormal];
    }
    
    if (isSelected && isShow) {
        self.selectedPhoto.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [UIView animateWithDuration: 0.6 delay: 0 usingSpringWithDamping: 0.5 initialSpringVelocity: 1.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            self.selectedPhoto.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {}];
    }

    self.selectedPhoto.selected = isSelected;
    BMAlbumPhotoModel *model = self.photoAssets[_currentIndex];
    model.isSelected = isSelected;
}

- (void)confirm: (UIButton *)sender {
    if (self.bmPhotoPickerDelegate && [self.bmPhotoPickerDelegate respondsToSelector: @selector(handleDismissWithImages:)]) {
        [BMIndicator startIndicatorWithType: BMIndicatorTypeDefault];
        NSMutableArray *resultPhotos = @[].mutableCopy;
        NSMutableArray *tempPhotos = @[].mutableCopy;
        NSMutableArray *indexArray = @[].mutableCopy;
        __block NSInteger number = 0;
        for (NSInteger index = 0; index < self.selectedPhotos.count; index++) {
            BMAlbumPhotoModel *model = self.selectedPhotos[index];
            [[BMAlbumManager sharedInstance] photoWithAsset: model.asset width: [UIScreen mainScreen].bounds.size.width completion:^(UIImage *resultImage, NSDictionary *info, BOOL isDegraded) {
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
                    [self.bmPhotoPickerDelegate handleDismissWithImages: resultPhotos];
                    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
                }
            }];
        }
        
        if (self.selectedPhotos.count == 0) {
            BMAlbumPhotoModel *model = self.photoAssets[_currentIndex];
            [[BMAlbumManager sharedInstance] photoWithAsset: model.asset width: [UIScreen mainScreen].bounds.size.width completion:^(UIImage *resultImage, NSDictionary *info, BOOL isDegraded) {
                if (isDegraded) {
                    return ;
                }
                
                [BMIndicator stopIndicator];
                [resultPhotos addObject: resultImage];
                [self.bmPhotoPickerDelegate handleDismissWithImages: resultPhotos];
                [self.navigationController dismissViewControllerAnimated: YES completion: nil];
            }];
        }
    } else {
        [self.navigationController dismissViewControllerAnimated: YES completion: nil];
    }
}

- (void)playLivePhoto: (UIButton *)button {
    button.selected = !button.selected;
    PhotoPickerCell *cell = (PhotoPickerCell *)[self.photoScrollView cellForItemAtIndexPath: [NSIndexPath indexPathForRow: _currentIndex inSection: 0]];
    [cell playLivePhoto: button.selected];
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
        return;
    }
    
    if (!self.photoNumBackground.superview) {
        [self.photoToolBar addSubview: self.photoNumBackground];
    }
    
    if (!self.photoNum.superview) {
        [self.photoToolBar addSubview: self.photoNum];
    }
    
    self.photoNum.text = [NSString stringWithFormat: @"%ld", num];
    self.photoNumBackground.transform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration: 0.5 delay: 0 usingSpringWithDamping: 0.6 initialSpringVelocity: 1.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.photoNumBackground.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {}];
}

- (void)showToolBarAndNavigationBar: (BOOL)isShow {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        [self setNeedsStatusBarAppearanceUpdate];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] setStatusBarHidden: isShow withAnimation: UIStatusBarAnimationSlide];
    }
#pragma clang diagnostic pop
    [self.navigationController setNavigationBarHidden: isShow animated: YES];
    
    if (isShow) {
        [UIView animateWithDuration: 0.2 animations:^{
            self.photoToolBar.transform = CGAffineTransformMakeTranslation(0, 44);
        }];
    } else {
        [UIView animateWithDuration: 0.2 animations:^{
            self.photoToolBar.transform = CGAffineTransformIdentity;
        }];
    }
}

- (void)resetWithCell: (PhotoPickerCell *)cell {
    [cell resetAllStatus];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    CGFloat photoOffset = CGRectGetWidth(self.view.frame) + lineSpace;
    if (offsetX <= 0) {
        _currentIndex = 0;
    } else if (offsetX >= photoOffset * self.photoAssets.count) {
        _currentIndex = self.photoAssets.count - 1;
    } else {
        _currentIndex = floor((scrollView.contentOffset.x + CGRectGetWidth(self.view.frame) * 0.5) / photoOffset);
    }
    BMAlbumPhotoModel *model = self.photoAssets[_currentIndex];
    [self showPhotoSeleted: model.isSelected showAnimation: NO];
    if (model.type == BMAlbumModelMediaTypeLivePhoto) {
        self.livePhotoPlayButton.hidden = NO;
    } else {
        self.livePhotoPlayButton.hidden = YES;
    }
    
    NSInteger befIndex = 0;
    NSInteger afterIndex = 0;
    if (_currentIndex == 0) {
        befIndex = 0;
        afterIndex = 1;
    } else if (_currentIndex == self.photoAssets.count - 1) {
        befIndex = self.photoAssets.count - 2;
        afterIndex = self.photoAssets.count - 1;
    } else {
        befIndex = _currentIndex - 1;
        afterIndex = _currentIndex + 1;
    }
    [self resetWithCell: (PhotoPickerCell *)[self.photoScrollView cellForItemAtIndexPath: [NSIndexPath indexPathForRow: befIndex inSection: 0]]];
    [self resetWithCell: (PhotoPickerCell *)[self.photoScrollView cellForItemAtIndexPath: [NSIndexPath indexPathForRow: afterIndex inSection: 0]]];
}

#pragma mark - Custom Accessors

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

- (UIButton *)livePhotoPlayButton {
    if (!_livePhotoPlayButton) {
        _livePhotoPlayButton = [UIButton buttonWithType: UIButtonTypeCustom];
        _livePhotoPlayButton.bounds = CGRectMake(0, 0, 40, 40);
        [_livePhotoPlayButton setImage: [UIImage imageNamed:@"LivePhotoPlayIcon"] forState: UIControlStateNormal];
        [_livePhotoPlayButton setImage: [UIImage imageNamed:@"LivePhotPauseIcon"] forState: UIControlStateSelected];
        [_livePhotoPlayButton addTarget: self action: @selector(playLivePhoto:) forControlEvents: UIControlEventTouchUpInside];
    }
    return _livePhotoPlayButton;
}

#pragma mark - PHLivePhotoViewDelegate

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView willBeginPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    self.livePhotoPlayButton.selected = YES;
}

- (void)livePhotoView:(PHLivePhotoView *)livePhotoView didEndPlaybackWithStyle:(PHLivePhotoViewPlaybackStyle)playbackStyle {
    self.livePhotoPlayButton.selected = NO;
    [self showToolBarAndNavigationBar: NO];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoAssets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: NSStringFromClass([PhotoPickerCell class]) forIndexPath: indexPath];
    __weak typeof(self) weakSelf = self;
    cell.singleTapBlock = ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.hideNavigationBar = !weakSelf.hideNavigationBar;
        [strongSelf showToolBarAndNavigationBar: strongSelf.hideNavigationBar];
    };
    BMAlbumPhotoModel *model = self.photoAssets[indexPath.row];
    [cell setPhotoModel: model];
    cell.livePhotoView.delegate = self;
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - Override

- (BOOL)prefersStatusBarHidden {
    return self.hideNavigationBar;
}

@end
