//
//  YT_StringArrayRenderer.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/6/1.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YT_StockChartRendererProtocol.h"

@interface YT_StringArrayRenderer : NSObject <YT_StockChartRendererProtocol>

@property (nonatomic, strong) NSMutableArray<NSString *> * stringArray;
@property (nonatomic, strong) NSMutableArray<NSValue *> * stringPoints;

/**
 * 绘制文字字体
 */
@property (nonatomic, strong) UIFont * font;

/**
 * 绘制文字颜色
 */
@property (nonatomic, strong) UIColor * color;

/**
 * 轴线文字颜色数组
 */
@property (nonatomic, copy) UIColor *(^colorsBlock)(YT_StringArrayRenderer *renderer, NSInteger index);

/**
 * 绘制文字偏移量
 */
@property (nonatomic, assign) CGSize offset;

///< reture YT_RATIO_POINT_CONVERT(textOffSet)
@property (nonatomic, copy) CGSize (^offsetsBlock)(YT_StringArrayRenderer *renderer, NSInteger index);

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

@property (nonatomic, copy) CGPoint (^offSetRatiosBlock)(YT_StringArrayRenderer *renderer, NSInteger index);

/**
 * 限制范围, 设置之后不可超出大小
 Demo
 Renderer.limitSize = CGSizeMake(kRight_Sapce - 10, 0);
 Renderer.fixSizeBlockUntilLimitSize = ^UIFont *(NSString *string, UIFont *font, BOOL *stop) {
     return [UIFont fontWithName:font.fontName size:font.pointSize-1];
 };
 */
@property (nonatomic, assign) CGSize limitSize;
@property (nonatomic, copy) UIFont * (^fixSizeBlockUntilLimitSize)(NSString *string, UIFont *font, BOOL *stop);
@property (nonatomic, assign) BOOL textKeepSameFont; // 默认NO

/**
 * 增加轴关键点以及文字
 *
 * @param string 文字
 * @param point 点
 */
- (void)addString:(NSString *)string point:(CGPoint)point;

/**
 * 清除所有附加文字
 */
- (void)removeAllPointString;

/**
 * Block设置 stringPoints 点文字
 */
- (void)setStringBlock:(NSString *(^)(CGPoint point, NSInteger index, NSInteger count))stringBlock;

+(NSMutableArray<NSValue *> *)pointArrayFormPoint:(CGPoint)fPoint toPoint:(CGPoint)tPoint sepCount:(NSUInteger)sepCount offset:(CGPoint)offset ;
@end

