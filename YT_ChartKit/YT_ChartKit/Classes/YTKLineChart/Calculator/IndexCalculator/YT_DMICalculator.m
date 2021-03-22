//
//  YT_DMICalculator.m
//  KDS_Phone
//
//  Created by yangjinming on 2018/6/1.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_DMICalculator.h"
#import "YT_FloatQueue.h"

@implementation YT_DMICalculator

#if !defined(YTSCMAXABS3)
#define YTSCMAXABS3(A,B,C)   MAX((MAX(ABS(A), ABS(B))), ABS(C))
#endif

#if !defined(YTSCDMID_DEFAULTVALUE)
#define YTSCDMID_DEFAULTVALUE 0
#endif

/// 准备计算
+ (void)t_readyParmKdata:(NSArray<id<YT_StockKlineData>> *)kdataArr
                      qPlusDM:(double *)queue_plusDM
                     qMinusDM:(double *)queue_minusDM
                          qTR:(double *)queue_TR
                  queuesOrder:(YT_FloatQueuesOrder *)queuesOrder_pmt
                          idx:(NSInteger)idx
                         days:(NSInteger)days {
    
    NSInteger toIdx = idx + 1;
    NSInteger loc = toIdx - days;
    if (loc < 0) {
        loc = 0;
    }
    
    id<YT_StockKlineData> kxData_Cur,kxData_Pre;
    
    //临时参数为了重用所以放在for外面
    YTSCFloat high_Cur, high_Pre, low_Cur, low_Pre, close_Pre;
    YTSCFloat plusDM, minusDM, TR;
    
    if (loc == 0) {
        id<YT_StockKlineData> klineData = [kdataArr objectAtIndex:0];
        YTSCFloat high = klineData.yt_highPrice;//最高成交价格
        YTSCFloat low = klineData.yt_lowPrice; //最低成交价格
        
        TR = high - low;
        
        plusDM = YTSCDMID_DEFAULTVALUE;
        minusDM = YTSCDMID_DEFAULTVALUE;
        
        //使用队列存放数据 Push 放 Replace 后面顺序不可更改
        YT_FloatQueuesReplace((int)queuesOrder_pmt->firstOneIndex, queue_plusDM, plusDM);
        YT_FloatQueuesReplace((int)queuesOrder_pmt->firstOneIndex, queue_minusDM, minusDM);
        YT_FloatQueuesPush(queuesOrder_pmt, queue_TR, TR);
        
        loc++;
    }
    
    for (NSInteger index = loc ; index < toIdx; index++) {
        
        kxData_Cur = [kdataArr objectAtIndex:index];
        kxData_Pre = [kdataArr objectAtIndex:(index-1)];
        //最高成交价格
        high_Cur = kxData_Cur.yt_highPrice;
        high_Pre = kxData_Pre.yt_highPrice;
        //最低成交价格
        low_Cur = kxData_Cur.yt_lowPrice;
        low_Pre = kxData_Pre.yt_lowPrice;
        //前1日的收盘价
        close_Pre = kxData_Pre.yt_closePrice;
        
        //           (1)计算当日动向值
        plusDM = high_Cur - high_Pre;
        minusDM = low_Pre - low_Cur;
        if (plusDM < 0 || plusDM <= minusDM) {
            plusDM = 0;
        }
        if (minusDM < 0 || minusDM <= plusDM) {
            minusDM = 0;
        }
        //           (2)计算真实波幅（TR）
        TR = YTSCMAXABS3((high_Cur - low_Cur), (high_Cur - close_Pre), (low_Cur - close_Pre));
        
        //使用队列存放数据 Push 放 Replace 后面顺序不可更改
        YT_FloatQueuesReplace((int)queuesOrder_pmt->firstOneIndex, queue_plusDM, plusDM);
        YT_FloatQueuesReplace((int)queuesOrder_pmt->firstOneIndex, queue_minusDM, minusDM);
        YT_FloatQueuesPush(queuesOrder_pmt, queue_TR, TR);
    }
    
}

/// 准备计算
+ (void)t_readyParmWithData:(id<YT_StockDMIHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
                        qDX:(double *)queue_dx
                queuesOrder:(YT_FloatQueuesOrder *)queuesOrder
                        idx:(NSInteger)idx
                       days:(NSInteger)days {
    NSInteger toIdx = idx + 1;
    NSInteger loc = toIdx - days;
    if (loc < 0) {
        loc = 0;
    }
    YTSCFloat numerator, denominator, dx;
    id <YT_StockDMIHandle> handle;
    for (NSInteger index = loc ; index < toIdx; index++) {
        handle = handles(index);
        //  计算dx
        numerator = ABS((handle.cache_MDI - handle.cache_PDI));
        denominator = (handle.cache_MDI + handle.cache_PDI);
        dx = (numerator / denominator) * 100;//DX
        YT_FloatQueuesPush(queuesOrder,queue_dx,dx);
    }
}

+ (void)calculateDMI:(NSArray<id<YT_StockKlineData>> *)kdataArr
               range:(NSRange)range
    handleUsingBlock:(id<YT_StockDMIHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
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
 
    NSInteger minHasDIIndex =  DAYS_DMI_DI - 1; // DI有值的最小索引
    NSInteger minHasADXIndex =  minHasDIIndex + DAYS_DMI_ADX - 1; // ADX有值的最小索引
    NSInteger minHasADXRIndex =  minHasADXIndex + DAYS_DMI_ADXR; // ADXR有值的最小索引
    
    NSInteger indexPartition =  minHasDIIndex;
    if (indexPartition > toIndex) indexPartition = toIndex;
    
    id <YT_StockDMIHandle> handle;
    //第一段范围计算
    for (; index < indexPartition; index++) {
        handle = handles(index);
        handle.cache_PDI = YTSCFLOAT_NULL;
        handle.cache_MDI = YTSCFLOAT_NULL;
        handle.cache_ADX = YTSCFLOAT_NULL;
        handle.cache_ADXR = YTSCFLOAT_NULL;
    }
    
    if (toIndex <= indexPartition) return;
    
    double *queue_plusDM = malloc(sizeof(double) * DAYS_DMI_DI);
    double *queue_minusDM = malloc(sizeof(double) * DAYS_DMI_DI);
    double *queue_TR = malloc(sizeof(double) * DAYS_DMI_DI);
    
    //queue_plusDM,queue_minusDM,queue_TR 三个队列的共同控制者
    YT_FloatQueuesOrder queuesOrder_pmt = YT_FloatQueuesOrderMake(0,DAYS_DMI_DI);
    
    // 准备数据参数
    queue_plusDM[DAYS_DMI_DI -1] = 0;queue_minusDM[DAYS_DMI_DI -1] = 0;queue_TR[DAYS_DMI_DI -1] = 0;
    [self t_readyParmKdata:kdataArr qPlusDM:queue_plusDM qMinusDM:queue_minusDM qTR:queue_TR queuesOrder:&queuesOrder_pmt idx:index -1 days:DAYS_DMI_DI -1];
    
    id<YT_StockKlineData> kxData_Cur,kxData_Pre;
    //临时参数为了重用所以放在for外面
    YTSCFloat high_Cur, high_Pre, low_Cur, low_Pre, close_Pre;
    YTSCFloat plusDM, minusDM, TR;
    YTSCFloat sumPlusDM, sumMinusDM, sumTR;
    YTSCFloat numerator, denominator, dx;
    YTSCFloat sumDX = 0;
    
    sumPlusDM = YT_FloatQueuesSum(queue_plusDM, DAYS_DMI_DI);
    sumMinusDM = YT_FloatQueuesSum(queue_minusDM, DAYS_DMI_DI);
    sumTR = YT_FloatQueuesSum(queue_TR, DAYS_DMI_DI);
    
    double *queue_dx = malloc(sizeof(double) * DAYS_DMI_ADX);
    YT_FloatQueuesSet(queue_dx, DAYS_DMI_ADX, 0);
    YT_FloatQueuesOrder queuesOrder_dx = YT_FloatQueuesOrderMake(0,DAYS_DMI_ADX);
    NSInteger needReadyDX = index - minHasDIIndex;
    if (needReadyDX > 0) {
         // 准备数据参数
        needReadyDX = MIN( DAYS_DMI_ADX -1, needReadyDX);
        [self t_readyParmWithData:handles qDX:queue_dx queuesOrder:&queuesOrder_dx idx:index -1 days:needReadyDX];
        sumDX = YT_FloatQueuesSum(queue_dx, DAYS_DMI_ADX);
    }
    BOOL hadADX = index >= minHasADXIndex;
    BOOL hadADXR = index >= minHasADXRIndex;
    
    //第二段范围计算
    for (; index < toIndex; index++) {
        handle = handles(index);
        
        kxData_Cur = [kdataArr objectAtIndex:index];
        kxData_Pre = [kdataArr objectAtIndex:(index-1)];
        //最高成交价格
        high_Cur = kxData_Cur.yt_highPrice;
        high_Pre = kxData_Pre.yt_highPrice;
        //最低成交价格
        low_Cur = kxData_Cur.yt_lowPrice;
        low_Pre = kxData_Pre.yt_lowPrice;
        //前1日的收盘价
        close_Pre = kxData_Pre.yt_closePrice;
        
        //           (1)计算当日动向值
        plusDM = high_Cur - high_Pre;
        minusDM = low_Pre - low_Cur;
        if (plusDM < 0 || plusDM <= minusDM) {
            plusDM = 0;
        }
        if (minusDM < 0 || minusDM <= plusDM) {
            minusDM = 0;
        }
        //           (2)计算真实波幅（TR）
        TR = YTSCMAXABS3((high_Cur - low_Cur), (high_Cur - close_Pre), (low_Cur - close_Pre));
        
        //使用队列存放数据 Push 放 Replace 后面顺序不可更改
        sumPlusDM -= YT_FloatQueuesReplace((int)queuesOrder_pmt.firstOneIndex, queue_plusDM, plusDM);
        sumMinusDM -= YT_FloatQueuesReplace((int)queuesOrder_pmt.firstOneIndex, queue_minusDM, minusDM);
        sumTR -= YT_FloatQueuesPush(&queuesOrder_pmt, queue_TR, TR);
        
        sumPlusDM += plusDM;
        sumMinusDM += minusDM;
        sumTR += TR;
        
        //            (3) 计算方向线DI
        handle.cache_PDI = sumPlusDM * 100 / sumTR; //因为分子分母都除 DAYS_DMI_DI 求平均 所以约去了
        handle.cache_MDI = sumMinusDM * 100 / sumTR;
        
        //              计算dx
        numerator = ABS((handle.cache_MDI - handle.cache_PDI));
        denominator = (handle.cache_MDI + handle.cache_PDI);
        dx = (numerator / denominator) * 100;//DX
        sumDX -= YT_FloatQueuesPush(&queuesOrder_dx,queue_dx,dx);
        sumDX += dx;
        
        //          （4）计算动向平均数ADX
        if (hadADX) {
            YTSCFloat fADX = sumDX/DAYS_DMI_ADX;
            handle.cache_ADX = fADX;
            
        //           （5）计算评估数值ADXR
            if (hadADXR || (hadADXR = index >= minHasADXIndex)) {
                handle.cache_ADXR = (fADX + handles(index - DAYS_DMI_ADXR).cache_ADX) / 2;
            }else{
                handle.cache_ADXR = YTSCFLOAT_NULL;
            }
        }else{
            handle.cache_ADX = YTSCFLOAT_NULL;
            handle.cache_ADXR = YTSCFLOAT_NULL;
            hadADX = index + 1 >= minHasADXRIndex;
        }
    }

    free(queue_plusDM);
    free(queue_minusDM);
    free(queue_TR);
    free(queue_dx);
    if (complete) complete (targetRange,nil);
}

#pragma mark - -----

///<must  fromIndex = 0;
+ (void)calculateFullDMI:(NSArray<id<YT_StockKlineData>> *)kdataArr
                   range:(NSRange)range
        handleUsingBlock:(id<YT_StockDMIHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
                progress:(void (NS_NOESCAPE ^)(NSUInteger location, id<YT_StockDMIHandle> result))progress
                complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete {
    NSRange canUseRange = NSMakeRange(0, kdataArr.count);
    NSRange targetRange = NSIntersectionRange(canUseRange, range); // 求交集 same as YT_RangeIntersectsRange
    if (targetRange.length == 0) {
        if (complete) complete (targetRange,nil);
        return;
    }
    
    NSInteger fromIndex = targetRange.location;
    NSInteger toIndex =  fromIndex + targetRange.length;
    fromIndex = 0;//must  fromIndex = 0; 否则这个方法崩溃😓
    
    NSInteger index = fromIndex;
    NSInteger days14 = DAYS_DMI_DI;
    NSInteger days6 = DAYS_DMI_ADX;
    
    YTSCFloat *adx;
    adx = malloc(sizeof(YTSCFloat) * targetRange.length);
    YTSCFloat *tr;
    tr = malloc(sizeof(YTSCFloat) * targetRange.length);
    YTSCFloat *plusDM;
    plusDM = malloc(sizeof(YTSCFloat) * targetRange.length);
    YTSCFloat *minusDM;
    minusDM = malloc(sizeof(YTSCFloat) * targetRange.length);
    YTSCFloat *adxValue;
    adxValue = malloc(sizeof(YTSCFloat) * targetRange.length);
    
    YTSCFloat defaultValue = 0;
    YTSCFloat adxValueSum = defaultValue;
    
    id<YT_StockKlineData> klineData = [kdataArr objectAtIndex:0];
    YTSCFloat high = klineData.yt_highPrice;//最高成交价格
    YTSCFloat low = klineData.yt_lowPrice; //最低成交价格
    tr[0] = high - low;
    
    plusDM[0] = defaultValue;
    minusDM[0] = defaultValue;
    adxValue[0] = defaultValue;
    
    YTSCFloat sumPlusDM = 0;
    YTSCFloat sumMinusDM = 0;
    
    YTSCFloat sumTr = high - low;
    
    id <YT_StockDMIHandle> handle;
    for (; index < toIndex; index++) {
        handle = handles(index);
        adxValue[index] = defaultValue;
        adx[index] = defaultValue;
        if (index >= 1) {
            id<YT_StockKlineData> kxData_Cur = [kdataArr objectAtIndex:index];
            id<YT_StockKlineData> kxData_Pre = [kdataArr objectAtIndex:(index-1)];
            //最高成交价格
            YTSCFloat high_Cur = kxData_Cur.yt_highPrice;
            YTSCFloat high_Pre = kxData_Pre.yt_highPrice;
            //最低成交价格
            YTSCFloat low_Cur = kxData_Cur.yt_lowPrice;
            YTSCFloat low_Pre = kxData_Pre.yt_lowPrice;
            
            //前1日的收盘价
            YTSCFloat close_Pre = kxData_Pre.yt_closePrice;
            
            //            (1)计算当日动向值
            plusDM[index] = high_Cur - high_Pre;
            minusDM[index] = low_Pre - low_Cur;
            
            if ((plusDM[index] < 0) || (plusDM[index] <= minusDM[index])) {
                plusDM[index] = defaultValue;
            }
            if ((minusDM[index] < 0) || (minusDM[index] <= plusDM[index])) {
                minusDM[index] = defaultValue;
            }
            //            (2)计算真实波幅（TR）
            tr[index] = YTSCMAXABS3((high_Cur - low_Cur), (high_Cur - close_Pre), (low_Cur - close_Pre));
            
            sumTr = sumTr + tr[index];
            sumPlusDM = sumPlusDM + plusDM[index];
            sumMinusDM = sumMinusDM + minusDM[index];
            
            if (index >= (days14 - 1)) {
                if ((index - days14) >= 0) {
                    sumPlusDM = sumPlusDM - plusDM[(index - days14)];
                    sumMinusDM = sumMinusDM - minusDM[(index - days14)];
                    sumTr = sumTr - tr[(index - days14)];
                }
                //               (3) 计算方向线DI
                handle.cache_PDI = sumPlusDM * 100 / sumTr; //因为分子分母都除 DAYS_DMI_DI 求平均 所以约去了
                handle.cache_MDI = sumMinusDM * 100 / sumTr;
                
                YTSCFloat numerator = ABS((handle.cache_MDI - handle.cache_PDI));
                YTSCFloat denominator = (handle.cache_MDI + handle.cache_PDI);
                //              （4）计算动向平均数ADX
                adxValue[index] = (numerator / denominator) * 100;//DX
                adxValueSum = adxValueSum + adxValue[index];
                if (index >= days6 + days14 - 1) {
                    adxValueSum = adxValueSum - adxValue[(index - days6)];
                    adx[index] = adxValueSum / days6;
                    handle.cache_ADX = adx[index];
                } else {
                    handle.cache_ADX = YTSCFLOAT_NULL;
                }
                //              （5）计算评估数值ADXR
                if (index >= 2 * days6 + days14 - 1) {
                    handle.cache_ADXR = (adx[index] + adx[(index - days6)]) / 2;
                } else {
                    handle.cache_ADXR = YTSCFLOAT_NULL;
                }
            } else {
                handle.cache_PDI = YTSCFLOAT_NULL;
                handle.cache_MDI = YTSCFLOAT_NULL;
                handle.cache_ADX = YTSCFLOAT_NULL;
                handle.cache_ADXR = YTSCFLOAT_NULL;
            }
        } else {
            handle.cache_PDI = YTSCFLOAT_NULL;
            handle.cache_MDI = YTSCFLOAT_NULL;
            handle.cache_ADX = YTSCFLOAT_NULL;
            handle.cache_ADXR = YTSCFLOAT_NULL;
        }
        progress(index,handle); // 返回计算结果
    }
    free(adx);
    free(adxValue);
    free(plusDM);
    free(minusDM);
    free(tr);
    if (complete) complete (targetRange,nil);
}

@end
