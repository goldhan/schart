//
//  YT_KDJLayer.m
//  KDS_Phone
//
//  Created by yangjinming on 2018/6/5.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_KDJLayer.h"

@interface YT_KDJLayer()<YT_KDJLayerConfig>
#pragma mark - 线

@property (nonatomic, strong) CAShapeLayer * line_KDJ_K;
@property (nonatomic, strong) CAShapeLayer * line_KDJ_D;
@property (nonatomic, strong) CAShapeLayer * line_KDJ_J;
@end

@implementation YT_KDJLayer
@synthesize volKDJLineWidth = _volKDJLineWidth;
@synthesize volKDJColor_K = _volKDJColor_K;
@synthesize volKDJColor_D = _volKDJColor_D;
@synthesize volKDJColor_J = _volKDJColor_J;

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _volKDJLineWidth  = 1;
        _volKDJColor_K = [UIColor blueColor]; // 子层颜色
        _volKDJColor_D  = [UIColor yellowColor];  // 子层颜色
        _volKDJColor_J  = [UIColor redColor];  // 子层颜色
    }
    return self;
}

#pragma mark - getter

- (id<YT_KDJLayerConfig>)configuration {
    if (_configuration) {
        return _configuration;
    }
    return self;
}

#pragma mark - 功能

/**
 * titile @"KDJ(9,3,3)"
 */
- (NSAttributedString *)titleAttributedString {
    NSString * string = [NSString stringWithFormat:@"KDJ(%d,%d,%d)",DAYS_RSV,DAYS_RSVMA,DAYS_KMA];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:string];
    return attrString;
}

- (NSArray<NSString *> *)infoStringWithIndex:(NSInteger)index {
    id <YT_StockKDJHandle> adata = [self.dataArray objectAtIndex:index];
    int digit = self.textDecimalPlaces;
    
    NSString * string1 = [NSString stringWithFormat:@"K:%.*f    ",digit, adata.cache_K];
    NSString * string2 = [NSString stringWithFormat:@"D:%.*f    ",digit, adata.cache_D];
    NSString * string3 = [NSString stringWithFormat:@"J:%.*f    ",digit, adata.cache_J];
    
    return [NSArray arrayWithObjects:string1,string2,string3,nil];
}

/**
 * 指标字符串 长按手势 查询层（十字线） 出现 时显示
 */
- (NSAttributedString *)attrStringWithIndex:(NSInteger)index {
    
    UIColor *color1 = self.configuration.volKDJColor_K?:[UIColor blackColor];
    UIColor *color2 = self.configuration.volKDJColor_D?:[UIColor blackColor];
    UIColor *color3 = self.configuration.volKDJColor_J?:[UIColor blackColor];
    
    return [self attrStringWithStringArray:[self infoStringWithIndex:index] colorArr:@[color1,color2,color3]];
}

- (void)initSubLayers {
    
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (!_line_KDJ_K) {
        _line_KDJ_K = [CAShapeLayer layer];
        _line_KDJ_K.frame = rect;
        [self addSublayer:_line_KDJ_K];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_KDJ_K)];
    }
    if (!_line_KDJ_D) {
        _line_KDJ_D = [CAShapeLayer layer];
        _line_KDJ_D.frame = rect;
        [self addSublayer:_line_KDJ_D];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_KDJ_D)];
    }
    if (!_line_KDJ_J) {
        _line_KDJ_J = [CAShapeLayer layer];
        _line_KDJ_J.frame = rect;
        [self addSublayer:_line_KDJ_J];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_KDJ_J)];
    }
}

/**
 layer 初始化配置
 */
- (void)configLayer {
    [self initSubLayers];
    
    self.line_KDJ_K.strokeColor = self.configuration.volKDJColor_K.CGColor;
    self.line_KDJ_K.fillColor = [UIColor clearColor].CGColor;
    self.line_KDJ_K.lineWidth = self.configuration.volKDJLineWidth;
    
    self.line_KDJ_D.strokeColor = self.configuration.volKDJColor_D.CGColor;
    self.line_KDJ_D.fillColor = [UIColor clearColor].CGColor;
    self.line_KDJ_D.lineWidth = self.configuration.volKDJLineWidth;
    
    self.line_KDJ_J.strokeColor = self.configuration.volKDJColor_J.CGColor;
    self.line_KDJ_J.fillColor = [UIColor clearColor].CGColor;
    self.line_KDJ_J.lineWidth = self.configuration.volKDJLineWidth;
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
    
    [_dataArray layer:_line_KDJ_K addPoints:range getter:@selector(cache_K) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_line_KDJ_D addPoints:range getter:@selector(cache_D) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_line_KDJ_J addPoints:range getter:@selector(cache_J) axisXScaler:axisXScaler axisYScaler:axisYScaler];
}
@end
