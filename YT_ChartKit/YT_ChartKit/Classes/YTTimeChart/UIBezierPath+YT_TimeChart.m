//
//  CoreGraphics_demo
//
//  Created by zhanghao on 2018/7/10.
//  Copyright © 2018年 snail-z. All rights reserved.
//

#import "UIBezierPath+YT_TimeChart.h"

@implementation UIBezierPath (YT_TimeChart)

- (void)addLine:(CGPoint)start end:(CGPoint)end {
    [self moveToPoint:start];
    [self addLineToPoint:end];
}

- (void)addHorizontalLine:(CGPoint)start len:(CGFloat)len {
    [self moveToPoint:start];
    [self addLineToPoint:CGPointMake(start.x + len, start.y)];
}

- (void)addVerticalLine:(CGPoint)start len:(CGFloat)len {
    [self moveToPoint:start];
    [self addLineToPoint:CGPointMake(start.x, start.y + len)];
}

- (void)addRect:(CGRect)rect {
    [self moveToPoint:rect.origin];
    [self addLineToPoint:CGPointMake(CGRectGetMaxX(rect), rect.origin.y)];
    [self addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))];
    [self addLineToPoint:CGPointMake(rect.origin.x, CGRectGetMaxY(rect))];
    [self closePath];
}

- (void)addPolygon:(NSArray *)points {
    CGPoint start = CGPointFromString([points firstObject]);
    [self moveToPoint:start];
    for (int i = 1; i < points.count; i++) {
        CGPoint move = CGPointFromString([points objectAtIndex:i]);
        [self addLineToPoint:move];
    }
}
@end
