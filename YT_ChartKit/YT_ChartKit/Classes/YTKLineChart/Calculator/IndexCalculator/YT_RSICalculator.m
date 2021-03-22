//
//  YT_RSICalculator.m
//  KDS_Phone
//
//  Created by yangjinming on 2018/6/4.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_RSICalculator.h"

@implementation NSValue(YT_RSICalculateArgv)

+ (NSValue *)valueWithYT_RSICalculateArgv:(YT_RSICalculateArgv)calculateArgv {
    return  [NSValue value:&calculateArgv withObjCType:@encode(YT_RSICalculateArgv)];
}

- (YT_RSICalculateArgv)YT_RSICalculateArgvValue {
    YT_RSICalculateArgv argv_tmp;
    [self getValue:&argv_tmp];
    return argv_tmp;
}

@end

@implementation YT_RSICalculator

+ (void)calculateRSI:(NSArray<id<YT_StockKlineData>> *)kdataArr
            prevArgv:(YT_RSICalculateArgv *)prevArgv
               range:(NSRange)range
    handleUsingBlock:(id<YT_StockRSIHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
            complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete {
    NSRange canUseRange = NSMakeRange(0, kdataArr.count);
    NSRange targetRange = NSIntersectionRange(canUseRange, range); // 求交集 same as YT_RangeIntersectsRange
    if (targetRange.length == 0) {
        if (complete) complete (targetRange,nil);
        return;
    }
    
    NSInteger fromIndex = targetRange.location;
    NSInteger toIndex =  fromIndex + targetRange.length;
    
    const NSInteger days6 = DAYS_RSI6;
    const NSInteger days12 = DAYS_RSI12;
    const NSInteger days24 = DAYS_RSI24;
    
    double SMAMAX_RSI6, SMAMAX_RSI12, SMAMAX_RSI24, SMAABS_RSI6, SMAABS_RSI12, SMAABS_RSI24;
    
    if (fromIndex == 0) {
        SMAMAX_RSI6 = 0;
        SMAMAX_RSI12 = 0;
        SMAMAX_RSI24 = 0;
        
        SMAABS_RSI6 = 0;
        SMAABS_RSI12 = 0;
        SMAABS_RSI24 = 0;
    }else{
        SMAMAX_RSI6 = prevArgv->SMAMAX_RSI6;
        SMAMAX_RSI12 = prevArgv->SMAMAX_RSI12;
        SMAMAX_RSI24 = prevArgv->SMAMAX_RSI24;
        
        SMAABS_RSI6 = prevArgv->SMAABS_RSI6;
        SMAABS_RSI12 = prevArgv->SMAABS_RSI12;
        SMAABS_RSI24 = prevArgv->SMAABS_RSI24;
    }
    
    YTSCFloat colse, yesterdayClose, maxCloseSubYesterdayClose, absCloseSubYesterdayClose;
    id <YT_StockRSIHandle> handle;
    id<YT_StockKlineData> kxData;
    for (NSInteger index = fromIndex; index < toIndex; index++) {
        handle = handles(index);
        kxData = [kdataArr objectAtIndex:index];
        colse = kxData.yt_closePrice;
        yesterdayClose = kxData.yt_closePriceYesterday;
        maxCloseSubYesterdayClose = MAX((colse- yesterdayClose), 0);
        absCloseSubYesterdayClose = ABS(colse- yesterdayClose);
        // RSI$1:SMA(MAX(CLOSE-LC,0),N1,1)/SMA(ABS(CLOSE-LC),N1,1)*100;
        // SMA(MAX(CLOSE-LC,0),N1,1)
        //当日sma值 = N1-1 / N1 * 前一日sma值 + N1-1 / N1 * MAX(CLOSE-LC,0
        //    NFloat *nk = [NFloat add:[NFloat div:[NFloat mul:fk Integer:2] Integer:3] :[NFloat div:rsv Integer:3]];
        SMAMAX_RSI6 = (SMAMAX_RSI6 * (days6 - 1)) / days6 + maxCloseSubYesterdayClose / days6;
        SMAMAX_RSI12 = (SMAMAX_RSI12 * (days12 - 1)) / days12 + maxCloseSubYesterdayClose / days12;
        SMAMAX_RSI24 = (SMAMAX_RSI24 * (days24 - 1)) / days24 + maxCloseSubYesterdayClose / days24;
        
        // SMA(ABS(CLOSE-LC),N1,1)
        SMAABS_RSI6 = (SMAABS_RSI6 * (days6 - 1)) / days6 + absCloseSubYesterdayClose / days6;
        SMAABS_RSI12 = (SMAABS_RSI12 * (days12 - 1)) / days12 + absCloseSubYesterdayClose / days12;
        SMAABS_RSI24 = (SMAABS_RSI24 * (days24 - 1)) / days24 + absCloseSubYesterdayClose / days24;
        
        //RSI6
        if (0 == SMAABS_RSI6) handle.cache_RSI6 = 0;
        else handle.cache_RSI6 = SMAMAX_RSI6 / SMAABS_RSI6 * 100;
        //RSI12
        if (0 == SMAABS_RSI12) handle.cache_RSI12 = 0;
        else handle.cache_RSI12 = SMAMAX_RSI12 / SMAABS_RSI12 * 100;
        //RSI24
        if (0 == SMAABS_RSI24) handle.cache_RSI24 = 0;
        else handle.cache_RSI24 = SMAMAX_RSI24 / SMAABS_RSI24 * 100;
    }
    
    YT_RSICalculateArgvReset(prevArgv, SMAMAX_RSI6, SMAMAX_RSI12, SMAMAX_RSI24, SMAABS_RSI6, SMAABS_RSI12, SMAABS_RSI24);
    if (complete) complete (targetRange,nil);
    
}

#pragma mark -

+ (void)calculateRSI:(NSArray<id<YT_StockKlineData>> *)kdataArr
               range:(NSRange)range
    handleUsingBlock:(id<YT_StockRSIHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
            progress:(void (NS_NOESCAPE ^)(NSUInteger location, id<YT_StockRSIHandle> result))progress
            complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete {
    NSRange canUseRange = NSMakeRange(0, kdataArr.count);
    NSRange targetRange = NSIntersectionRange(canUseRange, range); // 求交集 same as YT_RangeIntersectsRange
    if (targetRange.length == 0) {
        if (complete) complete (targetRange,nil);
        return;
    }
    
    NSInteger fromIndex = targetRange.location;
    NSInteger toIndex =  fromIndex + targetRange.length;
    
    NSInteger index = 0; //这个方法只能从0算
    NSInteger days6 = DAYS_RSI6;
    NSInteger days12 = DAYS_RSI12;
    NSInteger days24 = DAYS_RSI24;
    
    YTSCFloat zeroFloat = 0;
    YTSCFloat SMAMAX_RSI6 = 0;
    YTSCFloat SMAMAX_RSI12 = 0;
    YTSCFloat SMAMAX_RSI24 = 0;
    
    YTSCFloat SMAABS_RSI6 = 0;
    YTSCFloat SMAABS_RSI12 = 0;
    YTSCFloat SMAABS_RSI24 = 0;
    
    id <YT_StockRSIHandle> handle;
    for (; index < toIndex; index++) {
        handle = handles(index);
        id<YT_StockKlineData> kxData = [kdataArr objectAtIndex:index];
        YTSCFloat colse = kxData.yt_closePrice;
        YTSCFloat yesterdayClose = kxData.yt_closePriceYesterday;
        YTSCFloat maxCloseSubYesterdayClose = MAX((colse- yesterdayClose), zeroFloat);
        YTSCFloat absCloseSubYesterdayClose = ABS(colse- yesterdayClose);
        // RSI$1:SMA(MAX(CLOSE-LC,0),N1,1)/SMA(ABS(CLOSE-LC),N1,1)*100;
        // SMA(MAX(CLOSE-LC,0),N1,1)
        //当日sma值 = N1-1 / N1 * 前一日sma值 + N1-1 / N1 * MAX(CLOSE-LC,0
        //    NFloat *nk = [NFloat add:[NFloat div:[NFloat mul:fk Integer:2] Integer:3] :[NFloat div:rsv Integer:3]];
        SMAMAX_RSI6 = (SMAMAX_RSI6 * (days6 - 1)) / days6 + maxCloseSubYesterdayClose / days6;
        SMAMAX_RSI12 = (SMAMAX_RSI12 * (days12 - 1)) / days12 + maxCloseSubYesterdayClose / days12;
        SMAMAX_RSI24 = (SMAMAX_RSI24 * (days24 - 1)) / days24 + maxCloseSubYesterdayClose / days24;
        
        // SMA(ABS(CLOSE-LC),N1,1)
        SMAABS_RSI6 = (SMAABS_RSI6 * (days6 - 1)) / days6 + absCloseSubYesterdayClose / days6;
        SMAABS_RSI12 = (SMAABS_RSI12 * (days12 - 1)) / days12 + absCloseSubYesterdayClose / days12;
        SMAABS_RSI24 = (SMAABS_RSI24 * (days24 - 1)) / days24 + absCloseSubYesterdayClose / days24;
        
        //RSI6
        if (index >= days6) {
            handle.cache_RSI6 = SMAMAX_RSI6 / SMAABS_RSI6 * 100;
        } else {
            handle.cache_RSI6 = YTSCFLOAT_NULL;
        }
        
        //RSI12
        if (index >= days12) {
            handle.cache_RSI12 = SMAMAX_RSI12 / SMAABS_RSI12 * 100;
        } else {
            handle.cache_RSI12 = YTSCFLOAT_NULL;
        }
        
        //RSI24
        if (index >= days24) {
            handle.cache_RSI24 = SMAMAX_RSI24 / SMAABS_RSI24 * 100;
        } else {
            handle.cache_RSI24 = YTSCFLOAT_NULL;
        }
        progress(index,handle); // 返回计算结果
    }
    if (complete) complete (targetRange,nil);
}
@end
