//
//  stock_kline_data+calculateCache.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2017/9/25.
//  Copyright © 2017年 kds. All rights reserved.
//
// * 说明 这个文件 协助 YT_KLineDataSource 主要用于 计算结果 数据的存储

//#import "Protobuf.pbobjc.h"

#import <UIKit/UIKit.h>
#import "YT_StockChartProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@interface YT_KlineDataCalculateCache :NSObject

// K--MA
@property(nonatomic,assign,readonly) YTSCFloat *cache_Closs_MA; // cache_Closs_MA[5];
@property(nonatomic,assign,readonly) NSUInteger cache_Closs_MA_count;
@property(nonatomic,assign) YTSCFloat cache_Closs_MA0; ///< cache_Closs_MA[0];
@property(nonatomic,assign) YTSCFloat cache_Closs_MA1; ///< cache_Closs_MA[1];
@property(nonatomic,assign) YTSCFloat cache_Closs_MA2; ///< cache_Closs_MA[2];
@property(nonatomic,assign) YTSCFloat cache_Closs_MA3; ///< cache_Closs_MA[3];
@property(nonatomic,assign) YTSCFloat cache_Closs_MA4; ///< cache_Closs_MA[4];

// Vol--MA
//@property(nonatomic,assign,readonly) YTSCFloat TechMA1;
//@property(nonatomic,assign,readonly) YTSCFloat TechMA2;
//@property(nonatomic,assign,readonly) YTSCFloat TechMA3;

// VR，VR6天平均值
@property(nonatomic,assign) YTSCFloat cache_VR;
@property(nonatomic,assign) YTSCFloat cache_VR_MA6;

//WR
@property(nonatomic,assign) YTSCFloat cache_WR6;
@property(nonatomic,assign) YTSCFloat cache_WR10;

//MACD
@property(nonatomic,assign) YTSCFloat cache_EMA12;
@property(nonatomic,assign) YTSCFloat cache_EMA26;
@property(nonatomic,assign) YTSCFloat cache_DIF;
@property(nonatomic,assign) YTSCFloat cache_DEA;
@property(nonatomic,assign) YTSCFloat cache_MACD;

//KDJ
@property(nonatomic,assign) YTSCFloat cache_K;
@property(nonatomic,assign) YTSCFloat cache_D;
@property(nonatomic,assign) YTSCFloat cache_J;

//OBV
@property(nonatomic,assign) YTSCFloat cache_OBV;
@property(nonatomic,assign) YTSCFloat cache_OBVM;

//RSI
@property(nonatomic,assign) YTSCFloat cache_RSI6;
@property(nonatomic,assign) YTSCFloat cache_RSI12;
@property(nonatomic,assign) YTSCFloat cache_RSI24;

//DMA
@property(nonatomic,assign) YTSCFloat cache_DMA;
@property(nonatomic,assign) YTSCFloat cache_AMA;

//CR
@property(nonatomic,assign) YTSCFloat cache_CR;
@property(nonatomic,assign,readonly) YTSCFloat * cache_CR_MA; //cache_CR_MA[4]
@property(nonatomic,assign,readonly) NSUInteger cache_CR_MA_count;
@property(nonatomic,assign) YTSCFloat cache_CR_MA10;
@property(nonatomic,assign) YTSCFloat cache_CR_MA20;
@property(nonatomic,assign) YTSCFloat cache_CR_MA40;
@property(nonatomic,assign) YTSCFloat cache_CR_MA62;

//BOLL
@property(nonatomic,assign) YTSCFloat cache_BOLL_Mid;
@property(nonatomic,assign) YTSCFloat cache_BOLL_Upper;
@property(nonatomic,assign) YTSCFloat cache_BOLL_Lower;

//BIAS
@property(nonatomic,assign) YTSCFloat cache_BIAS6;
@property(nonatomic,assign) YTSCFloat cache_BIAS12;
@property(nonatomic,assign) YTSCFloat cache_BIAS24;

//CCI
@property(nonatomic,assign) YTSCFloat cache_CCI;

//DMI
@property(nonatomic,assign) YTSCFloat cache_PDI;
@property(nonatomic,assign) YTSCFloat cache_MDI;
@property(nonatomic,assign) YTSCFloat cache_ADX;
@property(nonatomic,assign) YTSCFloat cache_ADXR;
@end


@interface YT_KlineDataCalculateCacheManager :NSObject
@property (nonatomic, strong, null_resettable) NSMutableArray<YT_KlineDataCalculateCache *> * cacheArray; ///< 计算结果缓存数据

// 决定是否需要计算
@property (nonatomic,assign,readonly) NSRange * readyRange_Closs_MA; //readyRange_Closs_MA[5]
@property (nonatomic,assign,readonly) NSUInteger readyRange_Closs_MA_count;
@property (nonatomic,assign,readonly) NSRange * readyRange_CR_MA;
@property (nonatomic,assign,readonly) NSUInteger readyRange_CR_MA_count;

//@property (nonatomic, assign) NSRange readyRange_MA_Vol;

@property (nonatomic, assign) NSRange readyRange_VR;
@property (nonatomic, assign) NSRange readyRange_WR;
@property (nonatomic, assign) NSRange readyRange_MACD;
@property (nonatomic, assign) NSRange readyRange_KDJ;
@property (nonatomic, assign) NSRange readyRange_OBV;
@property (nonatomic, assign) NSRange readyRange_RSI;
@property (nonatomic, assign) NSRange readyRange_DMA;
@property (nonatomic, assign) NSRange readyRange_CR;
@property (nonatomic, assign) NSRange readyRange_BOLL;
@property (nonatomic, assign) NSRange readyRange_BIAS;
@property (nonatomic, assign) NSRange readyRange_CCI;
@property (nonatomic, assign) NSRange readyRange_DMI;

- (instancetype)initWithCacheArrayCount:(NSUInteger)count;
+ (instancetype)cacheManagerWithCacheArrayCount:(NSUInteger)count;

- (void)cacheArrayDeletObjsAtLast:(NSUInteger)count;
- (void)cacheArrayAppendObjectObjs:(NSUInteger)count;
- (void)cacheArrayInsertObjsAtIndex0:(NSUInteger)count;

@end
NS_ASSUME_NONNULL_END


/*
 @interface stock_kline_data (calculateCache)
 
 @property(nonatomic,assign)YT_KlineDataCalculateCache * calculateCache;
 
 
 // K--MA
 @property(nonatomic,assign,readonly) YTSCFloat MA1;//5
 @property(nonatomic,assign,readonly) YTSCFloat MA2;//10
 @property(nonatomic,assign,readonly) YTSCFloat MA3;//30
 
 // Vol--MA
 @property(nonatomic,assign,readonly) YTSCFloat TechMA1;
 @property(nonatomic,assign,readonly) YTSCFloat TechMA2;
 @property(nonatomic,assign,readonly) YTSCFloat TechMA3;
 
 
 @end
 */
