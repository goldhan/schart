//
//  YT_KLineChartConfiguration.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/28.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YT_IndexLayerConfigProtocol.h"


@interface YT_KLineChartConfiguration : NSObject  <YT_KLineMALayerConfig, YT_MACDLayerConfig, YT_BIASLayerConfig, YT_DMALayerConfig, YT_CCILayerConfig, YT_OBVLayerConfig, YT_VOLLayerConfig>

#pragma mark  rect

/** 顶部留白 (默认0)*/
@property (nonatomic, assign) CGFloat topGap;

/** 顶部图表与底部图表间距 (默认20) */
@property (nonatomic, assign) CGFloat riverGap;

/** 图表权值 */
@property (nonatomic, assign) CGFloat kChartWeight;
@property (nonatomic, assign) CGFloat vChartWeight;

/** 底部图表与底部留白间距 (默认10) */
@property (nonatomic, assign) CGFloat bottomGap;

@property (nonatomic, assign) NSUInteger kAxisYSplit; ///< k线纵轴 默认2
@property (nonatomic, assign) NSUInteger vAxisYSplit; ///< k线纵轴 默认1

#pragma mark  YT_KLineChart

@property (nonatomic, assign) UIEdgeInsets kChartTBDrawGap;      ///< 绘制留白区默认 5 5

/**  kMaxCountVisibale = NSIntegerMax kMinCountVisibale = 1 为无限制*/
@property (nonatomic, assign) NSInteger kMaxCountVisibale;      ///< 屏幕最多显示多少k线     默认120
@property (nonatomic, assign) NSInteger kMinCountVisibale;      ///< 屏幕最少显示多少k线     默认20

/** _kMaxShapeWidth = CGFLOAT_MAX  _kMinShapeWidth = CGFLOAT_MIN 为无限制*/
@property (nonatomic, assign) CGFloat kMaxShapeWidth;      ///< 每一个模型的最大宽度 与 kMaxCountVisibale 共同起作用
@property (nonatomic, assign) CGFloat kMinShapeWidth;      ///< 每一个模型的最小宽度 与 kMinCountVisibale 共同起作用

@property (nonatomic, assign) NSInteger kLineCountVisibaleInit;  ///< 初始化时 一屏幕显示多少根k线  默认60
@property (nonatomic, assign) NSInteger kShapeWidthInit;     ///<  初始化时 k线每一个模型的默认宽度 比 kLineCountVisibaleInit 优先

//@property (nonatomic, assign) NSInteger kLineCountVisibale;     ///< 一屏幕显示多少根k线
@property (nonatomic, assign) CGFloat kShapeWidth;     ///< k线每一个模型的宽度
@property (nonatomic, assign) CGFloat kShapeInterval;    ///< k线之间的间隔

@property (nonatomic, strong) UIColor * riseColor;      ///< 涨颜色  默认 RGB(216, 94, 101)
@property (nonatomic, strong) UIColor * fallColor;      ///< 跌颜色  默认 RGB(150, 234, 166)
@property (nonatomic, strong) UIColor * holdColor;      ///< 平颜色  默认 RGB(216, 94, 101)
@property (nonatomic, strong) UIColor * closePriceLineColor;      ///< 收盘价定位线  默认 rgba(137,110,228,1)
@property (nonatomic, strong) UIColor * gridColor;      ///< 网格颜色  默认 RGB(154, 160, 180)

@property (nonatomic, strong) UIColor * closslineColor;     ///< 收盘线颜色
@property (nonatomic, strong) UIColor * closslineAreaColor;  ///< 收盘线下颜色
@property (nonatomic, assign) CGFloat  closslineWidth;     ///< 收盘线宽度

@property (nonatomic, strong) UIFont * lableKLineIndexFont;      ///< 8.5
@property (nonatomic, strong) UIFont * lableVolumIndexFont;      ///< 8.5

@property (nonatomic, strong) UIColor * lableKLineIndexColor;      ///< 主图指标数据颜色
@property (nonatomic, strong) UIColor * lableVolumIndexColor;      ///< 技术指标数据颜色

@property (nonatomic, strong) UIFont * axisXTextFont;      ///< 14
@property (nonatomic, strong) UIFont * kAxisYTextFont;      ///< 14
@property (nonatomic, strong) UIFont * vAxisYTextFont;      ///< 14

@property (nonatomic, strong) UIColor * axisXTextColor;      ///< 黑
@property (nonatomic, strong) UIColor * kAxisYTextColor;      ///< 黑
@property (nonatomic, strong) UIColor * vAxisYTextColor;      ///< 黑

/**
 历史问题 之后 弃用 kFloat 就不需要这种恶心的转化了  详情看 YT_KLineChartStringFormat.m
 目前只有 k线收盘价 改 指标涉及到收盘价计算不准确 但 原来的KDS_KlineView 没有修正 ，这里也不对vol区域的指标做修正 也就是这个属性
 只对 图形上面部分（蜡烛线部分）有用。这个属性待删 。。。。
 if (self.bIsGGQQ) {
     targetPrice = targetPrice/10.0;
     label_CrossLineLeft.text = [NSString stringWithFormat:@"%.4lf", targetPrice];
 } else {
     label_CrossLineLeft.text = [NSString stringWithFormat:@"%.2lf", targetPrice];
 }
 */
@property (nonatomic, assign) float truthfulValueFloat;      ///< 真实数据浮动 一般为 1.000000

#pragma mark YT_KLineMALayerConfig

@property (nonatomic, assign) CGFloat kLineMALineWidth;
@property (nonatomic, strong) NSArray <UIColor *> *kLineMAColors; // 子层颜色

#pragma mark YT_MACDLayerConfig

@property (nonatomic, assign) CGFloat volMACDLineWidth;
@property (nonatomic, assign) CGFloat volMACDBarWidth;

@property (nonatomic, strong) UIColor * volMACDColor_DIFF; // 子层颜色
@property (nonatomic, strong) UIColor * volMACDColor_DEA;  // 子层颜色

#pragma mark YT_KDJLayerConfig
@property (nonatomic, assign) CGFloat volKDJLineWidth;
@property (nonatomic, strong) UIColor * volKDJColor_K; // 子层颜色
@property (nonatomic, strong) UIColor * volKDJColor_D; // 子层颜色
@property (nonatomic, strong) UIColor * volKDJColor_J; // 子层颜色

#pragma mark YT_VRLayerConfig
@property (nonatomic, assign) CGFloat volVRLineWidth;
@property (nonatomic, strong) UIColor * volVRColor;     // 子层颜色
@property (nonatomic, strong) UIColor * volVRColor_MA6; // 子层颜色

#pragma mark YT_DMALayerConfig

@property (nonatomic, assign) CGFloat volDMALineWidth;

@property (nonatomic, strong) UIColor *volDMAColor_DMA;  // 子层颜色
@property (nonatomic, strong) UIColor *volDMAColor_AMA;  // 子层颜色

#pragma mark YT_WRLayerConfig

@property (nonatomic, assign) CGFloat volWRLineWidth;

@property (nonatomic, strong) UIColor *volWRColor_WR10;  // 子层颜色
@property (nonatomic, strong) UIColor *volWRColor_WR6;   // 子层颜色

#pragma mark YT_BOLLLayerConfig

@property (nonatomic, assign) CGFloat volBOLLLineWidth;
@property (nonatomic, strong) UIColor *volBOLLColor_M;  // 子层颜色
@property (nonatomic, strong) UIColor *volBOLLColor_U;  // 子层颜色
@property (nonatomic, strong) UIColor *volBOLLColor_D;  // 子层颜色

#pragma mark YT_RSILayerConfig
@property (nonatomic, assign) CGFloat volRSILineWidth;
@property (nonatomic, strong) UIColor *volRSIColor_RSI6;  // 子层颜色
@property (nonatomic, strong) UIColor *volRSIColor_RSI12;  // 子层颜色
@property (nonatomic, strong) UIColor *volRSIColor_RSI24;  // 子层颜色

#pragma mark YT_DMILayerConfig
@property (nonatomic, assign) CGFloat volDMILineWidth;
@property (nonatomic, strong) UIColor *volDMIColor_PDI;  // 子层颜色
@property (nonatomic, strong) UIColor *volDMIColor_MDI;  // 子层颜色
@property (nonatomic, strong) UIColor *volDMIColor_ADX;  // 子层颜色
@property (nonatomic, strong) UIColor *volDMIColor_ADXR; // 子层颜色

#pragma mark YT_BIASLayerConfig

@property (nonatomic, assign) CGFloat kLineBIASLineWidth;
@property (nonatomic, strong) UIColor *volBIASColor_BIAS6;  // 子层颜色
@property (nonatomic, strong) UIColor *volBIASColor_BIAS12;  // 子层颜色
@property (nonatomic, strong) UIColor *volBIASColor_BIAS24;  // 子层颜色

#pragma mark YT_CCILayerConfig

@property (nonatomic, assign) CGFloat volCCILineWidth;
@property (nonatomic, strong) UIColor *volCCIColor;  // 子层颜色

#pragma mark YT_CRLayerConfig

@property (nonatomic, assign) CGFloat volCRLineWidth;

@property (nonatomic, strong) UIColor *volCRColor_CR;  // 子层颜色
@property (nonatomic, strong) UIColor *volCRColor_CR_MA10;  // 子层颜色
@property (nonatomic, strong) UIColor *volCRColor_CR_MA20;  // 子层颜色
@property (nonatomic, strong) UIColor *volCRColor_CR_MA40;  // 子层颜色
@property (nonatomic, strong) UIColor *volCRColor_CR_MA62;  // 子层颜色

#pragma mark YT_OBVLayerConfig

@property (nonatomic, assign) CGFloat volOBVLineWidth;
@property (nonatomic, strong) UIColor *volOBVColor;
@property (nonatomic, strong) UIColor *volOBVMColor;

#pragma mark YT_VOLLayerConfig

@property (nonatomic, assign) CGFloat volVOLLineWidth;
@property (nonatomic, assign) CGFloat volVOLBarLineWidth;
@property (nonatomic, strong) UIColor *volVOLColor;   // vol文字颜色
@property (nonatomic, strong) UIColor *volVOLColor_MA1;   // 子层颜色
@property (nonatomic, strong) UIColor *volVOLColor_MA2;  // 子层颜色

//text 文字单位
@property (nonatomic, strong) NSString *volVOLTextUnit;      ///< 手/股

@end
