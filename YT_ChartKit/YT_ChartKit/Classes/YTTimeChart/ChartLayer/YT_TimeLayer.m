//
//  YT_TimeLayer.m
//  YT_ChartKit
//
//  Created by ChenRui Hu on 2018/8/21.
//

#import "YT_TimeLayer.h"
#import "YT_TimePulsingLayer.h"
#import "YT_TimeChart+Calculator.h"
#import "UIBezierPath+YT_TimeChart.h"

@interface YTHHLayer : CAShapeLayer

@end

@implementation YTHHLayer

- (void)drawInContext:(CGContextRef)ctx {
    
    // 消除锯齿
    CGContextSetShouldAntialias(ctx, YES);
    
}

@end


@interface YT_TimeLayer ()

/** 横向网格虚线 */
@property (nonatomic, strong) CAShapeLayer *yTimeDashLayer;

/** 分时线 */
@property (nonatomic, strong) CAShapeLayer *timeLineLayer;

/** 分时线填充 */
@property (nonatomic, strong) CAShapeLayer *timeLineFillLayer;

/** 分时线填充渐变色 */
@property (nonatomic, strong) CAGradientLayer *timeGradientLayer;

/** 分时线闪动点视图 */
@property (nonatomic, strong) YT_TimePulsingLayer *pulsingLayer;

/** 分时均线 */
@property (nonatomic, strong) YTHHLayer *avgTimeLineLayer;

@end

@implementation YT_TimeLayer

- (instancetype)init {
    if (self = [super init]) {
        [self sublayerInitialization];
    }
    return self;
}

- (void)sublayerInitialization {
    _yTimeDashLayer = [CAShapeLayer layer];
    [self addSublayer:_yTimeDashLayer];
    
    _timeLineLayer = [CAShapeLayer layer];
    [self addSublayer:_timeLineLayer];
    
    _timeLineFillLayer = [CAShapeLayer layer];
    _timeLineFillLayer.lineWidth = 0;
    _timeLineFillLayer.strokeColor = [UIColor clearColor].CGColor;
    _timeLineFillLayer.fillColor = [UIColor whiteColor].CGColor;
    [self insertSublayer:_timeLineFillLayer atIndex:0];
    
    _timeGradientLayer = [CAGradientLayer layer];
//    _timeGradientLayer.locations = @[@0, @1];
    _timeGradientLayer.startPoint = CGPointMake(0, 0);
    _timeGradientLayer.endPoint = CGPointMake(0, 1.0);
    [self addSublayer:_timeGradientLayer];
    
    _pulsingLayer = [YT_TimePulsingLayer layer];
    [self addSublayer:_pulsingLayer];
    
    _avgTimeLineLayer = [YTHHLayer layer];
    _avgTimeLineLayer.contentsScale = [UIScreen mainScreen].scale;
    [self addSublayer:_avgTimeLineLayer];
}

- (void)configLayer {
    _yTimeDashLayer.fillColor = [UIColor clearColor].CGColor;
    _yTimeDashLayer.strokeColor = _dashLineColor.CGColor;
    _yTimeDashLayer.lineWidth = _dashLineWidth;
    _yTimeDashLayer.lineDashPattern = _dashLinePattern;
    
    _timeLineLayer.fillColor = [UIColor clearColor].CGColor;
    _timeLineLayer.strokeColor = _timeLineColor.CGColor;
    _timeLineLayer.lineWidth = _timeLineWith;
    _timeLineLayer.lineJoin = kCALineJoinRound;
    _timeLineLayer.lineCap = kCALineCapRound;
    
    _timeLineFillLayer.strokeColor = [UIColor clearColor].CGColor;
    _timeLineFillLayer.fillColor = _timeLineFillColor.CGColor;
    
    if (_timeGradientColors.count > 0) {
        _timeGradientLayer.colors = _timeGradientColors;
    }
    
    _pulsingLayer.standpointColor = _timeLineColor;
    
    _avgTimeLineLayer.fillColor = [UIColor clearColor].CGColor;
    _avgTimeLineLayer.strokeColor = _avgTimeLineColor.CGColor;
    _avgTimeLineLayer.lineWidth = _avgTimeLineWidth;
    _avgTimeLineLayer.lineJoin = kCALineJoinRound;
    _avgTimeLineLayer.lineCap = kCALineCapRound;
}

- (void)updateLayout:(CGRect)frame {
    self.frame = frame;
    _timeLineFillLayer.frame = (CGRect){.size.width = self.bounds.size.width, .size.height = CGRectGetMaxY(frame)};
    _timeGradientLayer.frame = _timeLineFillLayer.frame;
}

/** 绘制分时图 */
- (void)drawTimeChart:(id)timeChart {
    YT_TimeChart *chart = (YT_TimeChart *)timeChart;
    
    CGPeakValue peak = chart.timePeakValue;
    CG_AxisConvertBlock yAxisCallback = CG_YaxisConvertBlock(peak, chart.timeRect);
    CGFloat halfTimeLineWith = _timeLineWith * 0.5;
    id<YT_TimeProtocol>firstObj = chart.dataArray.firstObject;
    CGFloat firstPointY = yAxisCallback(chart.propData.yt_originPrice) + halfTimeLineWith;
    CGFloat avgFirstPointY = yAxisCallback(firstObj.yt_timeAveragePrice) + halfTimeLineWith;
    
    UIBezierPath *timePath = [UIBezierPath bezierPath];
    UIBezierPath *avgPath = [UIBezierPath bezierPath];
    [timePath moveToPoint:CGPointMake(chart.timeRect.origin.x, firstPointY)];
    [avgPath moveToPoint:CGPointMake(chart.timeRect.origin.x, avgFirstPointY)];
    [chart.dataArray enumerateObjectsUsingBlock:^(id<YT_TimeProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat centerX = [chart getCenterXWithIndex:idx];
        CGFloat pointY = yAxisCallback(obj.yt_timePrice) + halfTimeLineWith;
        CGFloat avgPointY = yAxisCallback(obj.yt_timeAveragePrice) + halfTimeLineWith;
        [timePath addLineToPoint:CGPointMake(centerX, pointY)];
        [avgPath addLineToPoint:CGPointMake(centerX, avgPointY)];
    }];
    
    _timeLineLayer.path = timePath.CGPath;
    _avgTimeLineLayer.path = avgPath.CGPath;
    [_avgTimeLineLayer setNeedsDisplay];
    
    id<YT_TimeProtocol>lastObj = chart.dataArray.lastObject;
    CGFloat lastCenterX = [chart getCenterXWithIndex:chart.dataArray.count - 1];
    UIBezierPath *fillPath = [UIBezierPath bezierPathWithCGPath:timePath.CGPath];
    [fillPath addLineToPoint:CGPointMake(lastCenterX, CGRectGetMaxY(chart.timeRect))];
    [fillPath addLineToPoint:CGPointMake(chart.timeRect.origin.x, CGRectGetMaxY(chart.timeRect))];
    [fillPath closePath];
    _timeLineFillLayer.path = fillPath.CGPath;
    if (_timeGradientColors.count > 0) {
        _timeGradientLayer.mask = _timeLineFillLayer;
    }
    
    CGFloat lastPointY = yAxisCallback(lastObj.yt_timePrice) + halfTimeLineWith;
    _pulsingLayer.position = CGPointMake(lastCenterX, lastPointY);
    [_pulsingLayer startAnimating];
    
    [self drawTimeDashLayer:chart];
}

/** 绘制五日分时图 */
- (void)drawFiveTimeChart:(id)timeChart {
    YT_TimeChart *chart = (YT_TimeChart *)timeChart;
    
    CGPeakValue peak = chart.timePeakValue;
    CG_AxisConvertBlock yAxisCallback = CG_YaxisConvertBlock(peak, chart.timeRect);
    CGFloat halfTimeLineWith = _timeLineWith * 0.5;
    id<YT_TimeProtocol>firstObj = chart.dataArray.firstObject;
    CGFloat firstPointY = yAxisCallback(chart.propData.yt_originPrice) + halfTimeLineWith;
    CGFloat avgFirstPointY = yAxisCallback(firstObj.yt_timeAveragePrice) + halfTimeLineWith;
    
    UIBezierPath *timePath = [UIBezierPath bezierPath];
    UIBezierPath *avgPath = [UIBezierPath bezierPath];
    UIBezierPath *fillPath = [UIBezierPath bezierPath];
    [timePath moveToPoint:CGPointMake(chart.timeRect.origin.x, firstPointY)];
    [fillPath moveToPoint:CGPointMake(chart.timeRect.origin.x, firstPointY)];
    [avgPath moveToPoint:CGPointMake(chart.timeRect.origin.x, avgFirstPointY)];
    
    // 时间轴
    chart.fiveDateArray = [NSMutableArray array];
    __block NSInteger dateFlag = 0;
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [chart.dataArray enumerateObjectsUsingBlock:^(id<YT_TimeProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat centerX = [chart getCenterXWithIndex:idx];
        CGFloat pointY = yAxisCallback(obj.yt_timePrice) + halfTimeLineWith;
        CGFloat avgPointY = yAxisCallback(obj.yt_timeAveragePrice) + halfTimeLineWith;
        NSInteger day = [[calendar components:NSCalendarUnitDay fromDate:obj.yt_timeDate] day];
        if (day && (dateFlag != day)) {
            dateFlag = day;
            [timePath moveToPoint:CGPointMake(centerX, pointY)];
            [avgPath moveToPoint:CGPointMake(centerX, avgPointY)];
            
            // 时间
            NSString *text = [chart timestringWithDate:obj.yt_timeDate format:@"MM-dd"];
            [chart.fiveDateArray addObject:text];
        } else {
            [timePath addLineToPoint:CGPointMake(centerX, pointY)];
            [avgPath addLineToPoint:CGPointMake(centerX, avgPointY)];
        }
        [fillPath addLineToPoint:CGPointMake(centerX, pointY)];
    }];
    _timeLineLayer.path = timePath.CGPath;
    _avgTimeLineLayer.path = avgPath.CGPath;
    
    id<YT_TimeProtocol>lastObj = chart.dataArray.lastObject;
    CGFloat lastCenterX = [chart getCenterXWithIndex:chart.dataArray.count - 1];
    [fillPath addLineToPoint:CGPointMake(lastCenterX, CGRectGetMaxY(chart.timeRect))];
    [fillPath addLineToPoint:CGPointMake(chart.timeRect.origin.x, CGRectGetMaxY(chart.timeRect))];
    [fillPath closePath];
    _timeLineFillLayer.path = fillPath.CGPath;
    if (_timeGradientColors.count > 0) {
        _timeGradientLayer.mask = _timeLineFillLayer;
    }
    
    CGFloat lastPointY = yAxisCallback(lastObj.yt_timePrice) + halfTimeLineWith;
    _pulsingLayer.position = CGPointMake(lastCenterX, lastPointY);
    [_pulsingLayer startAnimating];
    
    [self drawTimeDashLayer:chart];
}

/// 绘制横向网格虚线
- (void)drawTimeDashLayer:(YT_TimeChart *)timeChart {
    UIBezierPath *dash = [UIBezierPath bezierPath];
    CGFloat originY = timeChart.timeRect.origin.y + timeChart.configuration.gridLineWidth * 0.5;
    CGFloat ratioY = originY + timeChart.changeRatioPeakValue.max / CGGetPeakDistanceValue(timeChart.changeRatioPeakValue) * timeChart.timeRect.size.height;
    [dash addHorizontalLine:CGPointMake(timeChart.timeRect.origin.x, ratioY) len:timeChart.timeRect.size.width];
    _yTimeDashLayer.path = dash.CGPath;
}
@end
