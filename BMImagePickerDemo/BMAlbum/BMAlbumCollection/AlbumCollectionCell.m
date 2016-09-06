//
//  AlbumCollectionCell.m
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/6.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import "AlbumCollectionCell.h"
#import "BMAlbumManager.h"
#import <PhotosUI/PhotosUI.h>

@interface AlbumCollectionCell ()

@property (nonatomic, strong) BMAlbumPhotoModel *model;
@property (nonatomic, strong) UIImageView *livePhotoBadgeImageView;

@end

@implementation AlbumCollectionCell
{
    UIButton *checkButton;
    UIImageView *videoImageView;
    UIImageView *livePhotoImageView;
    CAGradientLayer *gradientLayer;
    UILabel *videoTimeLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = self.contentView.bounds;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview: _imageView];
        
        UIImage *image = [UIImage imageNamed:@"CheckOut"];
        checkButton = [UIButton buttonWithType: UIButtonTypeCustom];
        checkButton.frame = CGRectMake(self.frame.size.width - image.size.width, 0, image.size.width, image.size.height);
        [checkButton setImage: image forState: UIControlStateNormal];
        [checkButton addTarget: self action: @selector(selectPhoto:) forControlEvents: UIControlEventTouchUpInside];
        [self.contentView addSubview: checkButton];
        
        gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = CGRectMake(0, self.frame.size.height * 4 / 5, self.frame.size.width, self.frame.size.height / 5);
        gradientLayer.colors = @[(id)[UIColor colorWithWhite: 0 alpha: 0].CGColor, (id)[UIColor colorWithWhite: 0 alpha: 1.0].CGColor];
        gradientLayer.locations = @[@(0), @(1)];
        gradientLayer.hidden = YES;
        [self.layer addSublayer: gradientLayer];
        
        UIImage *videoIcon = [UIImage imageNamed:@"VideoIcon"];
        videoImageView = [UIImageView new];
        videoImageView.bounds = CGRectMake(0, 0, videoIcon.size.width, videoIcon.size.height);
        videoImageView.center = CGPointMake(5 + videoIcon.size.width * 0.5, self.frame.size.height * 9 / 10);
        videoImageView.contentMode = UIViewContentModeScaleAspectFit;
        videoImageView.image = videoIcon;
        videoImageView.hidden = YES;
        [self addSubview: videoImageView];
        
        videoTimeLabel = [[UILabel alloc] initWithFrame: CGRectMake(videoIcon.size.width + 10, self.frame.size.height * 4 / 5, self.frame.size.height - videoIcon.size.width - 10 - 5, self.frame.size.height / 5)];
        videoTimeLabel.textAlignment = NSTextAlignmentRight;
        videoTimeLabel.textColor = [UIColor whiteColor];
        videoTimeLabel.font = [UIFont systemFontOfSize: 11];
        videoTimeLabel.hidden = YES;
        [self addSubview: videoTimeLabel];
        
        [self addSubview: self.livePhotoBadgeImageView];
    }
    return self;
}

- (void)setPhotoModel: (BMAlbumPhotoModel *)model {
    _model = model;
    [self showPhotoCheck: model.isSelected isAnimation: NO];
    if (model.type == BMAlbumModelMediaTypeVideo) {
        gradientLayer.hidden = NO;
        videoImageView.hidden = NO;
        videoTimeLabel.hidden = NO;
        checkButton.hidden = YES;
        videoTimeLabel.text = model.timeLength;
    } else {
        gradientLayer.hidden = YES;
        videoImageView.hidden = YES;
        videoTimeLabel.hidden = YES;
        checkButton.hidden = NO;
    }
    
    if (model.type == BMAlbumModelMediaTypeLivePhoto) {
        self.livePhotoBadgeImageView.image = [PHLivePhotoView livePhotoBadgeImageWithOptions: PHLivePhotoBadgeOptionsOverContent];
        checkButton.hidden = YES;
    } else {
        self.livePhotoBadgeImageView.image = nil;
        checkButton.hidden = NO;
    }
    
    [[BMAlbumManager sharedInstance] getThumbnailWithAsset: model.asset completion:^(UIImage *resultImage) {
        _imageView.image = resultImage;
    }];
}

#pragma mark - Event Response

- (void)selectPhoto: (UIButton *)sender {
    [self showPhotoCheck: !sender.selected isAnimation: YES];
    if (self.selectPhoto) {
        self.selectPhoto(checkButton);
    }
}

#pragma mark - Custom Accessors

- (UIImageView *)livePhotoBadgeImageView {
    if (!_livePhotoBadgeImageView) {
        _livePhotoBadgeImageView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 0, 40, 40)];
        _livePhotoBadgeImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _livePhotoBadgeImageView;
}

#pragma mark - Private Method

- (void)showPhotoCheck: (BOOL)isCheck isAnimation: (BOOL)isAnimation {
    if (isCheck) {
        [checkButton setImage: [UIImage imageNamed:@"CheckIn"] forState: UIControlStateNormal];
    } else {
        [checkButton setImage: [UIImage imageNamed:@"CheckOut"] forState: UIControlStateNormal];
    }
    
    if (isCheck && isAnimation) {
        checkButton.transform = CGAffineTransformMakeScale(0.1, 0.1);
        [UIView animateWithDuration: 0.6 delay: 0 usingSpringWithDamping: 0.5 initialSpringVelocity: 1.0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
            checkButton.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {}];
    }
    
    checkButton.selected = isCheck;
//    _model.isSelected = isCheck;
}

@end
