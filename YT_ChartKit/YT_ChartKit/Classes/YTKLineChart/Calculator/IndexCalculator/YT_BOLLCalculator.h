//
//  YT_BOLLCalculator.h
//  KDS_Phone
//
//  Created by yangjinming on 2018/6/4.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YT_KLineDataProtocol.h"
#import "YT_KlineCalculatorProtocol.h"

/**
 BOLL 布林线
 在所有的指标计算中，BOLL指标的计算方法是最复杂的之一，其中引进了统计学中的标准差概念，涉及到中轨线（MB）、上轨线（UP）和下轨线（DN）的计算。另外，和其他指标的计算一样，由于选用的计算周期的不同，BOLL指标也包括日BOLL指标、周BOLL指标、月BOLL指标年BOLL指标以及分钟BOLL指标等各种类型。经常被用于股市研判的是日BOLL指标和周BOLL指标。虽然它们的计算时的取值有所不同，但基本的计算方法一样。
 
         中轨线=N日的移动平均线
         上轨线=中轨线+两倍的标准差
         下轨线=中轨线－两倍的标准差
     日BOLL指标的计算过程
     1）计算MA
     MA=N日内的收盘价之和÷N
     2）计算标准差MD
     MD= N日的（C－MA）的两次方之和除以（N-1） 的 平方根 （除于N-1因为是样本方差）
     3）计算MB、UP、DN线
     MB = MA  。。。 MB 的算法有很多可以直接等于 可以 是MA的N日平均然后开平方根，我们这里直接等于
     UP=MB + p×MD
     DN=MB - p×MD
     p间隔宽度倍数系数 一般为 2
 */

NS_ASSUME_NONNULL_BEGIN

@interface YT_BOLLCalculator : NSObject
+ (void)calculateBOLL:(NSArray<id<YT_StockKlineData>> *)kdataArr
               range:(NSRange)range
    handleUsingBlock:(id<YT_StockBOLLHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
            complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete;
@end

NS_ASSUME_NONNULL_END
