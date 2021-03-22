//
//  YT_TimeChartProtocol.h
//  YT_ChartKit
//
//  Created by ChenRui Hu on 2018/8/9.
//

#ifndef YT_TimeChartProtocol_h
#define YT_TimeChartProtocol_h

@protocol YT_TimeChartDelegate <NSObject>
@optional

/** 图表单击时回调 */
- (void)stockTimeChartDidSingleTap:(id)timeChart;

/** 图表长按时回调 */
- (void)stockTimeChart:(id)timeChart didLongPresOfIndex:(NSInteger)index;

/** 图表长按结束 */
- (void)stockTimeChartDidLongPresEnded:(id)timeChart;

@end

#endif /* YT_TimeChartProtocol_h */
