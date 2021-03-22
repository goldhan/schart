//
//  YT_KlineExtremePointRenderer.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/6/14.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_KlineExtremePointRenderer.h"

@interface YT_KlineExtremePointRenderer ()

/**
 * 绘制文字参数
 */
@property (nonatomic, strong) NSMutableDictionary * param;

@end

@implementation YT_KlineExtremePointRenderer

/**
 * 绘制文字字体
 */
- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    if (textFont) {
        [_param setObject:textFont forKey:NSFontAttributeName];
    }else{
        [_param removeObjectForKey:NSFontAttributeName];
    }
}

/**
 * 绘制文字颜色
 */
- (void)setTexColor:(UIColor *)texColor {
    _texColor = texColor;
    if (texColor) {
        [_param setObject:texColor forKey:NSForegroundColorAttributeName];
    }else{
        [_param removeObjectForKey:NSForegroundColorAttributeName];
    }
}


/**
 * 初始化
 */
- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _param = [NSMutableDictionary dictionary];
        [self setTexColor:[UIColor blackColor]];
        [self setTextFont:[UIFont systemFontOfSize:10]];
        
        _lineWidth = 1;
        _lineLength = 20;
        _lineColor = [UIColor blackColor];
        _drawRect = CGRectZero;
        _exclusionRect = CGRectZero;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {
    
    UIGraphicsPushContext(ctx);
    CGContextSetFillColorWithColor(ctx, _lineColor.CGColor);
    CGContextSetStrokeColorWithColor(ctx, _lineColor.CGColor);
    CGContextSetLineWidth(ctx, _lineWidth);
    
    if (self.lineDashBlock && self.lineDashSize > 0) {
        CGFloat lineDash[_lineDashSize];
        self.lineDashBlock(self, lineDash);
        CGContextSetLineDash(ctx, 0.0, lineDash, self.lineDashSize);
    }
    
    if (self.hadLineCapStyle) {
        CGContextSetLineCap(ctx, _lineCapStyle);
    }
    
    if (self.hadLineJoinStyle) {
        CGContextSetLineJoin(ctx, _lineJoinStyle);
    }
    
    [self t_drawInContext:ctx text:self.maxText point:self.maxPoint];
    [self t_drawInContext:ctx text:self.minText point:self.minPoint];
    
    UIGraphicsPopContext();
}

- (void)t_drawInContext:(CGContextRef)ctx text:(NSString*)text point:(CGPoint)point{
//    CGPoint point = self.maxPoint;
//    NSString * text = self.maxText;
    CGRect drawRect = self.drawRect;
    CGFloat lineLength  =  self.lineLength;
    if (text && text.length > 0 && YT_RectFullContainsPoint(drawRect, point) && !YT_RectFullContainsPoint(self.exclusionRect, point) ) {
        
        CGSize sizeText = [text sizeWithAttributes:_param];
        
        CGFloat newLineBeginX = point.x;
        CGFloat newLineEndX;
        CGPoint textDrawPoint;
        
        //判断当前点是屏幕左侧还是右侧
        if (point.x <= CGRectGetMidX(drawRect)) {
            newLineEndX =  newLineBeginX + lineLength; //左
            textDrawPoint.x = newLineEndX;
        } else {
            newLineEndX = newLineBeginX - lineLength; // 右
            textDrawPoint.x = newLineEndX - sizeText.width;
        }
        
        //判断当前点是屏幕上侧还是下侧
        if (point.y <= CGRectGetMidY(drawRect)) { //上
            point.y += _lineWidth/2;
            textDrawPoint.y = point.y;
        } else {
            point.y -= _lineWidth/2;
            textDrawPoint.y = point.y - sizeText.height;
        }
        
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, newLineBeginX,point.y);
        CGContextAddLineToPoint(ctx, newLineEndX, point.y);
        CGContextStrokePath(ctx);
        CGContextSaveGState(ctx);
        [text drawAtPoint:textDrawPoint withAttributes:_param];
        CGContextRestoreGState(ctx);
    }
}

static inline BOOL YT_RectFullContainsPoint(CGRect rect ,CGPoint point) {
    if (point.x < CGRectGetMinX(rect) ||  point.x > CGRectGetMaxX(rect) ||  point.y < CGRectGetMinY(rect) ||  point.y > CGRectGetMaxY(rect)) {
        return NO;
    }
    return YES;
}


- (void)configDottedLine {
    
    _lineDashSize = 2;
    [self setLineDashBlock:^(YT_KlineExtremePointRenderer *renderer, CGFloat *lineDash) {
          lineDash[0] = 0.1;
          lineDash[1] = 5.0;
    }];
    
    self.hadLineCapStyle = YES;
    self.lineCapStyle = kCGLineCapRound;
    self.hadLineJoinStyle = YES;
    self.lineJoinStyle = kCGLineJoinRound;

    self.lineWidth = 3;
}

@end
