//
//  YT_TimeChart+YT_TimeTextLayer.h
//  YT_ChartKit
//
//  Created by ChenRui Hu on 2018/8/20.
//

#import "YT_TimeChart.h"

/// 分时图左边成交价、成交量、右边涨跌幅、中间时间文本层
@interface YT_TimeChart (YT_TimeTextLayer)

/// 文本初始化
- (void)sublayerToTextInitialization;
/// 布局文本
- (void)textlayerUpdateLayout;
/// 绘制分时图左右价格与涨跌幅的文字
- (void)drawTimeText;
/// 绘制成交量左边文字
- (void)drawVolumeText;
/// 绘制五日分时时时间文字
- (void)drawFiveDateText:(CGRect)rect;
/// 绘制当日分时时间文字
- (void)drawDateText:(CGRect)rect;
@end
