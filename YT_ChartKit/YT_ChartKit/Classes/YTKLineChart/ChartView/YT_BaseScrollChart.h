//
//  YT_BaseScrollChart.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/21.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YT_BaseScrollChart : UIView <UIScrollViewDelegate>

@property (nonatomic, assign, readonly) UIEdgeInsets scrollViewInsets;  ///< 滚动位置定义
@property (nonatomic, strong, readonly) UIScrollView * scrollView;  ///< 滚动视图
@property (nonatomic, strong, readonly) UIScrollView * backScrollView;  ///< 背景滚动
@property (nonatomic, assign, readonly) CGFloat backScrollViewMinOffX;  ///< 背景滚动，最小偏移量
@property (nonatomic, assign, readonly) CGFloat backScrollViewMaxOffX;  ///< 背景滚动，最大偏移量

- (void)scrollsToLeft;
- (void)scrollsToRight;
@end
