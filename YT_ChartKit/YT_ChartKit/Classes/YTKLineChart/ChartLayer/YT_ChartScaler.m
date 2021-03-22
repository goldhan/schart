//
//  YT_ChartScaler.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/23.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_ChartScaler.h"

@implementation YT_ChartScaler

- (instancetype)init {
    self = [super init];
    if (self) {
        // 健壮性代码
        _axisXParser = ^(double x){return x;};
        _axisXScaler = ^(NSUInteger idx){return 0.0;};
        _axisYParser = ^(double y){return y;};
        _axisYScaler = ^(double y){return y;};
    }
    return self;
}

- (CGFloat)contentWidth {
    return  (_shapeInterval + _shapeWidth) * _totalShapeCount;
}

- (CGFloat)interval {
    return _shapeInterval + _shapeWidth;
}

//// 根据项目情况可重写
//- (NSRange)visibleRangeFormX:(CGFloat)startX toX:(CGFloat)endX {
//    startX +=  (_shapeInterval + _shapeWidth) *0.5;//四舍五入 centerX 过了 startX
//    endX -= (_shapeInterval + _shapeWidth) *0.5;//四舍五入 centerX 过了 endX
//    NSInteger from =  self.axisXParser(startX);
//    NSInteger to =   self.axisXParser(endX) + 1;
//    from = from > 0?:0;
//    to = to < _totalShapeCount ?:_totalShapeCount;
//    
//    return NSMakeRange(from, to - from);
//}

- (NSInteger)indexFromAxisXParser:(CGFloat)point_x {
    return (NSInteger)(_axisXParser(point_x));
}

- (NSInteger)roundIndexFromAxisXParser:(CGFloat)point_x {
     return round(_axisXParser(point_x));
}

- (void)updateAxisX {
    _axisXParser = YT_AxisXParserMake(_shapeWidth, _shapeInterval, _chartRect);
    _axisXScaler = YT_AxisXScalerMake(_shapeWidth, _shapeInterval, _chartRect);
}

- (void)updateAxisY {
    _axisYParser = YT_AxisYParserMake(_max, _min, _chartRect);
    _axisYScaler = YT_AxisYScalerMake(_max, _min, _chartRect);
}

- (void)updateAxisYForInsets:(UIEdgeInsets)insets {
    CGRect rect = UIEdgeInsetsInsetRect(_chartRect, insets);
    YT_AxisYParser yParser =  YT_AxisYParserMake(_max,_min,rect);
    _min = yParser(CGRectGetMaxY(_chartRect));
    _max = yParser(CGRectGetMinY(_chartRect));
    [self updateAxisY];
}

@end

#pragma mark - YT_ChartYScaler

@implementation YT_ChartYScaler

- (CGFloat)shapeWidth {
    return _xRelyon.shapeWidth;
}
- (void)setShapeWidth:(CGFloat)shapeWidth {
    _xRelyon.shapeWidth = shapeWidth;
}

- (CGFloat)shapeInterval {
    return _xRelyon.shapeInterval;
}
- (void)setShapeInterval:(CGFloat)shapeInterval {
    _xRelyon.shapeInterval = shapeInterval;
}

- (NSUInteger)totalShapeCount {
    return _xRelyon.totalShapeCount;
}
- (void)setTotalShapeCount:(NSUInteger)totalShapeCount {
    _xRelyon.totalShapeCount = totalShapeCount;
}

- (CGFloat)contentWidth {
    return  (self.shapeInterval + self.shapeWidth) * self.totalShapeCount;
}

- (CGFloat)interval {
    return self.shapeInterval + self.shapeWidth;
}

- (YT_AxisXScaler)axisXScaler {
    return _xRelyon.axisXScaler;
}
- (void)setAxisXScaler:(YT_AxisXScaler)axisXScaler {
     _xRelyon.axisXScaler = axisXScaler;
}

- (YT_AxisXParser)axisXParser {
    return _xRelyon.axisXParser;
}
- (void)setAxisXParser:(YT_AxisXParser)axisXParser {
    _xRelyon.axisXParser = axisXParser;
}

- (void)updateAxisX {
    [_xRelyon updateAxisX];
}

- (NSInteger)indexFromAxisXParser:(CGFloat)point_x {
    return [_xRelyon indexFromAxisXParser:point_x];
}

- (NSInteger)roundIndexFromAxisXParser:(CGFloat)point_x {
    return [_xRelyon roundIndexFromAxisXParser:point_x];
}

@end

