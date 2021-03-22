//
//  stock_kline_data+calculateCache.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2017/9/25.
//  Copyright © 2017年 kds. All rights reserved.
//

#import "Protobuf.pbobjc.h"
NS_ASSUME_NONNULL_BEGIN
@interface YT_KlineDataCalculateCache :NSObject
{
//    NFloat *fk, *fd, *fj;                         // KDJ计算需要的变量
//    NFloat *fEMA12, *fEMA26, *fDIF, *fDEA, *startKFloat, *endKFloat;// MACD计算需要的变量
//    NFloat *fOBV_Value1, *fOBV_Value2;           // OBV计算需要的变量
//    NFloat *fWR10, *fWR6;                      // WR
//    NFloat *fVR_Value1, *fVR_Value2;           // VR，VR6天平均值
//    NFloat *fCR_Value1;                        // CR
    
//    NFloat *fMA10, *fMA50, *fDMA_Value1, *fDMA_Value2;  // DMA
//    NFloat *fBOLLUPPER, *fBOLLLOWER;            // BOLL
//    NFloat *RSI6, *RSI12, *RSI24;               // RSI
//    NFloat *SMAMAX_RSI6, *SMAMAX_RSI12, *SMAMAX_RSI24,  *SMAABS_RSI6, *SMAABS_RSI12, *SMAABS_RSI24;             // RSI
    
}
@end


@interface stock_kline_data (calculateCache)
@property(nonatomic,strong)YT_KlineDataCalculateCache * calculateCache;

// K--MA
@property(nonatomic,strong,readonly)NFloat * MA1;//5
@property(nonatomic,strong,readonly)NFloat * MA2;//10
@property(nonatomic,strong,readonly)NFloat * MA3;//30

@property(nonatomic,strong,nullable)NFloat * cache_customMA1;
@property(nonatomic,strong,nullable)NFloat * cache_customMA2;
@property(nonatomic,strong,nullable)NFloat * cache_customMA3;
@property(nonatomic,strong,nullable)NFloat * cache_customMA4;
@property(nonatomic,strong,nullable)NFloat * cache_customMA5;

// Vol--MA
@property(nonatomic,strong,readonly)NFloat * TechMA1;
@property(nonatomic,strong,readonly)NFloat * TechMA2;
@property(nonatomic,strong,readonly)NFloat * TechMA3;

// VR，VR6天平均值
@property(nonatomic,strong,nullable)NFloat * cache_VR;
@property(nonatomic,strong,nullable)NFloat * cache_VR_MA6;

//WR
@property(nonatomic,strong,nullable)NFloat * cache_WR6;
@property(nonatomic,strong,nullable)NFloat * cache_WR10;

//MACD
@property(nonatomic,strong,nullable)NFloat * cache_EMA12;
@property(nonatomic,strong,nullable)NFloat * cache_EMA26;
@property(nonatomic,strong,nullable)NFloat * cache_DIF;
@property(nonatomic,strong,nullable)NFloat * cache_DEA;
@property(nonatomic,strong,nullable)NFloat * cache_MACD;

//KDJ
@property(nonatomic,strong,nullable)NFloat * cache_K;
@property(nonatomic,strong,nullable)NFloat * cache_D;
@property(nonatomic,strong,nullable)NFloat * cache_J;

//OBV
@property(nonatomic,strong,nullable)NFloat * cache_OBV;
@property(nonatomic,strong,nullable)NFloat * cache_OBV_MA30;

//RSI
@property(nonatomic,strong,nullable)NFloat * cache_RSI6;
@property(nonatomic,strong,nullable)NFloat * cache_RSI12;
@property(nonatomic,strong,nullable)NFloat * cache_RSI24;

//DMA
@property(nonatomic,strong,nullable)NFloat * cache_DMA;
@property(nonatomic,strong,nullable)NFloat * cache_DMA_MA10;

//CR
@property(nonatomic,strong,nullable)NFloat * cache_CR;
@property(nonatomic,strong,nullable)NFloat * cache_CR_MA1;
@property(nonatomic,strong,nullable)NFloat * cache_CR_MA2;
@property(nonatomic,strong,nullable)NFloat * cache_CR_MA3;
@property(nonatomic,strong,nullable)NFloat * cache_CR_MA4;

//BOLL
@property(nonatomic,strong,nullable)NFloat * cache_BOLL_Mid;
@property(nonatomic,strong,nullable)NFloat * cache_BOLL_Upper;
@property(nonatomic,strong,nullable)NFloat * cache_BOLL_Lower;
@end
NS_ASSUME_NONNULL_END

