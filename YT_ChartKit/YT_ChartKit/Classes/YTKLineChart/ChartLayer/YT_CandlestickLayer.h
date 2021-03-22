//
//  YT_CandlestickLayer.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/23.
//  Copyright © 2018年 kds. All rights reserved.
//  蜡烛线 Layer

#import <QuartzCore/QuartzCore.h>
@class YT_ChartScaler;
@protocol YT_StockKlineData;

typedef enum : NSUInteger {
    YT_CandlesDrawStyleCandles = 0,
    YT_CandlesDrawStyleAB,
    YT_CandlesDrawStyleLine,
} YT_CandlesDrawStyle;

typedef NS_OPTIONS(NSUInteger, YT_CandleStyleOps) {
    YT_CandleStyleOpsRiseFull = 1 << 0,
    YT_CandleStyleOpsFallFull = 1 << 1,
    YT_CandleStyleOpsHoldFull = 1 << 2,
};

@interface YT_CandlestickLayer : CALayer
@property (nonatomic, strong) NSArray <id <YT_StockKlineData> > * kLineArray;    ///< k线数组
@property (nonatomic, strong) YT_ChartScaler  * chartScaler;  ///< 绘制测量器
@property (nonatomic, assign) YT_CandlesDrawStyle  drawStyle;      ///< 红色K线

#pragma mark YT_CandlesDrawStyleCandles/YT_CandlesDrawStyleAB

@property (nonatomic, strong) CAShapeLayer * redLineLayer;      ///< 红色K线
@property (nonatomic, strong) CAShapeLayer * grayLineLayer;     ///< 灰色/红色K线
@property (nonatomic, strong) CAShapeLayer * greenLineLayer;    ///< 绿色k线

@property (nonatomic, strong) UIColor * riseColor;      ///< 涨颜色
@property (nonatomic, strong) UIColor * fallColor;      ///< 跌颜色
@property (nonatomic, strong) UIColor * holdColor;      ///< 平颜色

@property (nonatomic, assign) YT_CandleStyleOps candleStyleOps;      ///< 蜡烛样式下填满还是留空 默认 6

#pragma mark YT_CandlesDrawStyleCloss

@property (nonatomic, strong) CAShapeLayer * clossLayer;      ///< 红色K线
@property (nonatomic, strong) CAShapeLayer * clossAreaLayer;  ///< 灰色/红色K线
@property (nonatomic, assign) CGFloat  closslineWidth;     ///< 收盘线宽度
@property (nonatomic, strong) UIColor * clossColor;     ///< 收盘线颜色
@property (nonatomic, strong) UIColor * clossAreaColor;  ///< 收盘线下颜色

#pragma mark common

- (void)configLayer;
- (void)updateLayerWithRange:(NSRange)range;
@end
