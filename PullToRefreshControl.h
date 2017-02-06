//
//  PullToRefreshControl.h
//  husky
//
//  Created by Ed on 2016/3/23.
//  Copyright © 2016年 LiaoEd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PullToRefreshControl : UIView <UIScrollViewDelegate>

+ (PullToRefreshControl*)attachToTableView:(UITableView*)tableView positionY:(CGFloat)positionY refreshTarget:(id)refreshTarget refreshAction:(SEL)refreshAction;

+ (PullToRefreshControl*)attachToScrollView:(UIScrollView*)scrollView positionY:(CGFloat)positionY refreshTarget:(id)refreshTarget refreshAction:(SEL)refreshAction;

- (void)scrollViewDidScroll;

- (void)scrollViewDidEndDragging;

- (void)finishedRefreshing;

@end
