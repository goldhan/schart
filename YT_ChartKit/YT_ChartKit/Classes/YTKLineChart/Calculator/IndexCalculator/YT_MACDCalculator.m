//
//  YT_MACDCalculator.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/29.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_MACDCalculator.h"

@implementation YT_MACDCalculator

#pragma mark - MACD

+ (void)calculateMACDWithClose:(YTSCFloat)close prevHandle:(id<YT_StockMACDHandle>)prevHandle rsHandle:(id<YT_StockMACDHandle>)handle {
    YTSCFloat EMA12 = prevHandle.cache_EMA12 * (DAYS_EMA12 - 1) / (DAYS_EMA12 + 1) + close * 2 / (DAYS_EMA12 + 1); // 收盘价的加权平均值
    YTSCFloat EMA26 = prevHandle.cache_EMA26 * (DAYS_EMA26 - 1) / (DAYS_EMA26 + 1) + close * 2 / (DAYS_EMA26 + 1); // 收盘价的加权平均值
    
    YTSCFloat DIF   = EMA12 - EMA26;
    YTSCFloat DEA   = prevHandle.cache_DEA * (DAYS_DIF - 1) / (DAYS_DIF + 1) +  DIF * 2 / (DAYS_DIF + 1); // DEA 是 DIF的加权平均数
    
    YTSCFloat MACD = (DIF - DEA) * 2;
    
    handle.cache_EMA12 = EMA12; //must
    handle.cache_EMA26 = EMA26; //must
    
    handle.cache_DIF = DIF;
    handle.cache_DEA = DEA; //must
    handle.cache_MACD = MACD;
}

+ (void)calculateMACDWithClose:(YTSCFloat)close handleBy:(id<YT_StockMACDHandle>)handle{
    [self calculateMACDWithClose:close prevHandle:handle rsHandle:handle];
}

+(void)calculateMACD:(NSArray<id<YT_StockKlineData>> *)kdataArr
               range:(NSRange)range
    handleUsingBlock:(id<YT_StockMACDHandle>  _Nonnull (^)(NSUInteger))handles
            progress:(void (^)(NSUInteger, id<YT_StockMACDHandle> _Nonnull))progress
            complete:(void (^)(NSRange, NSError * _Nullable))complete {
    
    NSRange canUseRange = NSMakeRange(0, kdataArr.count);
    NSRange targetRange = NSIntersectionRange(canUseRange, range); // 求交集 same as YT_RangeIntersectsRange
    if (targetRange.length == 0) {
        if (complete) complete (targetRange,nil);
        return;
    }
    
    NSInteger fromIndex = targetRange.location;
    NSInteger toIndex =  fromIndex + targetRange.length;
    
    NSInteger index = fromIndex;
    
    id <YT_StockMACDHandle> handle;
    id <YT_StockMACDHandle> prevHandle;
    if (index == 0) {
        handle = handles(0);
        YTSCFloat close = [kdataArr objectAtIndex:0].yt_closePrice;
        handle.cache_EMA12 = close;
        handle.cache_EMA26 = close;
        handle.cache_DIF   = 0;
        handle.cache_DEA   = 0;
        handle.cache_MACD  = 0;
        progress(0,handle); // 返回计算结果
        
        index ++;
        prevHandle = handle;
    }else{
        prevHandle = handles(index - 1);
    }
    
    for (; index < toIndex ; index ++) {
        id<YT_StockKlineData> klineData = [kdataArr objectAtIndex:index];
        handle = handles(index);
        [self calculateMACDWithClose:klineData.yt_closePrice prevHandle:prevHandle rsHandle:handle];
        progress(index,handle); // 返回计算结果
        prevHandle = handle;
    }
    
    if (complete) complete (targetRange,nil);
    
}

+ (void)calculateMACD:(NSArray<id<YT_StockKlineData>> *)kdataArr
                range:(NSRange)range
             handleBy:(id<YT_StockMACDHandle>)handle
             progress:(void (NS_NOESCAPE ^)(NSUInteger location, id<YT_StockMACDHandle> result))progress
             complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete {
    [self calculateMACD:kdataArr range:range handleUsingBlock:^id<YT_StockMACDHandle> _Nonnull(NSUInteger idx) {
        return handle;
    } progress:progress complete:complete];
}

@end
