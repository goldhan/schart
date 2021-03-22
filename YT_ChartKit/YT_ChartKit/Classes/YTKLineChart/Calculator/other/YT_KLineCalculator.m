//
//  YT_KLineCalculator.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/10.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_KLineCalculator.h"
#import "YT_KlineCalculatorProtocol.h"

@implementation YT_KLineCalculator

#pragma mark - YT_CoordinateAxisParam

/**
  使用固定的模式调用 init block 和 progress block
  当 reuseIdx 在 range 的 范围内时 调用progress 范围为 range - reuseRange 否则
  调用 init(range.location) 一次 ，在range范围调用progress
  注意必须保证 YT_RangeContainLocation(reuseRange, reuseIdx) 为 Yes
 */
+ (void)findIdxUsePatternCallBlockWithReuseRange:(NSRange)reuseRange reuseIdx:(NSUInteger)reuseIdx range:(NSRange)range init:(void(NS_NOESCAPE^)(NSUInteger idx))init progress:(void(NS_NOESCAPE^)(NSUInteger idx))progress{
    
    if (range.length == 0) return;//must
    
    if (YT_RangeContainLocation(range, reuseIdx)) { //当重用点在可重用范围时
        NSRange rsRangePre = NSMakeRange(0, 0),rsRangeSuf  = NSMakeRange(0, 0);
        YT_RangeSubRange2(range, reuseRange, &rsRangePre, &rsRangeSuf);

        NSInteger i = rsRangePre.location;
        NSUInteger end = i + rsRangePre.length;
        for (; i < end ; i++) { progress(i); }
        i = rsRangeSuf.location;
        end = i + rsRangeSuf.length;
        for (; i < end ; i++) { progress(i); }
    }else{
        init(range.location);// 赋初始值
        NSUInteger end = range.location + range.length;
        for (NSInteger i = range.location ; i < end ; i++) {
            progress(i); //比较并赋值；
        }
    }
}

/**
 使用固定的模式调用 init block 和 progress block

 @param axisParam 坐标系参数结构体
 @param range 改变的x轴参数
 @param init axisParam 赋初始值
 @param progress axisParam 比较并赋值；
 注意必须保证 YT_RangeContainLocation(reuseRange, reuseIdx) 为 Yes
 */
+ (void)usePatternSetMaxMin:(YT_CoordinateAxisParam *)axisParam range:(NSRange)range init:(void(NS_NOESCAPE^)(NSUInteger idx, YT_CoordinateAxisParam * axisParam))init progress:(void(NS_NOESCAPE^)(NSUInteger idx,YT_CoordinateAxisParam * axisParam))progress {
   
    if (range.length == 0) return;//must
    
    //当 最大 最小 点 可以重用时,考虑重用 最大 最小 点
    if (YT_RangeContainLocation(range, axisParam->maxIndex) && YT_RangeContainLocation(range, axisParam->minIndex)) {
        NSRange rsRangePre = NSMakeRange(0, 0),rsRangeSuf  = NSMakeRange(0, 0);
        YT_RangeSubRange2(range, axisParam->range, &rsRangePre, &rsRangeSuf);
        
        NSInteger i = rsRangePre.location;
        NSUInteger end = i + rsRangePre.length;
        for (; i < end ; i++) { progress(i,axisParam); }
        i = rsRangeSuf.location;
        end = i + rsRangeSuf.length;
        for (; i < end ; i++) { progress(i,axisParam); }
    }else{
        init(range.location,axisParam);// axisParam 赋初始值
        NSUInteger end = range.location + range.length;
        for (NSInteger i = range.location ; i < end ; i++) {
            progress(i,axisParam); // axisParam 比较并赋值；
        }
    }
    axisParam->range = range;
}

+ (void)setMaxMin:(YT_CoordinateAxisParam *)axisParam afterCompare:(YTSCFloat)afloat idx:(NSUInteger)idx{
    if (afloat > axisParam->max) {
        axisParam->max = afloat;
        axisParam->maxIndex = idx;
    }else if (afloat < axisParam->min) {
        axisParam->min = afloat;
        axisParam->minIndex = idx;
    }
}

#pragma mark - tool 
+ (NSInteger)compareFloat:(YTSCFloat)val0 :(YTSCFloat)val1 {
    
    float f = val0 -  val1;
    if (f > YTSCFLOAT_EPSILON)   return 1;
    if (f < - YTSCFLOAT_EPSILON ) return -1;
    return 0;
}

+ (bool)aFloat:(YTSCFloat)val0 isEqual:(YTSCFloat)val1 {
    return  !!([self compareFloat:val0 :val1] == 0);
}
@end

