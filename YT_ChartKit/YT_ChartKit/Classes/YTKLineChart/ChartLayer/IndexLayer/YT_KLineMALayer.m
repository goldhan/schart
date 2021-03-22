//
//  YT_KLineMALayer.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/25.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_KLineMALayer.h"

@interface YT_KLineMALayer ()

@property (nonatomic, readonly) CGFloat kLineMALineWidth;
@property (nonatomic, readonly) NSArray <UIColor *> *kLineMAColors; // 子层颜色

#pragma mark - 线

@property (nonatomic, strong) NSMutableArray <CAShapeLayer *> * aryLineLayer;
@end

@implementation YT_KLineMALayer
@synthesize dataArray;

#pragma mark - getter

- (NSMutableArray<CAShapeLayer *> *)aryLineLayer {
    if (!_aryLineLayer) {
        _aryLineLayer = [NSMutableArray array];
    }
    return _aryLineLayer;
}

-(CGFloat)kLineMALineWidth {
    return self.configuration ? self.configuration.kLineMALineWidth : 1.0;
}

-(NSArray<UIColor *> *)kLineMAColors {
    return self.configuration ? self.configuration.kLineMAColors : [NSArray array];
}

- (NSArray <YT_KlineMAExplain *> *)explainArray {
    return self.dataSource.klineZBMAExplainArray;
}

- (NSUInteger)lineCount {
    return self.dataSource.klineZBMAExplainArray.count;
}


#pragma mark - 功能

/**
 * titile
 */
- (NSAttributedString *)titleAttributedString {
    return nil;
}

- (NSArray<NSString *> *)infoStringWithIndex:(NSInteger)index {
    
    NSMutableArray<NSString *>* stringArr = [NSMutableArray array];
    
    NSArray <YT_KlineMAExplain *> * explainArr = [self explainArray];
    NSUInteger count = explainArr.count;
    
    YT_KlineDataCalculateCacheManager * cacheManager = self.dataSource.cacheManager;
    NSMutableArray<YT_KlineDataCalculateCache *> * cacheArray = cacheManager.cacheArray;
    
    float truthfulValueFloat = self.configuration.truthfulValueFloat;
    int digit = self.textDecimalPlaces;
    
    for (int i = 0; i < count ; i++) {
        YT_KlineMAExplain * explain = [explainArr objectAtIndex:i];
        YTSCFloat madate = cacheArray[index].cache_Closs_MA[explain.index] * truthfulValueFloat;
        
        NSString * format = [NSString stringWithFormat:@"%%ld:%%.%dlf ", digit];
        NSString * string = [NSString stringWithFormat:format, explain.day, madate];
        [stringArr addObject:string];
    }
    return stringArr;
}

- (NSArray<UIColor *> *)infoStringColorArray {
    
    NSArray * colorsPool = self.kLineMAColors;
    NSMutableArray * colorsArr = [NSMutableArray array];
    NSArray <YT_KlineMAExplain *> * explainArr = [self explainArray];
    NSUInteger count = explainArr.count;
    for (int i = 0; i < count ; i++) {
        YT_KlineMAExplain * explain = [explainArr objectAtIndex:i];
        UIColor * color = colorsPool[explain.index];
        [colorsArr addObject:color];
    }
    return colorsArr;
}


/**
 * 指标字符串 长按手势 查询层（十字线） 出现 时显示
 */
- (NSAttributedString *)attrStringWithIndex:(NSInteger)index {
    
    NSArray * colors = [self infoStringColorArray];
//    UIColor * colorMa = colors.firstObject;
    NSMutableAttributedString * attrString = [[NSMutableAttributedString alloc] initWithString:@" MA "];
    NSMutableAttributedString * attrString_c = [self attrStringWithStringArray:[self infoStringWithIndex:index] colorArr:colors];
    [attrString appendAttributedString:attrString_c];
    return attrString;
    
}

- (void)initSubLayers {
    
    // 删除所有层
    [self.aryLineLayer makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.aryLineLayer removeAllObjects];
    
    NSUInteger count = self.lineCount;
    for (NSInteger i = 0; i < count; i++) {
        
        CAShapeLayer * layer = [CAShapeLayer layer];
        layer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        [self addSublayer:layer];
        [self.aryLineLayer addObject:layer];
        [self.autoFullLayoutLayers addPointer:(__bridge void * _Nullable)(layer)];
    }
}

/**
 layer 初始化配置
 */
- (void)configLayer {
    NSArray <YT_KlineMAExplain *> * explainArr = [self explainArray];
    NSUInteger count = explainArr.count;
    if (self.aryLineLayer.count != count) [self initSubLayers];
    
    NSArray * colors = self.kLineMAColors;
    CGFloat lineWidth = self.kLineMALineWidth;
    
    for (int i = 0; i < count ; i++) {
        
        CAShapeLayer * layer = [self.aryLineLayer objectAtIndex:i];
        
        NSUInteger contentIdx = [explainArr objectAtIndex:i].index;
        layer.fillColor = [UIColor clearColor].CGColor;
      
        UIColor * strokeColor;
        if (contentIdx < colors.count) {
            strokeColor  = [colors objectAtIndex:contentIdx];
        }else{
            strokeColor = [UIColor redColor];
        }
        layer.strokeColor = [strokeColor CGColor];
        layer.lineWidth = lineWidth;
    }
    
}


/**
 实时更新 layer
 
 @param range 数据数组绘制区间
 */
- (void)updateLayerWithRange:(NSRange)range {
    NSArray <YT_KlineMAExplain *> * explainArr = [self explainArray];
    NSUInteger count = explainArr.count;
    for (int i = 0; i < count ; i++) {
        CAShapeLayer * layer = [self.aryLineLayer objectAtIndex:i];
        NSUInteger index = [explainArr objectAtIndex:i].index;
        [self _updateLayerWithRange:range layer:layer index:index];
    }
    
}

- (void)_updateLayerWithRange:(NSRange)range layer:(CAShapeLayer *)layer index:(NSUInteger)index{
    if (index > 5) return;
    
    YT_KlineDataCalculateCacheManager * cacheManager = self.dataSource.cacheManager;
    // 有数据的部分
    NSRange targetRange = NSIntersectionRange(cacheManager.readyRange_Closs_MA[index], range);
    NSInteger from = targetRange.location;
    NSInteger to = targetRange.location + targetRange.length;
    
    NSMutableArray<YT_KlineDataCalculateCache *> * cacheArray = cacheManager.cacheArray;
    YT_AxisYScaler axisYScaler = self.chartScaler.axisYScaler;
    YT_AxisXScaler axisXScaler = self.chartScaler.axisXScaler;
    
   CGMutablePathRef pathRef = CGPathCreateMutable();
    BOOL isMovePoint = YES;
    for (NSUInteger i =  from; i < to ; i ++) {
        YTSCFloat afloat = [cacheArray objectAtIndex:i].cache_Closs_MA[index];
        if (afloat == YTSCFLOAT_NULL) { isMovePoint  = YES ; continue;};
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



