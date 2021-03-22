//
//  YT_CRCalculator.m
//  KDS_Phone
//
//  Created by ChenRui Hu on 2018/6/1.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_CRCalculator.h"

@implementation YT_CRCalculator
/// 计算前一天的MID
+ (void)_getPreMID:(YTSCFloat *)mid preHighPrice:(YTSCFloat)h preLowPrice:(YTSCFloat)l {
    YTSCFloat MID = (h + l)/2;
    * mid = MID;
}

/// 计算CR
+ (void)calculateCR:(NSArray<id<YT_StockKlineData>> *)kdataArr Index:(NSInteger)index CR:(YTSCFloat *)cr {
    NSInteger fromIndex = index;
    NSInteger toIndex = -1;
    if (index >= DAYS_CR26) {
        toIndex = index - DAYS_CR26;
    }
    
    YTSCFloat SUM1 = 0, SUM2 = 0, CR = 0;
    
    for (; fromIndex > toIndex; fromIndex--) {
        NSInteger preIndex = fromIndex - 1; // 记录用来计算上一值的索引
        preIndex = preIndex < 0 ? 0 : preIndex;
        
        YTSCFloat MID = 0, MAX1 = 0, MAX2 = 0;
        [self _getPreMID:&MID preHighPrice:[kdataArr objectAtIndex:preIndex].yt_highPrice preLowPrice:[kdataArr objectAtIndex:preIndex].yt_lowPrice];
        MAX1 = MAX(0, [kdataArr objectAtIndex:fromIndex].yt_highPrice - MID);
        MAX2 = MAX(0, MID - [kdataArr objectAtIndex:fromIndex].yt_lowPrice);
        SUM1 = SUM1 + MAX1;
        SUM2 = SUM2 + MAX2;
    }
    
    if (SUM2 != 0) {
        CR = SUM1/SUM2 * 100;
    }

    * cr = CR;
}

/// CR 平均值
+ (void)calculateCR:(id<YT_StockCRHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
                day:(NSUInteger)day
              range:(NSRange)range
           progress:(void (NS_NOESCAPE ^)(NSUInteger location, YTSCFloat maValue))progress {
    
    NSInteger fromIndex = range.location;
    NSInteger toIndex =  fromIndex + range.length;
    
    if (toIndex < day || day < 1) return;
    if(fromIndex < day - 1) fromIndex = day - 1 ;
    
    NSInteger min = fromIndex - day; // -1 ==> NSInteger
    YTSCFloat sum = 0.0;
    for (NSInteger i = fromIndex; i > min ; i --) {
        sum += handles(i).cache_CR;
    }
    
    progress(fromIndex,sum/day);
    
    for (NSUInteger i = fromIndex + 1 ; i < toIndex ; i++) {
        NSUInteger delIndex = i - day;
        sum = sum + (handles(i).cache_CR - handles(delIndex).cache_CR);
        progress(i,sum/day);
    }
}

+ (void)calculateCR:(NSArray<id<YT_StockKlineData>> *)kdataArr
              range:(NSRange)range
   handleUsingBlock:(id<YT_StockCRHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
           progress:(void (NS_NOESCAPE ^)(NSUInteger location, id<YT_StockCRHandle> result))progress
           complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete {
    NSRange canUseRange = NSMakeRange(0, kdataArr.count);
    NSRange targetRange = NSIntersectionRange(canUseRange, range); // 求交集 same as YT_RangeIntersectsRange
    if (targetRange.length == 0) {
        if (complete) complete (targetRange,nil);
        return;
    }
    
    NSInteger index = targetRange.location;
    NSInteger toIndex =  targetRange.location + targetRange.length;
    
    id<YT_StockCRHandle> handle;
    
    // 计算 CR
    for (; index < toIndex ; index ++) {
        YTSCFloat CR = 0;
        [self calculateCR:kdataArr Index:index CR:&CR];
        handle = handles(index);
        handle.cache_CR = CR;
        progress(index,handle); // 返回计算结果
    }
    
    // 计算 M1
    index = targetRange.location;
    NSInteger indexPartition = DAYS_CR_MA10 + DAYS_CR_MA10*2/5;
    indexPartition  = indexPartition <= toIndex ? indexPartition : toIndex;
    
    // 第一段
    for (; index < indexPartition ; index ++) {
        handle = handles(index);
        handle.cache_CR_MA10 = YTSCFLOAT_NULL;
        progress(index,handle); // 返回计算结果
    }
    
    YTSCFloat *MA10_CR = malloc(sizeof(YTSCFloat) * targetRange.length);
    [self calculateCR:handles day:DAYS_CR_MA10 range:targetRange progress:^(NSUInteger location, YTSCFloat maValue) {
        MA10_CR [location - targetRange.location] = maValue;
    }];
    
    // 第二段
    for (; index < toIndex ; index ++) {
        handle = handles(index);
        handle.cache_CR_MA10 = MA10_CR [index - targetRange.location - 1];
        progress(index,handle); // 返回计算结果
    }
    
    // 计算 M2
    index = targetRange.location;
    indexPartition = DAYS_CR_MA20 + DAYS_CR_MA20*2/5;
    indexPartition  = indexPartition <= toIndex ? indexPartition : toIndex;
    
    // 第一段
    for (; index < indexPartition ; index ++) {
        handle = handles(index);
        handle.cache_CR_MA20 = YTSCFLOAT_NULL;
        progress(index,handle); // 返回计算结果
    }
    
    YTSCFloat *MA20_CR;
    MA20_CR = malloc(sizeof(YTSCFloat) * targetRange.length);
    [self calculateCR:handles day:DAYS_CR_MA20 range:targetRange progress:^(NSUInteger location, YTSCFloat maValue) {
        MA20_CR [location - targetRange.location] = maValue;
    }];
    
    // 第二段
    for (; index < toIndex ; index ++) {
        handle = handles(index);
        handle.cache_CR_MA20 = MA20_CR [index - targetRange.location - 1];
        progress(index,handle); // 返回计算结果
    }
    
    // 计算 M3
    index = targetRange.location;
    indexPartition = DAYS_CR_MA40 + DAYS_CR_MA40*2/5;
    indexPartition  = indexPartition <= toIndex ? indexPartition : toIndex;
    
    // 第一段
    for (; index < indexPartition ; index ++) {
        handle = handles(index);
        handle.cache_CR_MA40 = YTSCFLOAT_NULL;
        progress(index,handle); // 返回计算结果
    }
    
    YTSCFloat *MA40_CR;
    MA40_CR = malloc(sizeof(YTSCFloat) * targetRange.length);
    [self calculateCR:handles day:DAYS_CR_MA40 range:targetRange progress:^(NSUInteger location, YTSCFloat maValue) {
        MA40_CR [location - targetRange.location] = maValue;
    }];
    
    // 第二段
    for (; index < toIndex ; index ++) {
        handle = handles(index);
        handle.cache_CR_MA40 = MA40_CR [index - targetRange.location - 1];
        progress(index,handle); // 返回计算结果
    }
    
    // 计算 M4
    index = targetRange.location;
    indexPartition = DAYS_CR_MA62 + DAYS_CR_MA62*2/5;
    indexPartition  = indexPartition <= toIndex ? indexPartition : toIndex;
    
    // 第一段
    for (; index < indexPartition ; index ++) {
        handle = handles(index);
        handle.cache_CR_MA62 = YTSCFLOAT_NULL;
        progress(index,handle); // 返回计算结果
    }
    
    YTSCFloat *MA62_CR;
    MA62_CR = malloc(sizeof(YTSCFloat) * targetRange.length);
    [self calculateCR:handles day:DAYS_CR_MA62 range:targetRange progress:^(NSUInteger location, YTSCFloat maValue) {
        MA62_CR [location - targetRange.location] = maValue;
    }];
    
    // 第二段
    for (; index < toIndex ; index ++) {
        handle = handles(index);
        handle.cache_CR_MA62 = MA62_CR [index - targetRange.location - 1];
        progress(index,handle); // 返回计算结果
    }
    
    if (complete) complete (targetRange,nil);
    
}


#pragma mark -

/// 计算CR
+ (void)calculateCR:(NSArray<id<YT_StockKlineData>> *)kdataArr index:(NSInteger)index forthTo:(NSInteger)toIndex CR:(YTSCFloat *)cr {
    NSInteger fromIndex = toIndex + 1;
    toIndex = index + 1;
    
    id<YT_StockKlineData> prekdata;
    id<YT_StockKlineData> kdata;
    if (fromIndex == 0) {
        prekdata = [kdataArr objectAtIndex:0];
    }else{
        prekdata = [kdataArr objectAtIndex:fromIndex - 1];
    }
    YTSCFloat SUM1 = 0, SUM2 = 0;
    YTSCFloat MID = 0, MAX1 = 0, MAX2 = 0;
    YTSCFloat sub_tmp = 0;
    for (NSInteger idx = fromIndex ; idx < toIndex ; idx++) {
        kdata = [kdataArr objectAtIndex:idx];
 
        MID = (prekdata.yt_highPrice + prekdata.yt_lowPrice)/2;
        sub_tmp = kdata.yt_highPrice - MID;
        MAX1 = sub_tmp > 0 ? sub_tmp : 0;
        sub_tmp = MID - kdata.yt_lowPrice;
        MAX2 = sub_tmp > 0 ? sub_tmp : 0;
        
        SUM1 += MAX1;
        SUM2 += MAX2;
        
        prekdata = kdata;
    }
    if (SUM2 == 0) {
        * cr = 0;
    }else{
        * cr = SUM1/SUM2 * 100;
    }
}

/// 计算 CR
+ (void)calculateCR:(NSArray<id<YT_StockKlineData>> *)kdataArr from:(NSInteger)fromIndex to:(NSInteger)toIndex handleUsingBlock:(id<YT_StockCRHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles {
    
//    NSInteger forthTo = index - DAYS_CR26;
    
    NSInteger indexPartition = DAYS_CR26;
    NSInteger idx = fromIndex;
    if (indexPartition > toIndex) {
        indexPartition = toIndex;
    }
    
    id<YT_StockCRHandle> handle;
    YTSCFloat CR = 0;
    for (; idx < indexPartition ; idx ++) {
        handle = handles(idx);
        [self calculateCR:kdataArr index:idx forthTo:-1 CR:&CR];
        handle.cache_CR = CR;
    }

    for (; idx < toIndex ; idx ++) {
        handle = handles(idx);
        [self calculateCR:kdataArr index:idx forthTo:(idx - DAYS_CR26) CR:&CR];
        handle.cache_CR = CR;
    }
    
}

/// CR 平均值 fromIndex toIndex 不能小于 0
+ (void)calculateCRMA:(id<YT_StockCRHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
                day:(NSUInteger)day
              from:(NSInteger)fromIndex
                to:(NSInteger)toIndex
           progress:(void (NS_NOESCAPE ^)(NSUInteger location, YTSCFloat maValue))progress {
    
    NSInteger offday = day/2.5 + 1;// CR 的 平均值 求的是 （day/2.5 + 1）天前的平均值
    // real from = fromIndex - offday;
    NSInteger realfrom = fromIndex - offday;//可能为负数
    NSInteger realTo = toIndex - offday;//可能为负数
    
    NSInteger indexPartition = day - 1;
    if (indexPartition > realTo) {
        indexPartition = realTo;
    }
    
    // 第一段
    NSInteger index = realfrom;
    for (; index < indexPartition ; index++) {
        progress(index + offday,YTSCFLOAT_NULL); // 返回计算结果
    }
    
    // 第二段
    if(index >= realTo) return;
    NSInteger min = index - day; // -1 ==> NSInteger
    double sum = 0.0;
    for (NSInteger i = index; i > min ; i --) {
        sum += handles(i).cache_CR;
    }
    progress(index + offday,sum/day);
    index++;
    for ( ; index < realTo ; index++) {
        NSUInteger delIndex = index - day;
        sum = sum + (handles(index).cache_CR - handles(delIndex).cache_CR);
        progress(index + offday,sum/day);
    }
}

+ (void)calculateCR:(NSArray<id<YT_StockKlineData>> *)kdataArr
              range:(NSRange)range
   handleUsingBlock:(id<YT_StockCRHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
           complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete {
    NSRange canUseRange = NSMakeRange(0, kdataArr.count);
    NSRange targetRange = NSIntersectionRange(canUseRange, range); // 求交集 same as YT_RangeIntersectsRange
    if (targetRange.length == 0) {
        if (complete) complete (targetRange,nil);
        return;
    }
    
    NSInteger index = targetRange.location;
    NSInteger toIndex =  targetRange.location + targetRange.length;
    
    // 计算 CR
    [self calculateCR:kdataArr from:index to:toIndex handleUsingBlock:handles];
    // 计算 M1
    [self calculateCRMA:handles day:DAYS_CR_MA10 from:index to:toIndex progress:^(NSUInteger location, YTSCFloat maValue) {
        handles(location).cache_CR_MA10 = maValue;
    }];
    // 计算 M2
    [self calculateCRMA:handles day:DAYS_CR_MA20 from:index to:toIndex progress:^(NSUInteger location, YTSCFloat maValue) {
        handles(location).cache_CR_MA20 = maValue;
    }];
    /*
    // 计算 M3
    [self calculateCRMA:handles day:DAYS_CR_MA40 from:index to:toIndex progress:^(NSUInteger location, YTSCFloat maValue) {
        handles(location).cache_CR_MA40 = maValue;
    }];
    // 计算 M4
    [self calculateCRMA:handles day:DAYS_CR_MA62 from:index to:toIndex progress:^(NSUInteger location, YTSCFloat maValue) {
        handles(location).cache_CR_MA62 = maValue;
    }];
    */
    if (complete) complete (targetRange,nil);
}

@end
