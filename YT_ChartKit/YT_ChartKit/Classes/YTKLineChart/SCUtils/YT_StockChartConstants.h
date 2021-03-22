//
//  YT_StockChartConstants.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/31.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 纯小数(-1 <= x <= 1)
 */
#define YT_RATIO_FIX_DECIMAL(x)     (x > 1 ? 1 : (x < -1 ? -1 : x))

/**
 * 偏移比例转换
 *
 * {0, 0} 中心, {-1, -1} 右上, {0, 0} 左下
 *
 * {-1, -1}, { 0, -1}, { 1, -1},
 * {-1,  0}, { 0,  0}, { 1,  0},
 * {-1,  1}, { 0,  1}, { 1,  1},
 */
#define YT_RATIO_POINT_CONVERT(p)              \
CGPointMake((-1 + YT_RATIO_FIX_DECIMAL(p.x)) / 2, (-1 + YT_RATIO_FIX_DECIMAL(p.y)) / 2)

/**
 * 文字偏移比例
 */
CG_EXTERN CGPoint const YTRatioTopLeft;
CG_EXTERN CGPoint const YTRatioTopCenter;
CG_EXTERN CGPoint const YTRatioTopRight;

CG_EXTERN CGPoint const YTRatioBottomLeft;
CG_EXTERN CGPoint const YTRatioBottomCenter;
CG_EXTERN CGPoint const YTRatioBottomRight;

CG_EXTERN CGPoint const YTRatioCenterLeft;
CG_EXTERN CGPoint const YTRatioCenter;
CG_EXTERN CGPoint const YTRatioCenterRight;
