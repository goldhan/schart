//
//  YT_KLChartIndexCalculatConfige.h
//  KL
//
//  Created by yt_liyanshan on 2018/11/29.
//

#import <Foundation/Foundation.h>

#import "YT_KLineDataProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface YT_KLChartIndexCalculatConfige : NSObject <NSCopying>

#pragma mark - VOL 成交量

@property (nonatomic,assign) int vol_ma5;
@property (nonatomic,assign) int vol_ma10;
@property (nonatomic,assign) int vol_ma20;

#pragma mark - MACD 平滑异同平均

@property (nonatomic,assign) int macd_ema12; ///< 日快速移动均线
@property (nonatomic,assign) int macd_ema26; ///< 日慢速移动均线
@property (nonatomic,assign) int macd_dif_ema9; ///< 日移动平均 ema(加权平均)

#pragma mark - KDJ 随机指标

@property (nonatomic,assign) int kdj_rsv; ///< 9
@property (nonatomic,assign) int kdj_rsv_ema3; ///< 输出K:RSV的M1日[1日权重]移动平均
@property (nonatomic,assign) int kdj_k_ema3; ///< 输出D:K的M2日[1日权重]移动平均

#pragma mark - VR 成交量变异率

@property (nonatomic,assign) int vr_days26; ///< 日成交量变异率
@property (nonatomic,assign) int vr_ma6; ///< 日移动平均 ma(简单平均)

#pragma mark - BIAS 乖离率

@property (nonatomic,assign) int bias_days6; ///< 日乖离率
@property (nonatomic,assign) int bias_days12; ///< 日乖离率
@property (nonatomic,assign) int bias_days24; ///< 日乖离率

#pragma mark - DMA 平均差

@property (nonatomic,assign) int dma_ma10; ///< 日快速移动均线
@property (nonatomic,assign) int dma_ma50; ///< 日慢速移动均线
@property (nonatomic,assign) int dma_dif_ma10; ///< 日移动平均

#pragma mark - CCI 顺势指标

@property (nonatomic,assign) int cci_days14;

#pragma mark - DMI 趋向指标

@property (nonatomic,assign) int dmi_di14; ///< 日DMI
@property (nonatomic,assign) int dmi_adx6; ///< 日DMI移动均线 MA
//@property (nonatomic,assign) int dmi_adxr6; ///< （ 日DMI移动均线MA 的R日偏移 + 日DMI移动均线MA ）/2 （same as dmi_adx6)

#pragma mark - WR 威廉指标

@property (nonatomic,assign) int wr_days10;
@property (nonatomic,assign) int wr_days6;

#pragma mark - RSI 相对强弱指数

@property (nonatomic,assign) int rsi_days6;
@property (nonatomic,assign) int rsi_days12;
@property (nonatomic,assign) int rsi_days24;

#pragma mark - BOLL 布林线指标

@property (nonatomic,assign) int boll_days20;
@property (nonatomic,assign) int boll_p2; ///< 宽度

#pragma mark - CR 能量指标 （中间意愿指标、价格动量指标）

@property (nonatomic,assign) int cr_days26;
@property (nonatomic,assign) int cr_ma10;
@property (nonatomic,assign) int cr_ma20;
@property (nonatomic,assign) int cr_ma40;
@property (nonatomic,assign) int cr_ma62;

#pragma mark - OBV 累计能量线/能力潮

@property (nonatomic,assign) int obv_days30;

#pragma mark -

+ (instancetype)sharedConfige;
- (instancetype)initDefaultConfige;

- (void)resetConfige:(YT_KLChartIndexCalculatConfige *)confige;
- (BOOL)hadChanged; //是否发生改变
- (BOOL)hadChangedForZBType:(YT_ZBType)zbType;// 指标参数是否发生了改变
- (void)cleanChangedStatus; //清除改变状态

@end

NS_ASSUME_NONNULL_END



