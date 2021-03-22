//
//  YT_KLineChart+Layouter.h
//  YT_ChartKit
//
//  Created by yt_liyanshan on 2018/9/14.
//

#import "YT_KLineChart.h"

@interface YT_KLineChart (Layouter)

/**
 在 scrollView 中 能用于绘图的窗口 Frame
 */
- (CGRect)chartWindowFrameInScrollView;

- (CGFloat)chartContentH;

/**
 在 scrollView 中 kLineChart 用于绘图的Layr窗口 Frame
 */
- (CGRect)kLineChartLayerWindowYFrameInScrollView;

/**
 在 scrollView 中 volumChart 用于绘图的Layr窗口 Frame
 */
- (CGRect)volumChartLayerWindowYFrameInScrollViewWithIndex:(NSUInteger)idx;
- (CGRect)volumChartLayerWindowYFrameInScrollViewWithIndex:(NSUInteger)idx rect:(CGRect)rect;
- (void)updateChartRect;


- (CGRect)lableKLineIndexFrame;
- (CGRect)lableVolumIndexFrameAtIndex:(NSInteger)index;
- (CGRect)gridAxisXDateTextRect;

#pragma mark -

/** 图标的边缘绘制会被裁剪掉，所以当图表充满layer的时候要设置绘制缩进以免部分被切掉了 最少设置为最宽线的一半 */
- (UIEdgeInsets)chartDrawXInsets;

/**
 图标的边缘绘制会被裁剪掉，所以当图表充满layer的时候要设置绘制缩进以免部分被切掉了 最少设置为最宽线的一半
 */
- (UIEdgeInsets)kLineChartlayerYDrawInsets;

/**
 图标的边缘绘制会被裁剪掉，所以当图表充满layer的时候要设置绘制缩进以免部分被切掉了 最少设置为最宽线的一半
 */
- (UIEdgeInsets)volumChartlayerYDrawInsetsWithIndex:(NSUInteger)idx;

@end

UIKIT_STATIC_INLINE CGRect YT_FixChartRectXStd(CGRect rect ,CGRect xStd){
    return CGRectMake(xStd.origin.x, rect.origin.y, xStd.size.width, rect.size.height);
}

UIKIT_STATIC_INLINE UIEdgeInsets YT_FixChartDrawInsetsXStd(UIEdgeInsets insets , UIEdgeInsets xStd){
    return UIEdgeInsetsMake(insets.top, xStd.left, insets.bottom, xStd.right);
}

UIKIT_STATIC_INLINE CGRect YT_EdgeInsetsExRect(CGRect rect, UIEdgeInsets insets) {
    rect.origin.x    -= insets.left;
    rect.origin.y    -= insets.top;
    rect.size.width  += (insets.left + insets.right);
    rect.size.height += (insets.top  + insets.bottom);
    return rect;
}

UIKIT_STATIC_INLINE CGRect YT_EdgeInsetsExRectBounds(CGRect rect, UIEdgeInsets insets) {
    rect.origin.x    = insets.left;
    rect.origin.y    = insets.top;
    rect.size.width  = CGRectGetWidth(rect);
    rect.size.height = CGRectGetHeight(rect);
    return rect;
}
