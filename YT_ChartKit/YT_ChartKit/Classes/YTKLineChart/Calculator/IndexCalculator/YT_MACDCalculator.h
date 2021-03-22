//
//  YT_MACDCalculator.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/29.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YT_KLineDataProtocol.h"
#import "YT_KlineCalculatorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface YT_MACDCalculator : NSObject

/*  MACD说明
 公式
 DIF:EMA(CLOSE,SHORT)-EMA(CLOSE,LONG);
 DEA:EMA(DIF,MID);
 MACD:(DIF-DEA)*2,COLORSTICK;
 
 备注
 输出DIF:收盘价的SHORT日指数移动平均-收盘价的LONG日指数移动平均
 输出DEA:DIF的MID日指数移动平均
 输出平滑异同平均:(DIF-DEA)*2,COLORSTICK
 
 注意:需要从头算（从 index 0 开始算）
 */

#pragma mark - MACD

/**
 计算 MACD
 第一个方法 handle 既是 参数传递容器 又是 计算结果传递容器
 第二个方法 prevHandle 是 参数传递容器 , rsHandle 是 计算结果传递容器 （prevHandle 和 rsHandle 可以是同一个）
 @param close 收盘价
 @param handle 参数传递容器以及计算结果传递容器
 */
+ (void)calculateMACDWithClose:(YTSCFloat)close handleBy:(id<YT_StockMACDHandle>)handle;
+ (void)calculateMACDWithClose:(YTSCFloat)close prevHandle:(id<YT_StockMACDHandle>)prevHandle rsHandle:(id<YT_StockMACDHandle>)handle;

/**
 计算 MACD
 
 @param kdataArr 数据数组
 @param range 计算范围
 @param handle 计算前置参数 注意：progress中的参数result 和 handle 是同一个对象
 @param progress 计算结果
 @param complete 完成范围内计算回调
 */
+ (void)calculateMACD:(NSArray<id<YT_StockKlineData>> *)kdataArr
                range:(NSRange)range
             handleBy:(id<YT_StockMACDHandle>)handle
             progress:(void (NS_NOESCAPE ^)(NSUInteger location, id<YT_StockMACDHandle> result))progress
             complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete;

+ (void)calculateMACD:(NSArray<id<YT_StockKlineData>> *)kdataArr
                range:(NSRange)range
     handleUsingBlock:(id<YT_StockMACDHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
             progress:(void (NS_NOESCAPE ^)(NSUInteger location, id<YT_StockMACDHandle> result))progress
             complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete;

@end

NS_ASSUME_NONNULL_END
