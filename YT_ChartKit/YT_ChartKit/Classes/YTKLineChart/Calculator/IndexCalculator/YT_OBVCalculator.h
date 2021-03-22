//
//  YT_OBVCalculator.h
//  KDS_Phone
//
//  Created by zhanghao on 2018/6/6.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YT_KLineDataProtocol.h"
#import "YT_KlineCalculatorProtocol.h"

/**
 VA赋值:如果收盘价>1日前的收盘价,返回成交量(手),否则返回-成交量(手)
 输出OBV:如果收盘价=1日前的收盘价,返回0,否则返回VA的历史累和
 输出MAOBV:OBV的M日简单移动平均
 
 注意:OBV 的计算类似MACD 需要从头算（从 index 0 开始算）
 */
@interface YT_OBVCalculator : NSObject

+ (void)calculateOBV:(NSArray<id<YT_StockKlineData>> *)kdataArr
               range:(NSRange)range
    handleUsingBlock:(id<YT_StockOBVHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
            complete:(void (NS_NOESCAPE ^)(NSRange rsRange, NSError * error))complete;

@end

