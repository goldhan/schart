//
//  YT_KLineMALayer.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/25.
//  Copyright © 2018年 kds. All rights reserved.
//
// * 说明 这个Layer 绘制 K线 view 中 K线区域 （蜡烛线区域）的 MA 指标 (一般是 closs 收盘价 的 移动平均)

#import "YT_KlineCalculatorProtocol.h"
#import "YT_IndexLayerProtocol.h"
#import "YT_IndexLayerConfigProtocol.h"
#import "YT_BaseIndexLayer.h"

@interface YT_KLineMALayer : YT_BaseIndexLayer <YT_IndexLayerProtocol>
@property (nonatomic, strong) id<YT_KLineMALayerConfig> configuration;  ///< layer相关配置对象
@property (nonatomic, strong) YT_KLineDataSource * dataSource; ///< 数据

- (NSArray<UIColor *> *)infoStringColorArray;
@end
