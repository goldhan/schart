//
//  CoreGraphics_demo
//
//  Created by zhanghao on 2018/7/10.
//  Copyright © 2018年 snail-z. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBezierPath (YT_TimeChart)

/** 绘制两点间连线 */
- (void)addLine:(CGPoint)start end:(CGPoint)end;

/** 绘制横线 */
- (void)addHorizontalLine:(CGPoint)start len:(CGFloat)len;

/** 绘制竖线 */
- (void)addVerticalLine:(CGPoint)start len:(CGFloat)len;

/** 绘制矩形框 */
- (void)addRect:(CGRect)rect;

/** 绘制多边形 */
- (void)addPolygon:(NSArray *)points;

@end

NS_ASSUME_NONNULL_END
