//
//  YT_TradeLayer.m
//  YT_ChartKit
//
//  Created by ChenRui Hu on 2018/8/27.
//

#import "YT_TradeLayer.h"
#import "YT_TimeChart+Calculator.h"
#import "UIBezierPath+YT_TimeChart.h"

@interface YT_TradeLayer ()

/** 买线 */
@property (nonatomic, strong) CAShapeLayer *buyLineLayer;

/** 卖线 */
@property (nonatomic, strong) CAShapeLayer *sellLineLayer;

@end

@implementation YT_TradeLayer
- (instancetype)init {
    if (self = [super init]) {
        [self sublayerInitialization];
    }
    return self;
}

- (void)sublayerInitialization {
    _buyLineLayer = [CAShapeLayer layer];
    [self addSublayer:_buyLineLayer];
    
    _sellLineLayer = [CAShapeLayer layer];
    [self addSublayer:_sellLineLayer];
}

- (void)configLayer {
    _buyLineLayer.fillColor = [UIColor clearColor].CGColor;
    _buyLineLayer.strokeColor = _buyLineColor.CGColor;
    _buyLineLayer.lineWidth = _tradeLineWidth;
    _buyLineLayer.lineJoin = kCALineJoinRound;
    _buyLineLayer.lineCap = kCALineCapRound;
    
    _sellLineLayer.fillColor = [UIColor clearColor].CGColor;
    _sellLineLayer.strokeColor = _sellLineColor.CGColor;
    _sellLineLayer.lineWidth = _tradeLineWidth;
    _sellLineLayer.lineJoin = kCALineJoinRound;
    _sellLineLayer.lineCap = kCALineCapRound;
}

/** 绘制买卖附图 */
- (void)drawTradeChart:(id)timeChart {
    YT_TimeChart *chart = (YT_TimeChart *)timeChart;
    
    CGPeakValue peak = [chart.dataArray yt_peakValueBySel:@selector(yt_timeVolume)];
    CG_AxisConvertBlock yAxisCallback = CG_YaxisConvertBlock(peak, chart.volumeRect);
    
    UIBezierPath *buyPath = [UIBezierPath bezierPath];
    UIBezierPath *sellPath = [UIBezierPath bezierPath];
    
    [chart.dataArray enumerateObjectsUsingBlock:^(id<YT_TimeProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat originX = [chart getOriginXWithIndex:idx];
        CGFloat pointY = yAxisCallback(obj.yt_timeVolume);
        CGPoint start = CGPointZero;
        CGPoint end = CGPointZero;
        if (0 == idx) {
            start = CGPointMake(originX, pointY);
        }
        NSInteger previousIdx = !idx ?: idx - 1;
        CGFloat previousPrice = chart.dataArray[previousIdx].yt_timePrice;
        CGFloat currentPrice = obj.yt_timePrice;
        if (currentPrice > previousPrice) {
            [buyPath addLine:start end:end];
        } else {
            [sellPath addLine:start end:end];
        }
    }];
    _buyLineLayer.path = buyPath.CGPath;
    _sellLineLayer.path = sellPath.CGPath;
}
@end
