//
//  YT_BIASLayer.h
//  KDS_Phone
//
//  Created by yangjinming on 2018/5/31.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_BaseIndexLayer.h"
#import "YT_IndexLayerProtocol.h"
#import "YT_IndexLayerConfigProtocol.h"
#import "YT_KlineCalculatorProtocol.h"
@interface YT_BIASLayer : YT_BaseIndexLayer<YT_IndexLayerProtocol>
@property (nonatomic, strong) id<YT_BIASLayerConfig> configuration;  ///< layer相关配置对象
@property (nonatomic, strong) NSArray<id <YT_StockBIASHandle>> * dataArray;  ///< 数据数组
@end
