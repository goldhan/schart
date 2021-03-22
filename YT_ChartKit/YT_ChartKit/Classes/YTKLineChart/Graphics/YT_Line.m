//
//  YT_Line.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/28.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_Line.h"

NS_ASSUME_NONNULL_BEGIN

void CGPathAddBrokenLineWithPointsInRangeRecursion(CGMutablePathRef ref, CGPoint * points, NSRange range, CGPoint ignorePoint)
{
    NSUInteger from = range.location;
    CGPoint point = points[from];
    if(CGPointEqualToPoint(point, ignorePoint)) {
        if (range.length > 1) {
            CGPathAddBrokenLineWithPointsInRangeRecursion(ref, points, NSMakeRange(from +1, range.length -1), ignorePoint);
        }
        return;
    }
    CGPathMoveToPoint(ref, NULL, point.x, point.y);
    NSUInteger size = NSMaxRange(range);
    
    for (NSInteger i = from +1 ; i < size; i++) {
        
        CGPoint point = points[i];
        if (CGPointEqualToPoint(point, ignorePoint)) {
            if ( ++i < size) {
              CGPathAddBrokenLineWithPointsInRangeRecursion(ref, points, NSMakeRange(i, size - i), ignorePoint);
            }
            break;
        }else {
            CGPathAddLineToPoint(ref, NULL, point.x, point.y);
        }
    }
    
}

void CGPathAddBrokenLineWithPointsInRange(CGMutablePathRef ref, CGPoint * points, NSRange range, CGPoint ignorePoint)
{
    BOOL isMovePoint = YES;
    
    NSUInteger size = NSMaxRange(range);
    
    for (NSInteger i = range.location; i < size; i++) {
        
        CGPoint point = points[i];
        
        if (CGPointEqualToPoint(point, ignorePoint)) {
            isMovePoint = YES;
            continue;
        }
        
        if (isMovePoint) {
            isMovePoint = NO;
            CGPathMoveToPoint(ref, NULL, point.x, point.y);
        }else {
            CGPathAddLineToPoint(ref, NULL, point.x, point.y);
        }
    }
}

void CGPathAddBrokenLineWithPoints(CGMutablePathRef ref, CGPoint * points, size_t size)
{
    CGPathAddBrokenLineWithPointsInRange(ref, points, NSMakeRange(0, size), CGPointMake(FLT_MIN, FLT_MIN));
}

void CGPathAddBrokenLineWithPointsInRangeFull(CGMutablePathRef ref, CGPoint * points, NSRange range)
{
    NSUInteger size = NSMaxRange(range);
    CGPoint point = points[range.location];
    CGPathMoveToPoint(ref, NULL, point.x, point.y);
    for (NSInteger i = range.location + 1; i < size; i++) {
        CGPathAddLineToPoint(ref, NULL, point.x, point.y);
    }
}

/**
 * 折线每个点于某一y坐标展开动画
 *
 * @param points 折线点
 * @param size 折线大小
 * @param y 指定y轴坐标
 *
 * @return 路径动画数组
 */
NSArray * CGPathLinesStretchAnimation(CGPoint * points, size_t size, CGFloat y)
{
    NSMutableArray * ary = [NSMutableArray array];
    
    for (NSInteger i = 0; i < size; i++) {
        
        CGPoint basePoints[size];
        
        for (NSInteger j = 0; j < size; j++) {
            
            basePoints[j] = CGPointMake(points[j].x, y);
        }
        
        for (NSInteger z = 0; z < i; z++) {
            
            basePoints[z] = CGPointMake(points[z].x, points[z].y);
        }
        
        CGMutablePathRef ref = CGPathCreateMutable();
        CGPathAddLines(ref, NULL, basePoints, size);
        [ary addObject:(__bridge id)ref];
        CGPathRelease(ref);
    }
    
    CGMutablePathRef ref = CGPathCreateMutable();
    CGPathAddLines(ref, NULL, points, size);
    [ary addObject:(__bridge id)ref];
    CGPathRelease(ref);
    
    return ary;
}

/**
 * 折线于某一y坐标展开动画
 *
 * @param points 折线点
 * @param size 折线大小
 * @param y 指定y轴坐标
 *
 * @return 路径动画数组
 */
NSArray * CGPathLinesUpspringAnimation(CGPoint * points, size_t size, CGFloat y)
{
    NSMutableArray * ary = [NSMutableArray array];
    
    CGPoint basePoints[size];
    
    for (NSInteger i = 0; i < size; i++) {
        
        basePoints[i] = CGPointMake(points[i].x, y);
    }
    
    CGMutablePathRef ref = CGPathCreateMutable();
    CGPathAddLines(ref, NULL, basePoints, size);
    [ary addObject:(__bridge id)ref];
    CGPathRelease(ref);
    
    ref = CGPathCreateMutable();
    CGPathAddLines(ref, NULL, points, size);
    [ary addObject:(__bridge id)ref];
    CGPathRelease(ref);
    
    return ary;
}

/**
 * 折线填充每个点于某一y坐标展开动画
 *
 * @param points 折线点
 * @param size 折线大小
 * @param y 指定y轴坐标
 *
 * @return 路径动画数组
 */
NSArray * CGPathFillLinesStretchAnimation(CGPoint * points, size_t size, CGFloat y)
{
    NSMutableArray * ary = [NSMutableArray array];
    
    for (NSInteger i = 0; i < size; i++) {
        
        CGPoint basePoints[size];
        
        for (NSInteger j = 0; j < size; j++) {
            
            basePoints[j] = CGPointMake(points[j].x, y);
        }
        
        for (NSInteger z = 0; z < i; z++) {
            
            basePoints[z] = CGPointMake(points[z].x, points[z].y);
        }
        
        CGMutablePathRef ref = CGPathCreateMutable();
        CGPathAddLines(ref, NULL, basePoints, size);
        CGPathAddLineToPoint(ref, NULL, basePoints[size - 1].x, y);
        CGPathAddLineToPoint(ref, NULL, basePoints[0].x, y);
        [ary addObject:(__bridge id)ref];
        CGPathRelease(ref);
    }
    
    CGMutablePathRef ref = CGPathCreateMutable();
    CGPathAddLines(ref, NULL, points, size);
    CGPathAddLineToPoint(ref, NULL, points[size - 1].x, y);
    CGPathAddLineToPoint(ref, NULL, points[0].x, y);
    [ary addObject:(__bridge id)ref];
    CGPathRelease(ref);
    
    return ary;
}

/**
 * 折线填充于某一y坐标展开动画
 *
 * @param points 折线点
 * @param size 折线大小
 * @param y 指定y轴坐标
 *
 * @return 路径动画数组
 */
NSArray * CGPathFillLinesUpspringAnimation(CGPoint * points, size_t size, CGFloat y)
{
    NSMutableArray * ary = [NSMutableArray array];
    
    CGPoint basePoints[size];
    
    for (NSInteger i = 0; i < size; i++) {
        
        basePoints[i] = CGPointMake(points[i].x, y);
    }
    
    CGMutablePathRef ref = CGPathCreateMutable();
    CGPathAddLines(ref, NULL, basePoints, size);
    CGPathAddLineToPoint(ref, NULL, basePoints[size - 1].x, y);
    CGPathAddLineToPoint(ref, NULL, basePoints[0].x, y);
    [ary addObject:(__bridge id)ref];
    CGPathRelease(ref);
    
    ref = CGPathCreateMutable();
    CGPathAddLines(ref, NULL, points, size);
    CGPathAddLineToPoint(ref, NULL, points[size - 1].x, y);
    CGPathAddLineToPoint(ref, NULL, points[0].x, y);
    [ary addObject:(__bridge id)ref];
    CGPathRelease(ref);
    
    return ary;
}

NS_ASSUME_NONNULL_END
