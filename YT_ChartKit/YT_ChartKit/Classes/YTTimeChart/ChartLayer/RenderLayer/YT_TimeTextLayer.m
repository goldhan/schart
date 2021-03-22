//
//  CoreGraphics_demo
//
//  Created by zhanghao on 2018/6/7.
//  Copyright © 2018年 snail-z. All rights reserved.
//

#import "YT_TimeTextLayer.h"

#define make_decimal(x) ((x) < 0 ? 0 : ((x) > 1 ? 1 : (x)))

@interface YT_KlineTextRenderer ()

@property (nonatomic, strong) NSMutableDictionary<NSAttributedStringKey, id> *textAttris;

@end

@implementation YT_KlineTextRenderer

+ (instancetype)defaultRenderer {
    YT_KlineTextRenderer *renderer = [YT_KlineTextRenderer new];
    renderer.backgroundColor = [UIColor clearColor];
    
    renderer.edgeInsets = UIEdgeInsetsMake(2, 3, 2, 3);
    renderer.baseOffset = UIOffsetZero;
    renderer.offsetRatio = CGPointMake(0, 1);
    
    renderer.maxWidth = 0.f;
    
    renderer.shouldDisplayRefline = NO;
    return renderer;
}

- (UIColor *)color {
    if (_color) return _color;
    return [UIColor blackColor];
}

- (UIFont *)font {
    if (_font) return _font;
    return [UIFont systemFontOfSize:10];
}

- (instancetype)init {
    if (self = [super init]) {
        self.textAttris = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context {
    if (!self.text) return;
    
    self.textAttris[NSFontAttributeName] = self.font;
    self.textAttris[NSForegroundColorAttributeName] = self.color;
    
    UIEdgeInsets insets = self.edgeInsets;
    CGPoint position = self.positionCenter;
    CGPoint scale = CGPointMake(make_decimal(self.offsetRatio.x),
                                make_decimal(self.offsetRatio.y));
    
    CGSize textSize = [self.text sizeWithAttributes:self.textAttris];
    textSize.width = self.maxWidth ? MIN(textSize.width, self.maxWidth) : textSize.width;

    CGSize fullSize = CGSizeMake(insets.left + insets.right + textSize.width,
                                 insets.top + insets.bottom + textSize.height);
    CGPoint fullOrigin = CGPointMake(position.x - fullSize.width * scale.x,
                                     position.y - fullSize.height * scale.y);
    fullOrigin.x += self.baseOffset.horizontal;
    fullOrigin.y += self.baseOffset.vertical;
    CGRect fullRect = (CGRect){.origin = fullOrigin, .size = fullSize};
    
    CGPoint textOrigin = fullRect.origin;
    textOrigin.x += insets.left;
    textOrigin.y += insets.top;
    CGRect textRect = (CGRect){.origin = textOrigin, .size = textSize};
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRoundedRect(path, NULL, fullRect, self.cornerRadius, self.cornerRadius);
    CGContextAddPath(context, path);
    CGPathRelease(path);
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    CGContextSetLineWidth(context, self.borderWidth);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    [self showReflineWithContext:context];
    
    UIGraphicsPushContext(context); // 切换到一个全新的绘图上下文
    [self.text drawInRect:textRect withAttributes:self.textAttris];
    UIGraphicsPopContext();
}

// 显示参考线，用于测试
- (void)showReflineWithContext:(CGContextRef)context {
    if (!self.shouldDisplayRefline) return;
    CGFloat lineLen = 100;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, self.positionCenter.x - lineLen, self.positionCenter.y);
    CGPathAddLineToPoint(path, NULL, self.positionCenter.x + lineLen, self.positionCenter.y);
    CGPathMoveToPoint(path, NULL, self.positionCenter.x, self.positionCenter.y - lineLen);
    CGPathAddLineToPoint(path, NULL, self.positionCenter.x, self.positionCenter.y + lineLen);
    CGContextAddPath(context, path);
    CGPathRelease(path);
    CGContextStrokePath(context);
}

@end

@implementation YT_TimeTextLayer

- (void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];
    for (YT_KlineTextRenderer *ren in self.rendererArray) {
        [ren drawInContext:ctx];
    }
}

- (void)updateRendererWithArray:(NSArray<YT_KlineTextRenderer *> *)array {
    if (!array.count) return;
    _rendererArray = array;
    [self setNeedsDisplay];
}

- (void)updateTextWithArray:(NSArray<NSString *> *)array {
    if (!array.count) return;
    [array enumerateObjectsUsingBlock:^(NSString * _Nonnull text, NSUInteger idx, BOOL * _Nonnull stop) {
        YT_KlineTextRenderer *ren = [self rendererWithIndex:idx];
        ren.text = text;
    }];
    [self setNeedsDisplay];
}

- (YT_KlineTextRenderer *)rendererWithIndex:(NSInteger)index {
    YT_KlineTextRenderer *ren = nil;
    if (index < self.rendererArray.count) {
        ren = self.rendererArray[index];
        return ren;
    }
    ren = [YT_KlineTextRenderer defaultRenderer];
    return ren;
}

@end
