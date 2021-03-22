//
//  YT_TimeGridLayer.m
//  YT_ChartKit
//
//  Created by ChenRui Hu on 2018/8/20.
//

#import "YT_TimeGridLayer.h"
#import "UIBezierPath+YT_TimeChart.h"
#import "YT_TimeChart+Calculator.h"

@interface YT_TimeGridLayer () {
    CGRect _timeRect;    // 分时图rect
    CGRect _volumeRect;  // 成交量图rect
    CGRect _tradeRect;   // 买卖图reat
}

/** 横向网格线(分时区域) */
@property (nonatomic, strong) CAShapeLayer *yTimeGridLayer;

/** 横向网格线(VOL区域区域) */
@property (nonatomic, strong) CAShapeLayer *yVolumeGridLayer;

/** 横向网格线(买卖区域区域) */
@property (nonatomic, strong) CAShapeLayer *yTradeGridLayer;

/** 纵向网格线(中间，绘制条数与分隔时间有关) */
@property (nonatomic, strong) CAShapeLayer *xDateGridLayer;

/** 纵向网格线(用于封闭网格两端的边框线) */
@property (nonatomic, strong) CAShapeLayer *borderGridLayer;

@end

@implementation YT_TimeGridLayer
- (instancetype)init {
    if (self = [super init]) {
        [self sublayerInitialization];
    }
    return self;
}

#pragma mark - SublayerInitialization

- (void)sublayerInitialization {
    _yTimeGridLayer = [CAShapeLayer layer];
    [self addSublayer:_yTimeGridLayer];

    _yVolumeGridLayer = [CAShapeLayer layer];
    [self addSublayer:_yVolumeGridLayer];
    
    _yTradeGridLayer = [CAShapeLayer layer];
    [self addSublayer:_yTradeGridLayer];
    
    _xDateGridLayer = [CAShapeLayer layer];
    [self addSublayer:_xDateGridLayer];
    
    _borderGridLayer = [CAShapeLayer layer];
    [self addSublayer:_borderGridLayer];
}

- (void)configLayer {
    // 网格线配制
    _yTimeGridLayer.fillColor = [UIColor clearColor].CGColor;
    _yTimeGridLayer.strokeColor = self.gridLineColor.CGColor;
    _yTimeGridLayer.lineWidth = self.gridLineWidth;

    _yVolumeGridLayer.fillColor = _yTimeGridLayer.fillColor;
    _yVolumeGridLayer.strokeColor = _yTimeGridLayer.strokeColor;
    _yVolumeGridLayer.lineWidth = _yTimeGridLayer.lineWidth;
    
    _yTradeGridLayer.fillColor = _yTimeGridLayer.fillColor;
    _yTradeGridLayer.strokeColor = _yTimeGridLayer.strokeColor;
    _yTradeGridLayer.lineWidth = _yTimeGridLayer.lineWidth;
    
    _xDateGridLayer.fillColor = _yTimeGridLayer.fillColor;
    _xDateGridLayer.strokeColor = _yTimeGridLayer.strokeColor;
    _xDateGridLayer.lineWidth = _yTimeGridLayer.lineWidth;
    
    _borderGridLayer.fillColor = _yTimeGridLayer.fillColor;
    _borderGridLayer.strokeColor = _yTimeGridLayer.strokeColor;
    _borderGridLayer.lineWidth = _yTimeGridLayer.lineWidth;
}

/** 绘制纵向网格线(中间，绘制条数与分隔时间有关) -- 五日分时以日期绘制 */
- (void)drawFiveDateLines {
    int nDays = 5;
    UIBezierPath *path = [UIBezierPath bezierPath];
    NSInteger gap = _timeRect.size.width / nDays;
    
    for (int i = 1; i < nDays; i++) {
        CGFloat originX = gap * i;
        [path addVerticalLine:CGPointMake(originX, CGRectGetMinY(_timeRect)) len:_timeRect.size.height];
        if (!CGRectEqualToRect(_volumeRect, CGRectZero)) {
            [path addVerticalLine:CGPointMake(originX, CGRectGetMinY(_volumeRect)) len:_volumeRect.size.height];
        }
        if (!CGRectEqualToRect(_tradeRect, CGRectZero)) {
            [path addVerticalLine:CGPointMake(originX, CGRectGetMinY(_tradeRect)) len:_tradeRect.size.height];
        }
    }
    _xDateGridLayer.path = path.CGPath;
}

/** 纵向网格线(中间，绘制条数与分隔时间有关) -- 分时以分时点数绘制 */
- (void)drawDateLines:(id)timeChart {
    if (!_xAxisDateSegments) return;
    UIBezierPath *path = [UIBezierPath bezierPath];
    NSInteger section = _maxDataCount / (_xAxisDateSegments - 1);
    YT_TimeChart *chart = (YT_TimeChart *)timeChart;
    
    for (int i = 1; i < _xAxisDateSegments - 1; i++) {
        NSInteger realIdx = i * section;
        CGFloat centerX = [chart getCenterXWithIndex:realIdx];
        [path addVerticalLine:CGPointMake(centerX, CGRectGetMinY(_timeRect)) len:_timeRect.size.height];
        if (!CGRectEqualToRect(_volumeRect, CGRectZero)) {
            [path addVerticalLine:CGPointMake(centerX, CGRectGetMinY(_volumeRect)) len:_volumeRect.size.height];
        }
        if (!CGRectEqualToRect(_tradeRect, CGRectZero)) {
            [path addVerticalLine:CGPointMake(centerX, CGRectGetMinY(_tradeRect)) len:_tradeRect.size.height];
        }
    }
    _xDateGridLayer.path = path.CGPath;
}

- (void)updateLayerWithRect:(CGRect)timeRect :(CGRect)volumeRect :(CGRect)tradeReact {
    _timeRect = timeRect;
    [self drawTimeGridLines];
    
    _volumeRect = volumeRect;
    [self drawVolumeGridLines];
    
    _tradeRect = tradeReact;
    [self drawTradeGridLines];
    
    [self drawGridBorderLines];
}
/** 绘制分时区域网格水平线 */
- (void)drawTimeGridLines {
    CGFloat segGap = _timeRect.size.height / _yAxisTimeSegments;
    CGFloat originY = _timeRect.origin.y + _gridLineWidth * 0.5;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < _yAxisTimeSegments + 1; i++) {
        CGPoint start = CGPointMake(_timeRect.origin.x, originY + segGap * i);
        [path addHorizontalLine:start len:_timeRect.size.width];
    }

    _yTimeGridLayer.path = path.CGPath;
}

/** 绘制成交量区域网格水平线 参数 */
- (void)drawVolumeGridLines {
    CGFloat segGap = _volumeRect.size.height / _yAxisVolumeSegments;
    CGFloat originY = _volumeRect.origin.y;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < _yAxisVolumeSegments + 1; i++) {
        CGPoint start = CGPointMake(_volumeRect.origin.x, originY + segGap * i);
        [path addHorizontalLine:start len:_volumeRect.size.width];
    }
    
    _yVolumeGridLayer.path = path.CGPath;
}

/** 绘制买卖区域网格水平线 参数 */
- (void)drawTradeGridLines {
    CGFloat segGap = _tradeRect.size.height / _yAxisVolumeSegments;
    CGFloat originY = _tradeRect.origin.y;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < _yAxisVolumeSegments + 1; i++) {
        CGPoint start = CGPointMake(_tradeRect.origin.x, originY + segGap * i);
        [path addHorizontalLine:start len:_tradeRect.size.width];
    }
    
    _yTradeGridLayer.path = path.CGPath;
}

/** 绘制网格的边框线 */
- (void)drawGridBorderLines {
    CGFloat halfWidth = _gridLineWidth * 0.5;
    CGFloat minX = CGRectGetMinX(_timeRect) + halfWidth;
    CGFloat maxX = CGRectGetMaxX(_timeRect) - halfWidth;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addVerticalLine:CGPointMake(minX, CGRectGetMinY(_timeRect)) len:_timeRect.size.height];
    [path addVerticalLine:CGPointMake(maxX, CGRectGetMinY(_timeRect)) len:_timeRect.size.height];
    if (!CGRectEqualToRect(_volumeRect, CGRectZero)) {
        [path addVerticalLine:CGPointMake(minX, CGRectGetMinY(_volumeRect)) len:_volumeRect.size.height];
        [path addVerticalLine:CGPointMake(maxX, CGRectGetMinY(_volumeRect)) len:_volumeRect.size.height];
    }
    if (!CGRectEqualToRect(_tradeRect, CGRectZero)) {
        [path addVerticalLine:CGPointMake(minX, CGRectGetMinY(_tradeRect)) len:_tradeRect.size.height];
        [path addVerticalLine:CGPointMake(maxX, CGRectGetMinY(_tradeRect)) len:_tradeRect.size.height];
    }
    _borderGridLayer.path = path.CGPath;
}
@end
