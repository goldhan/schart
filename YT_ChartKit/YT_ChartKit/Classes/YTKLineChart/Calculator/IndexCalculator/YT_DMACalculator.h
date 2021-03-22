//
//  YT_DMACalculator.h
//  KDS_Phone
//
//  Created by ChenRui Hu on 2018/5/30.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YT_KLineDataProtocol.h"
#import "YT_KlineCalculatorProtocol.h"

@interface YT_DMACalculator : NSObject

NS_ASSUME_NONNULL_BEGIN
/*  DMA说明 平行线差指标
 公式
 DIF:MA(CLOSE,N1)-MA(CLOSE,N2);
 DIFMA:MA(DIF,M);
 
 备注
 输出DIF:收盘价的N1日简单移动平均-收盘价的N2日简单移动平均
 输出DIFMA:DIF的M日简单移动平均
 */

/**
 计算 DMA
 
 @param kdataArr 数据数组
 @param range 计算范围
 @param handles 计算前置参数 注意：progress中的参数result 和 handle 是同一个对象
 @param complete 完成范围内计算回调
 */
+ (void)calculateDMA:(NSArray<id<YT_StockKlineData>> *)kdataArr
               range:(NSRange)range
    handleUsingBlock:(id<YT_StockDMAHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
            complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete;

@end

NS_ASSUME_NONNULL_END
