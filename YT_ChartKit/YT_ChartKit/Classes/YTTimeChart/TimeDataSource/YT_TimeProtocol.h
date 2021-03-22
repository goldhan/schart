//
//  CoreGraphics_demo
//
//  Created by zhanghao on 2018/5/25.
//  Copyright © 2018年 snail-z. All rights reserved.
//

#import <UIKit/UIKit.h>

// 绘制分时图需要的相关协议
@protocol YT_TimePropProtocol <NSObject>
@optional

/** 昨日收盘 (用于连接第一个点) */
- (CGFloat)yt_originPrice;

/** 右边y轴最大涨幅值 */
- (CGFloat)yt_maxChangeRatio;

/** 右边y轴最小涨幅值 */
- (CGFloat)yt_minChangeRatio;

/** 左边y轴最大值 */
- (CGFloat)yt_maxPrice;

/** 左边y轴最小值 */
- (CGFloat)yt_minPrice;

/** 成交量区域坐标轴最高值 */
- (CGFloat)yt_maxVolume;

/** 成交量区域坐标轴最小值 */
- (CGFloat)yt_minVolume;

/** 现手 */
- (CGFloat)yt_new_vol;

@end

@protocol YT_TimeProtocol <NSObject>
@required

/** 分时价 */
- (CGFloat)yt_timePrice;

/** 分时图均价 */
- (CGFloat)yt_timeAveragePrice;

/** 成交量 */
- (CGFloat)yt_timeVolume;

/** 分时详细时间 */
- (NSDate *)yt_timeDate;

@end

@protocol YT_TimeOverlayProtocol <NSObject>
@required

/** 叠加股票1涨跌幅 */
- (CGFloat)yt_overlayChangeRatio;

@end

@protocol YT_TimeOverlayOtherProtocol <NSObject>
@required

/** 叠加股票2涨跌幅 */
- (CGFloat)yt_overlayOtherChangeRatio;

@end
