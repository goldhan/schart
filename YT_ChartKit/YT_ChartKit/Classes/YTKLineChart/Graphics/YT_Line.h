//
//  YT_Line.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/28.
//  Copyright © 2018年 kds. All rights reserved.
//  curveLine 曲线 brokenLine 折线

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 直线结构体
 */
struct YTLine {
    CGPoint start;
    CGPoint end;
};
typedef struct YTLine YT_Line;

/**
 * 构造直线结构体
 */
CG_INLINE YT_Line
YT_LineMake(CGFloat x1, CGFloat y1, CGFloat x2, CGFloat y2)
{
    YT_Line line;
    line.start = CGPointMake(x1, y1);
    line.end = CGPointMake(x2, y2);
    return line;
}

/**
 * 构造直线结构体
 */
CG_INLINE YT_Line
YT_PointLineMake(CGPoint start, CGPoint end)
{
    YT_Line line;
    line.start = start;
    line.end = end;
    return line;
}


/**
 * 获取Rect顶直线
 */
CG_INLINE YT_Line
YT_TopLineRect(CGRect rect)
{
    return YT_LineMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMinY(rect));
}

/**
 * 获取Rect左直线
 */
CG_INLINE YT_Line
YT_LeftLineRect(CGRect rect)
{
    return YT_LineMake(CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMinX(rect), CGRectGetMaxY(rect));
}

/**
 * 获取Rect底直线
 */
CG_INLINE YT_Line
YT_BottomLineRect(CGRect rect)
{
    return YT_LineMake(CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMaxX(rect), CGRectGetMaxY(rect));
}

/**
 * 获取Rect右直线
 */
CG_INLINE YT_Line
YT_RightLineRect(CGRect rect)
{
    return YT_LineMake(CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMaxY(rect));
}

/**
 * 获取Rect中, 垂直于Y轴的直线
 */
CG_INLINE YT_Line
YT_LineRectForX(CGRect rect, CGFloat x)
{
    x = x > CGRectGetMaxX(rect) ? CGRectGetMaxX(rect) : x;
    x = x < CGRectGetMinX(rect) ? CGRectGetMinX(rect) : x;
    
    return YT_LineMake(x, CGRectGetMinY(rect), x, CGRectGetMaxY(rect));
}

/**
 * 获取Rect中, 垂直于X轴的直线
 */
CG_INLINE YT_Line
YT_LineRectForY(CGRect rect, CGFloat y)
{
    y = y > CGRectGetMaxY(rect) ? CGRectGetMaxY(rect) : y;
    y = y < CGRectGetMinY(rect) ? CGRectGetMinY(rect) : y;
    
    return YT_LineMake(CGRectGetMinX(rect), y, CGRectGetMaxX(rect), y);
}

#pragma mark - Path

/**
 * 绘制折线
 *
 * @param ref 路径结构体
 * @param points 折线点
 * @param range 区间
 */
CG_EXTERN void CGPathAddBrokenLineWithPointsInRangeRecursion(CGMutablePathRef ref, CGPoint * points, NSRange range, CGPoint ignorePoint);

/**
 * 绘制折线
 *
 * @param ref 路径结构体
 * @param points 折线点
 * @param range 区间
 * @param ignorePoint CGPointMake(FLT_MIN, FLT_MIN)
 */
CG_EXTERN void CGPathAddBrokenLineWithPointsInRange(CGMutablePathRef ref, CGPoint * points, NSRange range, CGPoint ignorePoint);

/**
 * 绘制折线
 *
 * @param ref 路径结构体
 * @param points 折线点
 * @param size 折线大小
 */
CG_EXTERN void CGPathAddBrokenLineWithPoints(CGMutablePathRef ref, CGPoint * points, size_t size);

/**
 * 绘制折线
 *
 * @param ref 路径结构体
 * @param points 折线点
 * @param range 区间
 */
CG_EXTERN void CGPathAddBrokenLineWithPointsInRangeFull(CGMutablePathRef ref, CGPoint * points, NSRange range);

#pragma mark - Path Animations

/**
 * 折线每个点于某一y坐标展开动画
 *
 * @param points 折线点
 * @param size 折线大小
 * @param y 指定y轴坐标
 *
 * @return 路径动画数组
 */
CG_EXTERN NSArray * CGPathLinesStretchAnimation(CGPoint * points, size_t size, CGFloat y);

/**
 * 折线填充每个点于某一y坐标展开动画
 *
 * @param points 折线点
 * @param size 折线大小
 * @param y 指定y轴坐标
 *
 * @return 路径动画数组
 */
CG_EXTERN NSArray * CGPathFillLinesStretchAnimation(CGPoint * points, size_t size, CGFloat y);

/**
 * 折线于某一y坐标展开动画
 *
 * @param points 折线点
 * @param size 折线大小
 * @param y 指定y轴坐标
 *
 * @return 路径动画数组
 */
CG_EXTERN NSArray * CGPathLinesUpspringAnimation(CGPoint * points, size_t size, CGFloat y);

/**
 * 折线填充于某一y坐标展开动画
 *
 * @param points 折线点
 * @param size 折线大小
 * @param y 指定y轴坐标
 *
 * @return 路径动画数组
 */
CG_EXTERN NSArray * CGPathFillLinesUpspringAnimation(CGPoint * points, size_t size, CGFloat y);


NS_ASSUME_NONNULL_END
