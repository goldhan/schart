//
//  YT_KlineDataManager.h
//  YT_ChartViewExample_Example
//
//  Created by yt_liyanshan on 2018/6/26.
//  Copyright © 2018年 李燕山. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protobuf.pbobjc.h"

typedef void(^YT_KlineRequestSuccessCallback)(stock_united_req *requestInfo,multi_stock_united_rep *responseObject);
typedef void(^YT_KlineRequestFailureCallback)(stock_united_req *requestInfo, NSError *error);

@interface YT_KlineDataManager : NSObject
    
@property (nonatomic, strong)  NSString  * sCode;
@property (nonatomic, assign)  NSInteger  marketId;
@property (nonatomic, assign)  NSInteger  currentFqType;
@property (nonatomic, assign)  NSInteger  currentKxType;

@property (nonatomic, strong)  YT_KlineRequestSuccessCallback   successCallback;
@property (nonatomic, strong)  YT_KlineRequestFailureCallback   failureCallback;
    
/**
 *  请求K线历史数据
 */
- (void)sendKLineHistoryDataReq:(NSString *)dateStr withTime:(NSString *)timeStr count:(NSInteger)count;
@end
