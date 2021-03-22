//
//  NSArray+YT_MACalculator.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/18.
//  Copyright © 2018年 kds. All rights reserved.
//
// * 说明 这个文件 定义了 移动平均值 的计算方式 注意点 usingGetterSel 的方式 性能更好 所以尽量使用 calculateMA:range:usingGetterSel:progress:complete:
// 注意 progress 一定要传入一个 block 内部 没有检查 语句;

/*  说明
 *  MA: 移动平均线，Moving Average，简称MA
 *
 *
 */

#import <Foundation/Foundation.h>
#import "YT_StockChartProtocol.h"

//# define __YT_CALCALCULATeMAALL__ 1

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType> (YT_MACalculator)

/**
 计算移动平均值

 @param day 平均值计算个数（分母）
 @param range 数组计算范围
 @param itemBlock 获取计算对象
 @param progress 计算进度回调，在这里会返回计算结果
 @param complete 计算完成回调
 */
- (void)calculateMA:(NSUInteger)day
              range:(NSRange)range
         usingBlock:(YTSCFloat (NS_NOESCAPE ^)(ObjectType obj, NSUInteger idx))itemBlock
           progress:(void (NS_NOESCAPE ^)(NSUInteger location, YTSCFloat maValue))progress
           complete:(nullable void (NS_NOESCAPE ^)(NSRange maValueRange, NSError * _Nullable error))complete;

/**
  计算移动平均值，速度快些，但对数组内部要求为同一个类对象。因为会使用同一个method函数获取计算对象

 @param day 平均值计算个数（分母）
 @param range 数组计算范围
 @param getter 获取计算对象
 @param progress 计算进度回调，在这里会返回计算结果
 @param complete 计算完成回调
 */
- (void)calculateMA:(NSUInteger)day
              range:(NSRange)range
     usingGetterSel:(SEL)getter
           progress:(void (NS_NOESCAPE ^)(NSUInteger location, YTSCFloat maValue))progress
           complete:(nullable void (NS_NOESCAPE ^)(NSRange maValueRange, NSError * _Nullable error))complete;

- (void)calculateMA:(NSUInteger)day
              range:(NSRange)range
            exclude:(NSRange)excludeRange
     usingGetterSel:(SEL)getter
           progress:(void (NS_NOESCAPE ^)(NSUInteger location, YTSCFloat maValue))progress
           complete:(nullable void (NS_NOESCAPE ^)(NSRange maValueRange, NSError * _Nullable error))complete;

- (void)calculateFullRangeMA:(NSUInteger)day
                       range:(NSRange)range
              usingGetterSel:(SEL)getter
           fullRangeProgress:(void (NS_NOESCAPE ^)(NSUInteger location, YTSCFloat maValue))progress;

- (void)calculateFullRangeMA:(NSUInteger)day
                       range:(NSRange)range
              usingGetterSel:(SEL)getter
              usingSetterSel:(SEL)setter;

/**
 返回数组可计算移动平均值的范围

 @param day 平均值计算个数（分母）
 @return 计算范围
 */
- (NSRange)canCalculateMARange:(NSUInteger)day;

/**
  计算移动平均值

 @param day 平均值计算个数（分母）
 @param index 计算范围
 @param itemBlock 获取计算对象
 @return 返回计算结果
 */
- (YTSCFloat)calculateMA:(NSUInteger)day index:(NSUInteger)index usingBlock:(YTSCFloat (NS_NOESCAPE ^)(ObjectType obj, NSUInteger idx))itemBlock;

@end

NS_ASSUME_NONNULL_END
