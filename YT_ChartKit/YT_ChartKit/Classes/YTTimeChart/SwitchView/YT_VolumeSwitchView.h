//
//  YT_VolumeSwitchView.h
//  AFNetworking
//
//  Created by ChenRui Hu on 2018/8/23.
//

#import <UIKit/UIKit.h>

/// 成交量切换图
@interface YT_VolumeSwitchView : UIView

/** 切换按钮边框线宽度 */
@property (nonatomic, assign) CGFloat switchLineWidth;

/** 切换按钮边框线颜色 */
@property (nonatomic, strong) UIColor *switchLineColor;

/** 文本颜色 */
@property (nonatomic, strong) UIColor *textColor;

/** 文本字体 */
@property (nonatomic, strong) UIFont *textFont;

@property (copy, nonatomic) void(^switchButtonBlock)(BOOL bOpen);   // 点击切换按钮是否打开下拉

/// 绘制成交量切换图内容
- (void)drawVolumeSwitchContent:(NSString *)content;
/// 设置按钮名称
- (void)drawVolumeSwitchButtonName:(NSString *)name;
@end
