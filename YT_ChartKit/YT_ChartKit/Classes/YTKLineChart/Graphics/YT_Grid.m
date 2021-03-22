//
//  YT_Grid.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/24.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_Grid.h"

NS_ASSUME_NONNULL_BEGIN

void CGPathAddYTHLines(CGMutablePathRef ref, CGRect rect, CGFloat step, NSInteger fromIdx, NSInteger toIdx)
{
    CGFloat x = CGRectGetMinX(rect);
    CGFloat y = CGRectGetMinY(rect);
    CGFloat x_Max = CGRectGetMaxX(rect);
    
    for (NSInteger i = fromIdx; i < toIdx ; i ++) {
        CGFloat y_step = y + i * step;
        CGPathMoveToPoint(ref, NULL, x, y_step);
        CGPathAddLineToPoint(ref, NULL, x_Max, y_step);
    }
}

void CGPathAddYTVLines(CGMutablePathRef ref, CGRect rect, CGFloat step, NSInteger fromIdx, NSInteger toIdx)
{
    CGFloat x = CGRectGetMinX(rect);
    CGFloat y = CGRectGetMinY(rect);
    CGFloat y_Max = CGRectGetMaxY(rect);
    
    for (NSInteger i = fromIdx; i < toIdx ; i ++) {
        CGFloat x_step = x + i * step;
        CGPathMoveToPoint(ref, NULL, x_step, y);
        CGPathAddLineToPoint(ref, NULL, x_step, y_Max);
    }
}

#pragma mark - YTGrid

void CGPathAddYTGrid(CGMutablePathRef ref, YT_Grid grid)
{

    CGFloat y_dis = CGRectGetHeight(grid.rect) / grid.row;
    CGFloat x_dis = CGRectGetWidth(grid.rect) / grid.column;
    
    CGPathAddYTHLines(ref, grid.rect, y_dis, 1, grid.row);
    CGPathAddYTVLines(ref, grid.rect, x_dis, 1, grid.column);
    
    CGPathAddRect(ref, NULL, grid.rect);
}


#pragma mark - YTGrid2

/**
 * 绘制网格
 */
void CGPathAddYTGrid2(CGMutablePathRef ref, YT_Grid2 grid)
{
    NSInteger h_count = grid.y_dis == 0 ? 0 : CGRectGetHeight(grid.rect) / grid.y_dis +1;  ///< 横线个数
    NSInteger v_count = grid.x_dis == 0 ? 0 : CGRectGetWidth(grid.rect) / grid.x_dis + 1; ///< 纵线个数
    
    CGPathAddYTHLines(ref, grid.rect, grid.y_dis, 1, h_count);
    CGPathAddYTVLines(ref, grid.rect, grid.x_dis, 1, v_count);
    
    CGPathAddRect(ref, NULL, grid.rect);
}

#pragma mark - 扩展

/**
 * NSValue 扩展
 */
@implementation NSValue (YT_GridExtensions)

+ (NSValue *)valueWithYTGrid:(YT_Grid)grid {
     return [NSValue value:&grid withObjCType:@encode(YT_Grid)];
}

- (YT_Grid)YTGridValue {
    YT_Grid grid;
    [self getValue:&grid];
    return grid;
}

+ (NSValue *)valueWithYTGrid2:(YT_Grid2)grid {
    return [NSValue value:&grid withObjCType:@encode(YT_Grid2)];
}

- (YT_Grid2)YTGrid2Value {
    YT_Grid2 grid;
    [self getValue:&grid];
    return grid;
}

@end

NS_ASSUME_NONNULL_END
