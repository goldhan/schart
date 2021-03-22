//
//  YT_WRCalculator.m
//  KDS_Phone
//
//  Created by ChenRui Hu on 2018/6/1.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_WRCalculator.h"

@implementation YT_WRCalculator
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

+ (void)calculateWRWithClose:(YTSCFloat)close
                          Hn:(YTSCFloat)Hn
                          Ln:(YTSCFloat)Ln
                          WR:(YTSCFloat *)wr {
    YTSCFloat WR = 0;
    //n日WR = 100 * (Hn - C) / (Hn - Ln)
    //C为收盘价；Ln为n日内的最低价；Hn为n日内的最高价
    if ((Hn - Ln) != 0) { //([self aFloat:Hn isEqual:Ln] == false)
        YTSCFloat C = close;
        WR = 100 * (Hn - C) / (Hn - Ln);
    }
    
    * wr = WR;
}

+ (void)calculateWR:(NSArray<id<YT_StockKlineData>> *)kdataArr
              range:(NSRange)range
   handleUsingBlock:(id<YT_StockWRHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
           progress:(void (NS_NOESCAPE ^)(NSUInteger location, id<YT_StockWRHandle> result))progress
           complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete {
    NSRange canUseRange = NSMakeRange(0, kdataArr.count);
    NSRange targetRange = NSIntersectionRange(canUseRange, range); // 求交集 same as YT_RangeIntersectsRange
    if (targetRange.length == 0) {
        if (complete) complete (targetRange,nil);
        return;
    }
    
    NSInteger index = targetRange.location;
    NSInteger toIndex =  targetRange.location + targetRange.length;
    
    id<YT_StockWRHandle> handle;
    
    // 计算 WR10
    NSInteger indexPartition =  DAYS_WR10 - 1;
    indexPartition  = indexPartition <= toIndex ? indexPartition : toIndex;
    /**
     *  第一段 和 第二段 不同点 ：就是计算点数不同 第一段为 index + 1 ，第二段 DAYS_RSV 。
     *  目的：为了不在 for 循环里加 if 判断写了两段
     */
    
    // 第一段
    for (; index < indexPartition ; index ++) {
        YTSCFloat closs = [kdataArr objectAtIndex:index].yt_closePrice;
        YTSCFloat Hn = 0, Ln = 0, WR = 0;
        [self _getTopPrice:&Hn bottomPrice:&Ln fromArr:kdataArr atIndex:index preDays:index + 1];// index + 1
        handle = handles(index);
        [self calculateWRWithClose:closs Hn:Hn Ln:Ln WR:&WR];
        handle.cache_WR10 = WR;
        progress(index,handle); // 返回计算结果
    }
    
    // 第二段
    for (; index < toIndex ; index ++) {
        YTSCFloat closs = [kdataArr objectAtIndex:index].yt_closePrice;
        YTSCFloat Hn = 0, Ln = 0, WR = 0;
        [self _getTopPrice:&Hn bottomPrice:&Ln fromArr:kdataArr atIndex:index preDays:DAYS_WR10];
        handle = handles(index);
        [self calculateWRWithClose:closs Hn:Hn Ln:Ln WR:&WR];
        handle.cache_WR10 = WR;
        progress(index,handle); // 返回计算结果
    }
    
    // 计算 WR6
    index = targetRange.location;
    indexPartition =  DAYS_WR6 - 1;
    indexPartition  = indexPartition <= toIndex ? indexPartition : toIndex;
    /**
     *  第一段 和 第二段 不同点 ：就是计算点数不同 第一段为 index + 1 ，第二段 DAYS_RSV 。
     *  目的：为了不在 for 循环里加 if 判断写了两段
     */
    
    // 第一段
    for (; index < indexPartition ; index ++) {
        YTSCFloat closs = [kdataArr objectAtIndex:index].yt_closePrice;
        YTSCFloat Hn = 0, Ln = 0, WR = 0;
        [self _getTopPrice:&Hn bottomPrice:&Ln fromArr:kdataArr atIndex:index preDays:index + 1];// index + 1
        handle = handles(index);
        [self calculateWRWithClose:closs Hn:Hn Ln:Ln WR:&WR];
        handle.cache_WR6 = WR;
        progress(index,handle); // 返回计算结果
    }
    
    // 第二段
    for (; index < toIndex ; index ++) {
        YTSCFloat closs = [kdataArr objectAtIndex:index].yt_closePrice;
        YTSCFloat Hn = 0, Ln = 0, WR = 0;
        [self _getTopPrice:&Hn bottomPrice:&Ln fromArr:kdataArr atIndex:index preDays:DAYS_WR6];
        handle = handles(index);
        [self calculateWRWithClose:closs Hn:Hn Ln:Ln WR:&WR];
        handle.cache_WR6 = WR;
        progress(index,handle); // 返回计算结果
    }
    
    if (complete) complete (targetRange,nil);
    
}

@end
