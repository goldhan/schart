//
//  YT_CCICalculator.m
//  KDS_Phone
//
//  Created by yangjinming on 2018/5/31.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_CCICalculator.h"
#import "YT_FloatQueue.h"

@implementation YT_CCICalculator

+ (void)calculateCCI:(NSArray<id<YT_StockKlineData>> *)kdataArr
               range:(NSRange)range
    handleUsingBlock:(id<YT_StockCCIHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
            progress:(void (NS_NOESCAPE ^)(NSUInteger location, id<YT_StockCCIHandle> result))progress
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
    
    const NSInteger days = DAYS_CCI;//计算周期
    
    NSInteger indexPartition = days - 1;
    if (indexPartition > toIndex) {
        indexPartition = toIndex;
    }
    
    id <YT_StockCCIHandle> handle;
    for (; index < indexPartition; index++) {
        handle = handles(index);
        handle.cache_CCI = YTSCFLOAT_NULL;
        progress(index,handle); // 返回计算结果
    }
    
    if (index >= toIndex) return;
    
    // 需要临时存储的数据
    double *  queue_tp = malloc(sizeof(double) * days);
    YT_FloatQueuesOrder queueOrder_tp = YT_FloatQueuesOrderMake(0, days);
    
    NSInteger forthTo  = index - days;
    NSAssert(forthTo > -2, @"indexPartition 计算出错");
    
    //临时计算参数,因为这些参数重用性高所以写外面性能更好些 当然写for循环里面可能可读性会更高
    YTSCFloat high = 0,low = 0,close = 0;
    double tp,tp_del;
    id<YT_StockKlineData> klineData;
    
    // 准备参数tp数组 准备个数 为 days - 1 个
    queue_tp[days - 1] = 0;//最后一个数据清0 也可以用 YT_FloatQueuesSet 函数对队列queue_tp清0
    for (NSInteger i = index -1 ; i > forthTo ; i --) {
        klineData = [kdataArr objectAtIndex:i];
        
        high = klineData.yt_highPrice;//最高成交价格
        low = klineData.yt_lowPrice; //最低成交价格
        close = klineData.yt_closePrice; //收盘价
        
        tp = (high + low + close) / 3;
        YT_FloatQueuesPush(&queueOrder_tp, queue_tp, tp); //存储数据
    }

    double tpSum = 0,tpMA = 0;
    tpSum = YT_FloatQueuesSum(queue_tp, days);
    
    for (; index < toIndex; index++) {
        klineData = [kdataArr objectAtIndex:index];
        handle = handles(index);
        
        high = klineData.yt_highPrice;//最高成交价格
        low = klineData.yt_lowPrice; //最低成交价格
        close = klineData.yt_closePrice; //收盘价
        tp = (high + low + close) / 3;
        tp_del = YT_FloatQueuesPush(&queueOrder_tp, queue_tp, tp); //存储数据
        tpSum = tpSum + tp - tp_del;
        tpMA = tpSum / days;
        
        YTSCFloat avetempDiffSum = 0;
        for (NSInteger j = 0 ; j < days; j++) {
//            YTSCFloat avetempDiff = fabs(queue_tp[j] - tpMA)
            avetempDiffSum += fabs(queue_tp[j] - tpMA);
        }
        
        YTSCFloat numerator = tp - tpMA;
        YTSCFloat coefficient = 0.015; //系数
        YTSCFloat denominator = avetempDiffSum / days;
        
        handle.cache_CCI = numerator / (denominator * coefficient);
        progress(index,handle); // 返回计算结果
    }
    free(queue_tp);
    if (complete) complete (targetRange,nil);
}

#pragma mark - 旧方法

+ (void)calculateCCI2:(NSArray<id<YT_StockKlineData>> *)kdataArr
                range:(NSRange)range
     handleUsingBlock:(id<YT_StockCCIHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
             progress:(void (NS_NOESCAPE ^)(NSUInteger location, id<YT_StockCCIHandle> result))progress
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
    
    NSInteger days = DAYS_CCI;
    YTSCFloat avetempSum = 0;
    YTSCFloat *avetempArray;

    avetempArray = malloc(sizeof(YTSCFloat) * toIndex-1);
    id <YT_StockCCIHandle> handle;
    for (; index < toIndex ; index ++) {
        id<YT_StockKlineData> klineData = [kdataArr objectAtIndex:index];
        handle = handles(index);
        
        YTSCFloat high = klineData.yt_highPrice;//最高成交价格
        YTSCFloat low = klineData.yt_lowPrice; //最低成交价格
        YTSCFloat close = klineData.yt_closePrice; //收盘价
        
        YTSCFloat avetemp = (high + low + close) / 3;
        avetempArray[index] = avetemp;
        avetempSum = avetempSum + avetemp;
        if (index > (days - 1)) {
            if ((index - days) >= 0) {
                avetempSum = avetempSum - avetempArray[(index - days)];
            }
            YTSCFloat avetempDiffSum = 0;
            for (NSInteger j = (index - days + 1); j <= index; j++) {
                YTSCFloat avetempDiff = fabs(avetempArray[j] - (avetempSum / days));
                avetempDiffSum = avetempDiffSum + avetempDiff;
            }
            
            YTSCFloat numerator = avetemp - avetempSum / days;
            YTSCFloat coefficient = 0.015; //系数
            YTSCFloat denominator = avetempDiffSum / days;
            
            handle.cache_CCI = numerator / (denominator * coefficient);
            
        } else {
            handle.cache_CCI = YTSCFLOAT_NULL;
        }
        progress(index,handle); // 返回计算结果
    }
    free(avetempArray);
    if (complete) complete (targetRange,nil);
}
@end
