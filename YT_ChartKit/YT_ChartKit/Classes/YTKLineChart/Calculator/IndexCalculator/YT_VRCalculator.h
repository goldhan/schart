//
//  YT_VRCalculator.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/29.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YT_KLineDataProtocol.h"
#import "YT_KlineCalculatorProtocol.h"

/**
 VR(26,6)
 
 TH:=SUM(IF(CLOSE>REF(CLOSE,1),VOL,0),N);
 TL:=SUM(IF(CLOSE<REF(CLOSE,1),VOL,0),N);
 TQ:=SUM(IF(CLOSE=REF(CLOSE,1),VOL,0),N);
 VR:100*(TH*2+TQ)/(TL*2+TQ);
 MAVR:MA(VR,M);
 
 TH赋值:如果收盘价>1日前的收盘价,返回成交量(手),否则返回0的N日累和 N->26
 TL赋值:如果收盘价<1日前的收盘价,返回成交量(手),否则返回0的N日累和
 TQ赋值:如果收盘价=1日前的收盘价,返回成交量(手),否则返回0的N日累和
 输出VR:100*(TH*2+TQ)/(TL*2+TQ)
 输出MAVR:VR的M日简单移动平均 M->6
 
 VR指标计算周期为26 MAVR指标对VR指标进行周期为6计算
 //     VR:100*(TH*2+TQ)/(TL*2+TQ); ?
 //     VR:100*(TH + TQ/2)/(TL+TQ/2) ？ 我们 KLineView 是这样的
 */

NS_ASSUME_NONNULL_BEGIN

@interface YT_VRCalculator : NSObject

#pragma mark - VR

/**
 可以计算出准确的 VR 指标的最小索引,重写可控制VR是否计算数据量不够的情况（0 - DAYS_VR-1）范围数据
 
 @return 最小索引
 */
+ (NSUInteger)minAccurateVRIndex;

+ (void)calculateVR:(NSArray<id<YT_StockKlineData>> *)kdataArr
              range:(NSRange)range
           progress:(void (NS_NOESCAPE ^)(NSUInteger location, YTSCFloat vr))progress
           complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete;

+ (void)calculateVR2:(NSArray<id<YT_StockKlineData>> *)kdataArr
               range:(NSRange)range
            progress:(void (NS_NOESCAPE ^)(NSUInteger location, YTSCFloat vr))progress
            complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete;


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
           complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete;
@end

NS_ASSUME_NONNULL_END
