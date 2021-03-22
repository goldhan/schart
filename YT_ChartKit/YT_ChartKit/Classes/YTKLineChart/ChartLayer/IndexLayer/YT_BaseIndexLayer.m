//
//  YT_BaseIndexLayer.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/25.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_BaseIndexLayer.h"
#define YT_TEXT_ADJUST_DIGIT_READY 1
#import "YT_KlineChartStringUtil.h"

@implementation YT_BaseIndexLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _textUnits = 0;
        _textDecimalPlaces = 2;
    }
    return self;
}

-(NSPointerArray *)autoFullLayoutLayers {
    if (!_autoFullLayoutLayers) {
        _autoFullLayoutLayers = [NSPointerArray weakObjectsPointerArray];
    }
    return _autoFullLayoutLayers;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    NSArray * arr = self.autoFullLayoutLayers.allObjects;
    for (NSUInteger idx = 0; idx < arr.count; idx++) {
        CALayer * obj = arr[idx];
        obj.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }
}

/**
 * titile
 */
- (NSAttributedString *)titleAttributedString { return [[NSAttributedString alloc] initWithString:@""];};


/**
 * 指标字符串组成部分 格式为 k:v
 */
- (NSArray<NSString *> *)infoStringWithIndex:(NSInteger)index {return @[];}

/**
 * 指标字符串 长按手势 查询层（十字线） 出现 时显示
 */
- (NSAttributedString *)attrStringWithIndex:(NSInteger)index {return [[NSAttributedString alloc] initWithString:@""];}

/**
 layer 初始化配置
 */
- (void)configLayer {};

/**
 实时更新 layer
 
 @param range 数据数组绘制区间
 */
- (void)updateLayerWithRange:(NSRange)range {};

#pragma mark  工具方法

- (NSMutableAttributedString *)attrStringWithStringArray:(NSArray<NSString *> *)strArr colorArr:(NSArray<UIColor *> *)colors {
    NSInteger count = MIN(strArr.count, colors.count);
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSString * string ;
    UIColor * color ;
    NSAttributedString * aString ;
    for (int i = 0; i < count; i ++) {
        string = strArr[i];
        color = colors[i];
        aString =  [[NSAttributedString alloc] initWithString:string attributes:@{NSForegroundColorAttributeName : color}];
        [attrString appendAttributedString:aString];
    }
    return attrString;
}

@end

#pragma mark - 工具方法

@implementation NSArray (CAShapeLayerAddPoints)

- (void)layer:(CAShapeLayer *)layer addPointsNotNULL:(NSRange)range getter:(SEL)getter axisXScaler:(YT_AxisXScaler)axisXScaler axisYScaler:(YT_AxisYScaler)axisYScaler {
    if (range.length == 0) return;
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    NSInteger from = range.location;
    NSInteger to = range.location + range.length;
    
    IMP imp = [self.firstObject methodForSelector:getter];
    YTSCFloat (*objGetter)(id obj, SEL getter) = (void *)imp;
    
    NSUInteger i =  from;
    YTSCFloat afloat = objGetter ([self objectAtIndex:i], getter);
    CGPoint point  = CGPointMake(axisXScaler(i), axisYScaler(afloat));
    CGPathMoveToPoint(pathRef, NULL, point.x, point.y);
    i++;
    for (; i < to ; i ++) {
        YTSCFloat afloat = objGetter ([self objectAtIndex:i], getter);
        CGPoint point  = CGPointMake(axisXScaler(i), axisYScaler(afloat));
        CGPathAddLineToPoint(pathRef, NULL, point.x, point.y);
    }
    layer.path = pathRef;
    CGPathRelease(pathRef);
}


- (void)layer:(CAShapeLayer *)layer addPoints:(NSRange)range getter:(SEL)getter axisXScaler:(YT_AxisXScaler)axisXScaler axisYScaler:(YT_AxisYScaler)axisYScaler {
    
    CGMutablePathRef pathRef = CGPathCreateMutable();
    
    NSInteger from = range.location;
    NSInteger to = range.location + range.length;
    
    IMP imp = [self.firstObject methodForSelector:getter];
    YTSCFloat (*objGetter)(id obj, SEL getter) = (void *)imp;
    
    BOOL isMovePoint = YES;
    for (NSUInteger i =  from; i < to ; i ++) {
        // Error: this application, or a library it uses, has passed an invalid numeric value (NaN, or not-a-number) to CoreGraphics API and this value is being ignored. Please fix this problem.
        // afloat = NaN -> point.y = NaN
        YTSCFloat afloat = objGetter ([self objectAtIndex:i], getter);
        if (afloat == YTSCFLOAT_NULL || isnan(afloat)) { isMovePoint  = YES ; continue;};//|| isnan(afloat)
        CGPoint point  = CGPointMake(axisXScaler(i), axisYScaler(afloat));
        if (isMovePoint) {
            isMovePoint = NO;
            CGPathMoveToPoint(pathRef, NULL, point.x, point.y);
        }else {
            CGPathAddLineToPoint(pathRef, NULL, point.x, point.y);
        }
    }
    layer.path = pathRef;
    CGPathRelease(pathRef);
    
}

@end

