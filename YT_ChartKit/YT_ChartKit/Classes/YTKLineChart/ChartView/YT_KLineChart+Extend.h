//
//  YT_KLineChart+Extend.h
//  AFNetworking
//
//  Created by yt_liyanshan on 2018/9/19.
//

#import "YT_KLineChart.h"

@class YT_KLChartIndexCalculatConfige;

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    YT_CandleLayerStyleCandleAllFill = 0,// 蜡烛线全实
    YT_CandleLayerStyleCandleHalfFill,// 蜡烛线半空
    YT_CandleLayerStyleCandleMAX = 1000,//分割
    YT_CandleLayerStyleAmerican,// 美国线
    YT_CandleLayerStyleCloss,//收盘线
    YT_CandleLayerStyleNone,
} YT_CandleLayerStyle;

@interface YT_KLineChart (Extend)

- (BOOL)klineIsFullDrawWidow;

/** 实时更新背景层 - X横轴设置**/
- (void)ex_updateGridLayerAxisXWithRange:(NSRange)range rect:(CGRect)dateRect;

/** 绘制时间轴 */
- (void)drawGridLayerAxisXRange:(NSRange)range rect:(CGRect)dateRect;

/**
 计算需要显示日期/时间线的索引值
 
 @param dateLineIndexSet 计算结果
 @param dateOps  控制比较日期，1则最终比较的是20161207格式，100则最终比较的是201612
 @param range 显示的Kline的范围
 @param minWidthGap 日期最小间隔
 */
- (void)calculateNeedShowDates:(NSMutableIndexSet *)dateLineIndexSet comparedOps:(NSInteger)dateOps range:(NSRange)range minWidthGap:(CGFloat)minWidthGap;
/** 绘制时间轴 */
- (void)drawGridLayerAxisXRange:(NSRange)range rect:(CGRect)dateRect needShowDates:(NSMutableIndexSet *_Nullable)datesIndexs;

- (NSString *)stringWithDateInt:(int32_t)date;

#pragma mark - changeCandleLayerStyle

@property (nonatomic,assign,readonly)YT_CandleLayerStyle candleLayerStyle;
- (void)changeCandleLayerStyle:(YT_CandleLayerStyle)style;

#pragma mark - 重设指标计算参数后更新指标图

/**
 清除指标计算结果
 */
- (void)cleanKLDataSourceAboutAttachedTechZB;

/**
 重设指标计算参数后更新指标图
 */
- (void)updateChartIfNeedForResetKLCalculatConfige:(nullable YT_KLChartIndexCalculatConfige *)confige ;

@end

static inline void CGPathAddYTLine(CGMutablePathRef  path,
                                   const CGAffineTransform * __nullable m, CGPoint Apoint , CGPoint Bpoint) {
    CGPathMoveToPoint(path, NULL, Apoint.x, Apoint.y);
    CGPathAddLineToPoint(path, NULL, Bpoint.x, Bpoint.y);
}

NS_ASSUME_NONNULL_END
