//
//  YT_DMILayer.m
//  KDS_Phone
//
//  Created by yangjinming on 2018/6/1.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_DMILayer.h"

@interface YT_DMILayer()<YT_DMILayerConfig>
#pragma mark - 线

@property (nonatomic, strong) CAShapeLayer *line_PDI;
@property (nonatomic, strong) CAShapeLayer *line_MDI;
@property (nonatomic, strong) CAShapeLayer *line_ADX;
@property (nonatomic, strong) CAShapeLayer *line_ADXR;
@end

@implementation YT_DMILayer
@synthesize volDMILineWidth = _volDMILineWidth;
@synthesize volDMIColor_PDI = _volDMIColor_PDI;
@synthesize volDMIColor_MDI = _volDMIColor_MDI;
@synthesize volDMIColor_ADX = _volDMIColor_ADX;
@synthesize volDMIColor_ADXR = _volDMIColor_ADXR;

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _volDMILineWidth  = 1;
        _volDMIColor_PDI = [UIColor blueColor]; // 子层颜色
        _volDMIColor_MDI = [UIColor yellowColor]; // 子层颜色
        _volDMIColor_ADX = [UIColor purpleColor]; // 子层颜色
        _volDMIColor_ADXR = [UIColor redColor]; // 子层颜色
    }
    return self;
}

#pragma mark - getter

- (id<YT_DMILayerConfig>)configuration {
    if (_configuration) {
        return _configuration;
    }
    return self;
}

#pragma mark - 功能

/**
 * titile @"DMI(14,6)";
 */
- (NSAttributedString *)titleAttributedString {
    NSString * string = [NSString stringWithFormat:@"DMI(%d,%d)",DAYS_DMI_DI,DAYS_DMI_ADXR];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:string];
    return attrString;
}

- (NSArray<NSString *> *)infoStringWithIndex:(NSInteger)index {
    id <YT_StockDMIHandle> adata = [self.dataArray objectAtIndex:index];
    int digit = self.textDecimalPlaces;
    
    NSString * string1 = [NSString stringWithFormat:@"PDI:%.*f    ",digit, adata.cache_PDI];
    NSString * string2 = [NSString stringWithFormat:@"MDI:%.*f    ",digit, adata.cache_MDI];
    NSString * string3 = [NSString stringWithFormat:@"ADX:%.*f    ",digit, adata.cache_ADX];
    NSString * string4 = [NSString stringWithFormat:@"ADXR:%.*f    ",digit, adata.cache_ADXR];
    
    return [NSArray arrayWithObjects:string1,string2,string3,string4,nil];
}

/**
 * 指标字符串 长按手势 查询层（十字线） 出现 时显示
 */
- (NSAttributedString *)attrStringWithIndex:(NSInteger)index {
    
    UIColor *color1 = self.configuration.volDMIColor_PDI?:[UIColor blackColor];
    UIColor *color2 = self.configuration.volDMIColor_MDI?:[UIColor blackColor];
    UIColor *color3 = self.configuration.volDMIColor_ADX?:[UIColor blackColor];
    UIColor *color4 = self.configuration.volDMIColor_ADXR?:[UIColor blackColor];
    
    return [self attrStringWithStringArray:[self infoStringWithIndex:index] colorArr:@[color1,color2,color3,color4]];
}

- (void)initSubLayers {
    
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (!_line_PDI) {
        _line_PDI = [CAShapeLayer layer];
        _line_PDI.frame = rect;
        [self addSublayer:_line_PDI];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_PDI)];
    }
    if (!_line_MDI) {
        _line_MDI = [CAShapeLayer layer];
        _line_MDI.frame = rect;
        [self addSublayer:_line_MDI];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_MDI)];
    }
    if (!_line_ADX) {
        _line_ADX = [CAShapeLayer layer];
        _line_ADX.frame = rect;
        [self addSublayer:_line_ADX];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_ADX)];
    }
    if (!_line_ADXR) {
        _line_ADXR = [CAShapeLayer layer];
        _line_ADXR.frame = rect;
        [self addSublayer:_line_ADXR];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_ADXR)];
    }
}

/**
 layer 初始化配置
 */
- (void)configLayer {
    [self initSubLayers];
    
    self.line_PDI.strokeColor = self.configuration.volDMIColor_PDI.CGColor;
    self.line_PDI.fillColor = [UIColor clearColor].CGColor;
    self.line_PDI.lineWidth = self.configuration.volDMILineWidth;
    
    self.line_MDI.strokeColor = self.configuration.volDMIColor_MDI.CGColor;
    self.line_MDI.fillColor = [UIColor clearColor].CGColor;
    self.line_MDI.lineWidth = self.configuration.volDMILineWidth;
    
    self.line_ADX.strokeColor = self.configuration.volDMIColor_ADX.CGColor;
    self.line_ADX.fillColor = [UIColor clearColor].CGColor;
    self.line_ADX.lineWidth = self.configuration.volDMILineWidth;
    
    self.line_ADXR.strokeColor = self.configuration.volDMIColor_ADXR.CGColor;
    self.line_ADXR.fillColor = [UIColor clearColor].CGColor;
    self.line_ADXR.lineWidth = self.configuration.volDMILineWidth;
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
    
    [_dataArray layer:_line_PDI addPoints:range getter:@selector(cache_PDI) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_line_MDI addPoints:range getter:@selector(cache_MDI) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_line_ADX addPoints:range getter:@selector(cache_ADX) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_line_ADXR addPoints:range getter:@selector(cache_ADXR) axisXScaler:axisXScaler axisYScaler:axisYScaler];
}
@end
