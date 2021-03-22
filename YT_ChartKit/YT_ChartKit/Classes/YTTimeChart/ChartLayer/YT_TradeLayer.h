//
//  YT_TradeLayer.h
//  YT_ChartKit
//
//  Created by ChenRui Hu on 2018/8/27.
//

#import <QuartzCore/QuartzCore.h>

/// 买卖层（附图）
@interface YT_TradeLayer : CALayer

/** 买线颜色 */
@property (nonatomic, strong) UIColor *buyLineColor;

/** 卖线颜色 */
@property (nonatomic, strong) UIColor *sellLineColor;

/** 线宽度 (默认1) */
@property (nonatomic, assign) CGFloat tradeLineWidth;

/// 配制
- (void)configLayer;
/// 绘制买卖附图
- (void)drawTradeChart:(id)timeChart;
@end
