//
//  PhotoPickerCell.m
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/7.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import "PhotoPickerCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "BMAlbumManager.h"

@interface PhotoPickerCell ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) BMAlbumPhotoModel *model;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIImageView *livePhotoBadgeView;
@property (nonatomic, assign) BOOL playingHint;

@end

@implementation PhotoPickerCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        _scrollView = [[UIScrollView alloc] initWithFrame: self.bounds];
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.bouncesZoom = YES;
        _scrollView.maximumZoomScale = 2.5f;
        _scrollView.minimumZoomScale = 1.f;
        _scrollView.zoomScale = 2.5f;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delaysContentTouches = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview: _scrollView];
        
        _imageView = [UIImageView new];
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_scrollView addSubview: _imageView];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(singleTap:)];
        [self addGestureRecognizer: singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [singleTap requireGestureRecognizerToFail: doubleTap];
        [self addGestureRecognizer: doubleTap];
        
        [self addSubview: self.livePhotoView];
        [self addSubview: self.playButton];
        [self addSubview: self.livePhotoBadgeView];
    }
    return self;
}

- (void)setPhotoModel: (BMAlbumPhotoModel *)model {
    _model = model;
    [self.scrollView setZoomScale: 1.0 animated: NO];
    if (_model.type == BMAlbumModelMediaTypeLivePhoto) {
        [self updateLivePhoto];
        self.livePhotoView.hidden = NO;
        self.playButton.hidden = YES;
        self.imageView.hidden = YES;
        self.playerLayer.hidden = YES;
        self.livePhotoBadgeView.hidden = NO;
        self.livePhotoBadgeView.image = [PHLivePhotoView livePhotoBadgeImageWithOptions: PHLivePhotoBadgeOptionsOverContent];
        return;
    }
    [[BMAlbumManager sharedInstance] getFullScreenImageWithAsset: _model.asset completion:^(UIImage *resultImage) {
        self.imageView.image = resultImage;
        self.livePhotoBadgeView.hidden = YES;
        self.livePhotoView.hidden = YES;
        self.imageView.hidden = NO;
        
        if (_model.type == BMAlbumModelMediaTypeVideo) {
            self.imageView.frame = self.bounds;
            self.playerLayer.hidden = NO;
            self.playButton.hidden = NO;
        } else {
            [self autoLayoutImageView];
            [self pauseVideo];
            self.playerLayer.hidden = YES;
            self.playButton.hidden = YES;
        }
    }];
}

- (void)loadVideo {
    [[BMAlbumManager sharedInstance] getVideoWithAsset: _model.asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopIndictor];
            self.player = [AVPlayer playerWithPlayerItem: playerItem];
            self.playerLayer = [AVPlayerLayer playerLayerWithPlayer: self.player];
            self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
            self.playerLayer.frame = self.bounds;
            [self.layer insertSublayer: self.playerLayer below: self.playButton.layer];
            [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(pauseVideo) name:AVPlayerItemDidPlayToEndTimeNotification object: nil];
            [self playVideo];
        });
    }];
}

- (void)updateLivePhoto {
    [[BMAlbumManager sharedInstance] getLivePhotoWithAsset: _model.asset completion:^(PHLivePhoto *livePhoto, NSDictionary *info) {
        self.livePhotoView.livePhoto = livePhoto;
        if (![info[PHImageResultIsDegradedKey] boolValue] && !self.playingHint) {
            self.playingHint = YES;
            [self.livePhotoView startPlaybackWithStyle: PHLivePhotoViewPlaybackStyleHint];
        }
    }];
}

- (void)autoLayoutImageView {
    CGFloat viewWidth = CGRectGetWidth(self.frame);
    CGFloat viewHeight = CGRectGetHeight(self.frame);
    
    CGRect rect = CGRectZero;
    rect.origin = CGPointZero;
    rect.size.width = viewWidth;
    
    CGSize imageSize = self.imageView.image.size;
    rect.size.height = (viewWidth * imageSize.height / imageSize.width);

    self.scrollView.contentSize = CGSizeMake(viewWidth, MAX(viewHeight, rect.size.height));
    [self.scrollView scrollRectToVisible: self.bounds animated: YES];
    self.imageView.bounds = rect;
    self.imageView.center = CGPointMake(viewWidth / 2, MAX(viewHeight, rect.size.height) / 2);
}

- (void)singleTap: (UITapGestureRecognizer *)tap {
//    if (_model.type != BMAlbumModelMediaTypePhoto) {
//        return;
//    }
//    if (self.singleTapBlock) {
//        self.singleTapBlock();
//    }
}

- (void)doubleTap: (UITapGestureRecognizer *)tap {
    if (_model.type != BMAlbumModelMediaTypePhoto) {
        return;
    }
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
        [self.scrollView setZoomScale: self.scrollView.minimumZoomScale animated: YES];
        [self.scrollView scrollRectToVisible: self.bounds animated: YES];
    } else {
        CGPoint touchPoint = [tap locationInView: self.imageView];
        CGFloat sWidth = self.frame.size.width / self.scrollView.maximumZoomScale;
        CGFloat sHeight = self.frame.size.height / self.scrollView.maximumZoomScale;
        CGRect newRect = CGRectMake(touchPoint.x - sWidth * 0.5, touchPoint.y - sHeight * 0.5, sWidth, sHeight);
        [self.scrollView zoomToRect: newRect animated: YES];
    }
    
    if (self.doubleTapBlock) {
        self.doubleTapBlock();
    }
}

#pragma mark - Public Method

- (void)playLivePhoto: (BOOL)play {
    if (self.livePhotoView.livePhoto) {
        if (play) {
            [self.livePhotoView startPlaybackWithStyle: PHLivePhotoViewPlaybackStyleFull];
        } else {
            [self.livePhotoView stopPlayback];
        }
    }
}

- (void)resetAllStatus {
    if (self.player.currentItem) {
        [self pauseVideo];
    }
    
    if (self.livePhotoView.livePhoto) {
        [self.livePhotoView stopPlayback];
    }
}

#pragma mark - Event Response

- (void)handlePlay: (UIButton *)button {
    if (!self.player) {
        [_playButton setImage: nil forState: UIControlStateNormal];
        [self startIndicator];
        [self loadVideo];
        return;
    }
    CMTime currentTime = _player.currentItem.currentTime;
    CMTime durationTime = _player.currentItem.duration;
    if (_player.rate == 0.0f) {
        if (currentTime.value == durationTime.value) {
            [_player.currentItem seekToTime: kCMTimeZero];
        }
        [self playVideo];
    } else {
        [self pauseVideo];
    }
}

- (void)startIndicator {
    [self addSubview: self.indicatorView];
    [self.indicatorView startAnimating];
}

- (void)stopIndictor {
    [self.indicatorView stopAnimating];
    [self.indicatorView removeFromSuperview];
}

- (void)pauseVideo {
    [_player pause];
    [_playButton setImage: [UIImage imageNamed:@"VideoPlayIcon"] forState: UIControlStateNormal];
}

- (void)playVideo {
    [_player play];
    [_playButton setImage: nil forState: UIControlStateNormal];
}

#pragma mark - Custom Accessors

- (UIButton *)playButton {
    if (!_playButton) {
        _playButton = [UIButton buttonWithType: UIButtonTypeCustom];
        _playButton.bounds = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _playButton.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height * 0.5);
        [_playButton setImage: [UIImage imageNamed:@"VideoPlayIcon"] forState: UIControlStateNormal];
        [_playButton setImage: [UIImage imageNamed:@"VideoPlayIconHL"] forState: UIControlStateHighlighted];
        [_playButton addTarget: self action: @selector(handlePlay:) forControlEvents: UIControlEventTouchUpInside];
    }
    return _playButton;
}

- (UIActivityIndicatorView *)indicatorView {
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
        _indicatorView.frame = CGRectMake((self.frame.size.width - 80) * 0.5, (self.frame.size.height - 80) * 0.5, 80, 80);
    }
    return _indicatorView;
}

- (PHLivePhotoView *)livePhotoView {
    if (!_livePhotoView) {
        _livePhotoView = [[PHLivePhotoView alloc] initWithFrame: self.bounds];
    }
    return _livePhotoView;
}

- (UIImageView *)livePhotoBadgeView {
    if (!_livePhotoBadgeView) {
        _livePhotoBadgeView = [[UIImageView alloc] initWithFrame: CGRectMake(0, 64, 40, 40)];
        _livePhotoBadgeView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _livePhotoBadgeView;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat width = scrollView.frame.size.width;
    CGFloat height = scrollView.frame.size.height;
    
    CGFloat offsetX = width > scrollView.contentSize.width? (width - scrollView.contentSize.width) * 0.5: 0.f;
    CGFloat offsetY = height > scrollView.contentSize.height? (height - scrollView.contentSize.height) * 0.5 : 0.f;
    self.imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

@end
