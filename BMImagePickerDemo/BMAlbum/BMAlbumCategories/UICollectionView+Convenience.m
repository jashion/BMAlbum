//
//  UICollectionView+Convenience.m
//  BMImagePickerDemo
//
//  Created by jashion on 16/6/30.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import "UICollectionView+Convenience.h"

@implementation UICollectionView (Convenience)

- (NSArray *)applyIndexPathsInRect: (CGRect)rect {
    NSArray *allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect: rect];
    if (allLayoutAttributes.count == 0) {
        return nil;
    }
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity: allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject: indexPath];
    }
    return indexPaths;
}

@end
