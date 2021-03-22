//
//  CoreGraphics_demo
//
//  Created by zhanghao on 2018/7/6.
//  Copyright © 2018年 snail-z. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YT_TimeChartType) {
    YT_TimeChartTypeDefault = 0, // 分时图
    YT_TimeChartTypeFiveDay      // 五日分时图
};

@interface YT_TimeChartConfiguration : NSObject

/** 分时图类型 */
@property (nonatomic, assign) YT_TimeChartType chartType;

/** 分时最大数据量，默认240条 */
@property (nonatomic, assign) NSInteger maxDataCount;

/** 顶部留白 */
@property (nonatomic, assign) CGFloat topGap;

/** 底部留白(日期栏) */
@property (nonatomic, assign) CGFloat dateGap;

/** 顶部图表与底部图表间距 (默认20) */
@property (nonatomic, assign) CGFloat riverGap;

/** 底部图表与底部留白间距 (默认20) */
@property (nonatomic, assign) CGFloat bottomGap;

/** 分时图高度的比例 (相对绘图区域的占比) */
@property (nonatomic, assign) CGFloat proportionOfHeight;

/** 网格线颜色 (默认-[UIColor lightGrayColor]) */
@property (nonatomic, strong) UIColor *gridLineColor;

/** 网格线宽度 (默认1) */
@property (nonatomic, assign) CGFloat gridLineWidth;

/** 分时参考线宽度(虚线) (默认1) */
@property (nonatomic, assign) CGFloat dashLineWidth;

/** 分时参考线颜色 */
@property (nonatomic, strong) UIColor *dashLineColor;

/** 设置虚线长度和间隔 (默认@[@5, @3]，即长度为5，间隔为3) */
@property (nonatomic, strong, nullable) NSArray<NSNumber *> *dashLinePattern;

/** 分时图网格分割数量 */
@property (nonatomic, assign) NSInteger yAxisTimeSegments;

/** 成交量网格分割数量 */
@property (nonatomic, assign) NSInteger yAxisVolumeSegments;

/** 分时图网格文本颜色数组（数组数量是4个： 价格涨、价格跌、价格平、成交量/时间） */
@property (nonatomic, strong, nullable) NSArray<UIColor *> *yAxisTimeTextColors;

/** 成交量柱状条之间的间距 (默认5) */
@property (nonatomic, assign) CGFloat volumeBarGap;

/** 成交量柱状条宽度 (根据间距volumeBarGap计算得出宽度) */
@property (nonatomic, assign, readonly) CGFloat volumeBarBodyWidth;

/** 成交量柱状条涨颜色 */
@property (nonatomic, strong) UIColor *volumeRiseColor;

/** 成交量柱状条跌颜色 */
@property (nonatomic, strong) UIColor *volumeFallColor;

/** 成交量柱状条平颜色 (默认-[UIColor grayColor]) */
@property (nonatomic, strong) UIColor *volumeFlatColor;

/** 成交量文字绘制，不绘制最小值（默认NO） */
@property (nonatomic, assign) BOOL volumeYTextIgnoreMinText;

/** 分时线线宽 */
@property (nonatomic, assign) CGFloat timeLineWith;

/** 分时线颜色 */
@property (nonatomic, strong) UIColor *timeLineColor;

/** 分时均线线宽 */
@property (nonatomic, assign) CGFloat avgTimeLineWidth;

/** 分时均线颜色 */
@property (nonatomic, strong) UIColor *avgTimeLineColor;

/** 分时均线填充色，无渐变 */
@property (nonatomic, strong, nullable) UIColor *timeLineFillColor;

/** 分时均线填充渐变色 (timeLineFillColor 与 timeGradientColors 只能有一个值，根据需求使用) */
@property (nonatomic, strong, nullable) NSArray *timeGradientColors;

/** 十字线颜色 */
@property (nonatomic, strong) UIColor *crosswireLineColor;

/** 十字线宽度 */
@property (nonatomic, assign) CGFloat crosswireLineWidth;

/** 十字线映射的文本颜色 */
@property (nonatomic, strong) UIColor *crosswireTextColor;

/** 十字线背景颜色(涨) */
@property (nonatomic, strong) UIColor *crosswireBackRiseColor;

/** 十字线背景颜色(跌) */
@property (nonatomic, strong) UIColor *crosswireBackFallColor;

/** 十字线日期文字背景颜色 */
@property (nonatomic, strong) UIColor *crosswireBackDateColor;

/** 十字线日期文本是否隐藏 */
@property (nonatomic, assign) BOOL crosswireDateHidden;

/** 设置图表中文本的字体 */
@property (nonatomic, strong) UIFont *textFont;

/// 2.0 添加配制 begin
/** 附图个数 (0: 无附图  1: 添加成交量附图 2: 添加买卖附图) */
@property (nonatomic, assign) NSInteger nFigureNum;

/** 十字线交叉点是否标记显示 */
@property (nonatomic, assign) BOOL crosswireCentralPointMark;

/** 十字线交叉点景颜色 */
@property (nonatomic, strong) UIColor *crosswireCentralPointColor;

/** 十字线交叉点半径 */
@property (nonatomic, assign) CGFloat crosswireCentralPointRadius;

/** 切换按钮边框线宽度 */
@property (nonatomic, assign) CGFloat switchLineWidth;

/** 切换按钮边框线颜色 */
@property (nonatomic, strong) UIColor *switchLineColor;

/** 切换文本颜色 */
@property (nonatomic, strong) UIColor *switchTextColor;

/** 切换文本字体 */
@property (nonatomic, strong) UIFont *switchTextFont;

/** 分时叠加线1颜色 */
@property (nonatomic, strong) UIColor *timeOverlayLineColor;

/** 分时叠加线2颜色 */
@property (nonatomic, strong) UIColor *timeOverlayOtherLineColor;

/// 2.0 添加配制 end

+ (instancetype)defaultConfiguration;

@end

NS_ASSUME_NONNULL_END
