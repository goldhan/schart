//
//  stock_kline_data+calculateCache.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2017/9/25.
//  Copyright © 2017年 kds. All rights reserved.
//

#import "YT_KLineDataCalculateCache.h"
#import <objc/message.h>

#define YTMAFloatSetGetMethod(Name, name, idx)            \
- (YTSCFloat)name##idx {                              \
return _##name[idx] ;                            \
}                                                           \
-(void)set##Name##idx:(YTSCFloat)name {     \
    _##name[idx] = name;     \
}

@interface YT_KlineDataCalculateCache()
{
    YTSCFloat _cache_Closs_MA[5];
    YTSCFloat _cache_CR_MA[4];
}
@end
@implementation YT_KlineDataCalculateCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cache_Closs_MA[0] = YTSCFLOAT_NULL;
        _cache_Closs_MA[1] = YTSCFLOAT_NULL;
        _cache_Closs_MA[2] = YTSCFLOAT_NULL;
        _cache_Closs_MA[3] = YTSCFLOAT_NULL;
        _cache_Closs_MA[4] = YTSCFLOAT_NULL;
        
        _cache_CR_MA[0] = YTSCFLOAT_NULL;
        _cache_CR_MA[1] = YTSCFLOAT_NULL;
        _cache_CR_MA[2] = YTSCFLOAT_NULL;
        _cache_CR_MA[3] = YTSCFLOAT_NULL;
    }
    return self;
}

-(YTSCFloat *)cache_Closs_MA {
    return  _cache_Closs_MA;
}
-(NSUInteger)cache_Closs_MA_count {
    return 5;
}
//
//-(void)setCache_Closs_MA0:(YTSCFloat)cache_Closs_MA0{
//    _cache_Closs_MA[0] = cache_Closs_MA0;
//}
//-(YTSCFloat)cache_Closs_MA0{
//   return _cache_Closs_MA[0];
//}
YTMAFloatSetGetMethod(Cache_Closs_MA,cache_Closs_MA,0)
YTMAFloatSetGetMethod(Cache_Closs_MA,cache_Closs_MA,1)
YTMAFloatSetGetMethod(Cache_Closs_MA,cache_Closs_MA,2)
YTMAFloatSetGetMethod(Cache_Closs_MA,cache_Closs_MA,3)
YTMAFloatSetGetMethod(Cache_Closs_MA,cache_Closs_MA,4)


-(YTSCFloat *)cache_CR_MA {
    return _cache_CR_MA;
}
-(NSUInteger)cache_CR_MA_count {
    return 4;
}

YTMAFloatSetGetMethod(Cache_CR_MA,cache_CR_MA,0)
YTMAFloatSetGetMethod(Cache_CR_MA,cache_CR_MA,1)
YTMAFloatSetGetMethod(Cache_CR_MA,cache_CR_MA,2)
YTMAFloatSetGetMethod(Cache_CR_MA,cache_CR_MA,3)


@end

#pragma mark -

@interface YT_KlineDataCalculateCacheManager()
{
    NSRange _readyRange_Closs_MA[5];
    NSRange _readyRange_CR_MA[4];
}
@end
@implementation YT_KlineDataCalculateCacheManager

#pragma mark getter
-(NSRange *)readyRange_Closs_MA {
    return _readyRange_Closs_MA;
}
-(NSUInteger)readyRange_Closs_MA_count {
    return 5;
}
-(NSRange *)readyRange_CR_MA {
    return _readyRange_CR_MA;
}
-(NSUInteger)readyRange_CR_MA_count {
    return 4;
}

#pragma mark init
- (instancetype)init {
    self = [super init];
    if (self) {
        _cacheArray =  [NSMutableArray array];
    }
    return self;
}


- (instancetype)initWithCacheArrayCount:(NSUInteger)count {
    self = [self init];
    if (self) {
        for (NSUInteger i = 0; i < count ; i ++) {
            YT_KlineDataCalculateCache * cache = [[YT_KlineDataCalculateCache alloc] init];
            [_cacheArray addObject:cache];
        }
    }
    return self;
}

+ (instancetype)cacheManagerWithCacheArrayCount:(NSUInteger)count {
    return [[self alloc] initWithCacheArrayCount:count];
}

#pragma mark pub


-(void)setCacheArray:(NSMutableArray<YT_KlineDataCalculateCache *> *)cacheArray {
    _cacheArray = cacheArray;
    if (_cacheArray == nil) {
        _cacheArray = [NSMutableArray array];
    }
}

- (void)cacheArrayDeletObjsAtLast:(NSUInteger)count {
    for (NSUInteger i = 0; i < count ; i ++) {
        [_cacheArray removeLastObject];
    }
     [self resetRandyRangeForFullRange:NSMakeRange(0, _cacheArray.count)];
}

- (void)cacheArrayAppendObjectObjs:(NSUInteger)count {
    for (NSUInteger i = 0; i < count ; i ++) {
        YT_KlineDataCalculateCache * cache = [[YT_KlineDataCalculateCache alloc] init];
        [_cacheArray addObject:cache];
    }
}

- (void)cacheArrayInsertObjsAtIndex0:(NSUInteger)count {
    for (NSUInteger i = 0; i < count ; i ++) {
        YT_KlineDataCalculateCache * cache = [[YT_KlineDataCalculateCache alloc] init];
        [_cacheArray insertObject:cache atIndex:0];
    }
    [self resetRandyRangeForFullRange:NSMakeRange(0, 0)];
}

- (void)resetRandyRangeForFullRange:(NSRange)fullRange {
    // 重置 各种 randyRange
   
    for (int i = 0; i < self.readyRange_Closs_MA_count; i ++) {
        rangeDeleWithFullRange(&_readyRange_Closs_MA[i],fullRange);
    }
    for (int i = 0; i < self.readyRange_CR_MA_count; i ++) {
        rangeDeleWithFullRange(&_readyRange_CR_MA[i],fullRange);
    }
    //    rangeDeleWithFullRange(&_readyRange_MA_Vol,fullRange);
    
    rangeDeleWithFullRange(&_readyRange_VR, fullRange);
    rangeDeleWithFullRange(&_readyRange_WR, fullRange);
    rangeDeleWithFullRange(&_readyRange_MACD, fullRange);
    rangeDeleWithFullRange(&_readyRange_KDJ, fullRange);
    rangeDeleWithFullRange(&_readyRange_OBV, fullRange);
    
    rangeDeleWithFullRange(&_readyRange_RSI, fullRange);
    rangeDeleWithFullRange(&_readyRange_DMA, fullRange);
    rangeDeleWithFullRange(&_readyRange_CR, fullRange);
    rangeDeleWithFullRange(&_readyRange_BOLL, fullRange);
    rangeDeleWithFullRange(&_readyRange_BIAS, fullRange);
    rangeDeleWithFullRange(&_readyRange_CCI, fullRange);
    rangeDeleWithFullRange(&_readyRange_DMI, fullRange);
}

static inline void rangeDeleWithFullRange (NSRange * range ,NSRange fullRange) {
    
    NSUInteger maxLoc = fullRange.location + fullRange.length;
    if (range->location >= maxLoc) {
        range->location = 0;
        range->length = 0;
        return;
    }
    if (range->location + range->length > maxLoc) {
        range->length = maxLoc - range->location;
    }
}

@end

/*
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


@end
*/
