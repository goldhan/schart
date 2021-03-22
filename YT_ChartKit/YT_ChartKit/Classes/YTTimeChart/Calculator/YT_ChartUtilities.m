//
//  CoreGraphics_demo
//
//  Created by zhanghao on 2018/6/1.
//  Copyright © 2018年 snail-z. All rights reserved.
//

#import "YT_ChartUtilities.h"

@implementation NSValue (TQChart)

+ (NSValue *)valueWithPeakValue:(CGPeakValue)peakValue {
    return [NSValue value:&peakValue withObjCType:@encode(CGPeakValue)];
}

- (CGPeakValue)peakValue {
    CGPeakValue peakValue;
    [self getValue:&peakValue];
    return peakValue;
}

@end
