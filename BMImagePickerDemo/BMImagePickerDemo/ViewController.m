//
//  ViewController.m
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/3.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import "ViewController.h"
#import "CustomeCollectionViewCell.h"
#import "StringUtils.h"
#import "BMActionSheetView.h"
#import "BMActionSheet.h"
#import "PhotoDisplay.h"

#define kScreenWidth    [UIScreen mainScreen].bounds.size.width
#define kScreenHeight   [UIScreen mainScreen].bounds.size.height
#define itemSpace       10
#define itemWith        (kScreenWidth - 50) / 4
#define itemHeight      (kScreenWidth - 50) / 4

@interface ViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, BMActionSheetViewDelegate>

@property (nonatomic, strong) UICollectionView *photoCollectionView;
@property (nonatomic, strong) NSMutableArray *photosArray;

@end

@implementation ViewController

- (instancetype)init {
    if (self = [super init]) {
        self.navigationItem.title = @"ImagePicker";
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initPhotoCollectionView];
}

- (void)addPhoto {
    BMActionSheetView *bmActionSheetView = [[BMActionSheetView alloc] initWithController: self];
    bmActionSheetView.delegate = self;
    bmActionSheetView.allowSelectVideo = YES;
    bmActionSheetView.allowSelectOriginalPhoto = NO;
    bmActionSheetView.maxImagesCount = 9;
    [bmActionSheetView showActionSheet];
    [self.view addSubview: bmActionSheetView];
}

#pragma mark - Init components

- (void)initPhotoCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.minimumLineSpacing = 10;
    flowLayout.itemSize = CGSizeMake(itemWith, itemHeight);
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    self.photoCollectionView = [[UICollectionView alloc] initWithFrame: [UIScreen mainScreen].bounds collectionViewLayout: flowLayout];
    self.photoCollectionView.dataSource = self;
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.backgroundColor = [UIColor whiteColor];
    [self.photoCollectionView registerClass: [CustomeCollectionViewCell class] forCellWithReuseIdentifier: NSStringFromClass([CustomeCollectionViewCell class])];
    [self.view addSubview: self.photoCollectionView];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photosArray.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CustomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: NSStringFromClass([CustomeCollectionViewCell class]) forIndexPath: indexPath];
    if (self.photosArray.count == indexPath.row) {
        [cell setupImage: [UIImage imageNamed:@"AddPhotoIcon"]];
    } else {
        [cell setupImage: self.photosArray[indexPath.row]];
    }
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.photosArray.count != indexPath.row) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath: indexPath];
        CGRect cellFrame = [cell convertRect: cell.contentView.frame toView: self.view];
        UIImage *image = self.photosArray[indexPath.row];
        PhotoDisplay *photoDisplay = [[PhotoDisplay alloc] initWithBGView: nil photo: image photoFrame: cellFrame];
        photoDisplay.hideBlockHandle = ^{
            cell.contentView.alpha = 1.0;
        };
        [photoDisplay show];
        cell.contentView.alpha = 0;
        return;
    }
    [self addPhoto];
}

#pragma mark - BMActionSheetViewDelegate

- (void)hanleDismissWithBMActionSheetView:(BMActionSheetView *)actionSheetView images:(NSArray *)images {
    [actionSheetView removeFromSuperview];
    [self.photosArray addObjectsFromArray: images];
    [self.photoCollectionView reloadData];
}

#pragma mark - Setter & Getter

- (NSMutableArray *)photosArray {
    if (!_photosArray) {
        _photosArray = @[].mutableCopy;
    }
    return _photosArray;
}

@end
