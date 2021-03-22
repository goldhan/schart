//
//  YT_TimeOverlayLayer.h
//  YT_ChartKit
//
//  Created by ChenRui Hu on 2018/8/27.
//

#import <QuartzCore/QuartzCore.h>

/// 分时叠加层
@interface YT_TimeOverlayLayer : CALayer

/** 分时叠加线线宽 */
@property (nonatomic, assign) CGFloat overlayLineWith;

/** 分时叠加线1颜色 */
@property (nonatomic, strong) UIColor *overlayLineColor;

/** 分时叠加线2颜色 */
@property (nonatomic, strong) UIColor *otherLineColor;

/// 配制
- (void)configLayer;
/// 绘制叠加层
- (void)drawOverlayLine:(id)timeChart;
@end
