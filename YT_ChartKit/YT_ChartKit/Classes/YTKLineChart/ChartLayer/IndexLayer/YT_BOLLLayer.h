//
//  YT_BOLLLayer.h
//  KDS_Phone
//
//  Created by yangjinming on 2018/6/5.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_BaseIndexLayer.h"
#import "YT_IndexLayerProtocol.h"
#import "YT_IndexLayerConfigProtocol.h"
#import "YT_KlineCalculatorProtocol.h"

@class YT_ChartScaler;
@protocol YT_StockKlineData;

@interface YT_BOLLLayer : YT_BaseIndexLayer<YT_IndexLayerProtocol>
@property (nonatomic, strong) id<YT_BOLLLayerConfig> configuration;  ///< layer相关配置对象
@property (nonatomic, strong) NSArray<id <YT_StockBOLLHandle>> * dataArray;  ///< 数据数组
@end
