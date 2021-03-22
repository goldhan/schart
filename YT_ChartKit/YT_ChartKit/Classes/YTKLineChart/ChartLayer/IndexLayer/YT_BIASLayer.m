//
//  YT_BIASLayer.m
//  KDS_Phone
//
//  Created by yangjinming on 2018/5/31.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_BIASLayer.h"

@interface YT_BIASLayer()<YT_BIASLayerConfig>

#pragma mark - 线
@property (nonatomic, strong) CAShapeLayer *line_BIAS6;
@property (nonatomic, strong) CAShapeLayer *line_BIAS12;
@property (nonatomic, strong) CAShapeLayer *line_BIAS24;
@end

@implementation YT_BIASLayer
@synthesize kLineBIASLineWidth = _kLineMALineWidth;
@synthesize volBIASColor_BIAS6 = _volBIASColor_BIAS6;
@synthesize volBIASColor_BIAS12 = _volBIASColor_BIAS12;
@synthesize volBIASColor_BIAS24 = _volBIASColor_BIAS24;

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _kLineMALineWidth  = 1;
        _volBIASColor_BIAS6 = [UIColor blueColor]; // 子层颜色
        _volBIASColor_BIAS12 = [UIColor purpleColor]; // 子层颜色
        _volBIASColor_BIAS24 = [UIColor redColor]; // 子层颜色
    }
    return self;
}

#pragma mark - getter
-(id<YT_BIASLayerConfig>)configuration {
    if (_configuration) {
        return _configuration;
    }
    return self;
}

#pragma mark - 功能

/**
 * titile @"BIAS(6,12,24)"
 */
- (NSAttributedString *)titleAttributedString {
    NSString * string = [NSString stringWithFormat:@"BIAS(%d,%d,%d)",DAYS_BIAS6,DAYS_BIAS12,DAYS_BIAS24];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:string];
    return attrString;
}

- (NSArray<NSString *> *)infoStringWithIndex:(NSInteger)index {
    
    id <YT_StockBIASHandle> adata = [self.dataArray objectAtIndex:index];
    int digit = self.textDecimalPlaces;
    
    NSString * string1 = [NSString stringWithFormat:@"BIAS1:%.*f    ",digit, adata.cache_BIAS6];
    NSString * string2 = [NSString stringWithFormat:@"BIAS2:%.*f    ",digit, adata.cache_BIAS12];
    NSString * string3 = [NSString stringWithFormat:@"BIAS3:%.*f    ",digit, adata.cache_BIAS24];
    
    return [NSArray arrayWithObjects:string1, string2, string3, nil];
}

/**
 * 指标字符串 长按手势 查询层（十字线） 出现 时显示
 */
- (NSAttributedString *)attrStringWithIndex:(NSInteger)index {
    
    UIColor *color1 = self.configuration.volBIASColor_BIAS6?:[UIColor blackColor];
    UIColor *color2 = self.configuration.volBIASColor_BIAS12?:[UIColor blackColor];
    UIColor *color3 = self.configuration.volBIASColor_BIAS24?:[UIColor blackColor];
    
    return [self attrStringWithStringArray:[self infoStringWithIndex:index] colorArr:@[color1,color2,color3]];
}

- (void)initSubLayers {
    
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (!_line_BIAS6) {
        _line_BIAS6 = [CAShapeLayer layer];
        _line_BIAS6.frame = rect;
        [self addSublayer:_line_BIAS6];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_BIAS6)];
    }
    if (!_line_BIAS12) {
        _line_BIAS12 = [CAShapeLayer layer];
        _line_BIAS12.frame = rect;
        [self addSublayer:_line_BIAS12];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_BIAS12)];
    }
    if (!_line_BIAS24) {
        _line_BIAS24 = [CAShapeLayer layer];
        _line_BIAS24.frame = rect;
        [self addSublayer:_line_BIAS24];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_BIAS24)];
    }
}

/**
 layer 初始化配置
 */
- (void)configLayer {
    [self initSubLayers];
    
    self.line_BIAS6.strokeColor = self.configuration.volBIASColor_BIAS6.CGColor;
    self.line_BIAS6.fillColor = [UIColor clearColor].CGColor;
    self.line_BIAS6.lineWidth = self.configuration.kLineBIASLineWidth;
    
    self.line_BIAS12.strokeColor = self.configuration.volBIASColor_BIAS12.CGColor;
    self.line_BIAS12.fillColor = [UIColor clearColor].CGColor;
    self.line_BIAS12.lineWidth = self.configuration.kLineBIASLineWidth;
    
    self.line_BIAS24.strokeColor = self.configuration.volBIASColor_BIAS24.CGColor;
    self.line_BIAS24.fillColor = [UIColor clearColor].CGColor;
    self.line_BIAS24.lineWidth = self.configuration.kLineBIASLineWidth;
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
    
    [_dataArray layer:_line_BIAS6 addPoints:range getter:@selector(cache_BIAS6) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_line_BIAS12 addPoints:range getter:@selector(cache_BIAS12) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_line_BIAS24 addPoints:range getter:@selector(cache_BIAS24) axisXScaler:axisXScaler axisYScaler:axisYScaler];
}
@end
