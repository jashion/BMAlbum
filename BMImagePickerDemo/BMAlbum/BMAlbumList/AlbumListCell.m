//
//  AlbumListCell.m
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/6.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import "AlbumListCell.h"
#import "UIView+Addition.h"
#import "BMAlbumManager.h"
#import "BMAlbumGlobalDefine.h"

@implementation AlbumListCell
{
    UIImageView     *albumPlaceHolderImageView;
    UILabel         *albumTitleLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle: style reuseIdentifier: reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self buildView];
    }
    return self;
}

- (void)buildView {
    albumPlaceHolderImageView = [[UIImageView alloc] initWithFrame: CGRectMake(5, 5, AlbumListCellHeight - 10, AlbumListCellHeight - 10)];
    albumPlaceHolderImageView.backgroundColor = [UIColor whiteColor];
    albumPlaceHolderImageView.contentMode = UIViewContentModeScaleAspectFill;
    albumPlaceHolderImageView.clipsToBounds = YES;
    albumPlaceHolderImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    albumPlaceHolderImageView.layer.borderWidth = 1;
    [self.contentView addSubview: albumPlaceHolderImageView];
    
    albumTitleLabel = [[UILabel alloc] initWithFrame: CGRectMake(albumPlaceHolderImageView.width + 10, 0, CGRectGetWidth([UIScreen mainScreen].bounds) - albumPlaceHolderImageView.width - 10 - 50, AlbumListCellHeight)];
    albumTitleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.contentView addSubview: albumTitleLabel];
    
    UIImageView *arrowHeadRight = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"RightArrowHead"]];
    arrowHeadRight.bounds = CGRectMake(0, 0, 14, 14);
    arrowHeadRight.center = CGPointMake([UIScreen mainScreen].bounds.size.width - 17, (AlbumListCellHeight - 14) * 0.5 + 7);
    arrowHeadRight.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview: arrowHeadRight];
    
    CGFloat offset = 1 / [UIScreen mainScreen].scale;
    CAShapeLayer *borderLine = [CAShapeLayer layer];
    borderLine.frame = CGRectMake(5, AlbumListCellHeight - offset, CGRectGetWidth([UIScreen mainScreen].bounds), offset);
    borderLine.backgroundColor = [UIColor lightGrayColor].CGColor;
    [self.contentView.layer addSublayer: borderLine];
}

- (void)setUpModel: (BMAlbumDataModel *)model {
    NSMutableAttributedString *albumAttrStr = [[NSMutableAttributedString alloc] initWithString: model.albumName attributes: @{NSFontAttributeName : [UIFont systemFontOfSize: 16], NSForegroundColorAttributeName : [UIColor blackColor]}];
    NSAttributedString *imagesCount = [[NSAttributedString alloc] initWithString: [NSString stringWithFormat: @"  (%zd)", model.imagesCount] attributes: @{NSFontAttributeName : [UIFont systemFontOfSize: 16], NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [albumAttrStr appendAttributedString: imagesCount];
    albumTitleLabel.attributedText = albumAttrStr;
    
    [[BMAlbumManager sharedInstance] getPosterImageWithBMAlbumDataModel: model completion:^(UIImage *posterImage) {
        albumPlaceHolderImageView.image = posterImage;
    }];
}

@end
