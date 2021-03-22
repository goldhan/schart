//
//  YT_KLineView.h
//  YT_Phone
//
//  Created by yt_liyanshan on 2017/9/14.
//  Copyright © 2017年 kds. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KDS_CALayer.h"
#import "KDS_SystemSetManager.h"

typedef enum {
    YT_KLineDirect_Hor,    // 水平方向
    YT_KLineDirect_Ver     // 垂直方向
}YT_KLineDirect;

@protocol YT_KLineViewDelegate <NSObject>

@optional
/**
 *  k线点击切换横竖屏
 *
 *  @param KLineViewDir 横竖屏标识
 *  @param bChange 是否切换
 */
- (void)KLineViewHandleTapFromRecognizer:(YT_KLineDirect)KLineViewDir bChange:(BOOL)bChange;

/**
 *  点击K线时的点
 *
 *  @param index     k线数据数组中的索引
 *  @param bTouching 是否接触点击
 */
- (void)KLineViewTouchDataIndex:(NSInteger)index bTouching:(BOOL)bTouching;

/**
 *  点击前后复权按钮时
 *
 *  @param index     k线数据数组中的索引
 */
- (void)KLineViewFuQuanButtonSelectIndex:(NSInteger)index;

/**
 *  当K线滑到最左端的时候请求新的K线数据
 */
- (void)KLineViewLoadHistoryDataWithCurrentDate:(NSString *)date withTime:(NSString *)time;

/**
 *  点击设置按钮时执行的方法
 */
- (void)SetButtonClick;

/**
 *  当点击到竖屏界面指标区域的时候
 *
 *  @param KLineViewDir 横竖屏标识
 */
- (void)KLIneViewTouchAtZBarea:(YT_KLineDirect)KLineViewDir;
@end



@class YT_KLineDataSource;
/**
 *  K线视图
 */
@interface YT_KLineView : UIView
{
    UIColor *   _coordinatelineColor;
    UIColor *   _upTextColor ;
    UIColor *   _downTextColor ;
    UIColor *   _normalTextColor;
    UIFont  *   _xFont;
    UIFont  *   _yFont;
}
@property (nonatomic, assign) YT_KLineDirect KLineDirect;           ///< k线方向类型
@property (nonatomic, assign) KDS_ZBType      zhiBiaoType;          ///< 指标类型
@property (nonatomic, weak)   id<YT_KLineViewDelegate> delegate;    ///< 代理
@property (nonatomic, strong) UIButton         *FQSeletcButton;     ///< 复权、均线自定义设置按钮
@property (nonatomic, assign) BOOL              isShowFQSet;     ///< 是否显示复权设置
@property (nonatomic, assign) BOOL              bIsHK;          ///< 是否为个港股

@property (nonatomic, copy)   NSString         *historyToDate;  ///< 请求此日期之前的历史数据
@property (nonatomic, copy)   NSString         *historyTime;    ///< 请求此时间之前的历史数据
@property (nonatomic, assign) NSInteger         KLineType;      ///< k线类型（五日、周、月等）
@property (nonatomic, strong) NSMutableArray   *arrKXDatas;     ///< k线数据

@property (nonatomic, strong) stock_kline_rep  *klineRep;       ///< k线数据
@property(nonatomic,strong,readonly) YT_KLineDataSource *klineDataSoure;
@end

