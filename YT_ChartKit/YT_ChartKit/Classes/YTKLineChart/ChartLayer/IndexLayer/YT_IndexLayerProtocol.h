//
//  YT_IndexLayerProtocol.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/25.
//  Copyright © 2018年 kds. All rights reserved.
// * 说明 这个文件定义 指标Layer 的使用协议 用于规范 指标Layer 的使用方式

#ifndef YT_IndexLayerProtocol_h
#define YT_IndexLayerProtocol_h

#import "YT_ChartScaler.h"
#import "YT_KLineDataSource.h"

@protocol YT_IndexLayerConfig;

@protocol YT_IndexLayerProtocol
@property (nonatomic, strong) NSArray * dataArray;  ///< 数据数组
@property (nonatomic, strong) YT_ChartScaler  * chartScaler;  ///< 绘制测量器
@property (nonatomic, strong) id<YT_IndexLayerConfig> configuration;  ///< layer 相关配置对象
@property (nonatomic, assign) int textDecimalPlaces;   ///<  文字推荐显示小数位数 一般 2 ~ 4
@property (nonatomic, assign) int textUnits;  ///< 文字推荐显示单位 0 个 4 万 8 亿 （整数位 0 的个数）

/**
 * 标题
 */
- (NSAttributedString *)titleAttributedString;

/**
 * 指标字符串组成部分 格式为 k:v
 */
- (NSArray<NSString *> *)infoStringWithIndex:(NSInteger)index;

/**
 * 指标字符串 长按手势 查询层（十字线） 出现 时显示
 */
- (NSAttributedString *)attrStringWithIndex:(NSInteger)index;

/**
 layer 初始化配置
 */
- (void)configLayer;

/**
 实时更新 layer

 @param range 数据数组绘制区间
 */
- (void)updateLayerWithRange:(NSRange)range;

@optional
@property (nonatomic, strong) YT_KLineDataSource * dataSource; ///< 数据
@property (nonatomic, strong) NSArray<id <YT_StockKlineData>> *klineDataArray; ///< k线数据
@property (nonatomic, strong) id indexExplain; //指标摘要说明，ma 自定义天数之类

/**
 * 坐标轴上的文字
 */
- (NSString *)axisStringWithValue:(double)value;
@end


#endif /* YT_IndexLayerProtocol_h */
