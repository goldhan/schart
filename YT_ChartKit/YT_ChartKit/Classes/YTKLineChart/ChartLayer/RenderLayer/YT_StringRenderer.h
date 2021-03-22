//
//  YT_StringRenderer.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/31.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YT_StockChartRendererProtocol.h"

@interface YT_StringRenderer : NSObject <YT_StockChartRendererProtocol>

/**
 * 绘制文字字体
 */
@property (nonatomic, strong) UIFont * font;

/**
 * 绘制文字颜色
 */
@property (nonatomic, strong) UIColor * color;

/**
 * 绘制文字关键点
 */
@property (nonatomic, assign) CGPoint point;

/**
 * 绘制文字偏移量
 */
@property (nonatomic, assign) CGSize offset;

/**
 * 文字偏移比例
 *
 * {0, 0} 中心, {-1, -1} 右上, {0, 0} 左下
 *
 * {-1, -1}, { 0, -1}, { 1, -1},
 * {-1,  0}, { 0,  0}, { 1,  0},
 * {-1,  1}, { 0,  1}, { 1,  1},
 */
@property (nonatomic, assign) CGPoint offSetRatio;

/**
 * 绘制文字
 */
@property (nonatomic, copy) NSString * string;

/**
 * 填充色
 */
@property (nonatomic, strong) UIColor * fillColor;

/**
 * 文字内边距
 */
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

/**
 * 标签背景弧度
 */
@property (nonatomic, assign) CGFloat radius;

/**
 * 限制范围, 设置之后不可超出范围
 */
@property (nonatomic, assign) CGRect limitRect;

@end
