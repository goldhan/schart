//
//  YT_KlineCalculatorProtocol.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/21.
//  Copyright © 2018年 kds. All rights reserved.
//

/* EMA（X，N）加权平均
 求X的N日指数平滑移动平均，在股票公式中一般表达为：EMA（X，N），其中X为当日收盘价，N为天数。
 公式表达是：当日指数平均值=平滑系数*（当日指数值-昨日指数平均值）+昨日指数平均值；或者 当日指数平均值=平滑系数*当日指数值 + (1-平滑系数)*昨日指数平均值；
 平滑系数一般为 =2/（周期单位+1）；由以上公式推导开，得到：EMA(N)= 2/(N+1) * X  + (N-1)/(N+1) * EMA(N-1)；
 */

#ifndef YT_KlineCalculatorProtocol_h
#define YT_KlineCalculatorProtocol_h

#import "YT_StockChartProtocol.h"
#import "YT_KLChartIndexCalculatConfige.h"

#pragma mark - MACD

#ifndef DAYS_EMA12
#define DAYS_EMA12                ([YT_KLChartIndexCalculatConfige sharedConfige].macd_ema12)
#endif
#ifndef DAYS_EMA26
#define DAYS_EMA26                ([YT_KLChartIndexCalculatConfige sharedConfige].macd_ema26)
#endif
#ifndef DAYS_DIF
#define DAYS_DIF                  ([YT_KLChartIndexCalculatConfige sharedConfige].macd_dif_ema9)
#endif

@protocol YT_StockMACDHandle
@property(nonatomic, assign) YTSCFloat cache_EMA12;
@property(nonatomic, assign) YTSCFloat cache_EMA26;
/// DIF线　（Difference）收盘价短期、长期指数平滑移动平均线间的差
@property(nonatomic, assign) YTSCFloat cache_DIF;
/// DEA线　（Difference Exponential Average）DIF线的M日指数平滑移动平均线
@property(nonatomic, assign) YTSCFloat cache_DEA;
/// MACD线　DIFF线与DEA线的差，彩色柱状线
@property(nonatomic, assign) YTSCFloat cache_MACD;
@end

#pragma mark - KDJ

#ifndef DAYS_RSV
#define DAYS_RSV                  ([YT_KLChartIndexCalculatConfige sharedConfige].kdj_rsv)
#endif

#ifndef DAYS_RSVMA
#define DAYS_RSVMA                ([YT_KLChartIndexCalculatConfige sharedConfige].kdj_rsv_ema3)
#endif

#ifndef DAYS_KMA
#define DAYS_KMA                  ([YT_KLChartIndexCalculatConfige sharedConfige].kdj_k_ema3)
#endif


@protocol YT_StockKDJHandle
//KDJ
@property(nonatomic,assign) YTSCFloat cache_K;
@property(nonatomic,assign) YTSCFloat cache_D;
@property(nonatomic,assign) YTSCFloat cache_J;
@end

#pragma mark - VR

// VR指标计算周期为26 MAVR指标对VR指标进行周期为6计算

//计算vr参数周期
#ifndef DAYS_VR
#define DAYS_VR                  ([YT_KLChartIndexCalculatConfige sharedConfige].vr_days26)
#endif

//vr平均值周期
#ifndef DAYS_MAVR
#define DAYS_MAVR                ([YT_KLChartIndexCalculatConfige sharedConfige].vr_ma6)
#endif

@protocol YT_StockVRHandle
// VR，VR6天平均值
@property(nonatomic,assign) YTSCFloat cache_VR;
@property(nonatomic,assign) YTSCFloat cache_VR_MA6;
@end

#pragma mark - BIAS

#ifndef DAYS_BIAS6
#define DAYS_BIAS6      ([YT_KLChartIndexCalculatConfige sharedConfige].bias_days6)
#endif

#ifndef DAYS_BIAS12
#define DAYS_BIAS12     ([YT_KLChartIndexCalculatConfige sharedConfige].bias_days12)
#endif

#ifndef DAYS_BIAS24
#define DAYS_BIAS24     ([YT_KLChartIndexCalculatConfige sharedConfige].bias_days24)
#endif

@protocol YT_StockBIASHandle
//BIAS
@property(nonatomic,assign) YTSCFloat cache_BIAS6;
@property(nonatomic,assign) YTSCFloat cache_BIAS12;
@property(nonatomic,assign) YTSCFloat cache_BIAS24;
@end

#pragma mark - DMA

#ifndef DAYS_DMA10
#define DAYS_DMA10                  ([YT_KLChartIndexCalculatConfige sharedConfige].dma_ma10)
#endif

#ifndef DAYS_DMA50
#define DAYS_DMA50                  ([YT_KLChartIndexCalculatConfige sharedConfige].dma_ma50)
#endif

#ifndef DAYS_DMA_DIFMA10
#define DAYS_DMA_DIFMA10                ([YT_KLChartIndexCalculatConfige sharedConfige].dma_dif_ma10)
#endif

@protocol YT_StockDMAHandle
//DMA

/// DMA线　10日股价平均值 — 50日股价平均值
@property(nonatomic,assign) YTSCFloat cache_DMA;
/// DIF线　10日DMA平均值
@property(nonatomic,assign) YTSCFloat cache_AMA;
@end
#pragma mark - CCI

#ifndef DAYS_CCI
#define DAYS_CCI        ([YT_KLChartIndexCalculatConfige sharedConfige].cci_days14)
#endif

@protocol YT_StockCCIHandle
//CCI
@property(nonatomic,assign) YTSCFloat cache_CCI;
@end

#pragma mark - DMI

#ifndef DAYS_DMI_DI
#define DAYS_DMI_DI         ([YT_KLChartIndexCalculatConfige sharedConfige].dmi_di14)
#endif

#ifndef DAYS_DMI_ADX
#define DAYS_DMI_ADX        ([YT_KLChartIndexCalculatConfige sharedConfige].dmi_adx6)
#endif

#ifndef DAYS_DMI_ADXR
#define DAYS_DMI_ADXR       ([YT_KLChartIndexCalculatConfige sharedConfige].dmi_adx6)
#endif

@protocol YT_StockDMIHandle
//DMI
@property(nonatomic,assign) YTSCFloat cache_PDI;
@property(nonatomic,assign) YTSCFloat cache_MDI;
@property(nonatomic,assign) YTSCFloat cache_ADX;
@property(nonatomic,assign) YTSCFloat cache_ADXR;
@end

#pragma mark - WR

#ifndef DAYS_WR10
#define DAYS_WR10                  ([YT_KLChartIndexCalculatConfige sharedConfige].wr_days10)
#endif

#ifndef DAYS_WR6
#define DAYS_WR6                   ([YT_KLChartIndexCalculatConfige sharedConfige].wr_days6)
#endif

@protocol YT_StockWRHandle
//WR

/// 10天买卖强弱指标线　((10日内最高价 - 当日收盘价) / (10日内最高价 - 10日内最低价)) * 100
@property(nonatomic,assign) YTSCFloat cache_WR10;
/// 6天买卖强弱指标线　((6日内最高价 - 当日收盘价) / (6日内最高价 - 10日内最低价)) * 100
@property(nonatomic,assign) YTSCFloat cache_WR6;

@end

#pragma mark - RSI

#ifndef DAYS_RSI6
#define DAYS_RSI6       ([YT_KLChartIndexCalculatConfige sharedConfige].rsi_days6)
#endif

#ifndef DAYS_RSI12
#define DAYS_RSI12      ([YT_KLChartIndexCalculatConfige sharedConfige].rsi_days12)
#endif

#ifndef DAYS_RSI24
#define DAYS_RSI24      ([YT_KLChartIndexCalculatConfige sharedConfige].rsi_days24)
#endif

@protocol YT_StockRSIHandle
//RSI
@property(nonatomic,assign) YTSCFloat cache_RSI6;
@property(nonatomic,assign) YTSCFloat cache_RSI12;
@property(nonatomic,assign) YTSCFloat cache_RSI24;
@end

#pragma mark - BOLL

#ifndef DAYS_BOLL
#define DAYS_BOLL           ([YT_KLChartIndexCalculatConfige sharedConfige].boll_days20)
#endif

#ifndef DAYS_BOLL_P2
#define DAYS_BOLL_P2        ([YT_KLChartIndexCalculatConfige sharedConfige].boll_p2)
#endif

@protocol YT_StockBOLLHandle
//BOLL
@property(nonatomic,assign) YTSCFloat cache_BOLL_Mid; //中轨
@property(nonatomic,assign) YTSCFloat cache_BOLL_Upper; //上轨
@property(nonatomic,assign) YTSCFloat cache_BOLL_Lower; //下轨
@end

#pragma mark - CR

#ifndef DAYS_CR26
#define DAYS_CR26       ([YT_KLChartIndexCalculatConfige sharedConfige].cr_days26)
#endif

#ifndef DAYS_CR_MA10
#define DAYS_CR_MA10    ([YT_KLChartIndexCalculatConfige sharedConfige].cr_ma10)
#endif

#ifndef DAYS_CR_MA20
#define DAYS_CR_MA20    ([YT_KLChartIndexCalculatConfige sharedConfige].cr_ma20)
#endif

#ifndef DAYS_CR_MA40
#define DAYS_CR_MA40    ([YT_KLChartIndexCalculatConfige sharedConfige].cr_ma40)
#endif

#ifndef DAYS_CR_MA62
#define DAYS_CR_MA62    ([YT_KLChartIndexCalculatConfige sharedConfige].cr_ma62)
#endif

@protocol YT_StockCRHandle
//CR
@property(nonatomic,assign) YTSCFloat cache_CR;
@property(nonatomic,assign) YTSCFloat cache_CR_MA10;
@property(nonatomic,assign) YTSCFloat cache_CR_MA20;
@property(nonatomic,assign) YTSCFloat cache_CR_MA40;
@property(nonatomic,assign) YTSCFloat cache_CR_MA62;
@end

#pragma mark - OBV

#ifndef DAYS_OBV_MA
#define DAYS_OBV_MA     ([YT_KLChartIndexCalculatConfige sharedConfige].obv_days30)
#endif

@protocol YT_StockOBVHandle
//OBV
@property(nonatomic,assign) YTSCFloat cache_OBV;
@property(nonatomic,assign) YTSCFloat cache_OBVM;
@end

#endif /* YT_KlineCalculatorProtocol_h */
