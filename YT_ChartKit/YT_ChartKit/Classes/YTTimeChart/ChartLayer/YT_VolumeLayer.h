//
//  YT_VolumeLayer.h
//  YT_ChartKit
//
//  Created by ChenRui Hu on 2018/8/22.
//

#import <QuartzCore/QuartzCore.h>

/// 成交量层
@interface YT_VolumeLayer : CALayer

/** 成交量柱状条涨颜色 */
@property (nonatomic, strong) UIColor *volumeRiseColor;

/** 成交量柱状条跌颜色 */
@property (nonatomic, strong) UIColor *volumeFallColor;

/** 成交量柱状条平颜色 (默认-[UIColor grayColor]) */
@property (nonatomic, strong) UIColor *volumeFlatColor;

/// 配制
- (void)configLayer;
/// 绘制成交量
- (void)drawVolumeChart:(id)timeChart;
@end
