//
//  YT_CRLayer.m
//  KDS_Phone
//
//  Created by ChenRui Hu on 2018/6/5.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_CRLayer.h"

@interface YT_CRLayer () <YT_CRLayerConfig>

#pragma mark - 线

@property (nonatomic, strong) CAShapeLayer *line_CR;
@property (nonatomic, strong) CAShapeLayer *line_CR_MA10;
@property (nonatomic, strong) CAShapeLayer *line_CR_MA20;
@property (nonatomic, strong) CAShapeLayer *line_CR_MA40;
@property (nonatomic, strong) CAShapeLayer *line_CR_MA62;

@end

@implementation YT_CRLayer
@synthesize volCRLineWidth     = _volCRLineWidth;
@synthesize volCRColor_CR      = _volCRColor_CR;
@synthesize volCRColor_CR_MA10 = _volCRColor_CR_MA10;
@synthesize volCRColor_CR_MA20 = _volCRColor_CR_MA20;
@synthesize volCRColor_CR_MA40 = _volCRColor_CR_MA40;
@synthesize volCRColor_CR_MA62 = _volCRColor_CR_MA62;

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _volCRLineWidth      = 1;
        _volCRColor_CR       = [UIColor blueColor];    // 子层颜色
        _volCRColor_CR_MA10  = [UIColor yellowColor];  // 子层颜色
        _volCRColor_CR_MA20  = [UIColor purpleColor];  // 子层颜色
        _volCRColor_CR_MA40  = [UIColor greenColor];   // 子层颜色
        _volCRColor_CR_MA62  = [UIColor blueColor];    // 子层颜色
    }
    return self;
}

#pragma mark - getter

- (id<YT_CRLayerConfig>)configuration {
    if (_configuration) {
        return _configuration;
    }
    return self;
}

#pragma mark - 功能

/**
 * titile @"CR(26,10,20)"
 */
- (NSAttributedString *)titleAttributedString {
    
    NSString * string = [NSString stringWithFormat:@"CR(%d,%d,%d)",DAYS_CR26,DAYS_CR_MA10,DAYS_CR_MA20];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:string];
    return attrString;
}

- (NSArray<NSString *> *)infoStringWithIndex:(NSInteger)index {
    
    id <YT_StockCRHandle> adata = [self.dataArray objectAtIndex:index];
    int digit = self.textDecimalPlaces;
    
    NSString * string1 = [NSString stringWithFormat:@"CR:%.*f    ",digit, adata.cache_CR];
    NSString * string2 = [NSString stringWithFormat:@"MA1:%.*f    ",digit, adata.cache_CR_MA10];
    NSString * string3 = [NSString stringWithFormat:@"MA2:%.*f    ",digit, adata.cache_CR_MA20];
    
    return [NSArray arrayWithObjects:string1, string2, string3, nil];
}

/**
 * 指标字符串 长按手势 查询层（十字线） 出现 时显示
 */
- (NSAttributedString *)attrStringWithIndex:(NSInteger)index {
    
    UIColor *color1 = self.configuration.volCRColor_CR?:[UIColor blackColor];
    UIColor *color2 = self.configuration.volCRColor_CR_MA10?:[UIColor blackColor];
    UIColor *color3 = self.configuration.volCRColor_CR_MA20?:[UIColor blackColor];
    
    return [self attrStringWithStringArray:[self infoStringWithIndex:index] colorArr:@[color1,color2,color3]];
}

- (void)initSubLayers {
    
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (!_line_CR) {
        _line_CR = [CAShapeLayer layer];
        _line_CR.frame = rect;
        [self addSublayer:_line_CR];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_CR)];
    }
    if (!_line_CR_MA10) {
        _line_CR_MA10 = [CAShapeLayer layer];
        _line_CR_MA10.frame = rect;
        [self addSublayer:_line_CR_MA10];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_CR_MA10)];
    }
    if (!_line_CR_MA20) {
        _line_CR_MA20 = [CAShapeLayer layer];
        _line_CR_MA20.frame = rect;
        [self addSublayer:_line_CR_MA20];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_CR_MA20)];
    }
    
    // 为了兼容之前错误的版本，以下两根线不添加
    /*
    if (!_line_CR_MA40) {
        _line_CR_MA40 = [CAShapeLayer layer];
        _line_CR_MA40.frame = rect;
        [self addSublayer:_line_CR_MA40];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_CR_MA40)];
    }
    if (!_line_CR_MA62) {
        _line_CR_MA62 = [CAShapeLayer layer];
        _line_CR_MA62.frame = rect;
        [self addSublayer:_line_CR_MA62];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_CR_MA62)];
    }
     */
}

/**
 layer 初始化配置
 */
- (void)configLayer {
    [self initSubLayers];
    
    self.line_CR.strokeColor = self.configuration.volCRColor_CR.CGColor;
    self.line_CR.fillColor = [UIColor clearColor].CGColor;
    self.line_CR.lineWidth = self.configuration.volCRLineWidth;
    
    self.line_CR_MA10.strokeColor = self.configuration.volCRColor_CR_MA10.CGColor;
    self.line_CR_MA10.fillColor = [UIColor clearColor].CGColor;
    self.line_CR_MA10.lineWidth = self.configuration.volCRLineWidth;
    
    self.line_CR_MA20.strokeColor = self.configuration.volCRColor_CR_MA20.CGColor;
    self.line_CR_MA20.fillColor = [UIColor clearColor].CGColor;
    self.line_CR_MA20.lineWidth = self.configuration.volCRLineWidth;
    
    self.line_CR_MA40.strokeColor = self.configuration.volCRColor_CR_MA40.CGColor;
    self.line_CR_MA40.fillColor = [UIColor clearColor].CGColor;
    self.line_CR_MA40.lineWidth = self.configuration.volCRLineWidth;
    
    self.line_CR_MA62.strokeColor = self.configuration.volCRColor_CR_MA62.CGColor;
    self.line_CR_MA62.fillColor = [UIColor clearColor].CGColor;
    self.line_CR_MA62.lineWidth = self.configuration.volCRLineWidth;
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
    
    [_dataArray layer:_line_CR addPoints:range getter:@selector(cache_CR) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_line_CR_MA10 addPoints:range getter:@selector(cache_CR_MA10) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_line_CR_MA20 addPoints:range getter:@selector(cache_CR_MA20) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_line_CR_MA40 addPoints:range getter:@selector(cache_CR_MA40) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_line_CR_MA62 addPoints:range getter:@selector(cache_CR_MA62) axisXScaler:axisXScaler axisYScaler:axisYScaler];
}

@end
