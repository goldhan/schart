//
//  YT_OBVCalculator.m
//  KDS_Phone
//
//  Created by zhanghao on 2018/6/6.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_OBVCalculator.h"

@implementation YT_OBVCalculator

+ (void)calculateOBV:(NSArray<id<YT_StockKlineData>> *)kdataArr range:(NSRange)range handleUsingBlock:(id<YT_StockOBVHandle> (^)(NSUInteger))handles complete:(void (^)(NSRange, NSError *))complete {
    
    NSRange canUseRange = NSMakeRange(0, kdataArr.count);
    NSRange targetRange = NSIntersectionRange(canUseRange, range); // 求交集 same as YT_RangeIntersectsRange
    if (targetRange.length == 0) {
        if (complete) complete (targetRange,nil);
        return;
    }
    
    NSInteger fromIndex = targetRange.location;
    NSInteger toIndex =  fromIndex + targetRange.length;
    
    NSInteger indexPartition =  DAYS_OBV_MA;
    if (indexPartition > toIndex) indexPartition = toIndex;

    NSInteger idx = fromIndex;
    
    id<YT_StockKlineData> obj;
    id<YT_StockOBVHandle> handle;
    
    double prevObv = 0;
    double sumObv = 0;
    if (idx != 0) {
       id<YT_StockOBVHandle> prevHandle = handles(idx -1);
        prevObv = prevHandle.cache_OBV;
        NSInteger maDays = idx < DAYS_OBV_MA-1 ? idx+1 : DAYS_OBV_MA;
        sumObv = [self t_calculateSUMForm:idx forthLeng:maDays handleUsingBlock:handles];
    }
    
    double yestodayClose = 0;
    double close = 0;
    
    // 第一段
    for (; idx < indexPartition ; idx ++) {
        handle = handles(idx);
        obj = [kdataArr objectAtIndex:idx];
        yestodayClose = obj.yt_closePriceYesterday;
        close = obj.yt_closePrice;
        
        //算obv
        if (close > yestodayClose) {
            prevObv += obj.yt_volumeOfTransactions;
        }else if (close < yestodayClose){
            prevObv -= obj.yt_volumeOfTransactions;
        }
        
        //算obv_ma
        sumObv += prevObv;
        
        handle.cache_OBV = prevObv;
        handle.cache_OBVM = sumObv / (idx + 1);
    }
    
    for (; idx < toIndex ; idx ++) {
        handle = handles(idx);
        obj = [kdataArr objectAtIndex:idx];
        yestodayClose = obj.yt_closePriceYesterday;
        close = obj.yt_closePrice;
        
        //算obv
        if (close > yestodayClose) {
            prevObv += obj.yt_volumeOfTransactions;
        }else if (close < yestodayClose){
            prevObv -= obj.yt_volumeOfTransactions;
        }
        
        //算obv_ma
        //算obv_ma
        sumObv += prevObv;
        sumObv -= handles(idx - DAYS_OBV_MA).cache_OBV;
        
        handle.cache_OBV = prevObv;
        handle.cache_OBVM = sumObv / DAYS_OBV_MA;
    }
    
    if (complete) complete (targetRange,nil);
    
}

+ (double)t_calculateSUMForm:(NSInteger)location forthLeng:(NSInteger)length handleUsingBlock:(id<YT_StockOBVHandle> (^)(NSUInteger))handles{
    
    NSInteger min = location - length; // -1 ==> NSInteger
//    if (min < 0) min = 0;
    double sum = 0.0;
    for (NSInteger i = location; i > min ; i --) {
        sum += handles(i).cache_OBV;
    }
    return sum;
}

@end
