//
//  YT_KlineDataManager.m
//  YT_ChartViewExample_Example
//
//  Created by yt_liyanshan on 2018/6/26.
//  Copyright © 2018年 李燕山. All rights reserved.
//

#import "YT_KlineDataManager.h"

#import "KDS_HangQingData.h"

#define MF_HQ_Protobuf  1   //行情类，protobuf的协议
#define HQ_StockUnited  1   // 个股详情（新）
#import <YTNetworking.h>

@interface YT_KlineDataRequest : YTBaseRequest <YTResponseDataParserAble>
@property (nonatomic, strong) id klineRequestInfo;
@end

@implementation YT_KlineDataRequest
// 统一定义baseURL
- (NSString *)requestBaseURL {
//      return @"http://hldj.ehlzq.com.cn:21800/";
    return @"http://153.37.191.203:21800";
}

- (NSString *)requestURL {
    return @"/api/quote/pb_stockUnited";
}

- (YTRequestMethod)requestMethod {
    return YTRequestMethodPOST;
}

- (short)mainFun {
    return MF_HQ_Protobuf;
}

- (short)slaveFun {
    return HQ_StockUnited;
}

- (YTResponseSerializerType)responseSerializerType {
    return YTResponseSerializerTypeHTTP;
}

- (id<YTResponseDataParserAble>)dataParser {
    return self;
}
/** 解析器需要提供解析的方法 */
- (id)parseNetworkResponseData:(id)responseObject {
    return  [multi_stock_united_rep parseFromData:responseObject error:nil];
}

/* UnpackFactory
+ (NSString *)gpbMessage:(short)mainFun subFun:(short)subFun {
    if (MF_HQ_Protobuf == mainFun) {
        switch (subFun) {
                case HQ_StockUnited:  // 个股详情
                return @"multi_stock_united_rep";
                
                case HQ_Selected:  // 自选股
                return @"multi_selectedStocks_rep";
                
                case HQ_CodeList:  // 代码链
                return @"codeList_rep";
                
                case HQ_BlockRank:  // 板块
                return @"multi_blockRank_rep";
                
                case HQ_StockRank:  // 排序
                return @"multi_stockRank_rep";
                
            default:
                break;
        }
    }
    return nil;
}
*/

@end

@interface AFHTTPResponseSerializer (HQProtobuf)
@end
@implementation AFHTTPResponseSerializer (HQProtobuf)
- (NSSet<NSString *> *)acceptableContentTypes {
    return [NSSet setWithObjects:@"text/javascript",@"application/json",@"text/json",@"application/octet-stream",nil];
}
@end


@interface YT_KlineDataManager ()
@property (nonatomic, assign)  NSInteger      kxdate;
@property (nonatomic, assign)  NSInteger      Kxtime;
@end

@implementation YT_KlineDataManager

/**
 *  请求K线历史数据
 */
- (void)sendKLineHistoryDataReq:(NSString *)dateStr withTime:(NSString *)timeStr count:(NSInteger)count{
    //发送K线
    if (_sCode) {
        NSInteger beginDate = [dateStr integerValue];
        NSInteger beginTime = 0;
        if (![timeStr isEqualToString:@"0"]) {
            beginTime = [timeStr integerValue];
        }
        NSInteger tempCount = count > 0 ? count: 120;
        NSInteger nFQType = self.currentFqType;
        stock_kline_req *klineReq = [self klineReq:self.currentKxType withKXDate:beginDate withKXTime:beginTime withKXCount:tempCount withFQType:nFQType];
        stock_united_req *unitedReq = [self stockUnitedReq:_marketId withsPszCode:_sCode withwType:0 withFieldsBitMap:0];
        unitedReq.klineReq = klineReq;
        
        multi_stock_united_req *gpbMessage = [[multi_stock_united_req alloc] init];
        gpbMessage.reqsArray = [NSMutableArray arrayWithObjects:unitedReq, nil];
        
        NSMutableData * reqData = [NSMutableData dataWithData:[gpbMessage data]];
        unsigned long reqLen    = [reqData length];
        
        YT_KlineDataRequest * net_req =  [[YT_KlineDataRequest alloc] init];
        net_req.bOnlyTransferBinary = YES;
        net_req.klineRequestInfo = unitedReq;
        net_req.reqData = reqData;
        net_req.reqSize = reqLen;
        __weak typeof(self) wself = self;
        [net_req startRequestSuccessCallback:^(__kindof YT_KlineDataRequest *request, id responseObject) {
            if (wself && wself.successCallback) {
                wself.successCallback(request.klineRequestInfo, responseObject);
            }
        } failureCallback:^(__kindof YT_KlineDataRequest *request, NSError *error) {
            NSLog(@"error---%@",error);
            if (wself && wself.successCallback) {
                wself.failureCallback(request.klineRequestInfo, error);
            }
        }];
    }
}

//K线周期
//#define KX_1MIN           0x100            //1分钟K线
//#define KX_5MIN           0x101            //5分钟K线
//#define KX_15MIN           0x103            //15分钟K线
//#define KX_30MIN            0x106            //30分钟K线
//#define KX_60MIN            0x10c            //60分钟K线
//#define KX_DAY               0x201            //日K线
//#define KX_WEEK                0x301            //周K线
//#define KX_MONTH            0x401            //月K线
//#define KX_QUARTER            0x403            //季K线
//#define KX_HALFYEAR            0x406            //半年K线
//#define KX_YEAR                0x40c            //年K线

// NSArray<NSString *> *array = @[@"不复权", @"前复权", @"后复权"];  0 1 2

//+(void)load {
//    YT_KlineDataManager *  dataManager = [[YT_KlineDataManager alloc] init];
//    dataManager.sCode = @"000001";
//    dataManager.marketId = 2;
//    dataManager.currentKxType = KX_DAY;
//    dataManager.currentFqType = 0;
//    [dataManager sendKLineHistoryDataReq:@"" withTime:@"" count:0];
//}

- (stock_kline_req *)klineReq:(NSInteger)wKXType
                       withKXDate:(NSInteger)dwKXDate
                       withKXTime:(NSInteger)dwKXTime
                      withKXCount:(NSInteger)wKXCount
                       withFQType:(NSInteger)wFQType {
    stock_kline_req *req = [[stock_kline_req alloc] init];
    req.wKxtype = (int32_t)wKXType;
    req.dwKxdate = (int32_t)dwKXDate;
    req.dwKxtime = (int32_t)dwKXTime;
    req.wKxcount = (int32_t)wKXCount;
    req.wFqtype = (int32_t)wFQType;
    
    return req;
}

- (stock_united_req *)stockUnitedReq:(NSInteger)wMarketID
                            withsPszCode:(NSString *)sPszCode
                               withwType:(NSInteger)wType
                        withFieldsBitMap:(UInt64)fields_bitMap {
    stock_united_req *req = [[stock_united_req alloc] init];
    req.wMarketId = (int32_t)wMarketID;
    req.sPszCode = sPszCode;
    req.wType = (int32_t)wType;
    req.fieldsBitMap = fields_bitMap;
    
    return req;
}

/*
+ (stock_united_req *)kds_stockUnitedReq:(stock_united_req *)req
                            withKLineReq:(stock_kline_req *)kline_req
                               withFSReq:(stock_timeDivision_req *)timeDivision_req
                               withFBReq:(stock_tradeDetail_req *)tradeDetail_req {
    req.klineReq = kline_req;
    req.timeDivisionReq = timeDivision_req;
    req.tradeDetailReq = tradeDetail_req;
    
    return req;
}
*/

@end
