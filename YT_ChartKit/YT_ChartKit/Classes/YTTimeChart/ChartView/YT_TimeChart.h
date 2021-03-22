//
//  CoreGraphics_demo
//
//  Created by zhanghao on 2018/7/6.
//  Copyright © 2018年 snail-z. All rights reserved.
//

#import "YT_TimeBaseChart.h"
#import "YT_TimeChartConfiguration.h"
#import "YT_TimeProtocol.h"
#import "YT_TimeChartProtocol.h"

#import "YT_TimeGridLayer.h"
#import "YT_TimeLayer.h"
#import "YT_VolumeLayer.h"
#import "YT_CrosswireView.h"

NS_ASSUME_NONNULL_BEGIN

@interface YT_TimeChart : YT_TimeBaseChart <UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<YT_TimeChartDelegate> delegate;

/** 设置外观样式 */
@property (nonatomic, strong) YT_TimeChartConfiguration *configuration;

/** 用于控制绘制分时图坐标值 */
@property (nonatomic, strong) id<YT_TimePropProtocol> propData;

/** 设置分时数据源 */
@property (nonatomic, strong) NSArray<id<YT_TimeProtocol>> *dataArray;

/** 设置分时叠加1数据源 */
@property (nonatomic, strong) NSArray<id<YT_TimeOverlayProtocol>> *overlayDataArray;

/** 设置分时叠加2数据源 */
@property (nonatomic, strong) NSArray<id<YT_TimeOverlayOtherProtocol>> *overlayOtherDataArray;

/** 设置时间线文本数据 */
@property (nonatomic, strong, nullable) NSArray<NSString *> *dateArray;
    
/** 五日分时时间线文本数据 */
@property (nonatomic, strong, nullable) NSMutableArray<NSString *> *fiveDateArray;

/** 绘图区域(包括分时图区域/中间分隔区和成交量区域) */
@property (nonatomic, assign) CGRect chartRect;

/** 分时图区域 */
@property (nonatomic, assign) CGRect timeRect;

/** 成交量区域 */
@property (nonatomic, assign) CGRect volumeRect;

/** 中间分隔区域 */
@property (nonatomic, assign) CGRect riverRect;

/** 网格层 */
@property (nonatomic, strong) YT_TimeGridLayer *timeGridLayer;

/** 分时层 */
@property (nonatomic, strong) YT_TimeLayer *timeLayer;

/** 成交量层 */
@property (nonatomic, strong) YT_VolumeLayer *volumeLayer;

/** 查询十字线视图 */
@property (nonatomic, strong) YT_CrosswireView *crosswireView;

/** 绘制图表 */
- (void)drawChart;

/** 配制子视图 */
- (void)updateSublayerAppearance;
/** 设置子视图的布局 */
- (void)updateLayout;
@end

NS_ASSUME_NONNULL_END
