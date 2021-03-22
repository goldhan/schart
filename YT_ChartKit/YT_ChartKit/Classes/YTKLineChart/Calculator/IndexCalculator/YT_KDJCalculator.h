//
//  YT_KDJCalculator.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/29.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YT_KLineDataProtocol.h"
#import "YT_KlineCalculatorProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface YT_KDJCalculator : NSObject

// KDJ 计算公式说明
//RSV:=(CLOSE-LLV(LOW,N))/(HHV(HIGH,N)-LLV(LOW,N))*100;
//K:SMA(RSV,M1,1);
//D:SMA(K,M2,1);
//J:3*K-2*D;
//
//RSV赋值:(收盘价-N日内最低价的最低值)/(N日内最高价的最高值-N日内最低价的最低值)*100
//输出K:RSV的M1日[1日权重]移动平均
//输出D:K的M2日[1日权重]移动平均
//输出J:3*K-2*D

#pragma mark - KDJ

+ (void)calculateKDJ:(NSArray<id<YT_StockKlineData>> *)kdataArr
               range:(NSRange)range
    handleUsingBlock:(id<YT_StockKDJHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
            progress:(void (NS_NOESCAPE ^)(NSUInteger location, id<YT_StockKDJHandle> result))progress
            complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete;

@end

NS_ASSUME_NONNULL_END
