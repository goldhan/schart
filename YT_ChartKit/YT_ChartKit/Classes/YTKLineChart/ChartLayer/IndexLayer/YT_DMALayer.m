//
//  YT_DMALayer.m
//  KDS_Phone
//
//  Created by ChenRui Hu on 2018/5/29.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_DMALayer.h"

@interface YT_DMALayer () <YT_DMALayerConfig>

#pragma mark - 线

@property (nonatomic, strong) CAShapeLayer *line_DMA;
@property (nonatomic, strong) CAShapeLayer *line_AMA;

@end

@implementation YT_DMALayer
@synthesize volDMALineWidth = _volDMALineWidth;
@synthesize volDMAColor_DMA = _volDMAColor_DMA;
@synthesize volDMAColor_AMA = _volDMAColor_AMA;

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _volDMALineWidth  = 1;
        _volDMAColor_DMA = [UIColor blueColor]; // 子层颜色
        _volDMAColor_AMA  = [UIColor yellowColor];  // 子层颜色
    }
    return self;
}

#pragma mark - getter

- (id<YT_DMALayerConfig>)configuration {
    if (_configuration) {
        return _configuration;
    }
    return self;
}

#pragma mark - 功能

/**
 * titile @"DMA(10,50,10)";
 */
- (NSAttributedString *)titleAttributedString {
    NSString * string = [NSString stringWithFormat:@"DMA(%d,%d,%d)",DAYS_DMA10,DAYS_DMA50,DAYS_DMA_DIFMA10];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:string];
    return attrString;
}

- (NSArray<NSString *> *)infoStringWithIndex:(NSInteger)index {
    
    id <YT_StockDMAHandle> adata = [self.dataArray objectAtIndex:index];
    int digit = self.textDecimalPlaces;
    
    NSString * string1 = [NSString stringWithFormat:@"DIF:%.*f    ",digit, adata.cache_DMA];
    NSString * string2 = [NSString stringWithFormat:@"DIFMA:%.*f    ",digit, adata.cache_AMA];
    
    return [NSArray arrayWithObjects:string1, string2, nil];
}

/**
 * 指标字符串 长按手势 查询层（十字线） 出现 时显示
 */
- (NSAttributedString *)attrStringWithIndex:(NSInteger)index {
    
    UIColor *color1 = self.configuration.volDMAColor_DMA?:[UIColor blackColor];
    UIColor *color2 = self.configuration.volDMAColor_AMA?:[UIColor blackColor];
    
    return [self attrStringWithStringArray:[self infoStringWithIndex:index] colorArr:@[color1,color2]];
}

- (void)initSubLayers {
    
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (!_line_DMA) {
        _line_DMA = [CAShapeLayer layer];
        _line_DMA.frame = rect;
        [self addSublayer:_line_DMA];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_DMA)];
    }
    if (!_line_AMA) {
        _line_AMA = [CAShapeLayer layer];
        _line_AMA.frame = rect;
        [self addSublayer:_line_AMA];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_AMA)];
    }
}

/**
 layer 初始化配置
 */
- (void)configLayer {
    [self initSubLayers];
    
    self.line_DMA.strokeColor = self.configuration.volDMAColor_DMA.CGColor;
    self.line_DMA.fillColor = [UIColor clearColor].CGColor;
    self.line_DMA.lineWidth = self.configuration.volDMALineWidth;
    
    self.line_AMA.strokeColor = self.configuration.volDMAColor_AMA.CGColor;
    self.line_AMA.fillColor = [UIColor clearColor].CGColor;
    self.line_AMA.lineWidth = self.configuration.volDMALineWidth;
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
    
    [_dataArray layer:_line_DMA addPoints:range getter:@selector(cache_DMA) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_line_AMA addPoints:range getter:@selector(cache_AMA) axisXScaler:axisXScaler axisYScaler:axisYScaler];
}

@end
