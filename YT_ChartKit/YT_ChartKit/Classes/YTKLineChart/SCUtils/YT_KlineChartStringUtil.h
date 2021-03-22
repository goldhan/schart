//
//  YT_KlineChartStringUtil.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/6/15.
//  Copyright © 2018年 kds. All rights reserved.
//

#ifndef YT_KlineChartStringUtil_h
#define YT_KlineChartStringUtil_h

#ifndef YT_TEXT_ADJUST_DIGIT_READY
#define YT_TEXT_ADJUST_DIGIT_READY 1
#endif

//#if __has_include("YT_KLineChartStringFormat.h")
//#import "YT_KLineChartStringFormat.h"
//#endif

#ifndef YT_TEXT_ADJUST_DIGIT

#if defined(YT_TEXT_ADJUST_DIGIT_READY) && YT_TEXT_ADJUST_DIGIT_READY && __has_include("YT_KLineChartStringFormat.h")
#import "YT_KLineChartStringFormat.h"
#define YT_TEXT_ADJUST_DIGIT(aFloat, aDigit, aSpan) ([YT_KLineChartStringFormat adjustDigitThis:(aFloat) digit:(aDigit) span:(aSpan) maxDigit:3])
#else
#define YT_TEXT_ADJUST_DIGIT(aFloat, aDigit, aSpan) ((aFloat) > (aSpan) ? (aDigit) : (aDigit))
#endif

#endif

struct YTFloatFormat {
    int decimalPlaces;  ///<  文字推荐显示小数位数 一般 2 ~ 4
    int units;          ///< 文字推荐显示单位 0 个 4 万 8 亿 （整数位 0 的个数）
};
typedef struct YTFloatFormat YT_FloatFormat; ///< 浮点型推荐显示格式

/**
 * 构造函数
 */
CG_INLINE YT_FloatFormat
YTFloatFormatMake(int decimalPlaces, int units) {
    YT_FloatFormat floatFormat;
    floatFormat.decimalPlaces = decimalPlaces;
    floatFormat.units = units;
    return floatFormat;
}

CG_INLINE YT_FloatFormat
YTFloatFormatDefault() {
    YT_FloatFormat floatFormat;
    floatFormat.decimalPlaces = 2;
    floatFormat.units = 0;
    return floatFormat;
}

#endif /* YT_KlineChartStringUtil_h */
