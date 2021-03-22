//
//  YT_BIASCalculator.m
//  KDS_Phone
//
//  Created by yangjinming on 2018/5/30.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_BIASCalculator.h"

@implementation YT_BIASCalculator

+ (void)calculateBIAS:(NSArray<id<YT_StockKlineData>> *)kdataArr
                range:(NSRange)range
     handleUsingBlock:(id<YT_StockBIASHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
             progress:(void (NS_NOESCAPE ^)(NSUInteger location, id<YT_StockBIASHandle> result))progress
             complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete {
    NSRange canUseRange = NSMakeRange(0, kdataArr.count);
    NSRange targetRange = NSIntersectionRange(canUseRange, range); // 求交集 same as YT_RangeIntersectsRange
    if (targetRange.length == 0) {
        if (complete) complete (targetRange,nil);
        return;
    }
    
    NSInteger fromIndex = targetRange.location;
    NSInteger toIndex =  fromIndex + targetRange.length;
    
    NSInteger index = fromIndex;
    
    YTSCFloat closeSum6 = 0;
    YTSCFloat closeSum12 = 0;
    YTSCFloat closeSum24 = 0;
    
    // 准备 closeSum6 closeSum12 closeSum24
    if(index != 0) {
        closeSum6 = [self t_readyParmForBIAS:kdataArr index:index days:DAYS_BIAS6];
        closeSum12 = [self t_readyParmForBIAS:kdataArr index:index days:DAYS_BIAS12];
        closeSum24 = [self t_readyParmForBIAS:kdataArr index:index days:DAYS_BIAS24];
    }
    
    id <YT_StockBIASHandle> handle;
    id<YT_StockKlineData> klineData;
    for (; index < toIndex ; index ++) {
        klineData = [kdataArr objectAtIndex:index];
        handle = handles(index);
        handle.cache_BIAS6 = [self calculateBIASWithClose:klineData.yt_closePrice dataArray:kdataArr index:index days:DAYS_BIAS6 closeSum:&closeSum6];
        handle.cache_BIAS12 = [self calculateBIASWithClose:klineData.yt_closePrice dataArray:kdataArr index:index days:DAYS_BIAS12 closeSum:&closeSum12];
        handle.cache_BIAS24 = [self calculateBIASWithClose:klineData.yt_closePrice dataArray:kdataArr index:index days:DAYS_BIAS24 closeSum:&closeSum24];
        progress(index,handle); // 返回计算结果
    }
    if (complete) complete (targetRange,nil);
}

+ (YTSCFloat)t_readyParmForBIAS:(NSArray<id<YT_StockKlineData>> *)kdataArr
                              index:(NSInteger)index
                               days:(NSInteger)days {
    YTSCFloat closeSum = 0;
    NSInteger needReadyIndex = index - 1;
    NSInteger forthToIndex = needReadyIndex - days;
    if (forthToIndex < -1) {
        forthToIndex = -1;
    }
    id<YT_StockKlineData> klineData;
    for (NSInteger idx = needReadyIndex; idx > forthToIndex ; idx --) {
        klineData = [kdataArr objectAtIndex:idx];
        closeSum += klineData.yt_closePrice;
    }
    return closeSum;
}

+ (YTSCFloat)calculateBIASWithClose:(YTSCFloat)close
                          dataArray:(NSArray<id<YT_StockKlineData>> *)kdataArr
                              index:(NSInteger)index
                               days:(NSInteger)days
                           closeSum:(YTSCFloat *)closeSum {
    *closeSum = *closeSum + close;
    if (index >= (days - 1)) {
        if ((index - days) >= 0) {
            id<YT_StockKlineData> klineData = [kdataArr objectAtIndex:(index - days)];
            *closeSum = *closeSum - klineData.yt_closePrice;
        }
        //n日BIAS = (C - MA_N) / MA_N * 100
        //C为收盘价；MA_N为n日内的移动平均价
        YTSCFloat mAn = *closeSum / days;
//        YTSCFloat temBIAS = (close - mAn) * 100 / mAn;
        return (close - mAn) * 100 / mAn;
    }else{
         return YTSCFLOAT_NULL;
    }
}
@end
