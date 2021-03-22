//
//  YT_LineRectTextLayer.h
//  YT_ModuleQuotes_Example
//
//  Created by 韩金 on 2019/1/22.
//  Copyright © 2019 李燕山. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
@class YT_ChartScaler;
@protocol YT_StockKlineData;
NS_ASSUME_NONNULL_BEGIN

@interface YT_LineRectTextLayer : CALayer
@property (nonatomic, strong) NSArray <id <YT_StockKlineData> > *kLineArray;    ///< k线数组
@property (nonatomic, strong) YT_ChartScaler  *chartScaler;  ///< 绘制测量器

@property (nonatomic, strong) UIColor *lineColor; ///> 线颜色
@property (nonatomic, strong) UIColor *textColor; ///> 字体颜色
@property (nonatomic, strong) UIColor *textRectBG; ///> 字符框背景颜色

@property (nonatomic, strong) UIFont *textFont; ///> 字符串字体

@property (nonatomic, assign) CGFloat lineWidth; ///> 线宽度

- (void)configLayer;
- (void)updateLayerWithRange:(NSRange)range;
@end

NS_ASSUME_NONNULL_END
