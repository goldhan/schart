//
//  YT_KDJCalculator.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/29.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_KDJCalculator.h"

@implementation YT_KDJCalculator

#pragma mark - KDJ

/// 私有方法 获取 在 索引 index（包括index） 之前 day 个数据的 最高价 和 最低价
+ (void)_getTopPrice:(YTSCFloat *)top bottomPrice:(YTSCFloat *)btm fromArr:(NSArray<id<YT_StockKlineData>> *)kdataArr atIndex:(NSInteger)index preDays:(NSInteger)day {
    
    id <YT_StockKlineData> kdata = [kdataArr objectAtIndex:index];
    
    YTSCFloat H = kdata.yt_highPrice;
    YTSCFloat L = kdata.yt_lowPrice;
    
    //  为了性能请在外部判断 传入 day 时可以这样写 MIN(index +1 ,day);
    //    NSInteger fromIndex = index >= day ?  index - day + 1 : 0;
    NSInteger fromIndex = index - day + 1;
    
    for (; fromIndex < index; fromIndex ++) {
        kdata = [kdataArr objectAtIndex:fromIndex];
        
        YTSCFloat Hc = kdata.yt_highPrice;
        YTSCFloat Lc = kdata.yt_lowPrice;
        
        H = H > Hc ? H : Hc;
        L = L < Lc ? L : Lc;
    }
    
    * top  = H;
    * btm  = L;
}

+ (void)calculateKDJWithClose:(YTSCFloat)close Hn:(YTSCFloat)Hn Ln:(YTSCFloat)Ln prevHandle:(id<YT_StockKDJHandle>)prevHandle rsHandle:(id<YT_StockKDJHandle>)handle {
    double ar_rsv = 1 / DAYS_RSVMA;
    double ar_k = 1 / DAYS_KMA;
    [self calculateKDJWithClose:close Hn:Hn Ln:Ln prevHandle:prevHandle rsHandle:prevHandle ar_rsv:ar_rsv ar_k:ar_k];
}

+ (void)calculateKDJWithClose:(YTSCFloat)close Hn:(YTSCFloat)Hn Ln:(YTSCFloat)Ln prevHandle:(id<YT_StockKDJHandle>)prevHandle rsHandle:(id<YT_StockKDJHandle>)handle ar_rsv:(double)ar_rsv ar_k:(double)ar_k{
    
    YTSCFloat RSV = 0;
    //n日RSV = (C - Ln) / (Hn - Ln) * 100
    //C为收盘价；Ln为n日内的最低价；Hn为n日内的最高价。默认n为9，明显的RSV值始终在1—100间波动
    if ((Hn - Ln) != 0) { //([self aFloat:Hn isEqual:Ln] == false)
        YTSCFloat C = close;
        RSV = (C - Ln) / (Hn - Ln) * 100;
    }
    
    //当日K值 = 2 / 3 * 前一日K值 + 1 / 3 * 当日RSV (K 为 RSV 的 加权平均)
//    YTSCFloat k =  prevHandle.cache_K * 2/3 +  RSV *1/3 ;
    YTSCFloat k =  prevHandle.cache_K * (1 - ar_rsv) +  RSV * ar_rsv ;
    //当日D值 = 2 / 3 * 前一日D值 + 1 / 3 * 当日K值 (D 为 K 的 加权平均)
//    YTSCFloat d =  prevHandle.cache_D * 2/3 +  k * 1/3;
    YTSCFloat d =  prevHandle.cache_D * (1 - ar_k) +  k * ar_k;
    //当日J值 = 3K — 2D
    YTSCFloat j = 3 * k - 2 * d;
    
    handle.cache_K = k; //prevHandle 和 handle 有可能是同一个对象,所以最后才赋值
    handle.cache_D = d;
    handle.cache_J = j;
    
}

+ (void)calculateKDJ:(NSArray<id<YT_StockKlineData>> *)kdataArr
               range:(NSRange)range
    handleUsingBlock:(id<YT_StockKDJHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
            progress:(void (NS_NOESCAPE ^)(NSUInteger location, id<YT_StockKDJHandle> result))progress
            complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete {
    
    NSRange canUseRange = NSMakeRange(0, kdataArr.count);
    NSRange targetRange = NSIntersectionRange(canUseRange, range); // 求交集 same as YT_RangeIntersectsRange
    if (targetRange.length == 0) {
        if (complete) complete (targetRange,nil);
        return;
    }
    
    NSInteger index = targetRange.location;
    NSInteger toIndex =  targetRange.location + targetRange.length;
    NSInteger indexPartition =  DAYS_RSV - 1;
    if (indexPartition > toIndex) indexPartition = toIndex;
    
    id<YT_StockKDJHandle> prevHandle;
    id<YT_StockKDJHandle> handle;
    if (index == 0) {
        prevHandle = handles(0);
        //preposition handle
        prevHandle.cache_K = 50.00; prevHandle.cache_D = 50.00; prevHandle.cache_J = 50.00/*可省*/;
    } else {
        prevHandle = handles(index - 1);
    }
    
    double ar_rsv = 1.00 / DAYS_RSVMA;
    double ar_k = 1.00 / DAYS_KMA;
    
    /**
     *  第一段 和 第二段 不同点 ：就是计算点数不同 第一段为 index + 1 ，第二段 DAYS_RSV 。
     *  目的：为了不在 for 循环里加 if 判断写了两段 😓 有更好的方式吗 ？
     */
    
    YTSCFloat closs = 0, Hn = 0, Ln = 0;
    // 第一段
    for (; index < indexPartition ; index ++) {
        closs = [kdataArr objectAtIndex:index].yt_closePrice;
        Hn = 0; Ln = 0;
        [self _getTopPrice:&Hn bottomPrice:&Ln fromArr:kdataArr atIndex:index preDays:index + 1];// index + 1
        handle = handles(index);
        [self calculateKDJWithClose:closs Hn:Hn Ln:Ln prevHandle:prevHandle rsHandle:handle ar_rsv:ar_rsv ar_k:ar_k];
        progress(index,handle); // 返回计算结果
        prevHandle = handle;
    }
    
    // 第二段
    for (; index < toIndex ; index ++) {
        closs = [kdataArr objectAtIndex:index].yt_closePrice;
        Hn = 0; Ln = 0;
        [self _getTopPrice:&Hn bottomPrice:&Ln fromArr:kdataArr atIndex:index preDays:DAYS_RSV];// DAYS_RSV
        handle = handles(index);
        [self calculateKDJWithClose:closs Hn:Hn Ln:Ln prevHandle:prevHandle rsHandle:handle ar_rsv:ar_rsv ar_k:ar_k];
        progress(index,handle); // 返回计算结果
        prevHandle = handle;
    }
    if (complete) complete (targetRange,nil);
    
}

@end
