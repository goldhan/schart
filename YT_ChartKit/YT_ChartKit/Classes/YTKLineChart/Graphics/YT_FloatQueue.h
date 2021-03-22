//
//  YT_FloatQueue.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/6/22.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>

//队列先进先出 进一个出一个 用于计算平均值 数组临时储存
@interface YT_FloatQueue : NSObject
{
    double * _floatQueue;
    NSInteger _firstOneIndex;// 数据索引
    double _defalutFloat; // 无数据时，队列中的数据
}
@property (nonatomic, assign, readonly) double * floatQueue;
@property (nonatomic, assign) size_t len; // 数据长度
@property (nonatomic, assign, readonly) double sumQueue; //队列数据和

+ (instancetype)floatQueue:(double)defalutFloat len:(size_t)len;

// 推进最后一个数据，返回推出的第一个数据
- (double)pushFloat:(double)aFloat;

@end

/**
 * 网格结构体
 */
struct YTFloatQueuesOrder
{
    NSInteger firstOneIndex;// 数据索引
    size_t len; // 数据长度
};
typedef struct YTFloatQueuesOrder YT_FloatQueuesOrder;

NS_INLINE YT_FloatQueuesOrder
YT_FloatQueuesOrderMake(NSUInteger firstOneIndex ,size_t len) {
    YT_FloatQueuesOrder queues;
    queues.firstOneIndex = firstOneIndex;
    queues.len = len;
    return queues;
}

NS_INLINE double
YT_FloatQueuesPush(YT_FloatQueuesOrder *queuesOrder , double *floatQueue, double afloat) {
    int firstOneIndex = (int)queuesOrder->firstOneIndex;
    double needPop = floatQueue[firstOneIndex];
    floatQueue [firstOneIndex] = afloat;
    queuesOrder->firstOneIndex = ((++firstOneIndex) % (int)queuesOrder->len);
    return needPop;
}

NS_INLINE double
YT_FloatQueuesReplace(int index , double *floatQueue, double afloat) {
    double needPop = floatQueue[index];
    floatQueue [index] = afloat;
    return needPop;
}

NS_INLINE void
YT_FloatQueuesSet(double *floatQueue , size_t len, double afloat) {
    for (int i = 0; i < len; i++) {
        floatQueue[i] = afloat;
    }
}

NS_INLINE double
YT_FloatQueuesSum(double *floatQueue , size_t len) {
    double sum = 0;
    for (int i = 0; i < len ; i++) {
        sum += floatQueue[i];
    }
    return sum;
}
