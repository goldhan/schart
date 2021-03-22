//
//  YT_ChartScaler.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/23.
//  Copyright © 2018年 kds. All rights reserved.
//
// * 说明 这个文件定义了测量器 用于 数据值和图纸中绘制点之间的转化

#import <Foundation/Foundation.h>
#import "YT_StockChartProtocol.h"

/** Y轴计算 */
typedef double(^YT_AxisYScaler)(double record);
typedef double(^YT_AxisYParser)(double y);

CG_INLINE YT_AxisYScaler YT_AxisYScalerMake(YTSCFloat max, YTSCFloat min, CGRect rect)
{
    CGFloat dis = CGRectGetHeight(rect);
    CGFloat div = max - min;
    div = div == 0 ? 1 : div;
    CGFloat pix = dis / div;
    CGFloat org_Y = CGRectGetMaxY(rect);
    
    return ^(double val) {
        return org_Y - (val - min) * pix;
    };
}

CG_INLINE YT_AxisYParser YT_AxisYParserMake(YTSCFloat max, YTSCFloat min, CGRect rect)
{
    CGFloat dis = CGRectGetHeight(rect);
    CGFloat pix = (max - min) / dis;
    CGFloat org_Y = CGRectGetMaxY(rect);
    
    return ^(double y) {
        return (min + (org_Y - y) * pix);
    };
}

/** X轴计算 */
typedef double(^YT_AxisXScaler)(NSUInteger idx);
typedef double(^YT_AxisXParser)(double x);

/**
 默认 0.5 （每一项 中心 在 shapeWidth + shapeInterval 的中心 0.5）【item】+ 【item】
 [shapeInterval/2 + shapeWidth + shapeInterval/2] + [shapeInterval/2 shapeWidth shapeInterval/2] ..
 可以自己设置调整
 另 默认 org_off_x 为 0  org_off_x （初始偏移量）
 */
CG_INLINE YT_AxisXScaler YT_AxisXScalerMake(CGFloat shapeWidth, CGFloat shapeInterval, CGRect rect)
{
    CGFloat width = shapeWidth + shapeInterval;
    CGFloat org_off_x = rect.origin.x;
    return ^(NSUInteger idx) {
        return (idx + 0.5) * width + org_off_x; // return (idx + 0.5) * width + org_off_x;
    };
}

/// 默认 org_off_x 为 0
CG_INLINE YT_AxisXParser YT_AxisXParserMake(CGFloat shapeWidth, CGFloat shapeInterval, CGRect rect)
{
    CGFloat width = shapeWidth + shapeInterval;
    CGFloat org_off_x = rect.origin.x;
    return ^(double x) {
        return  ((x - org_off_x )/width);
    };
}

@interface YT_ChartScaler : NSObject

@property (nonatomic, assign) CGRect  chartRect;  ///< 图表区域
@property (nonatomic, assign) CGFloat shapeWidth;     ///< 每一个模型的宽度
@property (nonatomic, assign) CGFloat shapeInterval;  ///< 形间距模型间距
@property (nonatomic, assign) NSUInteger totalShapeCount;  ///< 模型总数
@property (nonatomic, assign, readonly) CGFloat contentWidth; ///<所有绘制模型区域
@property (nonatomic, assign, readonly) CGFloat interval; ///< 模型之间中心点间距 (shapeWidth + shapeInterval)

@property (nonatomic, assign) YTSCFloat max; ///< 区域内最大值
@property (nonatomic, assign) YTSCFloat min; ///< 区域内最小值

@property (nonatomic, copy) YT_AxisYScaler axisYScaler;     ///< y轴换算 数值换坐标点
@property (nonatomic, copy) YT_AxisYParser axisYParser;     ///< y轴换算 坐标点换数值

@property (nonatomic, copy) YT_AxisXScaler axisXScaler;     ///< x轴换算 一个索引换为一个 centerX
@property (nonatomic, copy) YT_AxisXParser axisXParser;     ///< x轴换算 一个 x 换 一个索引

- (void)updateAxisX;
- (void)updateAxisY;
- (void)updateAxisYForInsets:(UIEdgeInsets)insets;

- (NSInteger)indexFromAxisXParser:(CGFloat)point_x;
- (NSInteger)roundIndexFromAxisXParser:(CGFloat)point_x;
@end


/// Y轴换算自己来，X轴由 xRelyon 控制，内部重写了所有关于 X轴的方法
@interface YT_ChartYScaler : YT_ChartScaler
@property (nonatomic, strong) YT_ChartScaler *xRelyon;  ///< x轴换算依赖
@end

