//
//  YT_Grid.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/24.
//  Copyright © 2018年 kds. All rights reserved.
//
// * 说明 这个文件 定义了网格结构体

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 添加水平线路径
 
 @param ref 路径
 @param rect 绘制范围
 @param step 跨度
 @param fromIdx 起始索引
 @param toIdx 结束索引
 */
CG_EXTERN void CGPathAddYTHLines(CGMutablePathRef ref, CGRect rect, CGFloat step, NSInteger fromIdx, NSInteger toIdx);

/**
 添加垂直线路径
 
 @param ref 路径
 @param rect 绘制范围
 @param step 跨度
 @param fromIdx 起始索引
 @param toIdx 结束索引
 */
CG_EXTERN void CGPathAddYTVLines(CGMutablePathRef ref, CGRect rect, CGFloat step, NSInteger fromIdx, NSInteger toIdx);

#pragma mark - YTGrid

/**
 * 网格结构体
 */
struct YTGrid
{
    NSUInteger row;     ///< y 轴分割
    NSUInteger column;  ///< x 轴分割
    CGRect rect;
};
typedef struct YTGrid YT_Grid;

/**
 * 构造函数
 */
CG_INLINE YT_Grid
YT_GridMake(CGFloat x, CGFloat y, CGFloat width, CGFloat height, NSUInteger row, NSUInteger column) {
    YT_Grid grid;
    grid.rect = CGRectMake(x, y, width, height);
    grid.row = row;
    grid.column = column;
    return grid;
}

/**
 * 构造函数
 */
CG_INLINE YT_Grid
YT_GridRectMake(CGRect rect, NSUInteger row, NSUInteger column) {
    YT_Grid grid;
    grid.rect = rect;
    grid.row = row;
    grid.column = column;
    return grid;
}


/**
 * 绘制网格
 */
CG_EXTERN void CGPathAddYTGrid(CGMutablePathRef ref, YT_Grid grid);

#pragma mark - YTGrid2

/**
 * 网格结构体
 */
struct YTGrid2
{
    CGFloat y_dis;     ///< y 轴分割
    CGFloat x_dis;     ///< x 轴分割
    CGRect rect;
};
typedef struct YTGrid2 YT_Grid2;

/**
 * 构造函数
 */
CG_INLINE YT_Grid2
YT_Grid2Make(CGFloat x, CGFloat y, CGFloat width, CGFloat height, CGFloat y_dis, CGFloat x_dis) {
    YT_Grid2 grid;
    grid.rect = CGRectMake(x, y, width, height);
    grid.y_dis = y_dis;
    grid.x_dis = x_dis;
    return grid;
}

/**
 * 构造函数
 */
CG_INLINE YT_Grid2
YTGrid2RectMake(CGRect rect, CGFloat y_dis, CGFloat x_dis) {
    YT_Grid2 grid;
    grid.rect = rect;
    grid.y_dis = y_dis;
    grid.x_dis = x_dis;
    return grid;
}

/**
 * 绘制网格
 */
CG_EXTERN void CGPathAddYTGrid2(CGMutablePathRef ref, YT_Grid2 grid);


#pragma mark - 扩展

/**
 * NSValue 扩展
 */
@interface NSValue (YT_GridExtensions)

+ (NSValue *)valueWithYTGrid:(YT_Grid)grid;
- (YT_Grid)YTGridValue;

+ (NSValue *)valueWithYTGrid2:(YT_Grid2)grid;
- (YT_Grid2)YTGrid2Value;

@end




NS_ASSUME_NONNULL_END

