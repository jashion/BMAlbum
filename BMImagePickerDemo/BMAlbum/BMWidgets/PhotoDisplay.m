//
//  PhotoDisplay.m
//  BMImagePickerDemo
//
//  Created by jashion on 16/8/31.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import "PhotoDisplay.h"

@interface PhotoDisplay ()<UIScrollViewDelegate, UIDynamicAnimatorDelegate>

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) UIImageView *photoContainer;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation PhotoDisplay
{
    CGRect oldRect;
    CGRect newRect;
    CGFloat duration;
}

- (instancetype)initWithBGView: (UIView *)bgView photo: (UIImage *)photo photoFrame: (CGRect)photoFrame {
	self = [super initWithFrame: [UIScreen mainScreen].bounds];
    if (self) {
        if (bgView) {
            _bgView = [bgView snapshotViewAfterScreenUpdates: NO];
        } else {
            self.backgroundColor = [UIColor clearColor];
        }
        
        _photo = photo;
        oldRect = photoFrame;
        duration = 0.3;
        
        _scrollView = [[UIScrollView alloc] initWithFrame: self.bounds];
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delaysContentTouches = NO;
        _scrollView.bounces = YES;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.maximumZoomScale = 2.5;
        _scrollView.bouncesZoom = YES;
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
        [self addSubview: _scrollView];
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleSingleTapGesture:)];
        [self addGestureRecognizer: singleTap];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(handleDoubleTapGesture:)];
        doubleTap.numberOfTapsRequired = 2;
        [singleTap requireGestureRecognizerToFail: doubleTap];
        [self addGestureRecognizer: doubleTap];
    }
    return self;
}

- (void)handleSingleTapGesture: (UITapGestureRecognizer *)singleTapGesture {
    if (self.scrollView.zoomScale > 1.0) {
        [self.scrollView setZoomScale: 1.0 animated: NO];
    }
    [self hide];
}

- (void)handleDoubleTapGesture: (UITapGestureRecognizer *)doubleTapGesture {
    if (self.scrollView.zoomScale > 1.0) {
        [self.scrollView setZoomScale: 1.0 animated: YES];
        [self.scrollView scrollRectToVisible: self.bounds animated: YES];
    } else {
        CGPoint touchPoint = [doubleTapGesture locationInView: self.photoContainer];
        CGFloat sWith = self.frame.size.width / self.scrollView.maximumZoomScale;
        CGFloat sHeight = self.frame.size.height / self.scrollView.maximumZoomScale;
        [self.scrollView zoomToRect: CGRectMake(touchPoint.x - sWith * 0.5, touchPoint.y - sHeight * 0.5, sWith, sHeight) animated: YES];
    }
}

- (void)handlePanGesture: (UIPanGestureRecognizer *)panGesture {
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            break;
        }
        
        case UIGestureRecognizerStateEnded:
        {
            break;
        }
        
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        default:
        {
            break;
        }
    }
}

- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview: self];
    self.photoContainer.frame = oldRect;
    self.photoContainer.image = _photo;
    [self.scrollView addSubview: self.photoContainer];

    CGSize photoSize = _photo.size;
    CGFloat screenWidth = self.frame.size.width;
    CGFloat screenHeight = self.frame.size.height;
    CGFloat newPhotoWidth = screenWidth;
    CGFloat newPhotoHeight = screenWidth * (photoSize.height / photoSize.width);
    newRect = CGRectMake(0, (screenHeight - newPhotoHeight) / 2, newPhotoWidth, newPhotoHeight);
    [UIView animateWithDuration: duration animations:^{
        self.photoContainer.frame = newRect;
        self.backgroundColor = [UIColor blackColor];
    }];
}

- (void)hide {
    [UIView animateWithDuration: duration animations:^{
        self.photoContainer.frame = oldRect;
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.hideBlockHandle) {
            self.hideBlockHandle();
        };
    }];
}

#pragma mark - Custom Accessors

- (UIImageView *)photoContainer {
    if (!_photoContainer) {
        _photoContainer = [UIImageView new];
        _photoContainer.contentMode = UIViewContentModeScaleAspectFill;
        _photoContainer.clipsToBounds = YES;
        _photoContainer.userInteractionEnabled = YES;
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget: self action: @selector(handlePanGesture:)];
        [_photoContainer addGestureRecognizer: panGesture];
    }
    return _photoContainer;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoContainer;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGSize scrollViewSize = scrollView.contentSize;
    CGFloat width = scrollView.frame.size.width;
    CGFloat height = scrollView.frame.size.height;
    CGFloat photoCenterX = width > scrollViewSize.width ? (width - scrollViewSize.width) * 0.5 + scrollViewSize.width * 0.5: scrollViewSize.width * 0.5;
    CGFloat photoCenterY = height > scrollViewSize.height ? (height - scrollViewSize.height) * 0.5 + scrollViewSize.height * 0.5: scrollViewSize.height * 0.5;
    self.photoContainer.center = CGPointMake(photoCenterX, photoCenterY);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

}

@end
