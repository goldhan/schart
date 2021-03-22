//
//  YT_KlineExtremePointRenderer.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/6/14.
//  Copyright © 2018年 kds. All rights reserved.
//

// k线的最大最小值渲染器 画线+画文字
#import <Foundation/Foundation.h>
#import "YT_StockChartRendererProtocol.h"

@interface YT_KlineExtremePointRenderer : NSObject <YT_StockChartRendererProtocol>

/**
 * 限制范围, 设置之后不可超出范围
 */
@property (nonatomic, assign) CGRect drawRect;

/**
 * 不会绘制区域
 */
@property (nonatomic, assign) CGRect exclusionRect;

/**
 * 绘制文字字体 默认 10
 */
@property (nonatomic, strong) UIFont * textFont;

/**
 * 绘制文字颜色 默认 blackColor
 */
@property (nonatomic, strong) UIColor * texColor;

/**
 * 绘制线的宽度 默认 1
 */
@property (nonatomic, assign) CGFloat lineWidth;

/**
 * 绘制线的长度 默认 5
 */
@property (nonatomic, assign) CGFloat lineLength;

/**
 * 绘制线的颜色 默认 blackColor
 */
@property (nonatomic, strong) UIColor * lineColor;

/**
 * 连接类型
 */
@property(nonatomic, assign) CGLineJoin lineJoinStyle;
@property(nonatomic, assign) BOOL hadLineJoinStyle;

/**
 * 端点类型
 */
@property(nonatomic, assign) CGLineCap lineCapStyle;
@property(nonatomic, assign) BOOL hadLineCapStyle;

/**
 * 绘制线的lineDash CGContextSetLineDash
 */
@property (nonatomic, copy) void(^lineDashBlock)(YT_KlineExtremePointRenderer *renderer ,CGFloat *lineDash);
@property (nonatomic, assign) size_t lineDashSize;

@property (nonatomic, assign) CGPoint minPoint;
@property (nonatomic, strong) NSString * minText;

@property (nonatomic, assign) CGPoint maxPoint;
@property (nonatomic, strong) NSString * maxText;

/**
 * 是否隐藏
 */
@property (nonatomic, assign) BOOL hidden;

/**
 配置画圆点线 （。。。text）
 */
- (void)configDottedLine;
@end
