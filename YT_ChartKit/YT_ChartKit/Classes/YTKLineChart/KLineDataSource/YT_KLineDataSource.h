//
//  YT_KLineDataSource.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/9.
//  Copyright © 2018年 kds. All rights reserved.
//
// * 说明 这个文件 主要用于 数据的存储 和 各种指标计算优化 优化方向为 重用之前的部分计算结果，使得需要计算的范围缩小

#import <Foundation/Foundation.h>
#import "YT_KLineDataProtocol.h"
#import "YT_CoordinateAxisParam.h"
#import "YT_KLineDataCalculateCache.h"

struct YTKLineCoordinateAxisParam {
    YTSCFloat maxPrice; ///< 最大价格
    YTSCFloat minPrice; ///< 最小价格
    YTSCFloat maxZDF;   ///< 最大涨跌幅 maxZDF = (maxPrice - firstData.fOpen)/firstData.fOpen
    YTSCFloat minZDF;   ///< 最小涨跌幅
    NSUInteger maxPriceIndex;
    NSUInteger minPriceIndex;
    
    NSRange range;
};
typedef struct YTKLineCoordinateAxisParam YT_KLineCoordinateAxisParam;

#pragma mark - YT_KlineModel

#pragma mark YT_KlineMAExplain
/**
 k线表格区域的 MA线 是 可以自定义的 所以 需要这个模型说明 我们要绘制的 MA
 */
@interface YT_KlineMAExplain : NSObject
@property (nonatomic, assign)NSUInteger index;  ///< 索引 有关 线的颜色 数据等 0 ~ 4
@property (nonatomic, assign)NSUInteger day;  ///< 这个指标线是几日均线
@end

#pragma mark YT_TechZBExplain

/**
 指标区域，(附图区域)
 */
@interface YT_TechZBExplain : NSObject
@property (nonatomic, assign) YT_ZBType zbType;  ///< 附图指标类型
@property (nonatomic, assign) YT_CoordinateAxisParam  axisParam; ///< 技术指标某范围内的坐标参数
@end

#pragma mark - YT_KLineDataSource

@interface YT_KLineDataSource : NSObject
//@property (nonatomic, strong) NSMutableArray<stock_kline_data*> *klineDataArrArray; ///< k线数据must
@property (nonatomic, strong) NSArray<id <YT_StockKlineData>> *klineDataArray; ///< k线数据must

#pragma mark klineChart(主图)

@property (nonatomic, strong) NSArray<YT_KlineMAExplain *>* klineZBMAExplainArray; ///< k线表格区域 MA参数

@property (nonatomic, assign) NSRange displayRange;  ///< k线显示起始索引 + k线显示数量
@property (nonatomic, assign, readonly) YT_KLineCoordinateAxisParam  klineAxisParam; ///< k线某范围内的坐标参数
@property (nonatomic, assign, readonly) YT_CoordinateAxisParam  klineCAxisParam;  ///< k线蜡烛图某范围内的坐标参数

#pragma mark techZBChart (attachedTechZBChart 技术指标附图)

@property (nonatomic, strong, readonly) NSArray<YT_TechZBExplain *> *attachedTechZBArray; ///< 技术指标

@property (nonatomic, assign) YT_ZBType techZBType;  ///< 技术指标附图一 指标类型
@property (nonatomic, assign, readonly) YT_CoordinateAxisParam  techAxisParam; ///< 技术指标附图一 某范围内的坐标参数

#pragma mark 计算结果

@property (nonatomic, strong, readonly) YT_KlineDataCalculateCacheManager * cacheManager; ///< 计算结果缓存数据

#pragma mark 引导计算

/**
 重置 klineDataArray 重置 cacheManager
 */
-(void)resetKlineDataArray:(NSArray<id <YT_StockKlineData>> *)klineDataArray;

/**
 *  重置 显示范围 并计算,耗时操作
 */
- (void)changeDisplayRangeAndResetAllDataIfNeed:(NSRange)displayRange;

/**
 *  重置 klineZBMAExplain 并计算,耗时操作
 */
- (void)changeKlineZBMAExplainAndResetAllDataIfNeed:(NSArray<YT_KlineMAExplain *>*)explainArray;

/**
 * 重置 技术指标附图一 techZBType 并计算,耗时操作
 */
- (void)changeTechZBTypeAndResetAllDataIfNeed:(YT_ZBType)zhiBiaoType;

#pragma mark 多附图指标 引导计算

/// 新增需要计算的附图指标，neddCaculate 是否需要计算，返回索引
- (YT_TechZBExplain *)addAttachedTechZB:(YT_ZBType)zbType neddCaculate:(BOOL)neddCaculate;
/// 删除图指标类型
- (BOOL)removeAttachedTechZB:(YT_TechZBExplain *)zbExplain cleanCahe:(BOOL)cleanCahe;
/// 改变副图指标类型 返回是否成功
- (BOOL)changeAttachedTechZB:(YT_TechZBExplain *)zbExplain to:(YT_ZBType)zbType neddCaculate:(BOOL)neddCaculate cleanCahe:(BOOL)cleanCahe;

#pragma mark 重置坐标轴计算结果
-(void)makeDefData;

@end
