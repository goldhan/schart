//
//  YT_WRLayer.m
//  KDS_Phone
//
//  Created by ChenRui Hu on 2018/6/1.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_WRLayer.h"
@interface YT_WRLayer () <YT_WRLayerConfig>

#pragma mark - 线

@property (nonatomic, strong) CAShapeLayer *line_WR10;
@property (nonatomic, strong) CAShapeLayer *line_WR6;

@end

@implementation YT_WRLayer
@synthesize volWRLineWidth = _volWRLineWidth;
@synthesize volWRColor_WR10 = _volWRColor_WR10;
@synthesize volWRColor_WR6 = _volWRColor_WR6;

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _volWRLineWidth  = 1;
        _volWRColor_WR10 = [UIColor blueColor]; // 子层颜色
        _volWRColor_WR6  = [UIColor yellowColor];  // 子层颜色
    }
    return self;
}

#pragma mark - getter

- (id<YT_WRLayerConfig>)configuration {
    if (_configuration) {
        return _configuration;
    }
    return self;
}

#pragma mark - 功能

/**
 * titile @"WR(10,6)";
 */
- (NSAttributedString *)titleAttributedString {
    NSString * string = [NSString stringWithFormat:@"WR(%d,%d)",DAYS_WR10,DAYS_WR6];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:string];
    return attrString;
}

- (NSArray<NSString *> *)infoStringWithIndex:(NSInteger)index {
    id <YT_StockWRHandle> adata = [self.dataArray objectAtIndex:index];
    int digit = self.textDecimalPlaces;
    NSString * string1 = [NSString stringWithFormat:@"WR1:%.*f    ",digit, adata.cache_WR10];
    NSString * string2 = [NSString stringWithFormat:@"WR2:%.*f    ",digit, adata.cache_WR6];
    return [NSArray arrayWithObjects:string1,string2,nil];
}

/**
 * 指标字符串 长按手势 查询层（十字线） 出现 时显示
 */
- (NSAttributedString *)attrStringWithIndex:(NSInteger)index {
    UIColor *color1 = self.configuration.volWRColor_WR10?:[UIColor blackColor];
    UIColor *color2 = self.configuration.volWRColor_WR6?:[UIColor blackColor];
    return [self attrStringWithStringArray:[self infoStringWithIndex:index] colorArr:@[color1,color2]];
}

- (void)initSubLayers {
    
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (!_line_WR10) {
        _line_WR10 = [CAShapeLayer layer];
        _line_WR10.frame = rect;
        [self addSublayer:_line_WR10];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_WR10)];
    }
    if (!_line_WR6) {
        _line_WR6 = [CAShapeLayer layer];
        _line_WR6.frame = rect;
        [self addSublayer:_line_WR6];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_WR6)];
    }
}

/**
 layer 初始化配置
 */
- (void)configLayer {
    [self initSubLayers];
    
    self.line_WR10.strokeColor = self.configuration.volWRColor_WR10.CGColor;
    self.line_WR10.fillColor = [UIColor clearColor].CGColor;
    self.line_WR10.lineWidth = self.configuration.volWRLineWidth;
    
    self.line_WR6.strokeColor = self.configuration.volWRColor_WR6.CGColor;
    self.line_WR6.fillColor = [UIColor clearColor].CGColor;
    self.line_WR6.lineWidth = self.configuration.volWRLineWidth;
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
    
    [_dataArray layer:_line_WR10 addPoints:range getter:@selector(cache_WR10) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_line_WR6 addPoints:range getter:@selector(cache_WR6) axisXScaler:axisXScaler axisYScaler:axisYScaler];
}

@end
