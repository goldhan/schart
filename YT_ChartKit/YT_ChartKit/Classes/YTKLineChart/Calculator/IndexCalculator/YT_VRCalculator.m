//
//  YT_VRCalculator.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/29.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_VRCalculator.h"
#import "NSArray+YT_MACalculator.h"

NS_ASSUME_NONNULL_BEGIN

//        DAYS_VR;//计算vr参数周期
//        DAYS_MAVR;//vr平均值周期6 (6-1 ，1为当天)

@implementation YT_VRCalculator

/**
 可以计算出准确的 VR 指标的最小索引

 @return 最小索引
 */
+ (NSUInteger)minAccurateVRIndex {
    // 注意 这里不是 DAYS_VR - 1 . 因为
    // VR 指标与 DAYS_VR（26） 个 数据内的 涨跌平有关 。 第一个点 算 涨跌和前一天有关，所以最少要 DAYS_VR + 1 个数据才有一个准确的VR值。
    // 所以 准确的VR指标的第一个索引为 （DAYS_VR + 1 - 1） 。
//    return 0;
    return DAYS_VR;
}

+ (void)calculateVR:(NSArray<id<YT_StockKlineData>> *)kdataArr
              range:(NSRange)range
           progress:(void (NS_NOESCAPE ^)(NSUInteger location, YTSCFloat vr))progress
           complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete {
    
    NSRange canUseRange = NSMakeRange(0, kdataArr.count);
    NSRange targetRange = NSIntersectionRange(canUseRange, range); // 求交集 same as YT_RangeIntersectsRange
    if (targetRange.length == 0) {
        if (complete) complete (targetRange,nil);
        return;
    }
    
    NSInteger fromIndex = targetRange.location;
    NSInteger toIndex =  fromIndex + targetRange.length;
    
//     VR:100*(TH*2+TQ)/(TL*2+TQ);
//     VR:100*(TH + TQ/2)/(TL+TQ/2)
    for (NSInteger i = fromIndex ; i < toIndex ; i ++) {
      YTSCFloat th = 0, tl = 0, tq = 0; //初始化
      [self t_calculateVRParm:kdataArr riseV:&th fallV:&tl holdV:&tq idx:i forthCount:DAYS_VR];
        double tq_2 = tq /2;
        YTSCFloat vr = 100*(th + tq_2)/(tl+tq_2);
        progress(i ,vr);
//        if (i == 0) {
//            NSLog(@"vrvrvr %zd === %f",i,vr);
//        }
    }
    
    if (complete) {
        complete (targetRange,nil);
    }
}

+ (void)calculateVR2:(NSArray<id<YT_StockKlineData>> *)kdataArr
              range:(NSRange)range
           progress:(void (NS_NOESCAPE ^)(NSUInteger location, YTSCFloat vr))progress
           complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete {
    
    NSRange canUseRange = NSMakeRange(0, kdataArr.count);
    NSRange targetRange = NSIntersectionRange(canUseRange, range); // 求交集 same as YT_RangeIntersectsRange
    if (targetRange.length == 0) {
        if (complete) complete (targetRange,nil);
        return;
    }
    
    NSInteger fromIndex = targetRange.location;
    NSInteger toIndex =  fromIndex + targetRange.length;
    NSInteger i = fromIndex;
    
    //     VR:100*(TH*2+TQ)/(TL*2+TQ);
    //     VR:100*(TH + TQ/2)/(TL+TQ/2)
    YTSCFloat th = 0, tl = 0, tq = 0;
    if (i == 0) {
        id <YT_StockKlineData> data = kdataArr.firstObject;
        tq = data.yt_volumeOfTransactions;
//        YTSCFloat vr = 100*(th + tq / 2)/(tl + tq / 2);
        progress(0 ,100);
        i ++ ;
    }
    
    NSInteger indexPartition =  DAYS_VR + 1;
    if (indexPartition > toIndex) indexPartition = toIndex;
    
    id <YT_StockKlineData> data_add;
    id <YT_StockKlineData> data_add_prev;
    id <YT_StockKlineData> data_del;
    id <YT_StockKlineData> data_del_prev;
    
    // 第一段 情况复杂 兼容所有 范围
    for ( ; i < indexPartition ; i ++) { // i 最大 DAYS_VR
        
        data_add = [kdataArr objectAtIndex:i];
        data_add_prev = [kdataArr objectAtIndex:i -1];
        [self t_calculateVRParmAddOneWithData:data_add prevData:data_add_prev riseV:&th fallV:&tl holdV:&tq];
        
        NSInteger delIdx = i - DAYS_VR;
        if ( delIdx == 0 ) {
            id <YT_StockKlineData> data = kdataArr.firstObject;
            tq -= data.yt_volumeOfTransactions;
        }else if ( delIdx > 0 ){
            data_del = [kdataArr objectAtIndex:delIdx];
            data_del_prev = [kdataArr objectAtIndex:delIdx -1];
            [self t_calculateVRParmDelOneWithData:data_del prevData:data_del_prev riseV:&th fallV:&tl holdV:&tq];
        }
        
        double tq_2 = tq / 2;
        YTSCFloat vr = 100*(th + tq_2)/(tl+tq_2);
        progress(i ,vr);
        
    }
    
    // 第二段 情况简单
    for ( ; i < toIndex ; i ++) { // i 最小 DAYS_VR + 1
        
        data_add = [kdataArr objectAtIndex:i];
        data_add_prev = [kdataArr objectAtIndex:i -1];
        [self t_calculateVRParmAddOneWithData:data_add prevData:data_add_prev riseV:&th fallV:&tl holdV:&tq];
        
        NSInteger delIdx = i - DAYS_VR;
        
        data_del = [kdataArr objectAtIndex:delIdx];
        data_del_prev = [kdataArr objectAtIndex:delIdx -1];
        [self t_calculateVRParmDelOneWithData:data_del prevData:data_del_prev riseV:&th fallV:&tl holdV:&tq];
        
        double tq_2 = tq / 2;
        YTSCFloat vr = 100*(th + tq_2)/(tl+tq_2);
        progress(i ,vr);
        
    }
    
    if (complete) {
        complete (targetRange,nil);
    }
}


#pragma mark - VR & VRMA

/**
 计算  VR & VRMA
 
 @param kdataArr 数据数组
 @param range 计算范围
 @param handles 计算结果容器
 @param complete 完成范围内计算回调
 */
+ (void)calculateVR:(NSArray<id<YT_StockKlineData>> *)kdataArr
              range:(NSRange)range
   handleUsingBlock:(id<YT_StockVRHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
           complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete {
    
    NSRange canUseRange = NSMakeRange(0, kdataArr.count);
    NSRange targetRange = NSIntersectionRange(canUseRange, range); // 求交集 same as YT_RangeIntersectsRange
    if (targetRange.length == 0) {
        if (complete) complete (targetRange,nil);
        return;
    }
    
    NSInteger fromIndex = targetRange.location;
    NSInteger toIndex =  fromIndex + targetRange.length;
    NSInteger i = fromIndex;
    
    NSInteger indexPartition =  [self minAccurateVRIndex];
    if (indexPartition > toIndex) indexPartition = toIndex;
    
    __block id<YT_StockVRHandle> handle;
    
    // 第一段
    for ( ; i < indexPartition ; i ++) { // i 最大 DAYS_VR
        handle = handles(i);
        handle.cache_VR = YTSCFLOAT_NULL;
        handle.cache_VR_MA6 = YTSCFLOAT_NULL;
    }
    
    if (i < toIndex) {
        [self calculateVR2:kdataArr range:NSMakeRange(i, toIndex - i) progress:^(NSUInteger location, YTSCFloat vr) {
             handle = handles(location);
             handle.cache_VR = vr;
        } complete:nil];
        
        NSInteger minHasMaIdx = [self minAccurateVRIndex] + DAYS_MAVR -1;
        
        // 第二段
        for ( ; i < toIndex && i < minHasMaIdx ; i ++) {
            handle = handles(i);
            handle.cache_VR_MA6 = YTSCFLOAT_NULL;
        }
        
        double sum = 0;
        if (i < toIndex) {
            sum = [self t_calculateSUMForm:i forthLeng:DAYS_MAVR handleUsingBlock:handles];
            handle = handles(i);
            handle.cache_VR_MA6 = sum / DAYS_MAVR;
            i ++;
        }
       
        // 第三段
        for ( ; i < toIndex ; i ++) {
            handle = handles(i);
            sum = sum - handles(i - DAYS_MAVR).cache_VR + handles(i).cache_VR;
            handle.cache_VR_MA6 = sum / DAYS_MAVR;;
        }
    }
    
    if (complete) {
        complete (targetRange,nil);
    }
  
}

#pragma mark - tool

/**
 TH:=SUM(IF(CLOSE>REF(CLOSE,1),VOL,0),N);
 TL:=SUM(IF(CLOSE<REF(CLOSE,1),VOL,0),N);
 TQ:=SUM(IF(CLOSE=REF(CLOSE,1),VOL,0),N);
 */
+ (void)t_calculateVRParm:(NSArray<id<YT_StockKlineData>> *)kdataArr
                  riseV:(YTSCFloat *)th
                  fallV:(YTSCFloat *)tl
                  holdV:(YTSCFloat *)tq
                    idx:(NSInteger)idx
                  forthCount:(NSInteger)forthCount {
    
   YTSCFloat vol_rise = 0, vol_fall = 0, vol_hold = 0;
   YTSCFloat vol_t = 0, curClose = 0, prevClose = 0;
    
   NSInteger minIdx = idx - forthCount;
   if (minIdx < 0) { //第一个值在 平 里，但这是不准确的
       id<YT_StockKlineData> data = [kdataArr objectAtIndex:0];
       vol_hold += data.yt_volumeOfTransactions;
       minIdx = 0;
   }
   for (NSInteger i = idx; i > minIdx ; i --) {
       id<YT_StockKlineData> data = [kdataArr objectAtIndex:i];
       id<YT_StockKlineData> prev_data = [kdataArr objectAtIndex:i -1];
       vol_t = data.yt_volumeOfTransactions;
       curClose = data.yt_closePrice;
       prevClose = prev_data.yt_closePrice;
       if (curClose > prevClose) {
           vol_rise += vol_t;
       }else if (curClose < prevClose) {
           vol_fall += vol_t;
       }else{
           vol_hold += vol_t;
       }
   }
    *th = vol_rise;
    *tl = vol_fall;
    *tq = vol_hold;
}

/// prev 是前一个的意思
+ (void)t_calculateVRParmAddOneWithData:(id<YT_StockKlineData>)data
                    prevData:(id<YT_StockKlineData>)prevData
                  riseV:(YTSCFloat *)th
                  fallV:(YTSCFloat *)tl
                  holdV:(YTSCFloat *)tq {
    YTSCFloat vol_t = data.yt_volumeOfTransactions;
    YTSCFloat curClose = data.yt_closePrice;
    YTSCFloat prevClose = prevData.yt_closePrice;
    if (curClose > prevClose) {
        *th  = *th + vol_t;
    }else if (curClose < prevClose) {
        *tl  = *tl + vol_t;
    }else{
        *tq  = *tq + vol_t;
    }
}

/// prev 是前一个的意思
+ (void)t_calculateVRParmDelOneWithData:(id<YT_StockKlineData>)data
                              prevData:(id<YT_StockKlineData>)prevData
                                 riseV:(YTSCFloat *)th
                                 fallV:(YTSCFloat *)tl
                                 holdV:(YTSCFloat *)tq {
    YTSCFloat vol_t = data.yt_volumeOfTransactions;
    YTSCFloat curClose = data.yt_closePrice;
    YTSCFloat prevClose = prevData.yt_closePrice;
    if (curClose > prevClose) {
        *th  = *th - vol_t;
    }else if (curClose < prevClose) {
        *tl  = *tl - vol_t;
    }else{
        *tq  = *tq - vol_t;
    }
}


+ (double)t_calculateSUMForm:(NSInteger)location forthLeng:(NSInteger)length handleUsingBlock:(id<YT_StockVRHandle> (^)(NSUInteger))handles{
    
    NSInteger min = location - length; // -1 ==> NSInteger
    //    if (min < 0) min = 0;
    double sum = 0.0;
    for (NSInteger i = location; i > min ; i --) {
        sum += handles(i).cache_VR;
    }
    return sum;
}


@end

NS_ASSUME_NONNULL_END

