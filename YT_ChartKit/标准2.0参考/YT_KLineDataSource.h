//
//  YT_KLineDataSource.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2017/9/15.
//  Copyright © 2017年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YT_KLineDataCalculateCache.h"

@interface YT_KLineDataSource : NSObject

/*-------DataSourceBegin----------*/
@property (nonatomic, strong)stock_kline_rep  *klineRep;    ///< k线数据must
@property (nonatomic, assign) KDS_ZBType      zhiBiaoType;  ///< 指标类型

/*******CoordinateAxisXParam**********/
@property (nonatomic,assign)NSInteger       klineNumberOfShowing;     ///< k线显示数量
@property (nonatomic,assign,readonly)NSInteger       pos;             ///< k线显示起始索引
/*-------DataSourceEnd----------*/


/*******CoordinateAxisYParam**********/
@property (nonatomic, strong)NFloat          *maxPrice;              ///< 最大价格
@property (nonatomic, strong)NFloat          *minPrice;              ///< 最小价格
@property (nonatomic, strong)NFloat          *maxZDF;                ///< 最大涨跌幅
@property (nonatomic, strong)NFloat          *minZDF;                ///< 最小涨跌幅
@property (nonatomic, strong)NFloat          *maxCJL;                ///< 最大成交量
@property (nonatomic, strong)NFloat          *maxTech;               ///< 最大技术指标值（技术指标区域y轴值）
@property (nonatomic, strong)NFloat          *minTech;               ///< 最小技术指标值（技术指标区域y轴值）

/*******Data**********/

@property (nonatomic, strong)NSMutableArray  *array_TechMA1;                ///< Tech均线1数据
@property (nonatomic, strong)NSMutableArray  *array_TechMA2;                ///< Tech均线2数据
@property (nonatomic, strong)NSMutableArray  *array_TechMA3;                ///< Tech均线3数据

@property (nonatomic, strong)NSMutableArray<UIColor *>  *array_colors;              ///< 每条均线的颜色

/**
 设置完成DataSource之后必须计算初始参数
 */
-(void)calculateInitParm;
/**
 *  计算需要显示的数据的最大和最小参数，确定Y轴数值以及蜡烛线的位置等
 */
- (void)calculateKineCoordinateAxisYParam;
/**
 * 计算指标
 */
-(void)calculateZhiBiao;

/**
 *  改变pos了重新计算指标等 ****************
 */
-(void)changePosAndResetAllDataIfNeed:(NSInteger)pos;
/**
 *  KlineRep 在插入数组到0索引后，必须优先调用 ********************
 */
-(void)insertKlineDataAtKlineRepZeroIndexHandle:(NSInteger)Count;

+(instancetype)klineDataSourceWithKlineRep:(stock_kline_rep *)klineRep pos:(NSInteger)pos;
@end
