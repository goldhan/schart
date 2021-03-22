//
//  YT_BaseIndexLayer.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/25.
//  Copyright © 2018年 kds. All rights reserved.
//
// * 说明 这个文件定义 基础指标Layer 实现部分 YT_IndexLayerProtocol 用于 快速创建子标layer 以及规避 协议未实现方法的调用导致的 崩溃 。不一定要集成 这个类 。只有实现  YT_IndexLayerProtocol 就好

#import <QuartzCore/QuartzCore.h>
#import "YT_IndexLayerProtocol.h"

@interface YT_BaseIndexLayer : CALayer

/// 添加<CALayer *>进数组 设置 IndexLayer 的 frame 自动 设置所有子 layer 铺满
@property (nonatomic, strong)NSPointerArray * autoFullLayoutLayers;

#pragma mark YT_IndexLayerProtocol 部分
@property (nonatomic, strong) YT_ChartScaler  * chartScaler;  ///< 绘制测量器
@property (nonatomic, assign) int textDecimalPlaces;   ///<  文字推荐显示小数位数 一般 2 ~ 4
@property (nonatomic, assign) int textUnits;  ///< 文字推荐显示单位 0 个 4 万 8 亿 （整数位 0 的个数）

#pragma mark  工具方法

- (NSMutableAttributedString *)attrStringWithStringArray:(NSArray<NSString *> *)strArr colorArr:(NSArray<UIColor *> *)colors;

@end

#pragma mark - 工具方法

@interface NSArray (CAShapeLayerAddPoints)

- (void)layer:(CAShapeLayer *)layer addPointsNotNULL:(NSRange)range getter:(SEL)getter axisXScaler:(YT_AxisXScaler)axisXScaler axisYScaler:(YT_AxisYScaler)axisYScaler;

- (void)layer:(CAShapeLayer *)layer addPoints:(NSRange)range getter:(SEL)getter axisXScaler:(YT_AxisXScaler)axisXScaler axisYScaler:(YT_AxisYScaler)axisYScaler;

@end
