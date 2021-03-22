//
//  YT_KLineChart.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/21.
//  Copyright © 2018年 kds. All rights reserved.
//
/**
 *  *用法
 *  KLineChart * kChart = [[KLineChart alloc] initWithFrame:..];
 *  [kChart setKLineArray:datas type:KLineTypeWeek];
 *  [kChart initChart];
 */

#import "YT_BaseScrollChart.h"
#import "YT_KLineDataProtocol.h"
#import "YT_KLineChartConfiguration.h"
#import "YT_KlineChartStringUtil.h"

@class YT_KLineDataSource, YT_CandlestickLayer, YT_StringArrayRenderer, YT_StockChartCanvas, YT_CrissCrossQueryView, YT_KlineExtremePointRenderer, YT_KLineMALayer, YT_ChartScaler;
@protocol YT_IndexLayerProtocol;

@protocol YT_TechZBChartContextAbstract <NSObject>

//public
@property (nonatomic, assign, readonly) YT_ZBType zbType;  ///< volum区域 指标类型
@property (nonatomic, copy) YT_ZBType (^nextZBTypeBlock)(YT_ZBType zbType); ///< 指标切换回调
@property (nonatomic, copy) void (^zbTypeChangedBlock)(YT_ZBType zbType); ///< 指标切换成功回调

@end

#pragma mark  - YT_KLineChart

@interface YT_KLineChart : YT_BaseScrollChart

@property (nonatomic, strong, readonly) YT_KLineChartConfiguration *config; ///< 配置对象 有默认值 只读对象
@property (nonatomic, readonly) NSArray <id <YT_StockKlineData> > *kLineArray;    ///< k线数组

#pragma mark techZBChart (attachedTechZBChart 技术指标附图)
/// 技术指标
@property (nonatomic, strong, readonly) NSArray<id <YT_TechZBChartContextAbstract>> *attachedTechZBArray;
@property (nonatomic, assign) NSInteger      attachedTechCount;  // 指标附图数量

#pragma mark 手势
@property (nonatomic, weak, readonly) UIPinchGestureRecognizer * pinchGesture;  ///< 缩放手势
@property (nonatomic, weak, readonly) UILongPressGestureRecognizer * longPressGesture;  ///< 长按手势
@property (nonatomic, weak, readonly) UITapGestureRecognizer * singleTapGesture;  ///< 点击手势

#pragma mark 刷新
@property (nonatomic, copy) void (^loadMoreBlock)(void);     ///< 加载更多刷新回调

#pragma mark 功能
@property (nonatomic, assign) BOOL  onceShow;  // 第一次显示

/** 设置k线 */
- (void)setKLineArray:(NSArray <id <YT_StockKlineData> > *)kLineArray;

/** 初始化视图 */
- (void)initChart;

/** 更新K线图 */
- (void)updateChart;

/** 插入新的数据后 更新K线图 */
- (void)updateChartForDIdInsetedKlineData:(NSArray <id <YT_StockKlineData> > *)kLineArray;

/** 末尾删除数据个数,并末尾添加K线数据 */
- (void)updateChartForDIdReplacedKlineDataAtLast:(NSInteger)count withKlineData:(NSArray <id <YT_StockKlineData> > *)kLineArray;

/** 结束刷新状态 */
- (void)endLoadingState;

/* 新增需要计算的附图指标 , 返回索引*/
- (NSInteger)addAttachedTechZB:(YT_ZBType)zbType display:(BOOL)display;
/* 删除图指标类型 */
- (BOOL)removeAttachedTechZBWithIndex:(NSInteger)index display:(BOOL)display;
/* 改变副图指标类型 返回是否成功 */
- (BOOL)setAttachedTechZBWithIndex:(NSInteger)index to:(YT_ZBType)zbType display:(BOOL)display;

/** 切换kline指标 */
- (void)setKLineZBType:(YT_ZBType)volumZBType;

/**
 放大缩小
 
 @param isZoom 是否为放大，反之缩小
 @param didEnd 已经到最大或者最小的回调
 */
- (void)zoomOrZoomOut:(BOOL) isZoom didEnd:(void(^)(void)) didEnd;


/**
 平移
 
 @param isRight 是否为向右，反之向左
 @param didEnd 已经到最右或者最左的回调
 */
- (void)moveView:(BOOL) isRight didEnd:(void(^)(void)) didEnd;

@end

/** demo 插入新的数据后 更新K线图 */
/*
 demo
 NSMutableArray * arr = self.kLineArray;
 NSArray * arr_c = [self.kLineArray copy];
 [arr insertObjects:arr_c atIndex:0];
 [self updateChartForDIdInsetedKlineData:arr_c];
 [self endLoadingState];
 */

/** demo 自动更新*/
/*
NSMutableArray * arr = self.kLineArray;
NSArray * arr_c = [self.kLineArray copy];
[arr removeLastObject];
[arr removeLastObject];
[arr removeLastObject];
[arr addObjectsFromArray:arr_c];
[self updateChartForDIdReplacedKlineDataAtLast:3 withKlineData:arr_c];
*/
