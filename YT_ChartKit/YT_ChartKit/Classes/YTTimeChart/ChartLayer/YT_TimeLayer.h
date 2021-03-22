//
//  YT_TimeLayer.h
//  YT_ChartKit
//
//  Created by ChenRui Hu on 2018/8/21.
//

#import <QuartzCore/QuartzCore.h>

/// 分时层
@interface YT_TimeLayer : CALayer

/** 分时参考线颜色 */
@property (nonatomic, strong) UIColor *dashLineColor;

/** 分时参考线宽度(虚线) (默认1) */
@property (nonatomic, assign) CGFloat dashLineWidth;

/** 设置虚线长度和间隔 (默认@[@5, @3]，即长度为5，间隔为3) */
@property (nonatomic, strong, nullable) NSArray<NSNumber *> *dashLinePattern;

/** 分时线颜色 */
@property (nonatomic, strong) UIColor *timeLineColor;

/** 分时线线宽 */
@property (nonatomic, assign) CGFloat timeLineWith;

/** 分时均线填充色 */
@property (nonatomic, strong, nullable) UIColor *timeLineFillColor;

/** 分时均线填充渐变色 */
@property (nonatomic, strong, nullable) NSArray *timeGradientColors;

/** 分时均线颜色 */
@property (nonatomic, strong) UIColor *avgTimeLineColor;

/** 分时均线线宽 */
@property (nonatomic, assign) CGFloat avgTimeLineWidth;

/// 配制
- (void)configLayer;
/// 布局
- (void)updateLayout:(CGRect)frame;
/// 绘制当日分时
- (void)drawTimeChart:(id)timeChart;
/// 绘制五日分时
- (void)drawFiveTimeChart:(id)timeChart;
@end
