//
//  YT_MACDLayer.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/29.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_MACDLayer.h"
//#import "YT_KlineCalculatorProtocol.h"

@interface YT_MACDLayer () <YT_MACDLayerConfig>

#pragma mark - 线

@property (nonatomic, strong) CAShapeLayer * line_DIFF;
@property (nonatomic, strong) CAShapeLayer * line_DEA;

#pragma mark - 柱

@property (nonatomic, strong) CAShapeLayer * positiveLayer; ///< 正
@property (nonatomic, strong) CAShapeLayer * negativeLayer; ///< 负

@end

@implementation YT_MACDLayer

@synthesize volMACDLineWidth = _volMACDLineWidth;
@synthesize volMACDBarWidth = _volMACDBarWidth;
@synthesize volMACDColor_DEA = _volMACDColor_DEA;
@synthesize volMACDColor_DIFF = _volMACDColor_DIFF;
@synthesize fallColor = _fallColor;
@synthesize riseColor = _riseColor;

#pragma mark - init

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _riseColor = [UIColor colorWithRed:234/255.0 green:82/255.0 blue:83/255.0 alpha:1];
        _fallColor = [UIColor colorWithRed:77/255.0 green:166/255.0 blue:73/255.0 alpha:1];
        
        _volMACDLineWidth  = 0.5;
        _volMACDBarWidth  = 1;
        _volMACDColor_DIFF = [UIColor yellowColor]; // 子层颜色
        _volMACDColor_DEA  = [UIColor purpleColor];  // 子层颜色
    }
    return self;
}

#pragma mark - getter

-(id<YT_MACDLayerConfig>)configuration {
    if (_configuration) {
        return _configuration;
    }
    return self;
}

#pragma mark - 功能
/**
 * titile @"MACD(12,26,9)"
 */
- (NSAttributedString *)titleAttributedString {
    NSString * string = [[NSString alloc] initWithFormat:@"MACD(%d,%d,%d)",DAYS_EMA12,DAYS_EMA26,DAYS_DIF];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:string];
    return attrString;
}

- (NSArray<NSString *> *)infoStringWithIndex:(NSInteger)index {
    id <YT_StockMACDHandle> adata = [self.dataArray objectAtIndex:index];
    int digit = self.textDecimalPlaces;
    
    NSString * string1 = [NSString stringWithFormat:@"DIF:%.*f    " ,digit, adata.cache_DIF];
    NSString * string2 = [NSString stringWithFormat:@"DEA:%.*f    " ,digit, adata.cache_DEA];
    NSString * string3 = [NSString stringWithFormat:@"MACD:%.*f    " ,digit, adata.cache_MACD];
    return [NSArray arrayWithObjects:string1,string2,string3,nil];
}

/**
 * 指标字符串 长按手势 查询层（十字线） 出现 时显示
 */
- (NSAttributedString *)attrStringWithIndex:(NSInteger)index {
    
    id <YT_StockMACDHandle> adata = [self.dataArray objectAtIndex:index];
    
    UIColor *color1 = self.configuration.volMACDColor_DIFF?:[UIColor blackColor];
    UIColor *color2 = self.configuration.volMACDColor_DEA?:[UIColor blackColor];
    UIColor *color3 = adata.cache_MACD < 0?self.configuration.fallColor:self.configuration.riseColor;
    
    return [self attrStringWithStringArray:[self infoStringWithIndex:index] colorArr:@[color1,color2,color3]];
}

- (void)initSubLayers {
    
   CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (!_negativeLayer) {
        _negativeLayer = [CAShapeLayer layer];
        _negativeLayer.frame = rect;
        [self addSublayer:_negativeLayer];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_negativeLayer)];
    }
    if (!_positiveLayer) {
        _positiveLayer = [CAShapeLayer layer];
        _positiveLayer.frame = rect;
        [self addSublayer:_positiveLayer];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_positiveLayer)];
    }
    if (!_line_DEA) {
        _line_DEA = [CAShapeLayer layer];
        _line_DEA.frame = rect;
        [self addSublayer:_line_DEA];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_DEA)];
    }
    if (!_line_DIFF) {
        _line_DIFF = [CAShapeLayer layer];
        _line_DIFF.frame = rect;
        [self addSublayer:_line_DIFF];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_DIFF)];
    }
    
//    if (self.aryLineLayer.count != 2) {
//        // 删除所有层
//        [self.aryLineLayer makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
//        [self.aryLineLayer removeAllObjects];
//
//        for (NSUInteger idx = 0; idx < 2; idx++) {
//            CAShapeLayer * layer = [CAShapeLayer layer];
//            layer.frame = rect;
//            [self addSublayer:layer];
//            [self.aryLineLayer addObject:layer];
//            [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(layer)];
//        }
//    }
}

/**
 layer 初始化配置
 */
- (void)configLayer {
    [self initSubLayers];
    
    self.positiveLayer.strokeColor = self.configuration.riseColor.CGColor;
    self.positiveLayer.fillColor = self.configuration.riseColor.CGColor;
    self.positiveLayer.lineWidth = 0; // 方式一
    self.negativeLayer.strokeColor = self.configuration.fallColor.CGColor;
    self.negativeLayer.fillColor = self.configuration.fallColor.CGColor;
    self.negativeLayer.lineWidth = 0; // 方式一
    
    self.line_DEA.strokeColor = self.configuration.volMACDColor_DEA.CGColor;
    self.line_DEA.fillColor = [UIColor clearColor].CGColor;
    self.line_DEA.lineWidth = self.configuration.volMACDLineWidth;
    
    self.line_DIFF.strokeColor = self.configuration.volMACDColor_DIFF.CGColor;
    self.line_DIFF.fillColor = [UIColor clearColor].CGColor;
    self.line_DIFF.lineWidth = self.configuration.volMACDLineWidth;
}

/**
 实时更新 layer
 
 @param range 数据数组绘制区间
 */
- (void)updateLayerWithRange:(NSRange)range {
    [self _updateLayerWithRange:range];
}

///方式一
- (void)_updateLayerWithRange:(NSRange)range {
    
    CGMutablePathRef ref_p = CGPathCreateMutable();
    CGMutablePathRef ref_n = CGPathCreateMutable();

    YT_AxisYScaler axisYScaler = self.chartScaler.axisYScaler;
    YT_AxisXScaler axisXScaler = self.chartScaler.axisXScaler;
    
    double baselinePoint_y = axisYScaler(0);
    CGFloat barWidth = self.configuration.volMACDBarWidth;
    CGFloat barWidth_2 = barWidth / 2;
    
    NSInteger from = range.location;
    NSInteger to = range.location + range.length;
    
    for (NSUInteger i =  from; i < to ; i ++) {
        //MACD
        YTSCFloat afloat = [_dataArray objectAtIndex:i].cache_MACD;
        CGPoint point  = CGPointMake(axisXScaler(i), axisYScaler(afloat));
        CGFloat height  = point.y - baselinePoint_y;
        CGRect rect = CGRectMake(point.x - barWidth_2, baselinePoint_y, barWidth, height);
        if (afloat >= 0) {
            CGPathAddRect(ref_p, NULL, rect);
        }else{
            CGPathAddRect(ref_n, NULL, rect);
        }
    }
 
    _negativeLayer.path = ref_n;
    _positiveLayer.path = ref_p;
    
    CGPathRelease(ref_p);
    CGPathRelease(ref_n);
    
    [_dataArray layer:_line_DEA addPoints:range getter:@selector(cache_DEA) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_line_DIFF addPoints:range getter:@selector(cache_DIF) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    
//    CGMutablePathRef ref_dea = CGPathCreateMutable();
//    CGMutablePathRef ref_diff = CGPathCreateMutable();
//    
//    _line_DEA.path = ref_dea;
//    _line_DIFF.path = ref_diff;
//    
//    CGPathRelease(ref_dea);
//    CGPathRelease(ref_diff);
}

@end




