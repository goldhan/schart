//
//  YT_WRCalculator.h
//  KDS_Phone
//
//  Created by ChenRui Hu on 2018/6/1.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YT_KLineDataProtocol.h"
#import "YT_KlineCalculatorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface YT_WRCalculator : NSObject
/*  WR说明 威廉指标
 公式
 WR1:100*(HHV(HIGH,N)-CLOSE)/(HHV(HIGH,N)-LLV(LOW,N));
 WR2:100*(HHV(HIGH,N1)-CLOSE)/(HHV(HIGH,N1)-LLV(LOW,N1));
 
 备注
 输出WR1:100*(N日内最高价的最高值-收盘价)/(N日内最高价的最高值-N日内最低价的最低值)
 输出WR2:100*(N1日内最高价的最高值-收盘价)/(N1日内最高价的最高值-N1日内最低价的最低值)
 
 目前公司上线的是通用的10日、6日，既：WR1 是 10 日，WR2 是 6 日
 */

/**
计算 WR

@param close 收盘价
@param Hn    N日内最高价
@param Ln    N日内最低价
@param wr    计算的最终结果
*/
+ (void)calculateWRWithClose:(YTSCFloat)close
                          Hn:(YTSCFloat)Hn
                          Ln:(YTSCFloat)Ln
                          WR:(YTSCFloat *)wr;

/**
 计算 WR
 
 @param kdataArr 数据数组
 @param range 计算范围
 @param handles 计算前置参数
 @param progress 计算结果
 @param complete 完成范围内计算回调
 */
+ (void)calculateWR:(NSArray<id<YT_StockKlineData>> *)kdataArr
              range:(NSRange)range
   handleUsingBlock:(id<YT_StockWRHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
           progress:(void (NS_NOESCAPE ^)(NSUInteger location, id<YT_StockWRHandle> result))progress
           complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete;

@end

NS_ASSUME_NONNULL_END
