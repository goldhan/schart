//
//  YT_DMACalculator.m
//  KDS_Phone
//
//  Created by ChenRui Hu on 2018/5/30.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_DMACalculator.h"
#import "NSArray+YT_MACalculator.h"

@implementation YT_DMACalculator
+ (void)calculateDMA:(NSArray<id<YT_StockKlineData>> *)kdataArr
               range:(NSRange)range
    handleUsingBlock:(id<YT_StockDMAHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
            complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete {
    
    NSRange canUseRange = NSMakeRange(0, kdataArr.count);
    NSRange targetRange = NSIntersectionRange(canUseRange, range);  // 求交集 same as YT_RangeIntersectsRange
    if (targetRange.length == 0) {
        if (complete) complete (targetRange,nil);
        return;
    }
    
    NSInteger fromIndex = targetRange.location;
    NSInteger toIndex =  fromIndex + targetRange.length;
    
    NSInteger minStartIndex = MAX(DAYS_DMA10, DAYS_DMA50) - 1;
    NSInteger indexPartition = minStartIndex < toIndex ? minStartIndex : toIndex;
    
    NSInteger index = fromIndex;
    id <YT_StockDMAHandle> handle;

    for (; index < indexPartition; index++) {
        handle = handles(index);
        handle.cache_DMA   = YTSCFLOAT_NULL;
        handle.cache_AMA  = YTSCFLOAT_NULL;
    }
    
    YTSCFloat *MA10_CLOSS;
    MA10_CLOSS = malloc(sizeof(YTSCFloat) * targetRange.length);
    YTSCFloat *MA50_CLOSS;
    MA50_CLOSS = malloc(sizeof(YTSCFloat) * targetRange.length);
    [self calculateDMA:kdataArr day:DAYS_DMA10 range:targetRange usingGetterSel:@selector(yt_closePrice) progress:^(NSUInteger location, YTSCFloat maValue) {
        MA10_CLOSS [location - targetRange.location] = maValue;
    }];
    [self calculateDMA:kdataArr day:DAYS_DMA50 range:targetRange usingGetterSel:@selector(yt_closePrice) progress:^(NSUInteger location, YTSCFloat maValue) {
        MA50_CLOSS [location - targetRange.location] = maValue;
    }];
    
    int ma_days = MAX(1, DAYS_DMA_DIFMA10);
    minStartIndex = minStartIndex + ma_days -1;
    
    for (; index < toIndex; index++) {
        handle = handles(index);
        // 计算 DMA
        YTSCFloat DMA10 = MA10_CLOSS [index - targetRange.location];
        YTSCFloat DMA50 = MA50_CLOSS [index - targetRange.location];
        handle.cache_DMA = DMA10 - DMA50;
        
        // 计算 AMA
        YTSCFloat AMA   = YTSCFLOAT_NULL;
        if (index  >= minStartIndex) {
            AMA = [self _calculateSUMForm:index leng:ma_days handleUsingBlock:handles]/ma_days;
        }
        handle.cache_AMA = AMA;
    }
    
    free(MA10_CLOSS);
    free(MA50_CLOSS);
    
    if (complete) complete (targetRange,nil);
}

#pragma mark - tool
/// 计算
+ (void)calculateDMA:(NSArray<id<YT_StockKlineData>> *)kdataArr
                 day:(NSUInteger)day
               range:(NSRange)range
      usingGetterSel:(SEL)getter
            progress:(void (NS_NOESCAPE ^)(NSUInteger location, YTSCFloat maValue))progress {
    
    NSInteger fromIndex = range.location;
    NSInteger toIndex =  fromIndex + range.length;
    
    if (toIndex < day || day < 1) return;
    if(fromIndex < day - 1) fromIndex = day - 1 ;
    
    
    NSObject * anyObj = (NSObject *)[kdataArr objectAtIndex:0];
    IMP imp = [anyObj methodForSelector:getter];
    YTSCFloat (*objGetter)(id obj, SEL getter) = (void *)imp;
    YTSCFloat (*objGetterSimple)(id obj) = (void *)imp;
    
    NSInteger min = fromIndex - day; // -1 ==> NSInteger
    YTSCFloat sum = 0.0;
    for (NSInteger i = fromIndex; i > min ; i --) {
        sum += (objGetterSimple ([kdataArr objectAtIndex:i]));
    }
    
    progress(fromIndex,sum/day);
    
    for (NSUInteger i = fromIndex + 1 ; i < toIndex ; i++) {
        NSUInteger delIndex = i - day;
        sum = sum + (objGetter ([kdataArr objectAtIndex:i], getter)) - (objGetter ([kdataArr objectAtIndex:delIndex], getter));
        progress(i,sum/day);
    }
}

/// 从 location 往后便利 length 长度 数据相加 为了性能没有任何健壮代码，所以调用的时候必须保证数据不会越界
+ (YTSCFloat)_calculateSUMForm:(NSUInteger)location leng:(NSUInteger)length handleUsingBlock:(id<YT_StockDMAHandle>  _Nonnull (^)(NSUInteger))handles {
    NSInteger startIndex = (NSInteger)(location - length + 1);
    if (startIndex < 0) {
        return YTSCFLOAT_NULL;
    }
    
    NSUInteger max = startIndex + length;
    YTSCFloat sum = 0.0;
    for (NSUInteger i = startIndex; i < max; i ++) {
        id <YT_StockDMAHandle> handle = handles(i);
        sum += handle.cache_DMA;
    }
    return sum;
}

@end
