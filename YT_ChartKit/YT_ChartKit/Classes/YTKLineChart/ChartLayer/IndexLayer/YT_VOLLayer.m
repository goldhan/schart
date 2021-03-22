//
//  YT_VOLLayer.m
//  KDS_Phone
//
//  Created by ChenRui Hu on 2018/6/6.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_VOLLayer.h"
#import "YT_KlineChartStringUtil.h"

@implementation NSArray (CAShapeLayerAddVolPoints)

/*
 notMoveMinLoc 均量前几个值跳过
 服务器下发的移动均量前几个无数据的值是0，在使用时不需要画点，此类只转换这几个数值
 比如：Tech1 是5日移动均量，从0到3的值是0
 */
- (void)layer:(CAShapeLayer *)layer addVolPoints:(NSRange)range notMoveMinLoc:(NSUInteger)loc getter:(SEL)getter axisXScaler:(YT_AxisXScaler)axisXScaler axisYScaler:(YT_AxisYScaler)axisYScaler {
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    NSInteger from = range.location;
    NSInteger to = range.location + range.length;
    
    IMP imp = [self.firstObject methodForSelector:getter];
    YTSCFloat (*objGetter)(id obj, SEL getter) = (void *)imp;
    
    if (from < loc) {
        from = loc;
    }
    if (from >= to) {
        layer.path = pathRef;
        CGPathRelease(pathRef);
        return;
    }
    
    NSUInteger i =  from;
    YTSCFloat afloat = objGetter ([self objectAtIndex:i], getter);
    CGPoint point  = CGPointMake(axisXScaler(i), axisYScaler(afloat));
    CGPathMoveToPoint(pathRef, NULL, point.x, point.y);
    i++;
    for (; i < to ; i ++) {
        YTSCFloat afloat = objGetter ([self objectAtIndex:i], getter);
        CGPoint point  = CGPointMake(axisXScaler(i), axisYScaler(afloat));
        CGPathAddLineToPoint(pathRef, NULL, point.x, point.y);
    }
    layer.path = pathRef;
    CGPathRelease(pathRef);
}

@end
@interface YT_VOLLayer()<YT_VOLLayerConfig>

#pragma mark - 柱
@property (nonatomic, strong) CAShapeLayer *positiveLayer;      ///< 红色空心 正
@property (nonatomic, strong) CAShapeLayer *negativeLayer;      ///< 绿色实心 负

#pragma mark - 线

@property (nonatomic, strong) CAShapeLayer *line_VOL_MA1;
@property (nonatomic, strong) CAShapeLayer *line_VOL_MA2;

@end

@implementation YT_VOLLayer
@synthesize riseColor       = _riseColor;
@synthesize fallColor       = _fallColor;

@synthesize volVOLLineWidth = _volVOLLineWidth;
@synthesize volVOLBarLineWidth;

@synthesize volVOLColor;
@synthesize volVOLColor_MA1 = _volVOLColor_MA1;
@synthesize volVOLColor_MA2 = _volVOLColor_MA2;

@synthesize klineDataArray = _klineDataArray;
@synthesize volVOLTextUnit = _volVOLTextUnit;


@synthesize dataArray;

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _riseColor = [UIColor colorWithRed:234/255.0 green:82/255.0 blue:83/255.0 alpha:1];
        _fallColor = [UIColor colorWithRed:77/255.0 green:166/255.0 blue:73/255.0 alpha:1];
        
        _volVOLLineWidth  = 0.5;
        
        _volVOLColor_MA1 = [UIColor purpleColor];  // 子层颜色
        _volVOLColor_MA2  = [UIColor yellowColor];  // 子层颜色
        
        _volVOLTextUnit = @"";
    }
    return self;
}

#pragma mark - getter

- (id<YT_VOLLayerConfig>)configuration {
    if (_configuration) {
        return _configuration;
    }
    return self;
}

#pragma mark - 功能
/**
 * titile @"VOL(5,10)";
 */
- (NSAttributedString *)titleAttributedString {
    NSString * string = [[NSString alloc] initWithFormat:@"VOL(%d,%d)",5,10];;
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:string];
    return attrString;
}

- (NSArray<NSString *> *)infoStringWithIndex:(NSInteger)index {
    id <YT_StockKlineData> adata = [_klineDataArray objectAtIndex:index];
    
    NSString * string1 = [NSString stringWithFormat:@"VOL:%@%@    ", [self axisStringWithValue:adata.yt_volumeOfTransactions],self.configuration.volVOLTextUnit];
    NSString * string2 = [NSString stringWithFormat:@"MA5:%@    ", [self axisStringWithValue:adata.yt_techMA1]];
    NSString * string3 = [NSString stringWithFormat:@"MA10:%@    ", [self axisStringWithValue:adata.yt_techMA2]];
    
    return [NSArray arrayWithObjects:string1,string2,string3,nil];
}

/**
 * 指标字符串 长按手势 查询层（十字线） 出现 时显示
 */
- (NSAttributedString *)attrStringWithIndex:(NSInteger)index {
    
    UIColor *color1 = self.configuration.volVOLColor?:[UIColor blackColor];
    UIColor *color2 = self.configuration.volVOLColor_MA1?:[UIColor blackColor];
    UIColor *color3 = self.configuration.volVOLColor_MA2?:[UIColor blackColor];
    
    return [self attrStringWithStringArray:[self infoStringWithIndex:index] colorArr:@[color1,color2,color3]];
}

/**
 * 坐标轴上的文字
 */
- (NSString *)axisStringWithValue:(double)value {
    int digit = 0;
    int unitTa = YTSC_NUMBER;
    double afloatTa = [YT_KLineChartStringFormat adjustFloatWithUnit:value unit:&unitTa];
    double span = self.chartScaler.max - self.chartScaler.min;
    if (YTSC_NUMBER != unitTa) {digit = 2 ; digit = YT_TEXT_ADJUST_DIGIT(value, digit, span);}

    return [YT_KLineChartStringFormat floatToString:afloatTa unit:unitTa digit:digit];
}

- (void)initSubLayers {
    
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (!_positiveLayer) {
        _positiveLayer = [CAShapeLayer layer];
        _positiveLayer.frame = rect;
        _positiveLayer.lineWidth = 0;
        [self addSublayer:_positiveLayer];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_positiveLayer)];
    }
    if (!_negativeLayer) {
        _negativeLayer = [CAShapeLayer layer];
        _negativeLayer.frame = rect;
        [self addSublayer:_negativeLayer];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_negativeLayer)];
    }
    if (!_line_VOL_MA1) {
        _line_VOL_MA1 = [CAShapeLayer layer];
        _line_VOL_MA1.frame = rect;
        [self addSublayer:_line_VOL_MA1];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_VOL_MA1)];
    }
    if (!_line_VOL_MA2) {
        _line_VOL_MA2 = [CAShapeLayer layer];
        _line_VOL_MA2.frame = rect;
        [self addSublayer:_line_VOL_MA2];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_VOL_MA2)];
    }
}

/**
 layer 初始化配置
 */
- (void)configLayer {
    [self initSubLayers];
    
    self.positiveLayer.strokeColor = self.configuration.riseColor.CGColor;
    self.positiveLayer.fillColor = [UIColor clearColor].CGColor;
    self.positiveLayer.lineWidth = self.configuration.volVOLBarLineWidth;
    
    self.negativeLayer.strokeColor = self.configuration.fallColor.CGColor;
    self.negativeLayer.fillColor = self.configuration.fallColor.CGColor;
    self.negativeLayer.lineWidth = self.configuration.volVOLBarLineWidth;
    
    self.line_VOL_MA1.strokeColor = self.configuration.volVOLColor_MA1.CGColor;
    self.line_VOL_MA1.fillColor = [UIColor clearColor].CGColor;
    self.line_VOL_MA1.lineWidth = self.configuration.volVOLLineWidth;
    
    self.line_VOL_MA2.strokeColor = self.configuration.volVOLColor_MA2.CGColor;
    self.line_VOL_MA2.fillColor = [UIColor clearColor].CGColor;
    self.line_VOL_MA2.lineWidth = self.configuration.volVOLLineWidth;
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
    
    // 柱
    CGMutablePathRef ref_p = CGPathCreateMutable();
    CGMutablePathRef ref_n = CGPathCreateMutable();
    
    [self _updateCandleArrayWithRange:range positive:ref_p negative:ref_n];
    
    _positiveLayer.path = ref_p;
    _negativeLayer.path = ref_n;
    
    CGPathRelease(ref_p);
    CGPathRelease(ref_n);
    
    // 移动均量线
    YT_AxisYScaler axisYScaler = self.chartScaler.axisYScaler;
    YT_AxisXScaler axisXScaler = self.chartScaler.axisXScaler;
    
    [_klineDataArray layer:_line_VOL_MA1 addVolPoints:range notMoveMinLoc:5 getter:@selector(yt_techMA1) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_klineDataArray layer:_line_VOL_MA2 addVolPoints:range notMoveMinLoc:10 getter:@selector(yt_techMA2) axisXScaler:axisXScaler axisYScaler:axisYScaler];
}

- (void)_updateCandleArrayWithRange:(NSRange)range positive:(CGMutablePathRef)ref_p negative:(CGMutablePathRef)ref_n {
    NSInteger count = NSMaxRange(range);
    YT_AxisYScaler axisYScaler = self.chartScaler.axisYScaler;
    YT_AxisXScaler axisXScaler = self.chartScaler.axisXScaler;
    CGFloat barWidth = self.chartScaler.shapeWidth;
    double baselinePoint_y = axisYScaler(self.chartScaler.min);
    
    for (NSInteger idx = range.location; idx < count; idx++) {
        id <YT_StockKlineData> data = [_klineDataArray objectAtIndex:idx];
        YTSCFloat afloat   = data.yt_volumeOfTransactions;
        
        CGFloat x = axisXScaler(idx);//中心点
        CGFloat aPointY = axisYScaler(afloat);
        
        CGRect rect;
        rect.origin = CGPointMake(x - barWidth/ 2, aPointY);
        rect.size = CGSizeMake(barWidth, baselinePoint_y - aPointY);
        
        YTSCFloat openPrice  = data.yt_openPrice;
        YTSCFloat closePrice = data.yt_closePrice;
        if (openPrice <= closePrice) { //red
            CGPathAddRect(ref_p, NULL, rect);
        } else { //green
            CGPathAddRect(ref_n, NULL, rect);
        }
    }
}





@end


