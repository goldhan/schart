//
//  YT_TimeChartV2.h
//  YT_ChartKit
//
//  Created by ChenRui Hu on 2018/8/22.
//

#import "YT_TimeChart.h"

@interface YT_TimeChartV2 : YT_TimeChart

/** 附图2上面切换区域 */
@property (nonatomic, assign) CGRect tradeSwitchRect;

/** 附图2买卖区域 */
@property (nonatomic, assign) CGRect tradeRect;

/** 最下方区域：时间区域 */
@property (nonatomic, assign) CGRect bottomRect;
@end
