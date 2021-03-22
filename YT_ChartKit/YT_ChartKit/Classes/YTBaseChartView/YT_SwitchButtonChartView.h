//
//  YT_SwitchButtonChartView.h
//  YT_ChartKit
//
//  Created by ChenRui Hu on 2018/12/24.
//

#import <UIKit/UIKit.h>

#define kLeftEdge     4.0f    // 按钮离左边距
#define kWidthButton  54.0f   // 按钮的宽度

NS_ASSUME_NONNULL_BEGIN

@interface YT_SwitchButtonChartView : UIView

/** 切换按钮边框线宽度 */
@property (nonatomic, assign) CGFloat switchLineWidth;

/** 切换按钮边框线颜色 */
@property (nonatomic, strong) UIColor *switchLineColor;

/** 文本颜色 */
@property (nonatomic, strong) UIColor *textColor;

/** 文本字体 */
@property (nonatomic, strong) UIFont *textFont;

/** 按钮内文字的 UIEdgeInsets 默认无 */
@property(nonatomic)          UIEdgeInsets titleEdgeInsets;

@property (copy, nonatomic) void(^switchButtonBlock)(BOOL bOpen);   // 点击切换按钮是否打开下拉

@property (nonatomic, assign) BOOL bOpen;    // 是否是打开状态

/// 关闭切换按钮（只修改了切换按钮的三角为关闭状态）
- (void)closeSwitchButtionMark;
/// 设置按钮名称
- (void)drawSwitchButtonName:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
