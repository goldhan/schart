//
//  YT_OBVLayer.m
//  KDS_Phone
//
//  Created by zhanghao on 2018/6/6.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_OBVLayer.h"
#import "YT_KlineChartStringUtil.h"

@interface YT_OBVLayer () <YT_OBVLayerConfig>

@property (nonatomic, strong) CAShapeLayer *OBVLayer;
@property (nonatomic, strong) CAShapeLayer *OBVMLayer;

@end

@implementation YT_OBVLayer

@synthesize volOBVLineWidth = _volOBVLineWidth;
@synthesize volOBVColor = _volOBVColor;
@synthesize volOBVMColor = _volOBVMColor;

- (instancetype)init {
    self = [super init];
    if (self) {
        _volOBVLineWidth = 1;
        _volOBVColor = [UIColor blueColor]; // 子层颜色
        _volOBVMColor = [UIColor yellowColor];  // 子层颜色
    }
    return self;
}

- (id<YT_OBVLayerConfig>)configuration {
    if (_configuration) {
        return _configuration;
    }
    return self;
}

/**
 * titile @"OBV(30)";
 */
- (NSAttributedString *)titleAttributedString {
    NSString * string = [[NSString alloc] initWithFormat:@"OBV(%d)",DAYS_OBV_MA];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:string];
    return attrString;
}

- (NSArray<NSString *> *)infoStringWithIndex:(NSInteger)index {
    id <YT_StockOBVHandle> adata = _dataArray[index];
    NSString * string1 =  [NSString stringWithFormat:@"OBV:%@    ", [self axisStringWithValue:adata.cache_OBV]];
    NSString * string2 =  [NSString stringWithFormat:@"MOBV:%@    ", [self axisStringWithValue:adata.cache_OBVM]];
    return [NSArray arrayWithObjects:string1,string2,nil];
}


- (NSAttributedString *)attrStringWithIndex:(NSInteger)index {
    UIColor *color1 = self.configuration.volOBVColor?:[UIColor blackColor];
    UIColor *color2 = self.configuration.volOBVMColor?:[UIColor blackColor];
    return [self attrStringWithStringArray:[self infoStringWithIndex:index] colorArr:@[color1,color2]];
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
    if (!_OBVLayer) {
        _OBVLayer = [CAShapeLayer layer];
        _OBVLayer.frame = rect;
        [self addSublayer:_OBVLayer];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_OBVLayer)];
    }
    if (!_OBVMLayer) {
        _OBVMLayer = [CAShapeLayer layer];
        _OBVMLayer.frame = rect;
        [self addSublayer:_OBVMLayer];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_OBVMLayer)];
    }
}

- (void)configLayer {
    [self initSubLayers];
    
    self.OBVLayer.strokeColor = self.configuration.volOBVColor.CGColor;
    self.OBVLayer.fillColor = [UIColor clearColor].CGColor;
    self.OBVLayer.lineWidth = self.configuration.volOBVLineWidth;
    
    self.OBVMLayer.strokeColor = self.configuration.volOBVMColor.CGColor;
    self.OBVMLayer.fillColor = [UIColor clearColor].CGColor;
    self.OBVMLayer.lineWidth = self.configuration.volOBVLineWidth;
}

- (void)updateLayerWithRange:(NSRange)range {
    [self _updateLayerWithRange:range];
}

- (void)_updateLayerWithRange:(NSRange)range {
    YT_AxisYScaler axisYScaler = self.chartScaler.axisYScaler;
    YT_AxisXScaler axisXScaler = self.chartScaler.axisXScaler;
    
    [_dataArray layer:_OBVLayer addPoints:range getter:@selector(cache_OBV) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_OBVMLayer addPoints:range getter:@selector(cache_OBVM) axisXScaler:axisXScaler axisYScaler:axisYScaler];
}

@end
