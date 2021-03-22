//
//  YT_KLineDataProtocol.h
//  YT_Phone
//
//  Created by yt_liyanshan on 2018/5/14.
//  Copyright © 2018年 kds. All rights reserved.
//

#ifndef YT_KLineDataProtocol_h
#define YT_KLineDataProtocol_h

#pragma mark - YTSCFloat

#import "YT_StockChartProtocol.h"

#pragma mark - YT_StockKlineData

@protocol YT_StockKlineData

/// 日期 yyyyMMddHHmmss
//@property(nonatomic, readonly) NSString* yt_DateString;
//@property(nonatomic, readonly) NSString* yt_DateFormate;

/// 时分秒 HHmmss
@property(nonatomic, readonly) int32_t yt_DateHms;
@property(nonatomic, readonly) BOOL hasNTime;
//@property(nonatomic, readonly) NSString* yt_DateHmsString;
//@property(nonatomic, readonly) NSString* yt_DateHmsFormate;

/// 年月日 yyyyMMdd
@property(nonatomic, readonly) int32_t yt_DateYmd;
@property(nonatomic, readonly) BOOL hasNDate;
//@property(nonatomic, readonly) NSString* yt_DateYmdString;
//@property(nonatomic, readonly) NSString* yt_DateYmdFormate;

///昨日收盘价
@property(nonatomic, readonly) YTSCFloat yt_closePriceYesterday;
@property(nonatomic, readonly) BOOL hasNYclose;

///收盘价
@property(nonatomic, readonly) YTSCFloat yt_closePrice; //usualness
@property(nonatomic, readonly) BOOL hasNClose;

///开盘价
@property(nonatomic, readonly) YTSCFloat yt_openPrice; //usualness
@property(nonatomic, readonly) BOOL hasNOpen;

///最高成交
@property(nonatomic, readonly) YTSCFloat yt_highPrice; //usualness
@property(nonatomic, readonly) BOOL hasNZgcj;

///最低成交
@property(nonatomic, readonly) YTSCFloat yt_lowPrice; //usualness
@property(nonatomic, readonly) BOOL hasNZdcj;

/////涨跌幅
//@property(nonatomic, readonly) YTSCFloat yt_zdf;
//@property(nonatomic, readonly) BOOL hasNZdf;
//
/////成交金额
//@property(nonatomic, readonly) YTSCFloat yt_cjje;
//@property(nonatomic, readonly) BOOL hasNCjje;

///成交数量
@property(nonatomic, readonly) YTSCFloat yt_volumeOfTransactions; //usualness
@property(nonatomic, readonly) BOOL hasNCjss;

/////持仓量
//@property(nonatomic, readonly) YTSCFloat yt_ccl;
//@property(nonatomic, readonly) BOOL hasNCcl;
//
/////涨跌
//@property(nonatomic, readonly) YTSCFloat yt_zd;
//@property(nonatomic, readonly) BOOL hasNZd;

/////移动均线
//@property(nonatomic, readonly, strong) GPBInt32Array *nMaArray;
///// The number of items in @c nMaArray without causing the array to be created.
//@property(nonatomic, readonly) NSUInteger nMaArray_Count;

// 移动均量 Vol--MA
@property(nonatomic, readonly) YTSCFloat yt_techMA1;
@property(nonatomic, readonly) YTSCFloat yt_techMA2;
@property(nonatomic, readonly) YTSCFloat yt_techMA3;

@end

#pragma mark - 技术指标枚举
// 技术指标
typedef enum : NSUInteger  {
    YT_ZBType_VOL,         // 成交量
    YT_ZBType_MACD,        // MACD
    YT_ZBType_DMI,         // DMI
    YT_ZBType_WR,          // WR
    YT_ZBType_BOLL,        // BOLL
    YT_ZBType_KDJ,         // KDJ
    YT_ZBType_OBV,         // OBV
    YT_ZBType_RSI,         // RSI
    YT_ZBType_SAR,         // SAR
    YT_ZBType_DMA,         // DMA
    YT_ZBType_VR,          // VR
    YT_ZBType_CR,          // CR
    YT_ZBType_CCI,         // CCI  /* CCI Line */ on the follow add by Charls
    YT_ZBType_BIAS,        // BIAS
}YT_ZBType;

#define YT_ZBTypeStringVOL      @"VOL"
#define YT_ZBTypeStringMACD     @"MACD"
#define YT_ZBTypeStringDMI      @"DMI"
#define YT_ZBTypeStringWR       @"WR"
#define YT_ZBTypeStringBOLL     @"BOLL"

#define YT_ZBTypeStringKDJ      @"KDJ"
#define YT_ZBTypeStringOBV      @"OBV"
#define YT_ZBTypeStringRSI      @"RSI"
#define YT_ZBTypeStringSAR      @"SAR"
#define YT_ZBTypeStringDMA      @"DMA"

#define YT_ZBTypeStringVR       @"VR"
#define YT_ZBTypeStringCR       @"CR"
#define YT_ZBTypeStringCCI      @"CCI"
#define YT_ZBTypeStringBIAS     @"BIAS"

static inline
NSString* YT_StringFromZhiBiaoType(YT_ZBType zbType) {
    switch (zbType) {
        case YT_ZBType_VOL:    return YT_ZBTypeStringVOL;    break;
        case YT_ZBType_MACD:   return YT_ZBTypeStringMACD;   break;
        case YT_ZBType_DMI:    return YT_ZBTypeStringDMI;    break;
        case YT_ZBType_WR:     return YT_ZBTypeStringWR;     break;
        case YT_ZBType_BOLL:   return YT_ZBTypeStringBOLL;   break;
            
        case YT_ZBType_KDJ:    return YT_ZBTypeStringKDJ;    break;
        case YT_ZBType_OBV:    return YT_ZBTypeStringOBV;    break;
        case YT_ZBType_RSI:    return YT_ZBTypeStringRSI;    break;
        case YT_ZBType_SAR:    return YT_ZBTypeStringSAR;    break;
        case YT_ZBType_DMA:    return YT_ZBTypeStringDMA;    break;
            
        case YT_ZBType_VR:     return YT_ZBTypeStringVR;     break;
        case YT_ZBType_CR:     return YT_ZBTypeStringCR;     break;
        case YT_ZBType_CCI:    return YT_ZBTypeStringCCI;    break;
        case YT_ZBType_BIAS:   return YT_ZBTypeStringBIAS;   break;
            
        default:
            break;
    }
    
    return YT_ZBTypeStringVOL;
}

static inline
YT_ZBType YT_ZhiBiaoTypeFromString(NSString* zbTypeString) {
    if ([zbTypeString isEqualToString:YT_ZBTypeStringVOL])      return YT_ZBType_VOL;
    if ([zbTypeString isEqualToString:YT_ZBTypeStringMACD])     return YT_ZBType_MACD;
    if ([zbTypeString isEqualToString:YT_ZBTypeStringDMI])      return YT_ZBType_DMI;
    if ([zbTypeString isEqualToString:YT_ZBTypeStringWR])       return YT_ZBType_WR;
    if ([zbTypeString isEqualToString:YT_ZBTypeStringBOLL])     return YT_ZBType_BOLL;
    
    if ([zbTypeString isEqualToString:YT_ZBTypeStringKDJ]) return YT_ZBType_KDJ;
    if ([zbTypeString isEqualToString:YT_ZBTypeStringOBV]) return YT_ZBType_OBV;
    if ([zbTypeString isEqualToString:YT_ZBTypeStringRSI]) return YT_ZBType_RSI;
    if ([zbTypeString isEqualToString:YT_ZBTypeStringSAR]) return YT_ZBType_SAR;
    if ([zbTypeString isEqualToString:YT_ZBTypeStringDMA]) return YT_ZBType_DMA;
    
    if ([zbTypeString isEqualToString:YT_ZBTypeStringVR])   return YT_ZBType_VR;
    if ([zbTypeString isEqualToString:YT_ZBTypeStringCR])   return YT_ZBType_CR;
    if ([zbTypeString isEqualToString:YT_ZBTypeStringCCI])  return YT_ZBType_CCI;
    if ([zbTypeString isEqualToString:YT_ZBTypeStringBIAS]) return YT_ZBType_BIAS;
    
    return YT_ZBType_VOL;
}

#endif /* YT_KLineDataProtocol_h */
