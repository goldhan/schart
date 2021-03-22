//
//  YT_Candlestick.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/22.
//  Copyright © 2018年 kds. All rights reserved.
//
// * 说明 这个文件定义了一个蜡烛线结构体 使用 CGPathAddYTCandle 可以添加蜡烛线路径


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

struct YTCandle{
    CGPoint top;
    CGRect rect;
    CGPoint end;
};
typedef struct YTCandle YT_Candle;

/**
 * candle构造K线蜡烛图candlestick
 */
CG_INLINE YT_Candle
YT_CandleMake(CGPoint top, CGRect rect, CGPoint end)
{
    YT_Candle candle;
    candle.top = top;
    candle.rect = rect;
    candle.end = end;
    return candle;
}

/**
 * 绘制k线形
 *
 * @param ref 路径元素
 * @param candle 蜡烛形状
 */
CG_EXTERN void CGPathAddYTCandle(CGMutablePathRef ref, YT_Candle candle);

/**
 * 绘制k线形
 *
 * @param ref 路径元素
 * @param candlestick 蜡烛线
 */
CG_EXTERN void CGPathAddYTCandlestick(CGMutablePathRef ref, YT_Candle * candlestick, size_t size);

/**
 * 绘制 BOLL/美国线 k线形
 * 必须 收盘价 （candle.rect.origin.y）往右画  //开盘价 （candle.rect.origin.y+candle.rect.size.height） 往左画
 * 收盘价 （rect.origin.y）, 开盘价 （rect.origin.y+rect.size.height）  rect.size.height 可正可负 + 涨 - 跌
 * @param ref 路径元素
 * @param candle 美国线形态
 */
CG_EXTERN void CGPathAddYTCandleStyleAB(CGMutablePathRef ref, YT_Candle candle);

/**
 * NSValue 扩展
 */
@interface NSValue (YT_Candle)

+ (NSValue *)valueWithYTCandle:(YT_Candle)candle;
- (YT_Candle)YTCandleValue;

@end


/**
 candle 链表
 */
struct YTCandleList {
    YT_Candle candle;
    struct YTCandleList * next;
};
typedef struct YTCandleList YT_CandleList;

CG_INLINE YT_CandleList *
YT_CandleListMallocBase()
{
    YT_CandleList * candleList = malloc(sizeof(YT_CandleList));
    candleList->next = NULL;
    return candleList;
}

CG_INLINE YT_CandleList *
YT_CandleListMalloc(YT_Candle candle)
{
    YT_CandleList * candleList = malloc(sizeof(YT_CandleList));
    candleList->candle = candle;
    candleList->next = NULL;
    return candleList;
}

CG_INLINE YT_CandleList *
YT_CandleListMalloc2(YT_Candle candle, YT_CandleList * next)
{
    YT_CandleList * candleList = malloc(sizeof(YT_CandleList));
    candleList->candle = candle;
    candleList->next = next;
    return candleList;
}

CG_INLINE void
YT_CandleListFree(YT_CandleList * list)
{
    YT_CandleList * next;
    do {
        next = list->next;
        free(list);
        list = next;
    }while (list && list != NULL);
//    NSInteger count = 0;
//    count ++;
//    NSLog(@"free count %zd",count);
}

@interface YT_CandleMutableArray : NSObject
@property (nonatomic, assign) YT_CandleList * _Nullable list; ///< 列表 count==0 时 为 NULL
@property (nonatomic, assign) NSUInteger count;   ///< 个数

-(void)addCandle:(YT_Candle)candle;
-(void)resetWithCandle:(YT_Candle)candle;
-(void)addCandleList:(YT_CandleList *)list;
-(void)enumerateCandlesUsingBlock:(void (NS_NOESCAPE ^)(YT_Candle candle, NSUInteger idx))block;
-(void)enumerateCandlesUsingBlock2:(void (NS_NOESCAPE ^)(YT_Candle candle, NSUInteger idx ,BOOL * stop))block;
@end

@interface YT_CandleArray : NSObject

@property (nonatomic, assign) YT_Candle *array;   ///< 数组
@property (nonatomic, assign) NSUInteger count;   ///< 个数

-(instancetype)initWitCount:(NSUInteger)count NS_DESIGNATED_INITIALIZER;

@end
NS_ASSUME_NONNULL_END
