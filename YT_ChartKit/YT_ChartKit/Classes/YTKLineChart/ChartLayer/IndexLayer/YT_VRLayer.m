//
//  YT_VRLayer.m
//  KDS_Phone
//
//  Created by yangjinming on 2018/6/6.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_VRLayer.h"

@interface YT_VRLayer()<YT_VRLayerConfig>
#pragma mark - 线

@property (nonatomic, strong) CAShapeLayer * line_VR;
@property (nonatomic, strong) CAShapeLayer * line_VR_MA6;
@end

@implementation YT_VRLayer
@synthesize volVRLineWidth = _volVRLineWidth;
@synthesize volVRColor = _volVRColor;
@synthesize volVRColor_MA6 = _volVRColor_MA6;

- (instancetype)init {
    self = [super init];
    if (self) {
        
        _volVRLineWidth  = 1;
        _volVRColor = [UIColor blueColor]; // 子层颜色
        _volVRColor_MA6  = [UIColor yellowColor];  // 子层颜色
    }
    return self;
}

#pragma mark - getter

- (id<YT_VRLayerConfig>)configuration {
    if (_configuration) {
        return _configuration;
    }
    return self;
}

#pragma mark - 功能

/**
 * titile @"VR(26,6)"
 */
- (NSAttributedString *)titleAttributedString {
    NSString * string = [NSString stringWithFormat:@"VR(%d,%d)",DAYS_VR,DAYS_MAVR];
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:string];
    return attrString;
}

- (NSArray<NSString *> *)infoStringWithIndex:(NSInteger)index {
    id <YT_StockVRHandle> adata = [self.dataArray objectAtIndex:index];
    NSString * string1 = [NSString stringWithFormat:@"VR:%.2f    ", adata.cache_VR];
    NSString * string2 = [NSString stringWithFormat:@"MAVR:%.2f    ", adata.cache_VR_MA6];
    return [NSArray arrayWithObjects:string1,string2,nil];
}

/**
 * 指标字符串 长按手势 查询层（十字线） 出现 时显示
 */
- (NSAttributedString *)attrStringWithIndex:(NSInteger)index {
    UIColor *color1 = self.configuration.volVRColor?:[UIColor blackColor];
    UIColor *color2 = self.configuration.volVRColor_MA6?:[UIColor blackColor];
    return [self attrStringWithStringArray:[self infoStringWithIndex:index] colorArr:@[color1,color2]];
}

/**
 * 坐标轴上的文字
 */
- (NSString *)axisStringWithValue:(double)value {
    return [NSString stringWithFormat:@"%.2f", value];
}

- (void)initSubLayers {
    
    CGRect rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (!_line_VR) {
        _line_VR = [CAShapeLayer layer];
        _line_VR.frame = rect;
        [self addSublayer:_line_VR];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_VR)];
    }
    if (!_line_VR_MA6) {
        _line_VR_MA6 = [CAShapeLayer layer];
        _line_VR_MA6.frame = rect;
        [self addSublayer:_line_VR_MA6];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(_line_VR_MA6)];
    }
}

/**
 layer 初始化配置
 */
- (void)configLayer {
    [self initSubLayers];
    
    self.line_VR.strokeColor = self.configuration.volVRColor.CGColor;
    self.line_VR.fillColor = [UIColor clearColor].CGColor;
    self.line_VR.lineWidth = self.configuration.volVRLineWidth;
    
    self.line_VR_MA6.strokeColor = self.configuration.volVRColor_MA6.CGColor;
    self.line_VR_MA6.fillColor = [UIColor clearColor].CGColor;
    self.line_VR_MA6.lineWidth = self.configuration.volVRLineWidth;
    
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
    
    [_dataArray layer:_line_VR addPoints:range getter:@selector(cache_VR) axisXScaler:axisXScaler axisYScaler:axisYScaler];
    [_dataArray layer:_line_VR_MA6 addPoints:range getter:@selector(cache_VR_MA6) axisXScaler:axisXScaler axisYScaler:axisYScaler];
}
@end
