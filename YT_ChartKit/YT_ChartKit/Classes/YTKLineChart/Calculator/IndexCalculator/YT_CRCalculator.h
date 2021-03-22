//
//  YT_CRCalculator.h
//  KDS_Phone
//
//  Created by ChenRui Hu on 2018/6/1.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YT_KLineDataProtocol.h"
#import "YT_KlineCalculatorProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@interface YT_CRCalculator : NSObject
/*  CR说明 中间意愿指标
 公式
 前一天最高价与最低价的中间值：MID = REF(HIGH+LOW,1)/2;
 当天最高与MID差与0取较大值：MAX1 = MAX(0,HIGH-MID)
 MID与当天最低差与0取较大值：MAX2 = MAX(0,MID-LOW)
 MAX1的N天和：SUM1 = SUM(MAX1,N)
 MAX2的N天和：SUM2 = SUM(MAX2,N)
 CR = SUM1 / SUM2 * 100;
 
 M1天的CR平均值：MA1 = MA(CR,M1)
 M2天的CR平均值：MA2 = MA(CR,M2)
 M3天的CR平均值：MA3 = MA(CR,M3)
 M4天的CR平均值：MA4 = MA(CR,M4)
 
 M1/2.5+1 天前的MA1：REF(MA1,M1/2.5+1);
 M2/2.5+1 天前的MA2：REF(MA2,M2/2.5+1);
 M3/2.5+1 天前的MA3：REF(MA3,M3/2.5+1);
 M4/2.5+1 天前的MA4：REF(MA4,M4/2.5+1);
 
 备注
 输出CR: N = 26 （最多26天的和）
 输出M1: M1 = 10
 输出M2: M2 = 20
 输出M3: M3 = 40
 输出M4: M4 = 62
 
 目前公司线上是有bug的，上面显示 CR(26,10,20,40,62)，实际下面画的线只有 CR、M1、M2
 
 注意:需要从头算（从 index 0 开始算）因为算法包含CR的平均值的计算 ，平均值的计算和之前算的CR有关
 // 从头开始算简单 另外能保证算CR ma时 之前的CR都是已经有计算结果了的
 
 例如计算Range 5 ~ 100 ; idx 5 的 ma6 和之前 0~5的CR有关 但下面算法并不会从算之前的 CR 通过handles取之前算得的CR结果
 */

/**
 计算 CR
 
 @param kdataArr 数据数组
 @param range 计算范围
 @param handles 计算前置参数以及计算结果容器
 @param complete 完成范围内计算回调
 */
+ (void)calculateCR:(NSArray<id<YT_StockKlineData>> *)kdataArr
              range:(NSRange)range
   handleUsingBlock:(id<YT_StockCRHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
           complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete;

@end
NS_ASSUME_NONNULL_END
