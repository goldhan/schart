//
//  YT_StockChartCanvas.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/31.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <QuartzCore/QuartzCore.h>
#import "YT_StockChartRendererProtocol.h"

@interface YT_StockChartCanvas : CALayer

/**
 * 是否关闭隐士动画
 */
@property (nonatomic, assign) BOOL isCloseDisableActions;

/**
 * 增加一个绘图工具
 *
 * @param renderer 绘制工具
 */
- (void)addRenderer:(id <YT_StockChartRendererProtocol>)renderer ;

/**
 * 删除所有绘图工具
 */
- (void)removeAllRenderer;

/**
 * 删除一个绘图工具
 *
 * @param renderer 绘制工具
 */
- (void)removeRenderer:(id <YT_StockChartRendererProtocol>)renderer ;
@end
