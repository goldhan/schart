//
//  CoreGraphics_demo
//
//  Created by zhanghao on 2018/6/7.
//  Copyright © 2018年 snail-z. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface YT_KlineTextRenderer : NSObject

/** 需要绘制的文本 */
@property (nonatomic, strong) NSString *text;

/** 文本颜色 */
@property (nonatomic, strong) UIColor *color;

/** 文本字体 */
@property (nonatomic, strong) UIFont *font;

/** 文本位置 */
@property (nonatomic, assign) CGPoint positionCenter;

/** 文本区域背景色 */
@property (nonatomic, strong) UIColor *backgroundColor;

/** 文本区域边框线宽 */
@property (nonatomic, assign) CGFloat borderWidth;

/** 文本区域边框颜色 */
@property (nonatomic, strong) UIColor *borderColor;

/** 文本区域圆角 */
@property (nonatomic, assign) CGFloat cornerRadius;

/** 文字内边距 */
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

/** 文本区域宽度限制 (由于仅支持单行文本，暂不考虑换行限制) */
@property (nonatomic, assign) CGFloat maxWidth;

/** 文本区域偏移量 (默认UIOffsetZero)*/
@property (nonatomic, assign) UIOffset baseOffset;

/**
 * 文字偏移比例 (取值范围0~1，默认值{0,1}) (基于position偏移) 如:
 * {0.5, 0.5} 则表示文本区域的中心点与文本位置重叠;
 * {0, 0} 则表示文本区域左上点与文本位置重叠;
 * {1, 0} 则表示文本区域右上点与文本位置重叠
 *
 * {0, 0} 左上, {0.5, 0.5} 中心, {1, 1} 右下
 *
 * {0,   0}, {0.5,   0}, {1,   0},
 * {0, 0.5}, {0.5, 0.5}, {1, 0.5},
 * {0,   1}, {0.5,   1}, {1,   1}
 */
@property (nonatomic, assign) CGPoint offsetRatio;

/** 是否显示参考线 (用于测试时观察文本偏移位置) */
@property (nonatomic, assign) BOOL shouldDisplayRefline;

+ (instancetype)defaultRenderer;

@end

@interface YT_TimeTextLayer : CALayer

@property (nonatomic, strong, readonly) NSArray<YT_KlineTextRenderer *> *rendererArray;

- (void)updateRendererWithArray:(NSArray<YT_KlineTextRenderer *> *)array;
- (void)updateTextWithArray:(NSArray<NSString *> *)array;

@end
