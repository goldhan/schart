//
//  YT_VolumeLayer.m
//  YT_ChartKit
//
//  Created by ChenRui Hu on 2018/8/22.
//

#import "YT_VolumeLayer.h"
#import "YT_TimeChart+Calculator.h"
#import "UIBezierPath+YT_TimeChart.h"

@interface YT_VolumeLayer () {
    CGRect _timeRect;    // 分时图rect
    CGRect _volumeRect;  // 成交量图rect
}

/** 成交量涨条形图 */
@property (nonatomic, strong) CAShapeLayer *volumeRiseLayer;

/** 成交量跌条形图 */
@property (nonatomic, strong) CAShapeLayer *volumeFallLayer;

/** 成交量平条形图 */
@property (nonatomic, strong) CAShapeLayer *volumeFlatLayer;

@end

@implementation YT_VolumeLayer

- (instancetype)init {
    if (self = [super init]) {
        [self sublayerInitialization];
    }
    return self;
}

- (void)sublayerInitialization {
    
    _volumeRiseLayer = [CAShapeLayer layer];
    _volumeRiseLayer.strokeColor = [UIColor clearColor].CGColor;
    _volumeRiseLayer.lineWidth = 0;
    [self addSublayer:_volumeRiseLayer];
    
    _volumeFallLayer = [CAShapeLayer layer];
    _volumeFallLayer.strokeColor = [UIColor clearColor].CGColor;
    _volumeFallLayer.lineWidth = 0;
    [self addSublayer:_volumeFallLayer];
    
    _volumeFlatLayer = [CAShapeLayer layer];
    _volumeFlatLayer.strokeColor = [UIColor clearColor].CGColor;
    _volumeFlatLayer.lineWidth = 0;
    [self addSublayer:_volumeFlatLayer];
}

- (void)configLayer {
    _volumeRiseLayer.fillColor = _volumeRiseColor.CGColor;
    _volumeFallLayer.fillColor = _volumeFallColor.CGColor;
    _volumeFlatLayer.fillColor = _volumeFlatColor.CGColor;
}

/** 绘制成交量条形图 */
- (void)drawVolumeChart:(id)timeChart {
    YT_TimeChart *chart = (YT_TimeChart *)timeChart;
    
    CGPeakValue peak = [chart.dataArray yt_peakValueBySel:@selector(yt_timeVolume)];
    CG_AxisConvertBlock yAxisCallback = CG_YaxisConvertBlock(peak, chart.volumeRect);
    
    UIBezierPath *risePath = [UIBezierPath bezierPath];
    UIBezierPath *fallPath = [UIBezierPath bezierPath];
    UIBezierPath *flatPath = [UIBezierPath bezierPath];
    [chart.dataArray enumerateObjectsUsingBlock:^(id<YT_TimeProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat originX = [chart getOriginXWithIndex:idx];
        CGFloat pointY = yAxisCallback(obj.yt_timeVolume);
        CGRect rect = CGRectMake(originX, pointY, chart.configuration.volumeBarBodyWidth, CGRectGetMaxY(chart.volumeRect) - pointY);
        NSInteger previousIdx = idx == 0 ? 0 : idx - 1;
        CGFloat previousPrice = chart.dataArray[previousIdx].yt_timePrice;
        CGFloat currentPrice = obj.yt_timePrice;
        if (currentPrice > previousPrice) {
            [risePath addRect:rect];
        } else if (currentPrice < previousPrice) {
            [fallPath addRect:rect];
        } else {
            [flatPath addRect:rect];
        }
    }];
    _volumeRiseLayer.path = risePath.CGPath;
    _volumeFallLayer.path = fallPath.CGPath;
    _volumeFlatLayer.path = flatPath.CGPath;
}

@end
