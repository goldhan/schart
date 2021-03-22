//
//  YT_StockChartProtocol.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/16.
//  Copyright © 2018年 kds. All rights reserved.
//

#ifndef YT_StockChartProtocol_h
#define YT_StockChartProtocol_h


#pragma mark - YTSCFloat

#if defined(__YT_YTSC64__) && __YTYTSC64__
# define YTSCFLOAT_TYPE double
# define YTSCFLOAT_MIN DBL_MIN
# define YTSCFLOAT_MAX DBL_MAX
#else
# define YTSCFLOAT_TYPE float
# define YTSCFLOAT_MIN FLT_MIN
# define YTSCFLOAT_MAX FLT_MAX
#endif


#ifndef YTSCFLOAT_EPSILON
#if defined(__YT_YTSC64__) && __YTYTSC64__
# define YTSCFLOAT_EPSILON DBL_EPSILON
#else
# define YTSCFLOAT_EPSILON FLT_EPSILON
#endif
#endif

typedef YTSCFLOAT_TYPE YTSCFloat;
# define YTSCFLOAT_NULL YTSCFLOAT_MIN


#if defined(__YT_YTSC64__) && __YTYTSC64__
static inline NSNumber * NSNumberFormYTSCFloat(YTSCFloat afloat)
{
    return [NSNumber numberWithDouble:afloat];
}
static inline YTSCFloat YTSCFloatFormNSNumber(NSNumber *num)
{
    return num.doubleValue;
}
#else
static inline NSNumber * NSNumberFormYTSCFloat(YTSCFloat afloat)
{
    return [NSNumber numberWithFloat:afloat];
}
static inline YTSCFloat YTSCFloatFormNSNumber(NSNumber *num)
{
    return num.floatValue;
}
#endif

#endif /* YT_StockChartProtocol_h */
