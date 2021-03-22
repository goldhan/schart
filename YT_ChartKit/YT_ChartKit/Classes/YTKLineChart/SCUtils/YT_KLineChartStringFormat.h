//
//  YT_KLineChartStringFormat.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/6/8.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>

#define YTSC_NUMBER              0   //个
#define YTSC_TEN_THOUSAND        4   //万
#define YTSC_HUNDRED_MILLION     8   //亿

NS_ASSUME_NONNULL_BEGIN
@interface YT_KLineChartStringFormat : NSObject

/**
 float 转 字符串
 
 @param v 值
 @param unit 单位
 @param digit numberOfDecimalPlaces 小数位数
 @return 字符串
 */
+ (NSString *)floatToString:(double)v unit:(int)unit digit:(int)digit;

/**
 浮点型转string 例子一个
 */
+ (NSString *)floatToStringAutoUnit:(double)v adjuetDigit:(int)digit max:(double)max min:(double)min;

/**
 根据最大最小调整小数位
 
 @param digit 默认小数位
 @param span 最大值 - 最小值 跨度
 @param limitDigit 最大值 - 1
 @return 合适的小数位
 */
+ (int)adjustDigit:(int)digit span:(double)span limitDigit:(int)limitDigit;
+ (int)adjustDigitThis:(double)v digit:(int)digit span:(double)span maxDigit:(int)maxDigit;

//取单位
+ (int)stringFormatGetUnits:(double)v;
+ (double)adjustFloatWithUnit:(double)v;
+ (double)adjustFloatWithUnit:(double)v unit:(int *)unit;

+ (NSString *)unitWan;
+ (NSString *)unitYi;

/**
 一个 afloat 在确定 有效位数 的情况下求 有效的整数位 和 有效的小数位
 当 整数位 >0 ,小数位 = 有效位数 - 有效的整数位 。否则 小数位 = 有效位数 + 0. 后紧跟着的0的个数
 @param workSpace 有效位数
 @param afloat 值
 @param units 有效的整数位
 @param digit 有效的小数位
 */
+ (void)workSpace:(int)workSpace afloat:(double)afloat units:(nullable int *)units digit:(int *)digit;
+ (int)digitForWorkSpace:(int)workSpace afloat:(double)afloat limitMaxDigit:(int)maxDigit;
@end

NS_ASSUME_NONNULL_END;
