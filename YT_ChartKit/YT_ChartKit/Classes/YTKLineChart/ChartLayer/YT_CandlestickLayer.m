//
//  YT_CandlestickLayer.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/23.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_CandlestickLayer.h"
#import "YT_Candlestick.h"
#import "YT_ChartScaler.h"
#import "YT_StockChartProtocol.h" // 基本 float 协议
#import "YT_KLineDataProtocol.h" // kline数据协议
@interface YT_CandlestickLayer ()
{
    NSRange _dispalyRange;
    void(*_drawMethod)(CGMutablePathRef ref, YT_Candle candle);
}
@end

@implementation YT_CandlestickLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.contentsScale = [UIScreen mainScreen].scale;
        self.masksToBounds = YES;
     
        _drawStyle =  YT_CandlesDrawStyleCandles;
        _candleStyleOps = YT_CandleStyleOpsFallFull | YT_CandleStyleOpsHoldFull;
        
        _redLineLayer   = [[CAShapeLayer alloc] init];
        _greenLineLayer = [[CAShapeLayer alloc] init];
        _grayLineLayer  = [[CAShapeLayer alloc] init];
        [self addSublayer:_redLineLayer];
        [self addSublayer:_grayLineLayer];
        [self addSublayer:_greenLineLayer];
        
        _dispalyRange = NSMakeRange(0, 0);
        _drawMethod = CGPathAddYTCandle;
        
        _closslineWidth = 1;
//        _clossColor  = [UIColor blueColor];
//        _clossAreaColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self.sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }];
}

- (void)makeClossLayerIfNeed {
    if (!_clossLayer) {
        // 重用会有旧颜色的残影闪烁
//        _clossLayer   = _redLineLayer;
//        _clossAreaLayer = _greenLineLayer;
        
        _clossLayer   =  [[CAShapeLayer alloc] init];
        _clossAreaLayer = [[CAShapeLayer alloc] init];

        _clossLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _clossAreaLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSublayer:_clossLayer];
        [self addSublayer:_clossAreaLayer];
    }
}

- (void)setDrawStyle:(YT_CandlesDrawStyle)drawStyle {
    if ([self updateForDrawStyleChangeTo:drawStyle]) {
        _drawStyle = drawStyle;
    }
}

- (BOOL)updateForDrawStyleChangeTo:(YT_CandlesDrawStyle)drawStyle {
    if (drawStyle == _drawStyle) return YES;
    
    BOOL noChangeLayer = (drawStyle != YT_CandlesDrawStyleLine && _drawStyle != YT_CandlesDrawStyleLine);
    
    //ChangeLayer
    if (noChangeLayer == NO) {
        
        if (drawStyle == YT_CandlesDrawStyleLine) {
            
            [self makeClossLayerIfNeed];
            
            _redLineLayer.hidden  = YES;
            _greenLineLayer.hidden  = YES;
            _grayLineLayer.hidden  = YES;
            
            _clossLayer.hidden = NO;
            _clossAreaLayer.hidden = NO;
            
        }else {
   
            _clossLayer.hidden = YES;
            _clossAreaLayer.hidden = YES;
            
            _redLineLayer.hidden = NO;
            _greenLineLayer.hidden = NO;
            _grayLineLayer.hidden = NO;
        }
        
    }
    
    //ChangeOps
    if (drawStyle == YT_CandlesDrawStyleAB) {
        _drawMethod = (void *)CGPathAddYTCandleStyleAB;
    }if (drawStyle == YT_CandlesDrawStyleCandles) {
        _drawMethod = (void *)CGPathAddYTCandle;
    }else {
    }
    
    //ChangeConfig
    [self configLayerForDrawStyle:drawStyle];
    
    //ChangePath
    //    if (_dispalyRange.location != NSNotFound && _dispalyRange.length != 0) {
    //        [self updateLayerWithRange:_dispalyRange];
    //    }
    return YES;
}

#pragma mark

- (void)setCandleStyleOps:(YT_CandleStyleOps)candleStyleOps {
    if (_candleStyleOps != candleStyleOps) {
        _candleStyleOps = candleStyleOps;
        [self configLayer];
    }
}

#pragma mark -

- (void)configLayer {
    [self configLayerForDrawStyle:_drawStyle];
}

- (void)configLayerForDrawStyle:(YT_CandlesDrawStyle)drawStyle {
    
    switch (drawStyle) {
            
        case YT_CandlesDrawStyleAB:
        {
            // k线图颜色设置
            _redLineLayer.strokeColor = _riseColor.CGColor;
            _redLineLayer.fillColor = _riseColor.CGColor;
            
            _greenLineLayer.strokeColor = _fallColor.CGColor;
            _greenLineLayer.fillColor = _fallColor.CGColor;
            
            _grayLineLayer.strokeColor = _riseColor.CGColor;
            _grayLineLayer.strokeColor = _riseColor.CGColor;
            
        }
            break;
            
        case YT_CandlesDrawStyleCandles:
            {
                // k线图颜色设置
                 _redLineLayer.strokeColor = _riseColor.CGColor;
                if (_candleStyleOps & YT_CandleStyleOpsRiseFull) {
                    _redLineLayer.fillColor = _riseColor.CGColor;
                }else {
                    _redLineLayer.fillColor = [UIColor clearColor].CGColor;
                }
               
                _greenLineLayer.strokeColor = _fallColor.CGColor;
                if (_candleStyleOps & YT_CandleStyleOpsFallFull) {
                    _greenLineLayer.fillColor = _fallColor.CGColor;
                }else {
                    _greenLineLayer.fillColor = [UIColor clearColor].CGColor;
                }
            
                 _grayLineLayer.strokeColor = _holdColor.CGColor;
                if (_candleStyleOps & YT_CandleStyleOpsHoldFull) {
                     _grayLineLayer.strokeColor = _holdColor.CGColor;
                }else {
                    _grayLineLayer.fillColor = [UIColor clearColor].CGColor;
                }
                
            }
            break;
        case YT_CandlesDrawStyleLine: {
            _clossLayer.strokeColor = _clossColor.CGColor;
            _clossLayer.fillColor = [UIColor clearColor].CGColor;
            _clossLayer.lineWidth =  _closslineWidth;
            _clossAreaLayer.strokeColor = _clossAreaColor.CGColor;
            _clossAreaLayer.fillColor = _clossAreaColor.CGColor;
        }
             break;
        default:
            break;
    }

}

/**
 * 绘制区间
 */
- (void)updateLayerWithRange:(NSRange)range {
    _dispalyRange = range;
    if (_drawStyle == YT_CandlesDrawStyleLine) {
        [self _updateLayerWithRangeStyleCloss:range];
    }else {
        [self _updateLayerWithRange:range];
    }
}

- (void)_updateLayerWithRange:(NSRange)range {
    
    CGMutablePathRef refRed = CGPathCreateMutable();
    CGMutablePathRef refGreen = CGPathCreateMutable();
    CGMutablePathRef refGray = CGPathCreateMutable();

    [self _updateCandleArrayWithRange:range red:refRed green:refGreen gray:refGray drawMethod:_drawMethod];
    
    self.redLineLayer.path = refRed;
    self.greenLineLayer.path = refGreen;
    self.grayLineLayer.path = refGray;
   
    CGPathRelease(refRed);
    CGPathRelease(refGreen);
    CGPathRelease(refGray);
}

/** 更新计算点 */
- (void)_updateCandleArrayWithRange:(NSRange)range red:(CGMutablePathRef)redCandles green:(CGMutablePathRef) greenCandles gray:(CGMutablePathRef)grayCandles drawMethod:(void(*)(CGMutablePathRef ref, YT_Candle candle))drawMethod
{
    
    NSInteger count = NSMaxRange(range);
    YT_AxisYScaler axisYScaler = self.chartScaler.axisYScaler;
    YT_AxisXScaler axisXScaler = self.chartScaler.axisXScaler;
    CGFloat shapeWidth = self.chartScaler.shapeWidth;
    
    for (NSInteger idx = range.location; idx < count; idx++) {
        
        id <YT_StockKlineData> data = [self.kLineArray objectAtIndex:idx];
        
        CGFloat x = axisXScaler(idx);//中心点
    
        YTSCFloat openPrice  = data.yt_openPrice;
        YTSCFloat closePrice = data.yt_closePrice;
        YTSCFloat lowPrice   = data.yt_lowPrice;
        YTSCFloat highPrice  = data.yt_highPrice;
        
        CGFloat openPointY = axisYScaler(openPrice);
        CGFloat closePointY = axisYScaler(closePrice);
        
        CGRect rect;
        CGFloat originY = closePointY;
        CGFloat high = openPointY - closePointY;
        rect.origin = CGPointMake(x - shapeWidth/ 2, originY);
        rect.size = CGSizeMake(shapeWidth, high);
        
        CGPoint lowPoint = CGPointMake(x, axisYScaler(lowPrice));
        CGPoint highPoint = CGPointMake(x, axisYScaler(highPrice));
        
        YT_Candle candle = YT_CandleMake(highPoint, rect, lowPoint);
        if (openPrice < closePrice) { //red
             drawMethod(redCandles, candle);
        }else if (openPrice > closePrice) { //green
             drawMethod(greenCandles, candle);
        }else {
             drawMethod(grayCandles, candle);
        }
    }
}


- (void)_updateLayerWithRangeStyleCloss:(NSRange)range {
    if (range.length == 0) return;
    CGFloat areaOffy = _clossLayer.lineWidth*0.5;
    
//    if(_clossAreaLayer.frame.origin.y == _clossLayer.frame.origin.y ) {
//        // 设置_clossAreaLayer 往下偏移 _clossLayer.lineWidth*0.5
//        CGRect frame = _clossLayer.frame;
//        _clossAreaLayer.frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(_clossLayer.lineWidth*0.5, 0, 0, 0));
//    }

    NSInteger idx = range.location;
//    if (idx > 0)  idx -= 1;
    NSInteger count = NSMaxRange(range);
//    if (count < self.kLineArray.count)  count += 1;
    
    YT_AxisYScaler axisYScaler = self.chartScaler.axisYScaler;
    YT_AxisXScaler axisXScaler = self.chartScaler.axisXScaler;
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    UIBezierPath *areaPath = [UIBezierPath bezierPath];
    
    CGFloat first_x = axisXScaler(idx);//中心点
    CGFloat x = first_x;
    id <YT_StockKlineData> data = [self.kLineArray objectAtIndex:idx];
    CGFloat closePointY = axisYScaler(data.yt_closePrice);
    
    [linePath moveToPoint:CGPointMake(x, closePointY)];
    [areaPath moveToPoint:CGPointMake(x, closePointY + areaOffy)];
    
    idx ++;
    for (; idx < count; idx++) {
         x = axisXScaler(idx);
         data = [self.kLineArray objectAtIndex:idx];
         closePointY = axisYScaler(data.yt_closePrice);
         [linePath addLineToPoint:CGPointMake(x, closePointY)];
         [areaPath addLineToPoint:CGPointMake(x, closePointY + areaOffy)];
    }
    _clossLayer.path = linePath.CGPath;
    
    CGFloat max_y =  CGRectGetMaxY(self.chartScaler.chartRect);
    CGFloat last_x = x;
    
    [areaPath addLineToPoint:CGPointMake(last_x,max_y)];
    [areaPath addLineToPoint:CGPointMake(first_x,max_y)];
    [areaPath closePath];
    _clossAreaLayer.path = areaPath.CGPath;
}

@end
