//
//  YT_TimeGridLayer.h
//  YT_ChartKit
//
//  Created by ChenRui Hu on 2018/8/20.
//

#import <QuartzCore/QuartzCore.h>

/// 分时图片后面的网格线
@interface YT_TimeGridLayer : CALayer

/** 网格线颜色 (默认-[UIColor lightGrayColor]) */
@property (nonatomic, strong) UIColor *gridLineColor;

/** 网格线宽度 (默认1) */
@property (nonatomic, assign) CGFloat gridLineWidth;

/** 分时图网格分割数量 */
@property (nonatomic, assign) NSInteger yAxisTimeSegments;

/** 成交量网格分割数量 */
@property (nonatomic, assign) NSInteger yAxisVolumeSegments;

/** x轴时间数量 */
@property (nonatomic, assign) NSInteger xAxisDateSegments;

/** 分时最大数据量，默认240条 */
@property (nonatomic, assign) NSInteger maxDataCount;

/// 配制
- (void)configLayer;
/// 绘制网格横线及两边竖线
- (void)updateLayerWithRect:(CGRect)timeRect :(CGRect)volumeRect :(CGRect)tradeReact;
/// 绘制五日分时时的中间竖线
- (void)drawFiveDateLines;
/// 绘制当日分时时的中间竖线
- (void)drawDateLines:(id)timeChart;
@end
