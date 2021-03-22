//
//  YT_StockChartRendererProtocol
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/31.
//  Copyright © 2018年 kds. All rights reserved.
//
//* 说明 Renderer （渲染器） 协议

#import <QuartzCore/QuartzCore.h>

@protocol YT_StockChartRendererProtocol <NSObject>

/**
 * 绘制结构体
 */
- (void)drawInContext:(CGContextRef)ctx;

@optional

/**
 * 是否隐藏
 */
@property (nonatomic, assign) BOOL hidden;

@end

