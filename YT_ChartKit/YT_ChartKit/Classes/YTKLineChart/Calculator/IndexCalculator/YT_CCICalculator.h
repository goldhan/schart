//
//  YT_CCICalculator.h
//  KDS_Phone
//
//  Created by yangjinming on 2018/5/31.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YT_KLineDataProtocol.h"
#import "YT_KlineCalculatorProtocol.h"

/**
 CCI（14）
 顺势指标CCI也包括日CCI指标、周CCI指标、年CCI指标以及分钟CCI指标等很多种类型。
 通用公式函数：
 第一种计算过程如下
 CCI（N日）=（TP－MA）÷MD÷0.015
 其中，TP=（最高价+最低价+收盘价）÷3
 MA=近N日收盘价的累计之和÷N
 MD=近N日（MA－收盘价）的累计之和÷N
 0.015为计算系数，N为计算周期
 第二种计算过程如下
 CCI（N日）= (TP-MA(TP,N))/(0.015*AVEDEV(TP,N));
 TP=（最高价+最低价+收盘价）÷3
 MA=近N日中价的累计之和÷N
 AVEDEV= 近N日(中价与MA之差绝对值)累计之和÷N
 0.015为计算系数，N为计算周期
 */

NS_ASSUME_NONNULL_BEGIN

@interface YT_CCICalculator : NSObject
/**
 * 采用第二种计算公式
 */
+ (void)calculateCCI:(NSArray<id<YT_StockKlineData>> *)kdataArr
                range:(NSRange)range
     handleUsingBlock:(id<YT_StockCCIHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
             progress:(void (NS_NOESCAPE ^)(NSUInteger location, id<YT_StockCCIHandle> result))progress
             complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete;
@end

NS_ASSUME_NONNULL_END
