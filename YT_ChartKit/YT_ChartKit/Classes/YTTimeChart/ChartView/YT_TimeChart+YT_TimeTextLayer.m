//
//  YT_TimeChart+YT_TimeTextLayer.m
//  YT_ChartKit
//
//  Created by ChenRui Hu on 2018/8/20.
//

#import "YT_TimeChart+YT_TimeTextLayer.h"
#import "YT_TimeTextLayer.h"
#import "YT_TimeChart+Calculator.h"
#import <objc/message.h>

@interface YT_TimeChart ()

/** 映射分时区域y轴文本 */
@property (nonatomic, strong, readonly) YT_TimeTextLayer *yTimeTextLayer;

/** 映射成交量区域y轴文本 */
@property (nonatomic, strong, readonly) YT_TimeTextLayer *yVolumeTextLayer;

/** 映射x轴时间标记文本 */
@property (nonatomic, strong, readonly) YT_TimeTextLayer *xDateTextLayer;

@end

@implementation YT_TimeChart (YT_TimeTextLayer)

- (YT_TimeTextLayer *)yTimeTextLayer {
    YT_TimeTextLayer * textLayer = objc_getAssociatedObject(self, _cmd);
    if (textLayer == nil) {
        textLayer = [YT_TimeTextLayer layer];
        textLayer.contentsScale = [UIScreen mainScreen].scale;
        objc_setAssociatedObject(self, _cmd, textLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return textLayer;
}

- (YT_TimeTextLayer *)yVolumeTextLayer {
    YT_TimeTextLayer * textLayer = objc_getAssociatedObject(self, _cmd);
    if (textLayer == nil) {
        textLayer = [YT_TimeTextLayer layer];
        textLayer.contentsScale = [UIScreen mainScreen].scale;
        objc_setAssociatedObject(self, _cmd, textLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return textLayer;
}

- (YT_TimeTextLayer *)xDateTextLayer {
    YT_TimeTextLayer * textLayer = objc_getAssociatedObject(self, _cmd);
    if (textLayer == nil) {
        textLayer = [YT_TimeTextLayer layer];
        textLayer.contentsScale = [UIScreen mainScreen].scale;
        objc_setAssociatedObject(self, _cmd, textLayer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return textLayer;
}

- (void)sublayerToTextInitialization {
    
    [self.contentTextLayer addSublayer:self.yTimeTextLayer];
    
    [self.contentTextLayer addSublayer:self.yVolumeTextLayer];
    
    [self.contentTextLayer addSublayer:self.xDateTextLayer];
}

- (void)textlayerUpdateLayout {
    self.yTimeTextLayer.frame = self.bounds;
    self.yVolumeTextLayer.frame = self.bounds;
    self.xDateTextLayer.frame = self.bounds;
}

/** 绘制分时图左右价格与涨跌幅的文字 */
- (void)drawTimeText {
    NSArray<NSString *> *array = [NSArray yt_partition2fWithPeak:self.timePeakValue segments:self.configuration.yAxisTimeSegments];
    NSArray<NSString *> *crArray = [NSArray yt_partition2fSubjonWithPeak:self.changeRatioPeakValue segments:self.configuration.yAxisTimeSegments];
    CGFloat segGap = self.timeRect.size.height / (CGFloat)(array.count - 1);
    CGFloat originY = self.timeRect.origin.y + self.configuration.gridLineWidth * 0.5;
    
    CGFloat ratioY = originY + self.changeRatioPeakValue.max / CGGetPeakDistanceValue(self.changeRatioPeakValue) * self.timeRect.size.height;
    
    UIColor *(^callbackColor)(CGFloat) = ^(CGFloat y) {
        if (y < ratioY) {
            return self.configuration.yAxisTimeTextColors[0];
        } else if (y > ratioY) {
            return self.configuration.yAxisTimeTextColors[1];
        } else {
            return self.configuration.yAxisTimeTextColors[2];
        }
    };
    
    __block NSMutableArray<YT_KlineTextRenderer *> *rendArray = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(NSString *text, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint start = CGPointMake(self.timeRect.origin.x, originY + segGap * idx);
        
        YT_KlineTextRenderer *leftRen = [YT_KlineTextRenderer defaultRenderer];
        leftRen.text = text;
        leftRen.font = self.configuration.textFont;
        leftRen.color = callbackColor(start.y);
        leftRen.positionCenter = start;
        leftRen.offsetRatio = (CGPoint){.x = 0, .y = (!idx ? 0 : 1)};
        [rendArray addObject:leftRen];
        
        YT_KlineTextRenderer *rightRen = [YT_KlineTextRenderer defaultRenderer];
        rightRen.font = self.configuration.textFont;
        rightRen.text = crArray[idx];;
        rightRen.color = callbackColor(start.y);
        rightRen.positionCenter = (CGPoint){.x = start.x + self.timeRect.size.width, .y = start.y};;
        rightRen.offsetRatio = (CGPoint){.x = 1, .y = (!idx ? 0 : 1)};
        [rendArray addObject:rightRen];
    }];
    
    [self.yTimeTextLayer updateRendererWithArray:rendArray];
}

/** 绘制成交量左边文字 */
- (void)drawVolumeText {
    CGPeakValue peak = [self.dataArray yt_peakValueBySel:@selector(yt_timeVolume)];
    NSArray<NSString *> *array = [NSArray yt_partitionWithPeak:peak segments:self.configuration.yAxisVolumeSegments format:@"%.f" attachedText:nil];
    CGFloat segGap = self.volumeRect.size.height / (CGFloat)(array.count - 1);
    CGFloat originY = self.volumeRect.origin.y;
    __block NSMutableArray<YT_KlineTextRenderer *> *rendArray = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(NSString *text, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint start = CGPointMake(self.volumeRect.origin.x, originY + segGap * idx);
        
        YT_KlineTextRenderer *ren = [YT_KlineTextRenderer defaultRenderer];
        ren.text = array[idx];
        ren.color = self.configuration.yAxisTimeTextColors[3];
        ren.positionCenter = start;
        ren.offsetRatio = (CGPoint){0, 1};
        [rendArray addObject:ren];
    }];
    rendArray.firstObject.offsetRatio = (CGPoint){0, 0};
    
    if (self.configuration.volumeYTextIgnoreMinText && rendArray.count >1) {
        [rendArray removeLastObject];
    }
    [self.yVolumeTextLayer updateRendererWithArray:rendArray];
}

/** 绘制五日分时时时间文字 */
- (void)drawFiveDateText:(CGRect)rect {
//    __block NSInteger dateFlag = 0;   放到了分时绘制时一起计算了日期 YT_TimeLayer
//    NSMutableArray<NSString *> *mud = [NSMutableArray array];
//    NSCalendar *calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
//    [self.dataArray enumerateObjectsUsingBlock:^(id<YT_TimeProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSInteger day = [[calendar components:NSCalendarUnitDay fromDate:obj.yt_timeDate] day];
//        if (day && (dateFlag != day)) {
//            dateFlag = day;
//            NSString *text = [self timestringWithDate:obj.yt_timeDate format:@"MM-dd"];
//            [mud addObject:text];
//        }
//    }];
//    NSInteger gap = rect.size.width / mud.count;
    NSInteger gap = rect.size.width / self.fiveDateArray.count;
    
    __block NSMutableArray<YT_KlineTextRenderer *> *rendArray = [NSMutableArray array];
    [self.fiveDateArray enumerateObjectsUsingBlock:^(NSString * _Nonnull text, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat originX = gap * idx;
        CGFloat centerX = originX +  gap * 0.5;
        
        CGPoint p = CGPointMake(centerX, CGRectGetMinY(rect));
        YT_KlineTextRenderer *ren = [YT_KlineTextRenderer defaultRenderer];
        ren.font = self.configuration.textFont;
        ren.text = text;
        ren.color = self.configuration.yAxisTimeTextColors[3];
        ren.offsetRatio = CGPointMake(0.5, 0.5);
        ren.baseOffset = UIOffsetMake(0, self.configuration.riverGap * 0.5);
        ren.positionCenter = p;
        [rendArray addObject:ren];
    }];
    [self.xDateTextLayer updateRendererWithArray:rendArray];
}

/** 绘制当日分时时间文字 */
- (void)drawDateText:(CGRect)rect {
    if (!self.dateArray.count) return;
    __block NSMutableArray<YT_KlineTextRenderer *> *rendArray = [NSMutableArray array];
    NSInteger section = self.configuration.maxDataCount / (self.dateArray.count - 1);
    NSRange range = NSMakeRange(1, self.dateArray.count - 2);
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.dateArray enumerateObjectsAtIndexes:indexSet options:kNilOptions usingBlock:^(NSString * _Nonnull text, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger realIdx = idx * section;
        CGFloat centerX = [self getCenterXWithIndex:realIdx];
        
        CGPoint p = CGPointMake(centerX, CGRectGetMinY(rect));
        YT_KlineTextRenderer *ren = [YT_KlineTextRenderer defaultRenderer];
        ren.font = self.configuration.textFont;
        ren.text = text;
        ren.color = self.configuration.yAxisTimeTextColors[3];
        ren.offsetRatio = (CGPoint){0.5, 0.5};
        ren.baseOffset = UIOffsetMake(0, self.configuration.riverGap * 0.5);
        ren.positionCenter = p;
        [rendArray addObject:ren];
    }];
    YT_KlineTextRenderer *firstRen = [YT_KlineTextRenderer defaultRenderer];
    firstRen.font = self.configuration.textFont;
    firstRen.baseOffset = UIOffsetMake(0, self.configuration.riverGap * 0.5);
    firstRen.text = self.dateArray.firstObject;
    firstRen.color = self.configuration.yAxisTimeTextColors[3];
    firstRen.offsetRatio = (CGPoint){0, 0.5};;
    firstRen.positionCenter = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    [rendArray insertObject:firstRen atIndex:0];
    
    YT_KlineTextRenderer *lastRen = [YT_KlineTextRenderer defaultRenderer];
    lastRen.font = self.configuration.textFont;
    lastRen.baseOffset = UIOffsetMake(0, self.configuration.riverGap * 0.5);
    lastRen.text = self.dateArray.lastObject;
    lastRen.color = self.configuration.yAxisTimeTextColors[3];
    lastRen.offsetRatio = (CGPoint){1, 0.5};
    lastRen.positionCenter = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
    [rendArray addObject:lastRen];
    
    [self.xDateTextLayer updateRendererWithArray:rendArray];
}
@end
