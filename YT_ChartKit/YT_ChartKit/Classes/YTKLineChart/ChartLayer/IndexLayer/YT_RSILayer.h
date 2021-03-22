//
//  YT_RSILayer.h
//  KDS_Phone
//
//  Created by yangjinming on 2018/6/4.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_BaseIndexLayer.h"
#import "YT_IndexLayerProtocol.h"
#import "YT_IndexLayerConfigProtocol.h"
#import "YT_KlineCalculatorProtocol.h"

@interface YT_RSILayer : YT_BaseIndexLayer<YT_IndexLayerProtocol>
@property (nonatomic, strong) id<YT_RSILayerConfig> configuration;  ///< layer相关配置对象
@property (nonatomic, strong) NSArray<id <YT_StockRSIHandle>> * dataArray;  ///< 数据数组
@end
