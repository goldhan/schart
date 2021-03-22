//
//  YT_BOLLLayer.m
//  KDS_Phone
//
//  Created by yangjinming on 2018/6/5.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_BOLLLayer.h"
#import "YT_Candlestick.h"
#import "YT_ChartScaler.h"

@interface YT_BOLLLayer()<YT_BOLLLayerConfig>
#pragma mark - 蜡烛图
@property (nonatomic, strong) CAShapeLayer * redLineLayer;      ///< 红色K线
@property (nonatomic, strong) CAShapeLayer * grayLineLayer;     ///< 灰色/红色K线
@property (nonatomic, strong) CAShapeLayer * greenLineLayer;    ///< 绿色k线

#pragma mark - 线

@property (nonatomic, strong) CAShapeLayer *line_BOLL_M;
@property (nonatomic, strong) CAShapeLayer *line_BOLL_U;
@property (nonatomic, strong) CAShapeLayer *line_BOLL_D;
@end

@implementation YT_BOLLLayer
@synthesize volBOLLLineWidth = _volBOLLLineWidth;
@synthesize riseColor = _riseColor;
@synthesize fallColor = _fallColor;
@synthesize volBOLLColor_M = _volBOLLColor_M;
@synthesize volBOLLColor_U = _volBOLLColor_U;
@synthesize volBOLLColor_D = _volBOLLColor_D;

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _volBOLLLineWidth  = 1;
        _riseColor = [UIColor colorWithRed:216/255.0 green:94/255.0 blue:101/255.0 alpha:1];
        _fallColor = [UIColor colorWithRed:150/255.0 green:234/255.0 blue:166/255.0 alpha:1];
        
        _volBOLLColor_M = [UIColor blueColor]; // 子层颜色
        _volBOLLColor_U = [UIColor redColor]; // 子层颜色
        _volBOLLColor_D = [UIColor purpleColor]; // 子层颜色
    }
    return self;
}

#pragma mark - getter

- (id<YT_BOLLLayerConfig>)configuration {
    if (_configuration) {
        return _configuration;
    }
    return self;
}

#pragma mark - 功能

/**
 * titile @"BOLL(20,2)"
 */
- (NSAttributedString *)titleAttributedString {
    NSString * string = [NSString stringWithFormat:@"BOLL(%d,%d)",DAYS_BOLL,DAYS_BOLL_P2];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:string];
    return attrString;
}

- (NSArray<NSString *> *)infoStringWithIndex:(NSInteger)index {
    
    id <YT_StockBOLLHandle> adata = [self.dataArray objectAtIndex:index];
    int digit = self.textDecimalPlaces;
    
    NSString * string1 = [NSString stringWithFormat:@"MID:%.*f    ",digit, adata.cache_BOLL_Mid];
    NSString * string2 = [NSString stringWithFormat:@"UPP:%.*f    ",digit, adata.cache_BOLL_Upper];
    NSString * string3 = [NSString stringWithFormat:@"LOW:%.*f    ",digit, adata.cache_BOLL_Lower];
    
    return [NSArray arrayWithObjects:string1, string2, string3, nil];
}

/**
 * 指标字符串 长按手势 查询层（十字线） 出现 时显示
 */
- (NSAttributedString *)attrStringWithIndex:(NSInteger)index {
    
    UIColor *color1 = self.configuration.volBOLLColor_M?:[UIColor blackColor];
    UIColor *color2 = self.configuration.volBOLLColor_U?:[UIColor blackColor];
    UIColor *color3 = self.configuration.volBOLLColor_D?:[UIColor blackColor];
    
    return [self attrStringWithStringArray:[self infoStringWithIndex:index] colorArr:@[color1,color2,color3]];
}

- (void)initSubLayers {
    
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (!_redLineLayer) {
        _redLineLayer = [CAShapeLayer layer];
        _redLineLayer.frame = rect;
        [self addSublayer:_redLineLayer];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_redLineLayer)];
    }
    if (!_greenLineLayer) {
        _greenLineLayer = [CAShapeLayer layer];
        _greenLineLayer.frame = rect;
        [self addSublayer:_greenLineLayer];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_greenLineLayer)];
    }
    if (!_grayLineLayer) {
        _grayLineLayer = [CAShapeLayer layer];
        _grayLineLayer.frame = rect;
        [self addSublayer:_grayLineLayer];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_grayLineLayer)];
    }
    
    if (!_line_BOLL_M) {
        _line_BOLL_M = [CAShapeLayer layer];
        _line_BOLL_M.frame = rect;
        [self addSublayer:_line_BOLL_M];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_BOLL_M)];
    }
    if (!_line_BOLL_U) {
        _line_BOLL_U = [CAShapeLayer layer];
        _line_BOLL_U.frame = rect;
        [self addSublayer:_line_BOLL_U];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_BOLL_U)];
    }
    if (!_line_BOLL_D) {
        _line_BOLL_D = [CAShapeLayer layer];
        _line_BOLL_D.frame = rect;
        [self addSublayer:_line_BOLL_D];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_BOLL_D)];
    }
}

/**
 layer 初始化配置
 */
- (void)configLayer {
    [self initSubLayers];
    
    // k线图颜色设置
    _redLineLayer.strokeColor = self.configuration.riseColor.CGColor;
    _redLineLayer.fillColor = self.configuration.riseColor.CGColor;
    
    _greenLineLayer.strokeColor = self.configuration.fallColor.CGColor;
    _greenLineLayer.fillColor = self.configuration.fallColor.CGColor;
    
    _grayLineLayer.strokeColor = self.configuration.riseColor.CGColor;
    _grayLineLayer.fillColor = self.configuration.riseColor.CGColor;
    
    self.line_BOLL_M.strokeColor = self.configuration.volBOLLColor_M.CGColor;
    self.line_BOLL_M.fillColor = [UIColor clearColor].CGColor;
    self.line_BOLL_M.lineWidth = self.configuration.volBOLLLineWidth;
    
    self.line_BOLL_U.strokeColor = self.configuration.volBOLLColor_U.CGColor;
    self.line_BOLL_U.fillColor = [UIColor clearColor].CGColor;
    self.line_BOLL_U.lineWidth = self.configuration.volBOLLLineWidth;
    
    self.line_BOLL_D.strokeColor = self.configuration.volBOLLColor_D.CGColor;
    self.line_BOLL_D.fillColor = [UIColor clearColor].CGColor;
    self.line_BOLL_D.lineWidth = self.configuration.volBOLLLineWidth;
}

/**
 实时更新 layer
 
 @param range 数据数组绘制区间
 */
- (void)updateLayerWithRange:(NSRange)range {
    [self _updateLayerWithRange:range];
}

- (void)_updateLayerWithRange:(NSRange)range {
    
    // 蜡烛图
    CGMutablePathRef refRed = CGPathCreateMutable();
    CGMutablePathRef refGreen = CGPathCreateMutable();
    CGMutablePathRef refGray = CGPathCreateMutable();
    
    [self  _updateCandleArrayWithRange:range red:refRed green:refGreen gray:refGray];
    
    self.redLineLayer.path = refRed;
    CGPathRelease(refRed);
    self.greenLineLayer.path = refGreen;
    CGPathRelease(refGreen);
    self.grayLineLayer.path = refGray;
    CGPathRelease(refGray);
    
    // 上中下轨线
    YT_AxisYScaler axisYScaler = self.chartScaler.axisYScaler;
    YT_AxisXScaler axisXScaler = self.chartScaler.axisXScaler;
    
    [_dataArray layer:_line_BOLL_M addPoints:range getter:@selector(cache_BOLL_Mid) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_line_BOLL_U addPoints:range getter:@selector(cache_BOLL_Upper) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_line_BOLL_D addPoints:range getter:@selector(cache_BOLL_Lower) axisXScaler:axisXScaler axisYScaler:axisYScaler];
}

/** 更新计算点 */
- (void)_updateCandleArrayWithRange:(NSRange)range red:(CGMutablePathRef)refRed green:(CGMutablePathRef)refGreen gray:(CGMutablePathRef)refGray
{
    
    NSInteger count = NSMaxRange(range);
    YT_AxisYScaler axisYScaler = self.chartScaler.axisYScaler;
    YT_AxisXScaler axisXScaler = self.chartScaler.axisXScaler;
    CGFloat shapeWidth = self.chartScaler.shapeWidth + self.chartScaler.shapeInterval;
    
    for (NSInteger idx = range.location; idx < count; idx++) {
        
        id <YT_StockKlineData> data = [self.dataSource.klineDataArray objectAtIndex:idx];
        
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
            CGPathAddYTCandleStyleAB(refRed, candle);
        }else if (openPrice > closePrice) { //green
            CGPathAddYTCandleStyleAB(refGreen, candle);
        }else {
            CGPathAddYTCandleStyleAB(refGray, candle);
        }
    }
}
@end
