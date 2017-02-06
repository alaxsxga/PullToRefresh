//
//  PullToRefreshControl.m
//  husky
//
//  Created by Ed on 2016/3/23.
//  Copyright © 2016年 LiaoEd. All rights reserved.
//

#import "PullToRefreshControl.h"


#define BACKGROUND_COLOR [UIColor clearColor]
#define ACTION_OFFSET 70
#define REFRESHING_HEIGHT 50
#define INDICATOR_OFFSET_Y 26

typedef enum {
    RefreshControlStatusEndRefresh,
    RefreshControlStatusRefreshing,
} RefreshControlStatus;

@interface PullToRefreshControl()

@property (nonatomic, assign) id refreshTarget;
@property (nonatomic) SEL refreshAction;
@property (nonatomic, assign) UIScrollView* scrollView;
@property (nonatomic, assign) CGFloat distanceScrolled;
@property (nonatomic, strong) UIActivityIndicatorView* indicator;
@property (nonatomic, assign) CGFloat positionY;
@property (nonatomic, assign) RefreshControlStatus status;

@end


@implementation PullToRefreshControl


+ (PullToRefreshControl*)attachToTableView:(UITableView*)tableView positionY:(CGFloat)positionY refreshTarget:(id)refreshTarget refreshAction:(SEL)refreshAction
{
    return [self attachToScrollView:tableView positionY:positionY refreshTarget:refreshTarget refreshAction:refreshAction];
}

+ (PullToRefreshControl*)attachToScrollView:(UIScrollView*)scrollView positionY:(CGFloat)positionY refreshTarget:(id)refreshTarget refreshAction:(SEL)refreshAction
{
    PullToRefreshControl* pullToRefreshControl = [[PullToRefreshControl alloc] initWithFrame:CGRectMake(0, positionY, scrollView.frame.size.width, 0)
                                                                                  scrollView:scrollView refreshTarget:refreshTarget
                                                                               refreshAction:refreshAction];
    [scrollView addSubview:pullToRefreshControl];
    
    return pullToRefreshControl;
}

- (id)initWithFrame:(CGRect)frame scrollView:(UIScrollView*)scrollView refreshTarget:(id)refreshTarget refreshAction:(SEL)refreshAction
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.backgroundColor = BACKGROUND_COLOR;
        
        _scrollView = scrollView;
        _refreshTarget = refreshTarget;
        _refreshAction = refreshAction;
        _positionY = frame.origin.y;
        _status = RefreshControlStatusEndRefresh;
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.center = CGPointMake(screenWidth/2, INDICATOR_OFFSET_Y);
        [self addSubview:_indicator];
    }
    return self;
}



- (void)scrollViewDidScroll
{
    CGFloat offsetY = _scrollView.contentOffset.y;
//    NSLog(@"refreshView_didScroll.offsetY:%f status:%d",offsetY,_status);
    
    if (!_indicator.isAnimating) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_indicator startAnimating];
        });
    }
    
    /* 處於更新狀態時，使畫面處於一定高度，更新完畢才收起來 */
    if (_status == RefreshControlStatusRefreshing && offsetY >= -REFRESHING_HEIGHT) {
        
        offsetY = -REFRESHING_HEIGHT;
    }
    
    if (offsetY <= 0) {
        [self setHeightAndOffsetOfRefreshControl:offsetY];
    }
}

- (void)scrollViewDidEndDragging
{
    CGFloat offsetY = _scrollView.contentOffset.y;
//    NSLog(@"refreshView_EndDragging status:%d offsetY:%f",_status,offsetY);
    
    /* 若拖拉的距離達觸發的條件，且不是已在更新的狀態，performSelector */
    if (offsetY <= -ACTION_OFFSET && _status != RefreshControlStatusRefreshing) {
        
        _status = RefreshControlStatusRefreshing;
        
        [self setInsetOfRefreshControl:REFRESHING_HEIGHT];
        
        if ([self.refreshTarget respondsToSelector:self.refreshAction]) {
            [self.refreshTarget performSelector:self.refreshAction];
        }
    }
    
}

- (void)finishedRefreshing
{
    _status = RefreshControlStatusEndRefresh;
    [self setInsetOfRefreshControl:0];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_indicator stopAnimating];
    });
}

- (void)setHeightAndOffsetOfRefreshControl:(CGFloat)offsetY
{
    CGRect newFrame = self.frame;
    newFrame.size.height = -offsetY;
    newFrame.origin.y = _positionY + offsetY;
    self.frame = newFrame;
}

- (void)setInsetOfRefreshControl:(CGFloat)insetY
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIEdgeInsets newInsets = _scrollView.contentInset;
        newInsets.top = insetY;
        
        [UIView animateWithDuration:0.4 animations:^(void) {
            _scrollView.contentInset = newInsets;
        }];
    });
}

@end
