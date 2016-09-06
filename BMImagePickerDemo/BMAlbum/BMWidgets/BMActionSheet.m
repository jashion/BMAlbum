//
//  BMActionSheet.m
//  BMImagePickerDemo
//
//  Created by jashion on 16/8/18.
//  Copyright © 2016年 BMu. All rights reserved.
//

#import "BMActionSheet.h"
#import "Utils.h"

static CGFloat space = 5;
static CGFloat buttonHeight = 44;
#define kRect [UIScreen mainScreen].bounds
#define buttonWidth CGRectGetWidth(kRect)

@interface BMActionSheet ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSArray *buttonTitles;
@property (nonatomic, copy) NSString *cancelButtonTitle;

@end

@implementation BMActionSheet
{
    NSInteger buttonCount;
    UITableView *actionSheetTableView;
    CGFloat titleHeight;
}

- (instancetype)initWithTitle: (NSString *)title buttonTitles: (NSArray *)buttonTitles cancelButtonTitle:(NSString *)cancelButtonTitle {
    if (self = [super init]) {
        _title              = title;
        _buttonTitles       = buttonTitles.copy;
        _cancelButtonTitle  = cancelButtonTitle;
        [self setup];
        [self buildView];
    }
    return self;
}

- (void)setup {
    if (_buttonTitles && _buttonTitles.count > 0) {
        buttonCount = _buttonTitles.count;
    }
}

- (void)buildView {
    CGFloat tableViewHeight = (buttonCount + 1)* buttonHeight + space;
    tableViewHeight += _title ? buttonHeight: 0;
    
    self.backgroundColor = [UIColor clearColor];
    self.frame = kRect;
    
    actionSheetTableView = [[UITableView alloc] initWithFrame: CGRectMake(0, CGRectGetHeight(kRect), buttonWidth, tableViewHeight) style: UITableViewStyleGrouped];
    actionSheetTableView.dataSource = self;
    actionSheetTableView.delegate = self;
    actionSheetTableView.scrollsToTop = NO;
    actionSheetTableView.scrollEnabled = NO;
    actionSheetTableView.showsVerticalScrollIndicator = NO;
    actionSheetTableView.showsHorizontalScrollIndicator = NO;
    actionSheetTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview: actionSheetTableView];
}

#pragma mark - Event Response

- (void)showActionSheet {
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview: self];
    
    [UIView animateWithDuration: 0.3 delay: 0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = [UIColor colorWithWhite: 0 alpha: 0.3];
        [actionSheetTableView setFrame: CGRectMake(0, kRect.size.height - actionSheetTableView.frame.size.height, buttonWidth, actionSheetTableView.frame.size.height)];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissActionSheet {
    [UIView animateWithDuration: 0.2 delay: 0 options: UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backgroundColor = [UIColor clearColor];
        [actionSheetTableView setFrame: CGRectMake(0, kRect.size.height, buttonWidth, actionSheetTableView.frame.size.height)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _buttonTitles.count;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"cell"];
    }
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, buttonWidth, 44)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    if (indexPath.section == 0) {
        titleLabel.font = self.buttonFont ? self.buttonFont : [UIFont systemFontOfSize: 16];
        titleLabel.textColor = self.buttonColor ? self.buttonColor : [UIColor blackColor];
        titleLabel.text = self.buttonTitles[indexPath.row];
    } else {
        titleLabel.font = self.cancelFont ? self.cancelFont : [UIFont systemFontOfSize: 16];
        titleLabel.textColor = self.cancelColor ? self.cancelColor : [UIColor blackColor];
        titleLabel.text = self.cancelButtonTitle;
    }
    [cell.contentView addSubview: titleLabel];
    
    UIView *line = [[UIView alloc] initWithFrame: CGRectMake(0, 43.5, buttonWidth, 0.5)];
    line.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.945 alpha:1.000];
    [cell.contentView addSubview: line];
    
    if ((indexPath.section == 0 && indexPath.row == (buttonCount - 1)) || indexPath.section == 1) {
        line.hidden = YES;
    } else {
        line.hidden = NO;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1 || (section == 0 && !_title)) {
        return nil;
    }
    
    UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, buttonWidth, buttonHeight)];
    headerView.backgroundColor = [UIColor whiteColor];
    UILabel *headerTitle = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, buttonWidth, buttonHeight)];
    headerTitle.backgroundColor = [UIColor whiteColor];
    headerTitle.textColor = self.titleColor ? self.titleColor : [UIColor colorWithRed:0.583 green:0.586 blue:0.603 alpha:1.000];
    headerTitle.font = self.titleFont ? self.titleFont : [UIFont systemFontOfSize: 12];
    headerTitle.textAlignment = NSTextAlignmentCenter;
    headerTitle.text = self.title;
    [headerView addSubview: headerTitle];
    
    UIView *line = [[UIView alloc] initWithFrame: CGRectMake(0, 43, buttonWidth, 0.5)];
    line.backgroundColor = [UIColor colorWithRed:0.922 green:0.922 blue:0.945 alpha:1.000];
    [headerView addSubview: line];
    
    return headerView;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0 && self.title) {
        return buttonHeight;
    }
    
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 0) {
        return space;
    } else {
        return 0.1;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.delegate || ![self.delegate respondsToSelector: @selector(bmActionSheet:clickedButtonAtIndex:)]) {
        [self dismissActionSheet];
        return;
    }
    
    NSInteger row = indexPath.section * buttonCount + indexPath.row;
    [self.delegate bmActionSheet: self clickedButtonAtIndex: row];
}

#pragma mark - Override

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView: self];
    if (point.y > kRect.size.height - actionSheetTableView.frame.size.height) {
        [super touchesBegan: touches withEvent: event];
        return;
    }
    
    [self dismissActionSheet];
}

@end
