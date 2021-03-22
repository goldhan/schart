//
//  YT_FloatQueue.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/6/22.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_FloatQueue.h"

@implementation YT_FloatQueue

// len must > 0
+ (instancetype)floatQueue:(double)defalutFloat len:(size_t)len {
   return [[self alloc] init:defalutFloat len:len];
}

- (instancetype)init:(double)defalutFloat len:(size_t)len {
    self = [super init];
    if (self) {
        _floatQueue = malloc(sizeof(double) * len);
        _len = len;
        _firstOneIndex = 0;
        _defalutFloat = defalutFloat;

        for (int i = 0; i < len; i++) {
            _floatQueue[i] = defalutFloat;
        }
    }
    return self;
}

- (double *)floatQueue {
    return _floatQueue;
}

- (void)dealloc {
    free(_floatQueue);
}

// 推进最后一个数据，返回推出的第一个数据
- (double)pushFloat:(double)aFloat {
    double needPop = _floatQueue[_firstOneIndex];
    _floatQueue[_firstOneIndex] = aFloat;
    _firstOneIndex ++;
    _firstOneIndex = _firstOneIndex % _len;
    return needPop;
}

- (double)sumQueue {
    double sum = 0;
    for (int i = 0; i <_len ; i++) {
        sum += _floatQueue[i];
    }
    return sum;
}

/*
#pragma mark -  测试代码 B
// 测试代码
+(void)load {
    [self test0];
    [self test1];
}

+(void)test0 {
    YT_FloatQueue * floatQueue =  [YT_FloatQueue floatQueue:12. len:30];
    for (int i = 0; i < 30 ; i++) {
        double alf =   [floatQueue pushFloat: i * M_PI_2];
        NSLog(@"floatQueue %lf",alf);
    }
    NSLog(@"floatQueue sumQueue %lf",floatQueue.sumQueue);
    for (int i = 0; i < 30 ; i++) {
        double alf =   [floatQueue pushFloat: i * M_PI_2];
        NSLog(@"floatQueue %lf",alf);
    }
    NSLog(@"floatQueue sumQueue %lf",floatQueue.sumQueue);
}

+(void)test1 {
    
    double * _floatQueue = malloc(sizeof(double) * 30);
    YT_FloatQueuesOrder queuesOrder = YT_FloatQueuesOrderMake(0,30);
    YT_FloatQueuesSet(_floatQueue, 30, 12);
    
    for (int i = 0; i < 30 ; i++) {
        double alf =  YT_FloatQueuesPush(&queuesOrder, _floatQueue,i * M_PI_2);
        NSLog(@"floatQueue %lf",alf);
    }
    NSLog(@"floatQueue sumQueue %lf",YT_FloatQueuesSum(_floatQueue, 30));
    for (int i = 0; i < 30 ; i++) {
        double alf = YT_FloatQueuesPush(&queuesOrder, _floatQueue,i * M_PI_2);
        NSLog(@"floatQueue %lf",alf);
    }
    NSLog(@"floatQueue sumQueue %lf",YT_FloatQueuesSum(_floatQueue, 30));
    free(_floatQueue);
}
#pragma mark -  测试代码 E
//*/
@end


