//
//  YT_OBVLayer.h
//  KDS_Phone
//
//  Created by zhanghao on 2018/6/6.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_BaseIndexLayer.h"
#import "YT_IndexLayerConfigProtocol.h"
#import "YT_KlineCalculatorProtocol.h"

@interface YT_OBVLayer : YT_BaseIndexLayer <YT_IndexLayerProtocol>

@property (nonatomic, strong) id<YT_OBVLayerConfig> configuration;  ///< layer相关配置对象
@property (nonatomic, strong) NSArray<id <YT_StockOBVHandle>> *dataArray;  ///< 数据数组

@end
