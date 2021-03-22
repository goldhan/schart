//
//  YT_KLineChart+Layouter.m
//  YT_ChartKit
//
//  Created by yt_liyanshan on 2018/9/14.
//

#import "YT_KLineChart+Layouter.h"
#import "YT_KlineChartPrivate.h"

@implementation YT_KLineChart (Layouter)

/** 图标的边缘绘制会被裁剪掉，所以当图表充满layer的时候要设置绘制缩进以免部分被切掉了 最少设置为最宽线的一半 */
- (UIEdgeInsets)chartDrawXInsets {
    return UIEdgeInsetsMake(1, 1, 1, 1);
}

/**
 图标的边缘绘制会被裁剪掉，所以当图表充满layer的时候要设置绘制缩进以免部分被切掉了 最少设置为最宽线的一半
 */
- (UIEdgeInsets)kLineChartlayerYDrawInsets {
    return UIEdgeInsetsMake(1, 1, 1, 1);
}

/**
 图标的边缘绘制会被裁剪掉，所以当图表充满layer的时候要设置绘制缩进以免部分被切掉了 最少设置为最宽线的一半
 */
- (UIEdgeInsets)volumChartlayerYDrawInsetsWithIndex:(NSUInteger)idx {
    return UIEdgeInsetsMake(1, 1, 1, 1);
}

#pragma mark rect

/**
 在 scrollView 中 能用于绘图的窗口 Frame
 */
- (CGRect)chartWindowFrameInScrollView {
    return CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
}


- (CGFloat)chartContentH{
    return self.chartWindowFrameInScrollView.size.height - (self.config.topGap + self.config.riverGap * self.techZBChartContexts.count + self.config.bottomGap);
}

/**
 在 scrollView 中 kLineChart 用于绘图的Layr窗口 Frame
 */
- (CGRect)kLineChartLayerWindowYFrameInScrollView {
    CGFloat y =  self.config.topGap;
    CGFloat h =  self.chartContentH * self.config.kChartWeight / (self.config.kChartWeight + self.config.vChartWeight * self.techZBChartContexts.count);
    return CGRectMake(0, y, 0, h);
}

/**
 在 scrollView 中 volumChart 用于绘图的Layr窗口 Frame
 */
- (CGRect)volumChartLayerWindowYFrameInScrollViewWithIndex:(NSUInteger)idx {
    CGRect rect_p;
    if (idx == 0) {
        rect_p = [self kLineChartLayerWindowYFrameInScrollView];
    }else {
        rect_p = [self volumChartLayerWindowYFrameInScrollViewWithIndex:idx -1];
    }
    return [self volumChartLayerWindowYFrameInScrollViewWithIndex:idx rect:rect_p];
}

- (CGRect)volumChartLayerWindowYFrameInScrollViewWithIndex:(NSUInteger)idx rect:(CGRect)rect{
    CGFloat y = CGRectGetMaxY(rect) + self.config.riverGap;
    CGFloat h = 0;
    if (idx == 0) {
        h = CGRectGetHeight(rect) / self.config.kChartWeight * self.config.vChartWeight;
    }else {
        h  = CGRectGetHeight(rect);
    }
    return CGRectMake(0, y, 0, h);
}

- (void)updateChartRect {
    // 决定 x 方向
    CGRect chartFrame = [self chartWindowFrameInScrollView];
    UIEdgeInsets drawInsets = [self chartDrawXInsets];
    
    // 决定 y 方向
    CGRect kChartFrame = [self kLineChartLayerWindowYFrameInScrollView];
    UIEdgeInsets kDrawInsets = [self kLineChartlayerYDrawInsets];
    kChartFrame = YT_FixChartRectXStd(kChartFrame, chartFrame);
    kDrawInsets = YT_FixChartDrawInsetsXStd(kDrawInsets, drawInsets);

    self.kDrawWindowFrame = kChartFrame;
    self.kDrawInsets = kDrawInsets;
    
    CGRect vChartFrame = kChartFrame;
    UIEdgeInsets vDrawInsets = kDrawInsets;
    
    for (int i = 0; i < self.techZBChartContexts.count; i ++) {
        YT_TechZBChartContext * cxt = [self.techZBChartContexts objectAtIndex:i];
        vChartFrame = [self volumChartLayerWindowYFrameInScrollViewWithIndex:i rect:vChartFrame];
        vDrawInsets = [self volumChartlayerYDrawInsetsWithIndex:i];
        cxt.drawWindowFrame = YT_FixChartRectXStd(vChartFrame, chartFrame);
        cxt.drawInsets = YT_FixChartDrawInsetsXStd(vDrawInsets, drawInsets);
    }

    chartFrame.origin.y =  CGRectGetMinY(kChartFrame);
    chartFrame.size.height = CGRectGetMaxY(vChartFrame) - chartFrame.origin.y;
    
    drawInsets.top = kDrawInsets.top;
    drawInsets.bottom = vDrawInsets.bottom;
    
    self.chartDrawWindowFrame = UIEdgeInsetsInsetRect(chartFrame, drawInsets);
    self.chartDrawInsets = drawInsets;
}

- (CGRect)lableKLineIndexFrame {
    CGRect chartFrame = self.kDrawWindowFrame;
    CGRect rect_scrollView = UIEdgeInsetsInsetRect(self.scrollView.frame, self.scrollView.contentInset);
    chartFrame.origin.x += rect_scrollView.origin.x;
    chartFrame.origin.y += rect_scrollView.origin.y;

    CGFloat height = self.config.lableKLineIndexFont.lineHeight;
    CGRect labelRect = CGRectMake(chartFrame.origin.x, chartFrame.origin.y - height, chartFrame.size.width, height);

    return labelRect;
}

- (CGRect)lableVolumIndexFrameAtIndex:(NSInteger)index {
    CGRect chartFrame = self.techZBChartContexts[index].drawWindowFrame;
    CGRect rect_scrollView = UIEdgeInsetsInsetRect(self.scrollView.frame, self.scrollView.contentInset);
    chartFrame.origin.x += rect_scrollView.origin.x;
    chartFrame.origin.y += rect_scrollView.origin.y;

    CGFloat height = self.config.lableVolumIndexFont.lineHeight;
    CGRect labelRect = CGRectMake(chartFrame.origin.x, chartFrame.origin.y, chartFrame.size.width, height);
    return labelRect;
}

/// 时间轴文字绘制位置
- (CGRect)gridAxisXDateTextRect {
    CGRect rect = self.kDrawWindowFrame;
    rect.size.height = self.config.riverGap;
    rect.origin.y = CGRectGetMaxY(self.kDrawWindowFrame);
    return rect;
}

@end
