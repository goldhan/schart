//
//  CoreGraphics_demo
//
//  Created by zhanghao on 2018/7/8.
//  Copyright © 2018年 snail-z. All rights reserved.
//

#import "YT_TimeChart+Calculator.h"
#import "YT_KlineChartStringUtil.h"

@implementation YT_TimeChart (Calculator)

- (CGPeakValue)timePeakValue {
    return CGPeakValueMake(self.propData.yt_maxPrice, self.propData.yt_minPrice);
}

- (CGPeakValue)changeRatioPeakValue {
    return CGPeakValueMake(self.propData.yt_maxChangeRatio, self.propData.yt_minChangeRatio);
}

- (CGFloat)getCenterXWithIndex:(NSInteger)index {
    CGFloat halfWidth = self.configuration.volumeBarBodyWidth * 0.5;
    CGFloat centerX = (self.configuration.volumeBarBodyWidth + self.configuration.volumeBarGap) * index + halfWidth;
    return centerX;
}

- (CGFloat)getOriginXWithIndex:(NSInteger)index {
    CGFloat halfWidth = self.configuration.volumeBarBodyWidth * 0.5;
    CGFloat centerX = [self getCenterXWithIndex:index];
    return centerX - halfWidth;
}

- (CGFloat)mapRefValueWithPointY:(CGFloat)py peak:(CGPeakValue)peak inRect:(CGRect)rect {
    CGFloat pointY = py - rect.origin.y;
    CGFloat proportion = pointY / rect.size.height;
    CGFloat proportionValue = (peak.max - peak.min) * proportion;
    return peak.max - proportionValue;
}

- (NSInteger)mapIndexWithPointX:(CGFloat)pointX {
    CGFloat widthAndGap = self.configuration.volumeBarBodyWidth + self.configuration.volumeBarGap;
    CGFloat widthAndHalfGap = self.configuration.volumeBarBodyWidth + self.configuration.volumeBarGap * 0.5;
    NSInteger index = pointX / widthAndGap;
    CGFloat ref = index * widthAndGap + widthAndHalfGap;
    if (pointX > ref) index += 1;
    index = MAX(0, index);
    index = MIN(self.dataArray.count - 1, index);
    return index;
}

- (NSString *)timestringWithDate:(NSDate *)date format:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    return [formatter stringFromDate:date];
}

+ (NSString *)axisStringWithValue:(double)value peak:(CGPeakValue)peak {
    int digit = 0;
    int unitTa = YTSC_NUMBER;
    double afloatTa = [YT_KLineChartStringFormat adjustFloatWithUnit:value unit:&unitTa];
    double span = peak.max - peak.min;
    if (YTSC_NUMBER != unitTa) {digit = 2 , digit = YT_TEXT_ADJUST_DIGIT(value, digit, span);}
    
    return [YT_KLineChartStringFormat floatToString:afloatTa unit:unitTa digit:digit];
}
@end

@implementation NSArray (Extendd)

- (CGPeakValue)yt_peakValueBySel:(SEL)sel {
    if (self.count <= 0) return CGPeakValueMake(0.f, 0.f);
    IMP imp = [self.lastObject methodForSelector:sel];
    CGFloat(*msgSend)(id, SEL) = (void*)imp;
    CGPeakValue peak = CGPeakValueMake(CGFLOAT_MIN, CGFLOAT_MAX);
    for (id obj in self) {
        CGFloat tempValue = msgSend(obj, sel);
        if (tempValue > peak.max) peak.max = tempValue;
        if (tempValue < peak.min) peak.min = tempValue;
    }
    return peak;
}

#pragma mark - 根据最大和最小值平均划分后构建成新数组
+ (NSArray<NSString *> *)yt_partitionWithPeak:(CGPeakValue)peak
                                     segments:(NSUInteger)segments
                                       format:(NSString *)format
                                 attachedText:(NSString *)attachedText {
    NSMutableArray<NSString *> *array = [NSMutableArray array];
    CGFloat numberOfSplit = fabs(peak.max - peak.min) / (CGFloat)segments;
    for (NSInteger i = 0; i <= segments; i++) {
        CGFloat value = peak.max - numberOfSplit * i;
        NSString *text = [YT_TimeChart axisStringWithValue:value peak:peak];
        if (attachedText) text = [text stringByAppendingString:attachedText];
        [array addObject:text];
    }
    return array.copy;
}

+ (NSArray<NSString *> *)yt_partition2fWithPeak:(CGPeakValue)peak
                                       segments:(NSUInteger)segments {
    NSMutableArray<NSString *> *array = [NSMutableArray array];
    CGFloat split = fabs(peak.max - peak.min) / (double)segments;
    for (NSInteger i = 0; i <= segments; i++) {
        NSString *text = [NSString stringWithFormat:@"%.2f", peak.max - split * i];
        [array addObject:text];
    }
    return array.copy;
}

+ (NSArray<NSString *> *)yt_partition2fSubjonWithPeak:(CGPeakValue)peak
                                       segments:(NSUInteger)segments {
    NSMutableArray<NSString *> *array = [NSMutableArray array];
    CGFloat split = fabs(peak.max - peak.min) / (double)segments;
    for (NSInteger i = 0; i <= segments; i++) {
        NSString *text = [NSString stringWithFormat:@"%.2f%%", peak.max - split * i];
        [array addObject:text];
    }
    return array.copy;
}

@end

@implementation CATextLayer (TQChartExtend)

- (void)yt_setText:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor {
    NSMutableAttributedString *attriText = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    attributes[NSFontAttributeName] = font;
    attributes[NSForegroundColorAttributeName] = textColor;
    [attriText addAttributes:attributes range:[text rangeOfString:text]];
    self.string = attriText;
}

- (CGSize)yt_sizeFit {
    if ([self.string isKindOfClass:[NSString class]]) {
        [self yt_setText:((NSString *)self.string)
                    font:[UIFont systemFontOfSize:[UIFont systemFontSize]]
               textColor:[UIColor blackColor]];
        NSAttributedString *attributedText = self.string;
        CGSize size = [attributedText boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
        return size;
    } else if ([self.string isKindOfClass:[NSAttributedString class]]) {
        NSAttributedString *attributedText = self.string;
        CGSize size = [attributedText boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT)
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
        return size;
    } else {
        return CGSizeZero;
    }
}

@end
