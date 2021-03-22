//
//  YT_VOLLayer.h
//  KDS_Phone
//
//  Created by ChenRui Hu on 2018/6/6.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_BaseIndexLayer.h"
#import "YT_IndexLayerConfigProtocol.h"
#import "YT_KlineCalculatorProtocol.h"

/*  VOL说明 成交量指标
 此指标柱子直接使用服务器下发的数据（成交量 nCjss）
 均线直接使用服务器下发的数据（移动均量 nTechArray）
 
 备注
 服务器下发的移动均量前几个无数据的值是0，在使用时不需要画点，此类只转换这几个数值
 比如：Tech1 是5日移动均量，从0到3的值是0
 */

@interface YT_VOLLayer : YT_BaseIndexLayer <YT_IndexLayerProtocol>

@property (nonatomic, strong) id<YT_VOLLayerConfig> configuration;  ///< layer相关配置对象

@end
