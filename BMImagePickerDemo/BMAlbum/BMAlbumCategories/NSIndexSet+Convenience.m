//
//  NSIndexSet+Convenience.m
//  BMImagePickerDemo
//
//  Created by jashion on 16/9/1.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSIndexSet+Convenience.h"

@implementation NSIndexSet (Convenience)

- (NSArray *)bm_indexPathsFromIndexsWithSection: (NSUInteger)section {
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity: self.count];
    [self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [indexPaths addObject: [NSIndexPath indexPathForItem: idx inSection: section]];
    }];
    return indexPaths;
}

@end
