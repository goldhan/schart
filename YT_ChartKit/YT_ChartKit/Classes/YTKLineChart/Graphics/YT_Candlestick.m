//
//  YT_Candlestick.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/22.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_Candlestick.h"
NS_ASSUME_NONNULL_BEGIN

/**
 * 绘制k线形
 */
CG_EXTERN void CGPathAddYTCandle(CGMutablePathRef ref, YT_Candle candle)
{
    CGPathMoveToPoint(ref, NULL, candle.top.x, candle.top.y);
    CGPathAddLineToPoint(ref, NULL, candle.top.x, CGRectGetMinY(candle.rect));
    CGPathAddRect(ref, NULL, candle.rect);
    CGPathMoveToPoint(ref, NULL, candle.end.x, CGRectGetMaxY(candle.rect));
    CGPathAddLineToPoint(ref, NULL, candle.end.x, candle.end.y);
}

/**
 * 绘制k线形
 */
CG_EXTERN void CGPathAddYTCandlestick(CGMutablePathRef ref, YT_Candle * candlestick, size_t size)
{
    for (int i = 0; i < size; i++) {
        CGPathAddYTCandle(ref, candlestick[i]);
    }
}

/**
 * 绘制 BOLL/美国线 k线形
 * 必须 收盘价 （candle.rect.origin.y）往右画  //开盘价 （candle.rect.origin.y+candle.rect.size.height） 往左画
 * 收盘价 （rect.origin.y）, 开盘价 （rect.origin.y+rect.size.height）  rect.size.height 可正可负
 * @param ref 路径元素
 * @param candle 美国线形态
 */
CG_EXTERN void CGPathAddYTCandleStyleAB(CGMutablePathRef ref, YT_Candle candle)
{
    CGPathMoveToPoint(ref, NULL, candle.top.x, candle.top.y);
    CGPathAddLineToPoint(ref, NULL, candle.end.x, candle.end.y);
    
    //收盘价 （candle.rect.origin.y）往右画
    CGPathMoveToPoint(ref, NULL, candle.top.x, candle.rect.origin.y);
    CGPathAddLineToPoint(ref, NULL, CGRectGetMaxX(candle.rect), candle.rect.origin.y);
    
    //开盘价 （candle.rect.origin.y+candle.rect.size.height） 往左画
    CGPathMoveToPoint(ref, NULL, candle.top.x, candle.rect.origin.y+candle.rect.size.height);
    CGPathAddLineToPoint(ref, NULL, CGRectGetMinX(candle.rect), candle.rect.origin.y+candle.rect.size.height);
}

/**
 * NSValue 扩展
 */
@implementation NSValue (GGValueGGKShapeExtensions)

+ (NSValue *)valueWithYTCandle:(YT_Candle)candle {
    return [NSValue value:&candle withObjCType:@encode(YT_Candle)];
}
- (YT_Candle)YTCandleValue{
    YT_Candle candle;
    [self getValue:&candle];
    return candle;
}

@end

@interface YT_CandleMutableArray()
{
//    YT_CandleList * _list;
    YT_CandleList * _lastOne;
}
@property (nonatomic, assign) YT_CandleList * preList;  ///< 索引为 -1。一直存在的对象 preList->next = list
@end

@implementation YT_CandleMutableArray

- (instancetype)init {
    self = [super init];
    if (self) {
        _preList = YT_CandleListMallocBase();
        _count = 0;
        _lastOne = _preList;
    }
    return self;
}

-(YT_CandleList * _Nullable )list {
     return _preList->next;
}

-(void)setList:(YT_CandleList * _Nullable)list {
     [self free];
     _preList->next = list;
     [self findAndResetLastOne];
}

-(void)findAndResetLastOne {
    _lastOne = _preList;
    NSUInteger idx = 0;
    while (_lastOne->next != NULL) {
        _lastOne = _lastOne->next;
        idx ++;
    }
    _count = idx;
}

-(void)addCandleList:(YT_CandleList *)list {
    _lastOne->next = list;
    NSUInteger idx_off = 0;
    while (_lastOne->next != NULL) {
        _lastOne = _lastOne->next;
        idx_off ++;
    }
    _count += idx_off;
}

-(void)resetWithCandle:(YT_Candle)candle {
    self.list = YT_CandleListMalloc(candle);
    _count = 1;
}

-(void)reset {
    self.list = NULL;
    _count = 0;
    _lastOne = _preList;
}

- (void)free {
    if (self.list != NULL) {
        YT_CandleListFree(self.list);
    }
}

- (void)dealloc {
    [self free];
    free(_preList);
}

-(void)addCandle:(YT_Candle)candle {
    YT_CandleList * list = YT_CandleListMalloc(candle);
    _lastOne->next = list;
    _lastOne = list;
    _count ++;
}

- (void)enumerateCandlesUsingBlock:(void (NS_NOESCAPE ^)(YT_Candle candle, NSUInteger idx))block {
    YT_CandleList * lastOne = _preList->next;
    NSUInteger idx = 0;
    while (lastOne != NULL) {
        block(lastOne->candle ,idx);
        lastOne = lastOne ->next;
        idx ++;
    }
}

- (void)enumerateCandlesUsingBlock2:(void (NS_NOESCAPE ^)(YT_Candle candle, NSUInteger idx ,BOOL * stop))block {
    BOOL stop = NO;
    YT_CandleList * lastOne = _preList->next;
    NSUInteger idx = 0;
    while (lastOne != NULL && stop) {
        block(lastOne->candle, idx, &stop);
        lastOne = lastOne ->next;
        idx ++;
    }
}

@end

@implementation YT_CandleArray : NSObject

- (instancetype)init {
    return [self initWitCount:1];
}

-(instancetype)initWitCount:(NSUInteger)count {
    self = [super init];
    if (self) {
        self.count = count;
        self.array = malloc(count * sizeof(YT_Candle));
    }
    return self;
}


- (void)dealloc {
    if (_array && _array != NULL) {
        free(_array);
    }
}

@end

NS_ASSUME_NONNULL_END
