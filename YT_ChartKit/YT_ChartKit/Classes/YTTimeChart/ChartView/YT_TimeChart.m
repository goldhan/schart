//
//  CoreGraphics_demo
//
//  Created by zhanghao on 2018/7/6.
//  Copyright © 2018年 snail-z. All rights reserved.
//

#import "YT_TimeChart.h"
#import "YT_TimeChart+Calculator.h"
#import "YT_ChartUtilities.h"
#import "UIBezierPath+YT_TimeChart.h"

#import "YT_TimeChart+YT_TimeTextLayer.h"


@implementation YT_TimeChart

#pragma mark - SublayerInitialization

- (void)sublayerInitialization {
    _timeGridLayer = [YT_TimeGridLayer layer];
    [self.contentChartLayer addSublayer:_timeGridLayer];
    
    _timeLayer = [YT_TimeLayer layer];
    [self.contentChartLayer addSublayer:_timeLayer];
    
    _volumeLayer = [YT_VolumeLayer layer];
    [self.contentChartLayer addSublayer:_volumeLayer];
    
    // 初始化文本
    [self sublayerToTextInitialization];
    
    _crosswireView = [YT_CrosswireView new];
    _crosswireView.fadeHidden = YES;
    [self addSubview:_crosswireView];
}

#pragma mark - Update sublayer

- (void)updateSublayerAppearance {
    _timeGridLayer.gridLineColor = self.configuration.gridLineColor;
    _timeGridLayer.gridLineWidth = self.configuration.gridLineWidth;
    _timeGridLayer.yAxisTimeSegments = self.configuration.yAxisTimeSegments;
    _timeGridLayer.yAxisVolumeSegments = self.configuration.yAxisVolumeSegments;
    _timeGridLayer.xAxisDateSegments = self.dateArray.count;
    _timeGridLayer.maxDataCount = self.configuration.maxDataCount;
    [_timeGridLayer configLayer];
    
    _timeLayer.dashLineColor = self.configuration.dashLineColor;
    _timeLayer.dashLineWidth = self.configuration.dashLineWidth;
    _timeLayer.dashLinePattern = self.configuration.dashLinePattern;
    _timeLayer.timeLineColor = self.configuration.timeLineColor;
    _timeLayer.timeLineWith = self.configuration.timeLineWith;
    _timeLayer.timeLineFillColor = self.configuration.timeLineFillColor;
    _timeLayer.timeGradientColors = self.configuration.timeGradientColors;
    _timeLayer.avgTimeLineColor = self.configuration.avgTimeLineColor;
    _timeLayer.avgTimeLineWidth = self.configuration.avgTimeLineWidth;
    [_timeLayer configLayer];

    _volumeLayer.volumeRiseColor = self.configuration.volumeRiseColor;
    _volumeLayer.volumeFallColor = self.configuration.volumeFallColor;
    _volumeLayer.volumeFlatColor = self.configuration.volumeFlatColor;
    [_volumeLayer configLayer];
    
    _crosswireView.textFont = self.configuration.textFont;
    _crosswireView.textColor = self.configuration.crosswireTextColor;
    _crosswireView.crosswireLineWidth = self.configuration.crosswireLineWidth;
    _crosswireView.crosswireLineColor = self.configuration.crosswireLineColor;
    _crosswireView.bdateHidden = self.configuration.crosswireDateHidden;
    _crosswireView.bcentralPointMark = self.configuration.crosswireCentralPointMark;
}

#pragma mark - Update drawing layout

- (void)updateDrawRect {
    _chartRect = (CGRect){.origin.y = self.configuration.topGap, .size.width = self.bounds.size.width, .size.height = self.bounds.size.height - self.configuration.topGap - self.configuration.dateGap};
    _timeRect = (CGRect){.origin.y = self.chartRect.origin.y, .size.width = self.chartRect.size.width, .size.height = self.chartRect.size.height * self.configuration.proportionOfHeight};
    _riverRect = (CGRect){.origin.y = self.chartRect.origin.y + self.timeRect.size.height, .size.width = self.chartRect.size.width, .size.height = self.configuration.riverGap};
    _volumeRect = (CGRect){.origin.y = CGRectGetMaxY(self.riverRect), .size.width = self.chartRect.size.width, .size.height = self.chartRect.size.height - self.timeRect.size.height - self.riverRect.size.height};
}

- (void)updateLayout {
    [_timeLayer updateLayout:self.timeRect];
    _crosswireView.frame = self.chartRect;
    _crosswireView.separationRect = CGRectMake(0, self.timeRect.size.height, self.timeRect.size.width, self.configuration.riverGap);
    // 布局文本
    [self textlayerUpdateLayout];
    
    NSInteger maxCount = self.configuration.maxDataCount;
    CGFloat allGap = (maxCount - 1) * self.configuration.volumeBarGap;
    CGFloat oneWidth = (self.timeRect.size.width - allGap) / (CGFloat)maxCount;
    [self.configuration setValue:@(oneWidth) forKey:NSStringFromSelector(@selector(volumeBarBodyWidth))];
}

#pragma mark - Draw charts

- (void)drawChart {
    if (self.dataArray) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        [self layoutIfNeeded];
        [self updateDrawRect];
        [self updateLayout];
        [self updateSublayerAppearance];
        
        // 绘制网格
        [_timeGridLayer updateLayerWithRect:self.timeRect :self.volumeRect :CGRectZero];
        
        // 绘制文本
        [self drawTimeText];
        
        // 绘制分时
        if (self.configuration.chartType == YT_TimeChartTypeDefault) {
            [_timeGridLayer drawDateLines:self];
            [_timeLayer drawTimeChart:self];
            [self drawDateText:self.riverRect];
        } else if (self.configuration.chartType == YT_TimeChartTypeFiveDay) {
            [_timeGridLayer drawFiveDateLines];
            [_timeLayer drawFiveTimeChart:self];
            [self drawFiveDateText:self.riverRect]; // 注：一定先绘制分时，在 drawFiveTimeChart 计算了日期 fiveDateArray
        }
        
        // 绘制成交量文字
        [self drawVolumeText];
        // 绘制成交量
        [_volumeLayer drawVolumeChart:self];
        
        [CATransaction commit];
    } else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        [self layoutIfNeeded];
        [self updateDrawRect];
        [self updateSublayerAppearance];
        // 绘制网格
        [_timeGridLayer updateLayerWithRect:self.timeRect :self.volumeRect :CGRectZero];
        [CATransaction commit];
    }
}

#pragma mark - GestureInitialization / 手势管理

- (void)gestureInitialization {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.delegate = self;
    [self addGestureRecognizer:singleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    longPress.delegate = self;
    [self addGestureRecognizer:longPress];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if (!self.crosswireView.fadeHidden) {
            self.crosswireView.fadeHidden = YES;
            return YES;
        }
    }
    CGPoint p = [gestureRecognizer locationInView:self];
    return CGRectContainsPoint(self.chartRect, p) && !CGRectContainsPoint(self.riverRect, p);
}

- (void)singleTap:(UITapGestureRecognizer *)g {
    if ([self.delegate respondsToSelector:@selector(stockTimeChartDidSingleTap:)]) {
        [self.delegate stockTimeChartDidSingleTap:self];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)g {
    if (!self.dataArray) return;
    
    switch (g.state) {
        case UIGestureRecognizerStateBegan: {
            self.crosswireView.fadeHidden = NO;
            CGPoint p = [g locationInView:self];
            [self updateCrosswireLayerWithPoint:p];
        } break;
        case UIGestureRecognizerStateEnded: {
            self.crosswireView.fadeHidden = YES;
            if ([self.delegate respondsToSelector:@selector(stockTimeChartDidLongPresEnded:)]) {
                [self.delegate stockTimeChartDidLongPresEnded:self];
            }
        } break;
        case UIGestureRecognizerStateChanged: {
            CGPoint p = [g locationInView:self];
            [self updateCrosswireLayerWithPoint:p];
        } break;
        default: break;
    }
}

- (void)updateCrosswireLayerWithPoint:(CGPoint)p {
    if (CGRectContainsPoint(self.timeRect, p)) { // 获取分时区域对应值
        CGFloat mapValue = [self mapRefValueWithPointY:p.y peak:self.timePeakValue inRect:self.timeRect];
        CGFloat mapCrValue = [self mapRefValueWithPointY:p.y peak:self.changeRatioPeakValue inRect:self.timeRect];
        _crosswireView.mapYaixsText = [NSString stringWithFormat:@"%.2f", mapValue];
        if (CG_Float2fIsZero(mapCrValue)) mapCrValue = 0.00;
        _crosswireView.mapYaixsSubjoinText = [NSString stringWithFormat:@"%.2f%%", mapCrValue];
    }
    if (CGRectContainsPoint(self.volumeRect, p)) { // 获取成交量区域对应值
        CGPeakValue peak = [self.dataArray yt_peakValueBySel:@selector(yt_timeVolume)];
        CGFloat mapValue = [self mapRefValueWithPointY:p.y peak:peak inRect:self.volumeRect];
        _crosswireView.mapYaixsText = [YT_TimeChart axisStringWithValue:mapValue peak:peak];
        _crosswireView.mapYaixsSubjoinText = nil;
    }
    p.x -= self.timeRect.origin.x; p.y -= self.timeRect.origin.y;
    NSInteger index = [self mapIndexWithPointX:p.x]; // 求对应的时间
    if (!_crosswireView.bdateHidden) {
        id<YT_TimeProtocol>obj = self.dataArray[index];
        NSString *dateFormat = (self.configuration.chartType == YT_TimeChartTypeDefault) ?  @"HH:mm" : @"MM-dd HH:mm";
        NSString *mapText = [self timestringWithDate:obj.yt_timeDate format:dateFormat];
        _crosswireView.mapIndexText = mapText;
    }
    CGFloat centerX = [self getCenterXWithIndex:index]; // 取中心值
    _crosswireView.spotOfTouched = p;
    
    CGFloat originY = self.timeRect.origin.y + self.configuration.gridLineWidth * 0.5;
    CGFloat ratioY = originY + self.changeRatioPeakValue.max / CGGetPeakDistanceValue(self.changeRatioPeakValue) * self.timeRect.size.height;
    UIColor *(^callbackColor)(CGFloat) = ^(CGFloat y) {
        if (y < ratioY) {
            return self.configuration.crosswireBackRiseColor;
        } else if (y > ratioY) {
            return self.configuration.crosswireBackFallColor;
        }
        return [UIColor darkGrayColor];
    };
    _crosswireView.textBackgroundColor = callbackColor(p.y + self.timeRect.origin.y);
    _crosswireView.dateBackgroundColor = self.configuration.crosswireBackDateColor;
    _crosswireView.centralPoint = CGPointMake(centerX - self.timeRect.origin.x, p.y);
    [_crosswireView updateContents];
    
    if ([self.delegate respondsToSelector:@selector(stockTimeChart:didLongPresOfIndex:)]) {
        [self.delegate stockTimeChart:self didLongPresOfIndex:index];
    }
}

@end
