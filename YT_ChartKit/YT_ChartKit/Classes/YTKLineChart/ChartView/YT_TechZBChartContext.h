//
//  YT_TechZBChartContext.h
//  Pods
//
//  Created by yt_liyanshan on 2018/9/5.
//

#import <Foundation/Foundation.h>
#import "YT_KLineDataProtocol.h"
#import "YT_KlineChartStringUtil.h"
#import "YT_SwitchButtonChartView.h"

@class  YT_ChartScaler,YT_StringArrayRenderer,YT_TechZBExplain,YT_StockChartCanvas;
@protocol YT_IndexLayerProtocol;

/**
 指标区域，(附图区域)
 */
@interface YT_TechZBChartContext : NSObject

//public
@property (nonatomic, assign, readonly) YT_ZBType zbType;  ///< volum区域 指标类型
@property (nonatomic, copy) YT_ZBType (^nextZBTypeBlock)(YT_ZBType zbType); ///< 指标切换回调
@property (nonatomic, copy) void (^zbTypeChangedBlock)(YT_ZBType zbType); ///< 指标切换成功回调

#pragma mark - private

/// ---- private -----
@property (nonatomic, strong) YT_TechZBExplain *zbExplain; ///< 指标描述

//rect记录
//图层
@property (nonatomic, strong) CALayer<YT_IndexLayerProtocol> * indexLayer;
@property (nonatomic, strong) UILabel * indexInfoLable;

@property (nonatomic, strong) YT_SwitchButtonChartView *switchButtonView;           // 切换的按钮

//文字
@property (nonatomic, weak) YT_StockChartCanvas * stringCanvas;  ///< k线坐标文字
@property (nonatomic, strong) YT_StringArrayRenderer * axisStrRenderer; ///< 成交量Y轴
//scaler
@property (nonatomic, strong) YT_ChartScaler * scaler;     ///<volumScaler
//浮点型格式化参数
@property (nonatomic, assign) YT_FloatFormat floatFormat; ///<  文字推荐显示
// 记录绘制区域窗口位置
@property (nonatomic, assign) CGRect drawWindowFrame;
// 记录绘制区域Insets drawWindowFrame + drawInsets == layer的窗口大小 宽度还要看k线数量
@property (nonatomic, assign) UIEdgeInsets drawInsets;

- (void)clearContext;

- (BOOL)resetIndexLayerIfNeeded:(YT_ZBType)zbType;
- (BOOL)resetIndexLayer:(YT_ZBType)zbType force:(BOOL)force;
- (CALayer<YT_IndexLayerProtocol> *)madeVolumIndexLayer:(YT_ZBType)zbType;

#pragma mark - private tool

- (void)updateIndexLayerWithRange:(NSRange)range;

// floatFormat
- (void)textAdjustDigitInChart:(double)v template:(YT_FloatFormat)floatFormat;
@end
