//
//  YT_CRLayer.h
//  KDS_Phone
//
//  Created by ChenRui Hu on 2018/6/5.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_BaseIndexLayer.h"
#import "YT_IndexLayerConfigProtocol.h"
#import "YT_KlineCalculatorProtocol.h"

@interface YT_CRLayer : YT_BaseIndexLayer <YT_IndexLayerProtocol>

@property (nonatomic, strong) id<YT_CRLayerConfig> configuration;  ///< layer相关配置对象
@property (nonatomic, strong) NSArray<id <YT_StockCRHandle>> *dataArray;  ///< 数据数组

@end
