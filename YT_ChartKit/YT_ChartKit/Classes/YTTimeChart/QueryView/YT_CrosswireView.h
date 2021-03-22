//
//  CoreGraphics_demo
//
//  Created by zhanghao on 2018/6/21.
//  Copyright © 2018年 snail-z. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YT_CrosswireView : UIView

/** 十字线宽度 */
@property (nonatomic, assign) CGFloat crosswireLineWidth;

/** 十字线颜色 */
@property (nonatomic, strong) UIColor *crosswireLineColor;

/** 文本颜色 */
@property (nonatomic, strong) UIColor *textColor;

/** 文本字体 */
@property (nonatomic, strong) UIFont *textFont;

/** 扩大文本边缘留白 */
@property (nonatomic, assign) UIOffset textEdgePadding;

/** 文本背景颜色 */
@property (nonatomic, strong) UIColor *textBackgroundColor;

/** 日期文本背景颜色 */
@property (nonatomic, strong) UIColor *dateBackgroundColor;

/** 映射Y轴的文本 */
@property (nonatomic, strong) NSString *mapYaixsText;

/** 映射Y轴另一端的文本 */
@property (nonatomic, strong, nullable) NSString *mapYaixsSubjoinText;

/** 映射X轴的文本 */
@property (nonatomic, strong) NSString *mapIndexText;

/** 中间分隔区域 */
@property (nonatomic, assign) CGRect separationRect;

/** 当前手指触摸点位置 */
@property (nonatomic, assign) CGPoint spotOfTouched;

/** 实际绘制的交叉点位置 */
@property (nonatomic, assign) CGPoint centralPoint;

/** 隐藏视图(淡入淡出) */
@property (nonatomic, assign) BOOL fadeHidden;

/** 日期文本是否隐藏 */
@property (nonatomic, assign) BOOL bdateHidden;

/** 交叉点是否标记显示 */
@property (nonatomic, assign) BOOL bcentralPointMark;

/** 交叉点景颜色 */
@property (nonatomic, strong) UIColor *centralPointColor;

/** 交叉点半径 */
@property (nonatomic, assign) CGFloat centralPointRadius;

/** 调用该方法以更新内容 */
- (void)updateContents;

@end

NS_ASSUME_NONNULL_END
