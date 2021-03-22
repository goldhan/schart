//
//  YT_BIASCalculator.h
//  KDS_Phone
//
//  Created by yangjinming on 2018/5/30.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YT_KLineDataProtocol.h"
#import "YT_KlineCalculatorProtocol.h"

/**
 BIAS（6,12,24）
 乖离率=（当日收盘价-N日内移动平均价）/N日内移动平均价╳100%
 5日乖离率=（当日收盘价-5日内移动平均价）/5日内移动平均价╳100%
 式中的N日按照选定的移动平均线日数确定，一般定为5，10。
 通用公式函数：
 BIAS6 : (CLOSE-MA(CLOSE,6））/MA(CLOSE,6）*100;
 BIAS12 : (CLOSE-MA(CLOSE,12））/MA(CLOSE,12）*100;
 BIAS24 : (CLOSE-MA(CLOSE,24））/MA(CLOSE,24）*100;
 */

NS_ASSUME_NONNULL_BEGIN

@interface YT_BIASCalculator : NSObject

+ (void)calculateBIAS:(NSArray<id<YT_StockKlineData>> *)kdataArr
               range:(NSRange)range
    handleUsingBlock:(id<YT_StockBIASHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
            progress:(void (NS_NOESCAPE ^)(NSUInteger location, id<YT_StockBIASHandle> result))progress
            complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete;

@end

NS_ASSUME_NONNULL_END
