//
//  YT_KLineCalculator.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/10.
//  Copyright © 2018年 kds. All rights reserved.
//
// * 说明 这个文件 定义了 各种指标的 计算方法类方法 在这里不要使用对象方法。后期可能会使用 C 重写 部分核心算法 会基于这个类 去调用 C



#import <Foundation/Foundation.h>
#import "YT_KLineDataProtocol.h"
#import "YT_KlineCalculatorProtocol.h"
#import "YT_CoordinateAxisParam.h"
#import "YT_IndexCalculator.h"

NS_ASSUME_NONNULL_BEGIN

@interface YT_KLineCalculator : NSObject

#pragma mark - YT_CoordinateAxisParam
/**
 使用固定的模式调用 init block 和 progress block
 当 reuseIdx 在 range 的 范围内时 调用progress 范围为 range - reuseRange 否则
 调用 init(range.location) 一次 ，在range范围调用progress
 *** 注意必须保证 YT_RangeContainLocation(reuseRange, reuseIdx) 为 Yes **
 */
+ (void)findIdxUsePatternCallBlockWithReuseRange:(NSRange)reuseRange reuseIdx:(NSUInteger)reuseIdx range:(NSRange)range init:(void(NS_NOESCAPE^)(NSUInteger idx))init progress:(void(NS_NOESCAPE^)(NSUInteger idx))progress;

/**
 使用固定的模式调用 init block 和 progress block
 
 @param axisParam 坐标系参数结构体
 @param range 改变的x轴参数
 @param init axisParam 赋初始值
 @param progress axisParam 比较并赋值；
 *** 注意必须保证 YT_RangeContainLocation(reuseRange, reuseIdx) 为 Yes **
 */
+ (void)usePatternSetMaxMin:(YT_CoordinateAxisParam *)axisParam range:(NSRange)range init:(void(NS_NOESCAPE^)(NSUInteger idx, YT_CoordinateAxisParam * axisParam))init progress:(void(NS_NOESCAPE^)(NSUInteger idx,YT_CoordinateAxisParam * axisParam))progress;

//#pragma mark - tool
//+ (NSInteger)compareFloat:(YTSCFloat)val0 :(YTSCFloat)val1;
///// 可重写
//+ (bool)aFloat:(YTSCFloat)val0 isEqual:(YTSCFloat)val1;
@end

/**
 在比较afloat之后改变axisParam的最大值或最小值
 
 @param axisParam 坐标系参数结构体
 @param afloat 比较值
 @param idx 比较值索引
 */
NS_INLINE void YT_CoordinateAxisParamSetMaxMinAfterCompare(YT_CoordinateAxisParam * axisParam, YTSCFloat afloat, NSUInteger idx)
{
    if (afloat > axisParam->max) {
        axisParam->max = afloat;
        axisParam->maxIndex = idx;
    }else if (afloat < axisParam->min) {
        axisParam->min = afloat;
        axisParam->minIndex = idx;
    }
}

/**
 在比较afloat之后改变axisParam的最大值或最小值
 
 @param axisParam 坐标系参数结构体
 @param afloat 比较值
 @param idx 比较值索引
 */
NS_INLINE void YT_CoordinateAxisParamSetMaxMinAfterCompare2(YT_CoordinateAxisParam * axisParam, YTSCFloat afloat, NSUInteger idx)
{
    if (afloat > axisParam->max) {
        axisParam->max = afloat;
        axisParam->maxIndex = idx;
    }
    if (afloat < axisParam->min) {
        axisParam->min = afloat;
        axisParam->minIndex = idx;
    }
}

NS_ASSUME_NONNULL_END

/**
 * 说明
 *
 
// 在初始值赋值为 axis->max = YTSCFLOAT_MIN; // 赋初始值 axis->min = YTSCFLOAT_MAX; // 赋初始值
// 最大最小值不同是要用 YT_CoordinateAxisParamSetMaxMinAfterCompare2 因为有可能第一个值就是最小值 最小值先比较了YTSCFLOAT_MIN 就赋值返回了 。。这个最小值求解就错了
[YT_KLineCalculator usePatternSetMaxMin:reuseParam range:range init:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
    axis->max = YTSCFLOAT_MIN; // 赋初始值
    axis->min = YTSCFLOAT_MAX; // 赋初始值
} progress:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
    YT_KlineDataCalculateCache * kdata_one = [cacheArray objectAtIndex:idx];
    for (YT_KlineMAExplain *explain in explainArr) {
        YTSCFloat afloat = kdata_one.cache_Closs_MA[explain.index];
        if (afloat != YTSCFLOAT_NULL) {
            YT_CoordinateAxisParamSetMaxMinAfterCompare2(axis,afloat,idx)
        }
    }
}];

//从新计算显示范围内的最大最小值
[YT_KLineCalculator usePatternSetMaxMin:axisParam range:range init:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
    YT_KlineDataCalculateCache *kdata_one = [cacheManager.cacheArray objectAtIndex:range.location];
    axis->max = kdata_one.cache_K; // 赋初始值
    axis->min = kdata_one.cache_K; // 赋初始值
} progress:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
    YT_KlineDataCalculateCache * kdata_one = [cacheManager.cacheArray objectAtIndex:idx];
    YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_K, idx);
    YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_D, idx);
    YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_J, idx);
}];
 

 
 
 //*/

