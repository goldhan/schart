//
//  YT_StockChartCanvas.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/31.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_StockChartCanvas.h"

@interface YT_StockChartCanvas ()

/**
 * 渲染器
 */
@property (nonatomic, strong) NSMutableArray <id <YT_StockChartRendererProtocol>> * aryRenderer;

@end

@implementation YT_StockChartCanvas

/** 初始化 */
- (instancetype)init {
    self = [super init];
    if (self) {
        self.contentsScale = [UIScreen mainScreen].scale;
        self.masksToBounds = YES;
        self.aryRenderer = [NSMutableArray array];
    }
    return self;
}

#pragma mark - 绘制

/**
 * 增加一个绘图工具
 *
 * @param renderer 绘制工具
 */
- (void)addRenderer:(id <YT_StockChartRendererProtocol>)renderer {
     [self.aryRenderer addObject:renderer];
}

/**
 * 删除一个绘图工具
 *
 * @param renderer 绘制工具
 */
- (void)removeRenderer:(id <YT_StockChartRendererProtocol>)renderer {
     [self.aryRenderer removeObject:renderer];
}

/**
 * 删除所有绘图工具
 */
- (void)removeAllRenderer {
    [self.aryRenderer removeAllObjects];
}

/**
 * 继承 CALayer
 *
 * @param ctx 上下文
 */
- (void)drawInContext:(CGContextRef)ctx {
    CGContextSaveGState(ctx);
    
    if (_isCloseDisableActions) {
        [CATransaction setDisableActions:YES];
    }
    
    [super drawInContext:ctx];
    
    for (id <YT_StockChartRendererProtocol> renderer in _aryRenderer) {
        if ([renderer respondsToSelector:@selector(hidden)] && renderer.hidden) continue;
        [renderer drawInContext:ctx];
    }
    
    CGContextRestoreGState(ctx);
}

@end
