//
//  BMActionSheet.h
//  BMImagePickerDemo
//
//  Created by jashion on 16/8/18.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BMActionSheet;

@protocol BMActionSheetDelegate <NSObject>

- (void)bmActionSheet:(BMActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface BMActionSheet : UIView

@property (nonatomic, weak) id<BMActionSheetDelegate> delegate;

/**
 *  设置标题的字号和颜色
 */

@property (nonatomic, strong) UIFont    *titleFont;
@property (nonatomic, strong) UIColor   *titleColor;

/**
 *  取消按钮的字号和颜色设置
 */

@property (nonatomic, strong) UIFont    *cancelFont;
@property (nonatomic, strong) UIColor   *cancelColor;

/**
 *  其它按钮的字号和颜色设置
 */

@property (nonatomic, strong) UIFont    *buttonFont;
@property (nonatomic, strong) UIColor   *buttonColor;

/**
 *  Init
 *
 *  @param title             顶部显示标题，不可点击区域
 *  @param buttonTitles      功能按钮
 *  @param cancelButtonTitle 最下面的取消按钮
 *
 *  @return YWActionSheet
 */

- (instancetype)initWithTitle: (NSString *)title buttonTitles: (NSArray *)buttonTitles cancelButtonTitle:(NSString *)cancelButtonTitle;
- (void)showActionSheet;
- (void)dismissActionSheet;

@end
