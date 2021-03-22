//
//  CoreGraphics_demo
//
//  Created by zhanghao on 2018/7/8.
//  Copyright © 2018年 snail-z. All rights reserved.
//

#import "YT_TimeChart.h"
#import "YT_ChartUtilities.h"

NS_ASSUME_NONNULL_BEGIN

@interface YT_TimeChart (Calculator)

@property (nonatomic, assign, readonly) CGPeakValue timePeakValue;
@property (nonatomic, assign, readonly) CGPeakValue changeRatioPeakValue;

- (CGFloat)getCenterXWithIndex:(NSInteger)index;
- (CGFloat)getOriginXWithIndex:(NSInteger)index;

- (CGFloat)mapRefValueWithPointY:(CGFloat)py peak:(CGPeakValue)peak inRect:(CGRect)rect;
- (NSInteger)mapIndexWithPointX:(CGFloat)pointX;

- (NSString *)timestringWithDate:(NSDate *)date format:(NSString *)format;

/** 转换单位 */
+ (NSString *)axisStringWithValue:(double)value peak:(CGPeakValue)peak;
@end

@interface NSArray<ObjectType> (Extendd)

/** 根据对象sel方法，查找数组内的最大最小值(不做类型判断) */
- (CGPeakValue)yt_peakValueBySel:(SEL)sel;

/** 根据最大和最小值等分后构建成新数组 (返回的新数组元素个数为 segments+1)
 - segments 等分数量段
 - format 格式化字符串 (e.g - %.2f %.f)
 - attachedText 附加字符串
 */
+ (NSArray<NSString *> *)yt_partitionWithPeak:(CGPeakValue)peak
                                     segments:(NSUInteger)segments
                                       format:(nullable NSString *)format
                                 attachedText:(nullable NSString *)attachedText;

/** 根据最大和最小值等分后构建成新数组 (返回的新数组元素个数为 segments+1)
 默认%.2f格式，保留两位小数
 */
+ (NSArray<NSString *> *)yt_partition2fWithPeak:(CGPeakValue)peak segments:(NSUInteger)segments;
+ (NSArray<NSString *> *)yt_partition2fSubjonWithPeak:(CGPeakValue)peak
                                             segments:(NSUInteger)segments;

@end

@interface CATextLayer (TQChartExtend)

- (CGSize)yt_sizeFit;

@end

NS_ASSUME_NONNULL_END
