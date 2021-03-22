//
//  YT_RSILayer.m
//  KDS_Phone
//
//  Created by yangjinming on 2018/6/4.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_RSILayer.h"

@interface YT_RSILayer()<YT_RSILayerConfig>
#pragma mark - 线

@property (nonatomic, strong) CAShapeLayer *line_RSI6;
@property (nonatomic, strong) CAShapeLayer *line_RSI12;
@property (nonatomic, strong) CAShapeLayer *line_RSI24;

@end

@implementation YT_RSILayer
@synthesize volRSILineWidth = _volRSILineWidth;
@synthesize volRSIColor_RSI6 = _volRSIColor_RSI6;
@synthesize volRSIColor_RSI12 = _volRSIColor_RSI12;
@synthesize volRSIColor_RSI24 = _volRSIColor_RSI24;

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _volRSILineWidth  = 1;
        _volRSIColor_RSI6 = [UIColor blueColor]; // 子层颜色
        _volRSIColor_RSI12 = [UIColor redColor]; // 子层颜色
        _volRSIColor_RSI24 = [UIColor purpleColor]; // 子层颜色
    }
    return self;
}

#pragma mark - getter

- (id<YT_RSILayerConfig>)configuration {
    if (_configuration) {
        return _configuration;
    }
    return self;
}

#pragma mark - 功能

/**
 * titile @"RSI(6,12,24)"
 */
- (NSAttributedString *)titleAttributedString {
    NSString * string = [[NSString alloc] initWithFormat:@"RSI(%d,%d,%d)",DAYS_RSI6,DAYS_RSI12,DAYS_RSI24];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:string];
    return attrString;
}

- (NSArray<NSString *> *)infoStringWithIndex:(NSInteger)index {
    id <YT_StockRSIHandle> adata = [self.dataArray objectAtIndex:index];
    int digit = self.textDecimalPlaces;
    
    NSString * string1 = [NSString stringWithFormat:@"RSI1:%.*f    ",digit, adata.cache_RSI6];
    NSString * string2 = [NSString stringWithFormat:@"RSI2:%.*f    ",digit, adata.cache_RSI12];
    NSString * string3 = [NSString stringWithFormat:@"RSI3:%.*f    ",digit, adata.cache_RSI24];
    
    return [NSArray arrayWithObjects:string1,string2,string3,nil];
}

/**
 * 指标字符串 长按手势 查询层（十字线） 出现 时显示
 */
- (NSAttributedString *)attrStringWithIndex:(NSInteger)index {
    
    UIColor *color1 = self.configuration.volRSIColor_RSI6?:[UIColor blackColor];
    UIColor *color2 = self.configuration.volRSIColor_RSI12?:[UIColor blackColor];
    UIColor *color3 = self.configuration.volRSIColor_RSI24?:[UIColor blackColor];
    
    return [self attrStringWithStringArray:[self infoStringWithIndex:index] colorArr:@[color1,color2,color3]];
}

- (void)initSubLayers {
    
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (!_line_RSI6) {
        _line_RSI6 = [CAShapeLayer layer];
        _line_RSI6.frame = rect;
        [self addSublayer:_line_RSI6];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_RSI6)];
    }
    if (!_line_RSI12) {
        _line_RSI12 = [CAShapeLayer layer];
        _line_RSI12.frame = rect;
        [self addSublayer:_line_RSI12];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_RSI12)];
    }
    if (!_line_RSI24) {
        _line_RSI24 = [CAShapeLayer layer];
        _line_RSI24.frame = rect;
        [self addSublayer:_line_RSI24];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_RSI24)];
    }
}

/**
 layer 初始化配置
 */
- (void)configLayer {
    [self initSubLayers];
    
    self.line_RSI6.strokeColor = self.configuration.volRSIColor_RSI6.CGColor;
    self.line_RSI6.fillColor = [UIColor clearColor].CGColor;
    self.line_RSI6.lineWidth = self.configuration.volRSILineWidth;
    
    self.line_RSI12.strokeColor = self.configuration.volRSIColor_RSI12.CGColor;
    self.line_RSI12.fillColor = [UIColor clearColor].CGColor;
    self.line_RSI12.lineWidth = self.configuration.volRSILineWidth;
    
    self.line_RSI24.strokeColor = self.configuration.volRSIColor_RSI24.CGColor;
    self.line_RSI24.fillColor = [UIColor clearColor].CGColor;
    self.line_RSI24.lineWidth = self.configuration.volRSILineWidth;
}

/**
 实时更新 layer
 
 @param range 数据数组绘制区间
 */
- (void)updateLayerWithRange:(NSRange)range {
    [self _updateLayerWithRange:range];
}

- (void)_updateLayerWithRange:(NSRange)range {
    
    YT_AxisYScaler axisYScaler = self.chartScaler.axisYScaler;
    YT_AxisXScaler axisXScaler = self.chartScaler.axisXScaler;
    
    [_dataArray layer:_line_RSI6 addPoints:range getter:@selector(cache_RSI6) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_line_RSI12 addPoints:range getter:@selector(cache_RSI12) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_line_RSI24 addPoints:range getter:@selector(cache_RSI24) axisXScaler:axisXScaler axisYScaler:axisYScaler];
}
@end
