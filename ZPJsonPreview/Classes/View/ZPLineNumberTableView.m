//
//  ZPLineNumberTableView.m
//  ZPAlexProject
//
//  Created by Alex on 2023/11/22.
//

#import "ZPLineNumberTableView.h"

@implementation ZPLineNumberTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self config];
    }
    return self;
}

- (void)config
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.bounces = NO;
    self.scrollsToTop = NO;
    self.delaysContentTouches = NO;
    self.canCancelContentTouches = NO;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    if (@available(iOS 11, *)) {
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.allowsMultipleSelection = YES;
    self.estimatedRowHeight = 0;
    self.estimatedSectionFooterHeight = 0;
    self.estimatedSectionHeaderHeight = 0;
}

@end
