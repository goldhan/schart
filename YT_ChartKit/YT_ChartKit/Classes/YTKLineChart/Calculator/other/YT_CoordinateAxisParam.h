//
//  YT_CoordinateAxisParam.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/18.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YT_StockChartProtocol.h"

#ifndef YT_CoordinateAxisParam_h
#define YT_CoordinateAxisParam_h

NS_ASSUME_NONNULL_BEGIN

struct YTCoordinateAxisParam {
    YTSCFloat max; ///< 最大值
    YTSCFloat min; ///< 最小值
    NSUInteger maxIndex;
    NSUInteger minIndex;
    NSRange range;
};
typedef struct YTCoordinateAxisParam YT_CoordinateAxisParam;

CG_INLINE YT_CoordinateAxisParam YT_MakeCoordinateAxisParam(YTSCFloat max, YTSCFloat min, NSUInteger maxIndex, NSUInteger minIndex, NSRange range) {
    YT_CoordinateAxisParam axis;
    axis.max = max;
    axis.min = max;
    axis.maxIndex = max;
    axis.minIndex = max;
    axis.range = range;
    return axis;
}

CG_INLINE YT_CoordinateAxisParam YT_MakeCoordinateAxisParamZero(){
    YT_CoordinateAxisParam axis;
    axis.max = YTSCFLOAT_MIN;
    axis.min = YTSCFLOAT_MAX;
    axis.maxIndex = NSUIntegerMax;
    axis.minIndex = NSUIntegerMax;
    axis.range = NSMakeRange(0, 0);
    return axis;
}

NS_INLINE NSString * NSStringFormCoordinateAxisParam(YT_CoordinateAxisParam axisParam){
    return [NSString stringWithFormat:@"{range loc %zd len %zd , maxIdx %zd max %lf ,minIdx %zd min %lf }",axisParam.range.location,axisParam.range.length,axisParam.maxIndex,axisParam.max,axisParam.minIndex,axisParam.min];
}

#pragma mark - RangeExtend

///same as NSIntersectionRange
extern NSRange YT_RangeIntersectsRange(NSRange range1, NSRange range2);
///same as NSLocationInRange
extern BOOL YT_RangeContainLocation(NSRange range, NSUInteger loc);
///same as NSUnionRange 拼接一个最小集合A 包含集合range2和range1 length == 0 无法判断
extern NSRange YT_RangeUnionRange(NSRange range1, NSRange range2);
extern NSRange YT_RangeUnionRange2(NSRange range1, NSRange range2);

extern BOOL YT_RangeContainsRange(NSRange range1, NSRange range2);
extern NSArray<NSValue *>* YT_RangeSubRange(NSRange range1, NSRange range2);
/**
 NSRange range1 = NSMakeRange(22, 500), range2 = NSMakeRange(3332, 4444);
 NSRange rsRangePre = NSMakeRange(0, 0),rsRangeSuf  = NSMakeRange(0, 0);
 YT_RangeSubRange2(range1, range2, &rsRangePre, &rsRangeSuf);
 */
extern NSInteger YT_RangeSubRange2(NSRange range1, NSRange range2, NSRange *rsRangePre,NSRange *rsRangeSuf);

NS_ASSUME_NONNULL_END

#endif /* YT_CoordinateAxisParam_h */
