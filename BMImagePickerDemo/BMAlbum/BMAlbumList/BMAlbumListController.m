//
//  BMAlbumListController.m
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/6.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import "BMAlbumListController.h"
#import "BMAlbumCollectionController.h"
#import "AlbumListCell.h"
#import "BMAlbumManager.h"
#import "UIView+Addition.h"
#import "BMAlbumGlobalDefine.h"
#import "BMIndicator.h"
#import "BMAlbumNavigationController.h"
#import "StringUtils.h"
#import "Utils.h"
#import "BMIndicator.h"

@interface BMAlbumListController ()<UITableViewDataSource, UITableViewDelegate, PHPhotoLibraryChangeObserver, UIAlertViewDelegate, BMAlbumCollectionDelegate>

@property (nonatomic, strong) UITableView *albumListTable;
@property (nonatomic, strong) NSMutableArray *albumList;
@property (nonatomic, strong) NSMutableArray *fetchResults;
@property (nonatomic, strong) NSMutableArray *phAssetCollections;

@end

@implementation BMAlbumListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver: self];

    self.view.backgroundColor = [UIColor whiteColor];        self.navigationItem.title = @"照片";
    self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName : [UIFont systemFontOfSize: 17], NSForegroundColorAttributeName : [UIColor blackColor]};
    [BMIndicator startIndicatorWithType: BMIndicatorTypeDefault];
    [self configureNavigationButton];
    [self configureTable];
}

- (void)dealloc {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver: self];
}

#pragma mark - Configure

- (void)configureNavigationButton {
    UIButton *cancelButton = [UIButton buttonWithType: UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0, 0, 40, 44);
    cancelButton.titleLabel.font = [UIFont systemFontOfSize: 16];
    [cancelButton setTitle: @"取消" forState: UIControlStateNormal];
    [cancelButton setTitleEdgeInsets: UIEdgeInsetsMake(0, 0, 0, - 10)];
    [cancelButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
    [cancelButton addTarget: self action: @selector(cancel) forControlEvents: UIControlEventTouchUpInside];
    
    UIButton *createButton = [UIButton buttonWithType: UIButtonTypeCustom];
    createButton.frame = CGRectMake(0, 0, 40, 44);
    createButton.titleLabel.font = [UIFont systemFontOfSize: 16];
    [createButton setTitle: @"创建" forState: UIControlStateNormal];
    [createButton setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
    [createButton addTarget: self action: @selector(createAlbum) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: cancelButton];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: createButton];
}

- (void)configureTable {
    self.albumListTable = [[UITableView alloc] initWithFrame: self.view.bounds style: UITableViewStylePlain];
    self.albumListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.albumListTable.dataSource = self;
    self.albumListTable.delegate = self;
    self.albumListTable.scrollsToTop = YES;
    [self.albumListTable registerClass: [AlbumListCell class] forCellReuseIdentifier: NSStringFromClass([AlbumListCell class])];
    [self.view addSubview: self.albumListTable];
    [self reloadTableData];
}

#pragma mark - Private Method

- (void)reloadTableData {
    BMAlbumNavigationController *bmNav = (BMAlbumNavigationController *)self.navigationController;
    [[BMAlbumManager sharedInstance] allAlbumsWithVideo: bmNav.allowSelectVideo completion:^(NSArray<BMAlbumDataModel *> *albums,  NSMutableArray *fetchResults, NSMutableArray *phAssetCollections) {
        self.albumList = [albums mutableCopy];
        self.fetchResults = [fetchResults mutableCopy];
        self.phAssetCollections = [phAssetCollections mutableCopy];
        [self.albumListTable reloadData];
        [BMIndicator stopIndicator];
    }];
}

- (UIImage *)createRandomImage {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(200, 200), NO, [UIScreen mainScreen].scale);
    [[Utils randomColor] setFill];
    UIRectFillUsingBlendMode(CGRectMake(0, 0, 200, 200), kCGBlendModeNormal);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumList.count;
};

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return AlbumListCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlbumListCell *cell = [tableView dequeueReusableCellWithIdentifier: NSStringFromClass([AlbumListCell class])];
    [cell setUpModel: _albumList[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BMAlbumCollectionController *albumCollection = [[BMAlbumCollectionController alloc] init];
    albumCollection.albumModel = self.albumList[indexPath.row];
    albumCollection.phAssetCollection = self.phAssetCollections[indexPath.row];
    albumCollection.albumCollectionDelegate = self;
    [self.navigationController pushViewController: albumCollection animated: YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
    cell.selected = NO;
}

#pragma mark - BMAlbumCollectionDelegate

- (void)handleDismissWithImages:(NSArray *)images {
    if (self.delegate && [self.delegate respondsToSelector: @selector(handleDismissWithAlbumList:images:)]) {
        [self.delegate handleDismissWithAlbumList: self images: images];
    }
}

#pragma mark - PHPhotoLibraryChangeObserver

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *updateSectionFetchResults = [self.fetchResults mutableCopy];
        __block BOOL reloadRequest = NO;
        
        [self.fetchResults enumerateObjectsUsingBlock:^(id collectionsFetchResult, NSUInteger index, BOOL *stop) {
            PHFetchResult *result;
            if ([collectionsFetchResult isKindOfClass: [PHFetchResult class]]) {
                result = collectionsFetchResult;
            } else if ([collectionsFetchResult isKindOfClass: [PHAssetCollection class]]) {
                PHFetchOptions *option = [[PHFetchOptions alloc] init];
                BMAlbumNavigationController *bmNav = (BMAlbumNavigationController *)self.navigationController;
                if (!bmNav.allowSelectVideo) {
                    option.predicate = [NSPredicate predicateWithFormat: @"mediaType == %ld", PHAssetMediaTypeImage];
                }
                option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey: @"creationDate" ascending: YES]];
                result = [PHAsset fetchAssetsInAssetCollection: collectionsFetchResult options: option];
            }
            
            PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult: result];
            if (changeDetails != nil) {
                [updateSectionFetchResults replaceObjectAtIndex: index withObject: [changeDetails fetchResultAfterChanges]];
                reloadRequest = YES;
            }
        }];
        
        if (reloadRequest) {
            self.fetchResults = updateSectionFetchResults;
            [self reloadTableData];
        }
    });
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1:
        {
            UITextField *textField = [alertView textFieldAtIndex: 0];
            if ([StringUtils isEmpty: textField.text]) {
                return;
            }
            
            [[BMAlbumManager sharedInstance] createAlbumWithTitle: [textField.text copy] completion:^(id assetGroup) {
                [[BMAlbumManager sharedInstance] saveImageToAlbum: assetGroup image: [self createRandomImage] completion:^(BOOL success) {
                    if (success) {
                        if ([NSThread mainThread]) {
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{});
                        }
                    }
                }];
            }];
            break;
        }
            
        case 0:
        default:
            break;
    }
}

#pragma clang diagnostic pop

#pragma mark - Event response

- (void)cancel {
    [self.navigationController dismissViewControllerAnimated: YES completion: nil];
}

- (void)createAlbum {
    if (iOS8Later) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle: nil message: @"新相册" preferredStyle: UIAlertControllerStyleAlert];
        __block UITextField *albumNameTextField;
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            albumNameTextField = textField;
        }];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle: @"确定" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([StringUtils isEmpty: albumNameTextField.text]) {
                return;
            }
            
            [[BMAlbumManager sharedInstance] createAlbumWithTitle: [albumNameTextField.text copy] completion:^(id assetGroup) {
                [[BMAlbumManager sharedInstance] saveImageToAlbum: assetGroup image: [self createRandomImage] completion:^(BOOL success) {
                    if (success) {
                        if ([NSThread mainThread]) {
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{});
                        }
                    }
                }];
            }];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
        [alertController addAction: confirmAction];
        [alertController addAction: cancelAction];
        [self presentViewController: alertController animated: YES completion: NULL];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: nil message: @"新相册" delegate: self cancelButtonTitle: @"取消" otherButtonTitles: @"创建", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
#pragma clang diagnostic pop
    }
}

#pragma mark - Getter & Setter

- (NSMutableArray *)ablumList {
    if (!_albumList) {
        _albumList = [[NSMutableArray alloc] init];
    }
    return _albumList;
}

@end
