//
//  stock_kline_data+calculateCache.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2017/9/25.
//  Copyright © 2017年 kds. All rights reserved.
//

#import "YT_KLineDataCalculateCache.h"
#import <objc/message.h>
@implementation YT_KlineDataCalculateCache


@end

@implementation stock_kline_data (calculateCache)

-(YT_KlineDataCalculateCache *)calculateCache{
    
    YT_KlineDataCalculateCache * calculateCache =   objc_getAssociatedObject(self, _cmd);
    if (!calculateCache) {
       calculateCache = [[YT_KlineDataCalculateCache alloc]init];
       [self setCalculateCache:calculateCache];
    }
    return calculateCache;
}

-(void)setCalculateCache:(YT_KlineDataCalculateCache *)calculateCache{
    objc_setAssociatedObject(self, @selector(calculateCache), calculateCache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark K -- MA
-(NFloat *)MA1{
//     return [NFloat initWithValue:[self.nMaArray valueAtIndex:0]];
    NFloat * temp;
    if (!(temp=objc_getAssociatedObject(self, _cmd))) {
        temp =  [NFloat initWithValue:[self.nMaArray valueAtIndex:0]];
        objc_setAssociatedObject(self, _cmd, temp, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return temp;
}
-(NFloat *)MA2{
//    return [NFloat initWithValue:[self.nMaArray valueAtIndex:1]];
    NFloat * temp;
    if (!(temp=objc_getAssociatedObject(self, _cmd))) {
        temp =  [NFloat initWithValue:[self.nMaArray valueAtIndex:1]];
        objc_setAssociatedObject(self, _cmd, temp, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return temp;
}
-(NFloat *)MA3{
//    return [NFloat initWithValue:[self.nMaArray valueAtIndex:2]];
    NFloat * temp;
    if (!(temp=objc_getAssociatedObject(self, _cmd))) {
        temp =  [NFloat initWithValue:[self.nMaArray valueAtIndex:2]];
        objc_setAssociatedObject(self, _cmd, temp, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return temp;
}

-(NFloat *)cache_customMA1{
   return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_customMA1:(NFloat *)cache{
    objc_setAssociatedObject(self, @selector(cache_customMA1), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NFloat *)cache_customMA2{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_customMA2:(NFloat *)cache{
    objc_setAssociatedObject(self, @selector(cache_customMA2), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NFloat *)cache_customMA3{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_customMA3:(NFloat *)cache{
    objc_setAssociatedObject(self, @selector(cache_customMA3), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NFloat *)cache_customMA4{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_customMA4:(NFloat *)cache{
    objc_setAssociatedObject(self, @selector(cache_customMA4), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NFloat *)cache_customMA5{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_customMA5:(NFloat *)cache{
    objc_setAssociatedObject(self, @selector(cache_customMA5), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


#pragma mark Vol -- MA
-(NFloat *)TechMA1{
    return [NFloat initWithValue:[self.nTechArray valueAtIndex:0]];
}
-(NFloat *)TechMA2{
    return [NFloat initWithValue:[self.nTechArray valueAtIndex:1]];
}
-(NFloat *)TechMA3{
    return [NFloat initWithValue:[self.nTechArray valueAtIndex:2]];
}

#pragma mark VR

-(NFloat *)cache_VR{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_VR:(NFloat *)cache_VR{
     objc_setAssociatedObject(self, @selector(cache_VR), cache_VR, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NFloat *)cache_VR_MA6{
     return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_VR_MA6:(NFloat *)cache_VR_MA6{
      objc_setAssociatedObject(self, @selector(cache_VR_MA6), cache_VR_MA6, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark  WR

-(NFloat *)cache_WR6{
     return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_WR6:(NFloat *)cache_WR6{
    objc_setAssociatedObject(self, @selector(cache_WR6), cache_WR6, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NFloat *)cache_WR10{
     return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_WR10:(NFloat *)cache_WR10{
    objc_setAssociatedObject(self, @selector(cache_WR10), cache_WR10, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark  MACD

-(NFloat *)cache_EMA12{
     return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_EMA12:(NFloat *)cache_EMA12{
      objc_setAssociatedObject(self, @selector(cache_EMA12), cache_EMA12, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NFloat *)cache_EMA26{
     return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_EMA26:(NFloat *)cache_EMA26{
    objc_setAssociatedObject(self, @selector(cache_EMA26), cache_EMA26, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NFloat *)cache_DIF{
     return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_DIF:(NFloat *)cache_DIF{
    objc_setAssociatedObject(self, @selector(cache_DIF), cache_DIF, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NFloat *)cache_DEA{
     return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_DEA:(NFloat *)cache_DEA{
    objc_setAssociatedObject(self, @selector(cache_DEA), cache_DEA, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NFloat *)cache_MACD{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_MACD:(NFloat *)cache_MACD{
    objc_setAssociatedObject(self, @selector(cache_MACD), cache_MACD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark  KDJ

-(NFloat *)cache_K{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_K:(NFloat *)cache{
    objc_setAssociatedObject(self, @selector(cache_K), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NFloat *)cache_D{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_D:(NFloat *)cache{
    objc_setAssociatedObject(self, @selector(cache_D), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NFloat *)cache_J{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_J:(NFloat *)cache{
    objc_setAssociatedObject(self, @selector(cache_J), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark  OBV

-(NFloat *)cache_OBV{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_OBV:(NFloat *)cache{
    objc_setAssociatedObject(self, @selector(cache_OBV), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NFloat *)cache_OBV_MA30{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_OBV_MA30:(NFloat *)cache{
    objc_setAssociatedObject(self, @selector(cache_OBV_MA30), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark RSI

-(NFloat *)cache_RSI6{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_RSI6:(NFloat *)cache_RSI6{
    objc_setAssociatedObject(self, @selector(cache_RSI6), cache_RSI6, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NFloat *)cache_RSI12{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_RSI12:(NFloat *)cache_RSI12{
    objc_setAssociatedObject(self, @selector(cache_RSI12), cache_RSI12, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NFloat *)cache_RSI24{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_RSI24:(NFloat *)cache_RSI24{
    objc_setAssociatedObject(self, @selector(cache_RSI24), cache_RSI24, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark DMA

-(NFloat *)cache_DMA{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_DMA:(NFloat *)cache{
    objc_setAssociatedObject(self, @selector(cache_DMA), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NFloat *)cache_DMA_MA10{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_DMA_MA10:(NFloat *)cache{
    objc_setAssociatedObject(self, @selector(cache_DMA_MA10), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark CR
-(NFloat *)cache_CR{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_CR:(NFloat *)cache{
    objc_setAssociatedObject(self, @selector(cache_CR), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NFloat *)cache_CR_MA1{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_CR_MA1:(NFloat *)cache{
    objc_setAssociatedObject(self, @selector(cache_CR_MA1), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NFloat *)cache_CR_MA2{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_CR_MA2:(NFloat *)cache{
    objc_setAssociatedObject(self, @selector(cache_CR_MA2), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NFloat *)cache_CR_MA3{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_CR_MA3:(NFloat *)cache{
    objc_setAssociatedObject(self, @selector(cache_CR_MA3), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NFloat *)cache_CR_MA4{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_CR_MA4:(NFloat *)cache{
    objc_setAssociatedObject(self, @selector(cache_CR_MA4), cache, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark BOLL
-(NFloat *)cache_BOLL_Mid{
     return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_BOLL_Mid:(NFloat *)cache_BOLL_Mid{
    objc_setAssociatedObject(self, @selector(cache_BOLL_Mid), cache_BOLL_Mid, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NFloat *)cache_BOLL_Upper{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_BOLL_Upper:(NFloat *)cache_BOLL_Upper{
    objc_setAssociatedObject(self, @selector(cache_BOLL_Upper), cache_BOLL_Upper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(NFloat *)cache_BOLL_Lower{
    return  objc_getAssociatedObject(self, _cmd);
}
-(void)setCache_BOLL_Lower:(NFloat *)cache_BOLL_Lower{
    objc_setAssociatedObject(self, @selector(cache_BOLL_Lower), cache_BOLL_Lower, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
