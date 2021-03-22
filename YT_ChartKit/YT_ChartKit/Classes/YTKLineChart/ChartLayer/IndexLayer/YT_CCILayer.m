//
//  YT_CCILayer.m
//  KDS_Phone
//
//  Created by yangjinming on 2018/6/1.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_CCILayer.h"

@interface YT_CCILayer () <YT_CCILayerConfig>

#pragma mark - 线

@property (nonatomic, strong) CAShapeLayer *line_CCI;

@end

@implementation YT_CCILayer
@synthesize volCCIColor = _volCCIColor;
@synthesize volCCILineWidth = _volCCILineWidth;

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _volCCILineWidth  = 1;
        _volCCIColor = [UIColor blueColor]; // 子层颜色
    }
    return self;
}

#pragma mark - getter

- (id<YT_CCILayerConfig>)configuration {
    if (_configuration) {
        return _configuration;
    }
    return self;
}

#pragma mark - 功能

/**
 * titile @"CCI(14)"
 */
- (NSAttributedString *)titleAttributedString {
    NSString * string = [NSString stringWithFormat:@"CCI(%d)",DAYS_CCI];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:string];
    return attrString;
}

- (NSArray<NSString *> *)infoStringWithIndex:(NSInteger)index {
    id <YT_StockCCIHandle> adata = [self.dataArray objectAtIndex:index];
    int digit = self.textDecimalPlaces;
    NSString * string = [NSString stringWithFormat:@"CCI:%.*f    ",digit, adata.cache_CCI];
    return [NSArray arrayWithObjects:string, nil];
}

/**
 * 指标字符串 长按手势 查询层（十字线） 出现 时显示
 */
- (NSAttributedString *)attrStringWithIndex:(NSInteger)index {
    
    UIColor * color = self.configuration.volCCIColor?:[UIColor blackColor];
    return [self attrStringWithStringArray:[self infoStringWithIndex:index] colorArr:@[color]];
}

- (void)initSubLayers {
    
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (!_line_CCI) {
        _line_CCI = [CAShapeLayer layer];
        _line_CCI.frame = rect;
        [self addSublayer:_line_CCI];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_CCI)];
    }
}

/**
 layer 初始化配置
 */
- (void)configLayer {
    [self initSubLayers];
    
    self.line_CCI.strokeColor = self.configuration.volCCIColor.CGColor;
    self.line_CCI.fillColor = [UIColor clearColor].CGColor;
    self.line_CCI.lineWidth = self.configuration.volCCILineWidth;
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
    
    [_dataArray layer:_line_CCI addPoints:range getter:@selector(cache_CCI) axisXScaler:axisXScaler axisYScaler:axisYScaler];
}
@end
