//
//  YT_BaseScrollChart.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/21.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_BaseScrollChart.h"

@implementation YT_BaseScrollChart

- (UIEdgeInsets)scrollViewInsets {
    return UIEdgeInsetsZero;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        CGRect scrollRect = UIEdgeInsetsInsetRect(CGRectMake(0, 0, frame.size.width, frame.size.height), self.scrollViewInsets);
        
        _backScrollView = [[UIScrollView alloc] initWithFrame:scrollRect];
        _backScrollView.showsHorizontalScrollIndicator = NO;
        _backScrollView.showsVerticalScrollIndicator = NO;
        _backScrollView.userInteractionEnabled = NO;
        [self addSubview:_backScrollView];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:scrollRect];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.alwaysBounceHorizontal = YES; ///< 设置内容不够时也可以弹一弹
        _scrollView.delegate = self;
        
        [self addSubview:_scrollView];
        
        [self addObservers];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGRect scrollRect = UIEdgeInsetsInsetRect(CGRectMake(0, 0, frame.size.width, frame.size.height), self.scrollViewInsets);
    
    _scrollView.frame = scrollRect;
    _backScrollView.frame = scrollRect;
}

- (void)scrollsToLeft {
    CGPoint contentOffset  = _scrollView.contentOffset;
    contentOffset.x =  [self backScrollViewMinOffX];
    [_scrollView setContentOffset:contentOffset animated:NO];
}

- (void)scrollsToRight {
    CGPoint contentOffset  = _scrollView.contentOffset;
    contentOffset.x =  [self backScrollViewMaxOffX];
    [_scrollView setContentOffset:contentOffset animated:NO];
}

#pragma mark - KVO监听

- (void)removeObservers {
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [_scrollView removeObserver:self forKeyPath:@"contentSize"];
    [_scrollView removeObserver:self forKeyPath:@"contentInset"];
}

- (void)addObservers {
//     NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [_scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [_scrollView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        [self scrollViewContentOffsetDidChange];
    }
    else if ([keyPath isEqualToString:@"contentSize"]) {
        _backScrollView.contentSize = _scrollView.contentSize;
    }
    else if ([keyPath isEqualToString:@"contentInset"]) {
        _backScrollView.contentInset = _scrollView.contentInset;
    }
}

- (void)scrollViewContentOffsetDidChange {
    CGPoint contentOffset = _scrollView.contentOffset;
    CGFloat s_contentOffset_x = contentOffset.x;
    CGFloat bs_minOffx;
    CGFloat bs_maxOffx;
    if (s_contentOffset_x < (bs_minOffx = self.backScrollViewMinOffX)) {
        contentOffset.x = bs_minOffx;
    }
    else if (s_contentOffset_x > (bs_maxOffx = self.backScrollViewMaxOffX)) {
        contentOffset.x = bs_maxOffx;
    }
    
    [_backScrollView setContentOffset:contentOffset];
}

- (CGFloat)backScrollViewMinOffX{
    return - _scrollView.contentInset.left;
}

- (CGFloat)backScrollViewMaxOffX{
    return (_scrollView.contentSize.width + _scrollView.contentInset.right) - _scrollView.frame.size.width;
}

-(void)dealloc {
    [self removeObservers];
}

@end
