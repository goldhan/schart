//
//  YT_TimeOverlayLayer.m
//  YT_ChartKit
//
//  Created by ChenRui Hu on 2018/8/27.
//

#import "YT_TimeOverlayLayer.h"
#import "YT_TimeChart+Calculator.h"
#import "UIBezierPath+YT_TimeChart.h"

@interface YT_TimeOverlayLayer ()

/** 分时叠加线1 */
@property (nonatomic, strong) CAShapeLayer *overlayLineLayer;

/** 分时叠加线2 */
@property (nonatomic, strong) CAShapeLayer *otherLineLayer;

@end

@implementation YT_TimeOverlayLayer
- (instancetype)init {
    if (self = [super init]) {
        [self sublayerInitialization];
    }
    return self;
}

- (void)sublayerInitialization {
    _overlayLineLayer = [CAShapeLayer layer];
    [self addSublayer:_overlayLineLayer];
    
    _otherLineLayer = [CAShapeLayer layer];
    [self addSublayer:_otherLineLayer];
}

- (void)configLayer {
    _overlayLineLayer.fillColor = [UIColor clearColor].CGColor;
    _overlayLineLayer.strokeColor = _overlayLineColor.CGColor;
    _overlayLineLayer.lineWidth = _overlayLineWith;
    _overlayLineLayer.lineJoin = kCALineJoinRound;
    _overlayLineLayer.lineCap = kCALineCapRound;
    _overlayLineLayer.lineDashPattern = @[@2, @1];
    
    _otherLineLayer.fillColor = [UIColor clearColor].CGColor;
    _otherLineLayer.strokeColor = _otherLineColor.CGColor;
    _otherLineLayer.lineWidth = _overlayLineWith;
    _otherLineLayer.lineJoin = kCALineJoinRound;
    _otherLineLayer.lineCap = kCALineCapRound;
    _otherLineLayer.lineDashPattern = @[@3, @3];
}

/** 绘制叠加层 */
- (void)drawOverlayLine:(id)timeChart {
    YT_TimeChart *chart = (YT_TimeChart *)timeChart;
    
    CGPeakValue peak = chart.changeRatioPeakValue;
    CG_AxisConvertBlock yAxisCallback = CG_YaxisConvertBlock(peak, chart.timeRect);
    CGFloat halfTimeLineWith = _overlayLineWith * 0.5;
    // 叠加第一条
    if (chart.overlayDataArray.count > 0) {
        id<YT_TimeOverlayProtocol>firstObj = chart.overlayDataArray.firstObject;
        
        CGFloat firstPointY = yAxisCallback(firstObj.yt_overlayChangeRatio * 100) + halfTimeLineWith;
        UIBezierPath *timePath = [UIBezierPath bezierPath];
        [timePath moveToPoint:CGPointMake(chart.timeRect.origin.x, firstPointY)];
        [chart.overlayDataArray enumerateObjectsUsingBlock:^(id<YT_TimeOverlayProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat centerX = [chart getCenterXWithIndex:idx];
            CGFloat pointY = yAxisCallback(obj.yt_overlayChangeRatio * 100) + halfTimeLineWith;
            [timePath addLineToPoint:CGPointMake(centerX, pointY)];
        }];
        _overlayLineLayer.path = timePath.CGPath;
    } else {
        UIBezierPath *timePath = [UIBezierPath bezierPath];
        _overlayLineLayer.path = timePath.CGPath;
    }
    
    // 叠加第二条
    if (chart.overlayOtherDataArray.count > 1) {
        id<YT_TimeOverlayOtherProtocol>firstObj = chart.overlayOtherDataArray.firstObject;
        
        CGFloat otherFirstPointY = yAxisCallback(firstObj.yt_overlayOtherChangeRatio * 100) + halfTimeLineWith;
        UIBezierPath *otherPath = [UIBezierPath bezierPath];
        [otherPath moveToPoint:CGPointMake(chart.timeRect.origin.x, otherFirstPointY)];
        [chart.overlayOtherDataArray enumerateObjectsUsingBlock:^(id<YT_TimeOverlayOtherProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat centerX = [chart getCenterXWithIndex:idx];
            CGFloat otherPointY = yAxisCallback(obj.yt_overlayOtherChangeRatio * 100) + halfTimeLineWith;
            [otherPath  addLineToPoint:CGPointMake(centerX, otherPointY)];
        }];
        _otherLineLayer.path = otherPath.CGPath;
    } else {
        UIBezierPath *timePath = [UIBezierPath bezierPath];
        _otherLineLayer.path = timePath.CGPath;
    }
}
@end
