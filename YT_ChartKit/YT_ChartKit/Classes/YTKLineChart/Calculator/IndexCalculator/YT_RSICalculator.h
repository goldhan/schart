//
//  YT_RSICalculator.h
//  KDS_Phone
//
//  Created by yangjinming on 2018/6/4.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YT_KLineDataProtocol.h"
#import "YT_KlineCalculatorProtocol.h"

/**
 RSI（6,12,24）强弱指标
 强弱指标理论认为，任何市价的大涨或大跌，均在0-100之间变动，根据常态分配，认为RSI值多在30-70之间变动，通常80甚至90时被认为市场已到达超买状态，至此市场价格自然会回落调整。当价格低跌至30以下即被认为是超卖状态，市价将出现反弹回升。
 RSI:= SMA(MAX(Close-LastClose,0),N,1)/SMA(ABS(Close-LastClose),N,1)*100
 
 五种用途
 1) 顶点及底点 70 及30 通常为超买及超卖讯号。
 2) 分歧（或背离）， 当市况创下新高 ( 低 ) 但RSI 并不处于新高（低），这通常表明市场将出现反转。
 3) 支撑及阻力 ，RSI 能显示支持及阻力位，有时比价格图更能清晰反应支持及阻力。
 4) 价格趋势形态 与价格图相比，价格趋势形态如双顶及头肩在 RSI 上表现更清晰。
 5) 峰回路转 当 RSI 突破 ( 超过前高或低点 ) 时，这可能表示价格将有突变与其它指标相同， RSI 需与其它指标配合使用，不能单独产生讯号，价格的确认是决定入市价位的关键。
 
 注意要从头算起 从index0 开始算 也就是说要算完 0~60 才能算 61~100
 算的是加权平均数
 */

NS_ASSUME_NONNULL_BEGIN
struct YT_RSICalculateArgv {
    double SMAMAX_RSI6;
    double SMAMAX_RSI12;
    double SMAMAX_RSI24;
    
    double SMAABS_RSI6;
    double SMAABS_RSI12;
    double SMAABS_RSI24;
};
typedef struct YT_RSICalculateArgv YT_RSICalculateArgv;

NS_INLINE void YT_RSICalculateArgvResetZero (YT_RSICalculateArgv *alculateArgv){
    alculateArgv->SMAMAX_RSI6 = 0;
    alculateArgv->SMAMAX_RSI12 = 0;
    alculateArgv->SMAMAX_RSI24 = 0;
    
    alculateArgv->SMAABS_RSI6 = 0;
    alculateArgv->SMAABS_RSI12 = 0;
    alculateArgv->SMAABS_RSI24 = 0;
}

NS_INLINE void YT_RSICalculateArgvReset (YT_RSICalculateArgv *alculateArgv, double SMAMAX_RSI6, double SMAMAX_RSI12, double SMAMAX_RSI24, double SMAABS_RSI6, double SMAABS_RSI12, double SMAABS_RSI24){
    alculateArgv->SMAMAX_RSI6 = SMAMAX_RSI6;
    alculateArgv->SMAMAX_RSI12 = SMAMAX_RSI12;
    alculateArgv->SMAMAX_RSI24 = SMAMAX_RSI24;
    
    alculateArgv->SMAABS_RSI6 = SMAABS_RSI6;
    alculateArgv->SMAABS_RSI12 = SMAABS_RSI12;
    alculateArgv->SMAABS_RSI24 = SMAABS_RSI24;
}


@interface NSValue (YT_RSICalculateArgv)
+ (NSValue *)valueWithYT_RSICalculateArgv:(YT_RSICalculateArgv)calculateArgv;
- (YT_RSICalculateArgv)YT_RSICalculateArgvValue;
@end

@interface YT_RSICalculator : NSObject
+ (void)calculateRSI:(NSArray<id<YT_StockKlineData>> *)kdataArr
            prevArgv:(YT_RSICalculateArgv *)prevArgv
               range:(NSRange)range
    handleUsingBlock:(id<YT_StockRSIHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
            complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete;

#pragma mark -

/*range.loc always 0 */
//+ (void)calculateRSI:(NSArray<id<YT_StockKlineData>> *)kdataArr
//               range:(NSRange)range
//    handleUsingBlock:(id<YT_StockRSIHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
//            progress:(void (NS_NOESCAPE ^)(NSUInteger location, id<YT_StockRSIHandle> result))progress
//            complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete;
@end

NS_ASSUME_NONNULL_END
