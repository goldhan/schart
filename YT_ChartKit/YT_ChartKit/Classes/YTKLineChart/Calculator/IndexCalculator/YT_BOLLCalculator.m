//
//  YT_BOLLCalculator.m
//  KDS_Phone
//
//  Created by yangjinming on 2018/6/4.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_BOLLCalculator.h"

@implementation YT_BOLLCalculator

+ (void)calculateBOLL:(NSArray<id<YT_StockKlineData>> *)kdataArr
                range:(NSRange)range
     handleUsingBlock:(id<YT_StockBOLLHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
             complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete {
    NSRange canUseRange = NSMakeRange(0, kdataArr.count);
    NSRange targetRange = NSIntersectionRange(canUseRange, range); // 求交集 same as YT_RangeIntersectsRange
    if (targetRange.length == 0) {
        if (complete) complete (targetRange,nil);
        return;
    }

    NSInteger fromIndex = targetRange.location;
    NSInteger toIndex =  fromIndex + targetRange.length;

    NSInteger indexPartition = DAYS_BOLL - 1;
    if (indexPartition > toIndex) {
        indexPartition = toIndex;
    }
    
    id <YT_StockBOLLHandle> handle;
    id <YT_StockKlineData> kxData;
    
    // 第一段
    NSInteger index = fromIndex;
    for (; index < indexPartition ; index++) {
        handle = handles(index);
        handle.cache_BOLL_Mid = YTSCFLOAT_NULL;
        handle.cache_BOLL_Upper = YTSCFLOAT_NULL;
        handle.cache_BOLL_Lower = YTSCFLOAT_NULL;
    }
    
    if (index >= toIndex) return;
    
    int P = DAYS_BOLL_P2;
    double closeSum = [self t_calculateCloseSumForm:index - 1 forthLeng:DAYS_BOLL -1 data:kdataArr];
    double closeMa = 0; //20日收盘的平均值 DAYS_BOLL 20
    double meanSquare = 0; //样本方差
    double deletv = 0;
    double addv = 0;
    
    // 第二段
    for (; index < toIndex ; index++) {
        
        handle = handles(index);
        kxData = [kdataArr objectAtIndex:index];
        
        addv = kxData.yt_closePrice;
        closeSum =  closeSum + addv - deletv;
        closeMa = closeSum/DAYS_BOLL;
        
        handle.cache_BOLL_Mid = closeMa;
        meanSquare = [self t_calculateSquareSUMTMP:index data:kdataArr days:DAYS_BOLL closeMa:closeMa];
        handle.cache_BOLL_Upper = closeMa + meanSquare * P;
        handle.cache_BOLL_Lower = closeMa - meanSquare * P;
        
        NSInteger deletIdx = index - DAYS_BOLL + 1;
        deletv = [kdataArr objectAtIndex:deletIdx].yt_closePrice;
    }
    
    if (complete) complete (targetRange,nil);
}

/// 算和
+ (double)t_calculateCloseSumForm:(NSInteger)location forthLeng:(NSInteger)length data:(NSArray<id<YT_StockKlineData>> *)kdataArr {
    
    NSInteger min = location - length; // -1 ==> NSInteger
//    if (min < -1)  min = -1; //检查判断 其实没必要 min必定大于 -1 这里是内部方法 是看传入值得
    
    double sum = 0.0;
    for (NSInteger i = location; i > min ; i --) {
        sum += (kdataArr[i].yt_closePrice);
    }
    return sum;
}

/// 算样本方差
+ (double)t_calculateSquareSUMTMP:(NSInteger)index
                             data:(NSArray<id<YT_StockKlineData>> *)kdataArr
                              days:(NSInteger)days
                            closeMa:(YTSCFloat)closeMa {
    NSInteger forthTo = index - days;
    if (forthTo < -1) { //检查判断 其实没必要
        forthTo = -1;
        days = index + 1;
    }
    
    //每个样本(收盘) 减去样本全部数据的平均值
    double squareSUM = 0;
    double eachColse = 0,colseSub = 0;
    for (NSInteger j = index; j > forthTo; j--) {
        eachColse = (kdataArr[j].yt_closePrice);
        colseSub = eachColse - closeMa;
        squareSUM += (colseSub * colseSub);
    }
    
//    double afterSqrt = sqrt(squareSUM / (days - 1));
    return sqrt(squareSUM / (days - 1));
}

@end
