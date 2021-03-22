//
//  YT_CrissCrossQueryView.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/6/1.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef YT_QueryViewAbstract_h
#define YT_QueryViewAbstract_h

@protocol YT_QueryViewAbstract <NSObject>

/**
 * 查询Value颜色
 *
 * @{@"key" : [UIColor redColor]}
 */
- (NSDictionary <NSString * ,UIColor *>*)queryViewColorsForValues;

/**
 * 查询Key颜色
 *
 * @{@"key" : [UIColor redColor]}
 */
- (NSDictionary <NSString * ,UIColor *> *)queryViewColorsForKeys;

/**
 * 键值对
 * @{@"key" : @"value" , @"key2" : @"value2"}
 */
- (NSDictionary <NSString * ,UIColor *> *)queryViewValuesForKeys;

/**
 * 需要显示的keys,确定顺序
 * @[@"key",@"key2"]
 */
- (NSArray <NSString *> *)queryViewKeys;

@end

#endif /* YT_QueryViewAbstract.h */

@interface YT_QueryView : UIView

@property (nonatomic, strong) UIFont * textFont;    ///< 文字颜色
@property (nonatomic, assign) CGFloat interval;     ///< 间距
@property (nonatomic, assign) UIEdgeInsets contentInset;        ///< 内容缩进 (10, 10, 10, 10)
@property (nonatomic, strong) id <YT_QueryViewAbstract> queryData;     ///< 显示数据

@property (nonatomic, readonly, assign) CGSize size;    ///< 大小

@end

@class YT_OpenLayer;
@interface YT_CrissCrossQueryView : UIView

@property (nonatomic, readonly) YT_OpenLayer *cirssLayer;
@property (nonatomic, readonly) YT_QueryView * queryView; ///< 默认 (0, 0, 120, 0)

/// y轴 上的 Label 上下 偏移 。显示的是 Y轴的详细信息(值)
@property (nonatomic, assign) CGFloat yCirssLableLeftOffsetX;     ///< orign.x 默认 bounds.x
@property (nonatomic, assign) CGFloat yCirssLableRightOffsetX;    ///< orign.max_x 默认 bounds.max_x

/// x轴 上的 Label 上下 偏移 。显示的是 X轴的详细信息(时间轴)
@property (nonatomic, assign) CGFloat xCirssLableOffsetY;  ///< orign.y 默认 bounds.max_y - 30

@property (nonatomic, strong) UILabel * yCirssLableLeft;
@property (nonatomic, strong) UILabel * yCirssLableRight;
@property (nonatomic, strong) UILabel * xCirssLable;

@property (nonatomic, strong) UIColor * cirssLineColor;
@property (nonatomic, assign) CGFloat cirssLineWidth;    ///< 线宽 默认 1.f

@property (nonatomic, strong) UIColor * cirssLableColor;
@property (nonatomic, strong) UIColor * cirssLableBackColor;
@property (nonatomic, strong) UIFont * cirssLableFont;

@property (nonatomic, assign) BOOL yCirssHidden;

@property (nonatomic, assign) BOOL bRightLabelOutChart;    // YES：右边label在K线外面  NO：右边label在K线里面（默认YES）

/** 设置中心点 */
- (void)setCenterPoint:(CGPoint)center;

- (void)configCirssLable;
@end
