//
//  YT_KLineChartStringFormat.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/6/8.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_KLineChartStringFormat.h"

#ifndef YTSCSTRWAN
#define YTSCSTRWAN @"万"
#endif

#ifndef YTSCSTRYI
#define YTSCSTRYI @"亿"
#endif

NS_ASSUME_NONNULL_BEGIN
/**
 历史问题 详解
 
 ########### ###########  ###########  ###########  ###########  ###########  ###########
 bIsGGQQ;        //是否为个股期权
 
 if (self.bIsGGQQ) {
     [NSString stringWithFormat:@"%.4f",(fZdcj->fValue)/10.0];
 } else {
     [NSString stringWithFormat:@"%.2f",fZdcj->fValue];
 }
 为什么要除 10 因为 个股期权 下发的 数据 要比 真正的数据 大 10 倍
 因为 KFloat 只有 2bit 表示小数位 只有最多表示 三位  bIsGGQQ 需要保留 4位小数 结果 😤 服务器下发 就把真实数据 * 10 再 * 1000 把
 nDigit 设为 3 （b11） 传过来了 [self adjustFloat] 转 float 是 只看 nDigit 为 3 ,self->fValue 就除于 1000,这就导致数据大了10倍 😤😤😤😤😤😤😤
 
 - (id)init:(int)value {
     self = [super init];
     if (nil != self) {
         self->nUnit = (value & 0x00000003);
         self->nDigit = ((value & 0x0000000c) >> 2);
         self->fValue = (value >> 4);
         [self adjustFloat];
     }
     return self;
 }
 ########### ###########  ###########  ###########  ###########  ###########  ###########
 

 */
@implementation YT_KLineChartStringFormat

/**
 float 转 字符串

 @param v 值
 @param unit 单位
 @param digit numberOfDecimalPlaces 小数位数
 @return 字符串
 */
+ (NSString *)floatToString:(double)v unit:(int)unit digit:(int)digit {
    
    NSString *format = [NSString stringWithFormat:@"%%.%dlf", digit];
    NSString *str = [NSString stringWithFormat:format, v];
    switch (unit) {
        case YTSC_TEN_THOUSAND:
            str = [str stringByAppendingString:[self unitWan]];
            break;
        case YTSC_HUNDRED_MILLION:
            str = [str stringByAppendingString:[self unitYi]];
            break;

        case YTSC_NUMBER:
        default:
            break;
    }
    return str;
}

/**
 浮点型转string 例子一个
 */
+ (NSString *)floatToStringAutoUnit:(double)v adjuetDigit:(int)digit max:(double)max min:(double)min{
    int unitTa = YTSC_NUMBER;
    double vTa = [self adjustFloatWithUnit:v unit:&unitTa];
    int digitTa = [self adjustDigit:digit span:max - min limitDigit:3];
    
    if (vTa < 1) {
        int minDigitTa = [self digitForWorkSpace:1 afloat:vTa limitMaxDigit:4];
        digitTa = minDigitTa > digitTa ? minDigitTa : digitTa;
    }
    return [self floatToString:vTa unit:unitTa digit:digitTa];
}

//+(void)load {
//    NSString * digit = [self floatToStringAutoUnit:0.001 adjuetDigit:2 max:0.2 min:0.0001];
//    NSLog(@"digit %@",digit); //输出 digit 0.001
//
//    NSString * digit2 = [self floatToStringAutoUnit:100000.213 adjuetDigit:2 max:100000.213 min:100000.2];
//    NSLog(@"digit %@",digit2); //输出 digit 100.0000万
//}

/**
 一个 afloat 在确定 有效位数 的情况下求 有效的整数位 和 有效的小数位
 当 整数位 >0 ,小数位 = 有效位数 - 有效的整数位 。否则 小数位 = 有效位数 + 0. 后紧跟着的0的个数
 @param workSpace 有效位数
 @param afloat 值
 @param units 有效的整数位
 @param digit 有效的小数位
 */
+ (void)workSpace:(int)workSpace afloat:(double)afloat units:(nullable int *)units digit:(int *)digit {
    
    int work = 0; // 有效的整数位 / 有效的小数位
    int taInt = (int)afloat;
    float taFlaot  = afloat - taInt;
    
    while (taInt > 0 && work < workSpace) {
        taInt /= 10;
        work ++;  //取得整数部分有效数
    }
    if (work > 0) {
        if (units != NULL) *units = work;
        *digit = (workSpace - work);
        return;
    }
    
    do {
        taFlaot *= 10;
        work ++;
    } while (taFlaot < 1 && work < 37);//float 最大位数
    work --; //0. 后紧跟着的0的个数
    work += workSpace;
    
    if (units != NULL) *units = 0;
    *digit = work;
}

+ (int)digitForWorkSpace:(int)workSpace afloat:(double)afloat limitMaxDigit:(int)maxDigit {

    int units_work = 0; // 有效的整数位
    int digit_work = 0; // 有效的小数位
    
    int taInt = (int)afloat;
    float taFlaot  = afloat - taInt;
    
    while (taInt > 0 && units_work < workSpace) {
        taInt /= 10;
        units_work ++;  //取得整数部分有效数
    }
    
    if (units_work > 0) {
        digit_work = workSpace - units_work;
        if (digit_work > maxDigit) {
            return maxDigit;
        }
        return digit_work;
    }
    
    do {
        taFlaot *= 10;
        digit_work ++;
    } while (taFlaot < 1 && digit_work <= maxDigit);
    digit_work --; //0. 后紧跟着的0的个数
    digit_work += workSpace;
    
    digit_work = workSpace - units_work;
    if (digit_work > maxDigit) {
        return maxDigit;
    }
    return digit_work;
}


/**
 根据最大最小调整小数位
 
 @param digit 默认小数位
 @param span 最大值 - 最小值 跨度
 @param limitDigit 最大值 - 1
 @return 合适的小数位
 */
+ (int)adjustDigit:(int)digit span:(double)span limitDigit:(int)limitDigit{
    if (digit > limitDigit) return digit; // 最大小数位
    float kuduStd = powf(0.1, digit) * 100;
    if ( span < kuduStd) {
        return [self adjustDigit:++digit span:span limitDigit:limitDigit];
    }
    return digit;
}

+ (int)adjustDigitThis:(double)v digit:(int)digit span:(double)span maxDigit:(int)maxDigit{

    if(digit >= maxDigit) return digit;
    
    int digitTa = [self adjustDigit:digit span:span limitDigit:maxDigit -1];
    if (v >= 1) return digitTa;
    int minDigitTa = [self digitForWorkSpace:1 afloat:v limitMaxDigit:maxDigit];
    digitTa = minDigitTa > digitTa ? minDigitTa : digitTa;
    return digitTa;
}

//取单位
+ (int)stringFormatGetUnits:(double)v {
    if (v > 100000000)
        return YTSC_HUNDRED_MILLION;
    else if  (v > 10000)
        return YTSC_TEN_THOUSAND;
    else
        return YTSC_NUMBER;
}

+ (double)adjustFloatWithUnit:(double)v unit:(int *)unit {
    if (v > 100000000){
        * unit = YTSC_HUNDRED_MILLION;
        return  v / 100000000 ;
    }else if  (v > 10000){
         * unit = YTSC_TEN_THOUSAND;
        return v / 10000 ;
    }else{
        * unit = YTSC_NUMBER;
        return v ;
    }
}

+ (double)adjustFloatWithUnit:(double)v {
    if (v > 100000000)
        return  v / 100000000;
    else if  (v > 10000)
        return v / 10000;
    else
        return v;
}


+ (NSString *)unitWan {
    return YTSCSTRWAN;
}

+ (NSString *)unitYi {
    return YTSCSTRYI;
}


@end

NS_ASSUME_NONNULL_END
