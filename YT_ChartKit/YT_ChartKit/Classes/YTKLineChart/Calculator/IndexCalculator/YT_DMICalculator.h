//
//  YT_DMICalculator.h
//  KDS_Phone
//
//  Created by yangjinming on 2018/6/1.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YT_KLineDataProtocol.h"
#import "YT_KlineCalculatorProtocol.h"

/**
 DMI（14,6）
 DMI指标的计算方法和过程比较复杂，它涉及到DM、TR、DX等几个计算指标和+DI（即PDI，下同）、-DI（即MDI，下同）、ADX和ADXR等4个研判指标的运算。
 1、计算的基本程序
 以计算日DMI指标为例，其运算的基本程序主要为：
 （1）按一定的规则比较每日股价波动产生的最高价、最低价和收盘价，计算出每日股价的波动的真实波幅、上升动向值、下降动向值TR、+DI、-DI，在运算基准日基础上按一定的天数将其累加，以求n日的TR、+DM和DM值。
 （2）将n日内的上升动向值和下降动向值分别除以n日内的真实波幅值，从而求出n日内的上升指标+DI和下降指标-DI。
 （3）通过n内的上升指标+DI和下降指标-DI之间的差和之比，计算出每日的动向值DX。
 （4）按一定的天数将DX累加后平均，求得n日内的平均动向值ADX。
 （5）再通过当日的ADX与前面某一日的ADX相比较，计算出ADX的评估数值ADXR。
 2、计算的具体过程
 （1）计算当日动向值
 动向指数的当日动向值分为上升动向、下降动向和无动向等三种情况，每日的当日动向值只能是三种情况的一种。
 A、上升动向（+DM）
 +DM代表正趋向变动值即上升动向值，其数值等于当日的最高价减去前一日的最高价，如果<=0 则+DM=0。
 B、下降动向（-DM）
 ﹣DM代表负趋向变动值即下降动向值，其数值等于前一日的最低价减去当日的最低价，如果<=0 则-DM=0。注意-DM也是非负数。
 再比较+DM和-DM，较大的那个数字保持，较小的数字归0。
 C、无动向
 无动向代表当日动向值为“零”的情况，即当日的+DM和﹣DM同时等于零。有两种股价波动情况下可能出现无动向。一是当当日的最高价低于前一日的最高价并且当日的最低价高于前一日的最低价，二是当上升动向值正好等于下降动向值。
 （2）计算真实波幅（TR）
 TR代表真实波幅，是当日价格较前一日价格的最大变动值。取以下三项差额的数值中的最大值（取绝对值）为当日的真实波幅：
 A、当日的最高价减去当日的最低价的价差。
 B、当日的最高价减去前一日的收盘价的价差。
 C、当日的最低价减去前一日的收盘价的价差。
 TR是A、B、C中的数值最大者
 （3）计算方向线DI
 方向线DI是衡量股价上涨或下跌的指标，分为“上升指标”和“下降指标”。在有的股市分析软件上，+DI代表上升方向线，-DI代表下降方向线。其计算方法如下：
 +DI=（+DM÷TR）×100
 -DI=（-DM÷TR）×100
 要使方向线具有参考价值，则必须运用平滑移动平均的原理对其进行累积运算。以12日作为计算周期为例，先将12日内的+DM、-DM及TR平均化，所得数值分别为+DM12，-DM12和TR12，具体如下：
 +DI（12）=（+DM12÷TR12）×100
 -DI（12）=（-DM12÷TR12）×100
 随后计算第13天的+DI12、-DI12或TR12时，只要利用平滑移动平均公式运算即可。
 上升或下跌方向线的数值永远介于0与100之间。
 （4）计算动向平均数ADX
 依据DI值可以计算出DX指标值。其计算方法是将+DI和—DI间的差的绝对值除以总和的百分比得到动向指数DX。由于DX的波动幅度比较大，一般以一定的周期的平滑计算，得到平均动向指标ADX。具体过程如下：
 DX=(DI DIF÷DI SUM) ×100
 其中，DI DIF为上升指标和下降指标的差的绝对值
 DI SUM为上升指标和下降指标的总和
 ADX就是DX的一定周期n的移动平均值。
 （5）计算评估数值ADXR
 在DMI指标中还可以添加ADXR指标，以便更有利于行情的研判。
 ADXR的计算公式为：
 ADXR=（当日的ADX+前n日的ADX）÷2
 n为选择的周期数
 和其他指标的计算一样，由于选用的计算周期的不同，DMI指标也包括日DMI指标、周DMI指标、月DMI指标年DMI指标以及分钟DMI指标等各种类型。经常被用于股市研判的是日DMI指标和周DMI指标。虽然它们的计算时的取值有所不同，但基本的计算方法一样。另外，随着股市软件分析技术的发展，投资者只需掌握DMI形成的基本原理和计算方法，无须去计算指标的数值，更为重要的是利用DMI指标去分析、研判股票行情
 */

NS_ASSUME_NONNULL_BEGIN

@interface YT_DMICalculator : NSObject
+ (void)calculateDMI:(NSArray<id<YT_StockKlineData>> *)kdataArr
               range:(NSRange)range
    handleUsingBlock:(id<YT_StockDMIHandle> (NS_NOESCAPE ^)(NSUInteger idx))handles
            complete:(nullable void (NS_NOESCAPE ^)(NSRange rsRange, NSError * _Nullable error))complete;
@end

NS_ASSUME_NONNULL_END
