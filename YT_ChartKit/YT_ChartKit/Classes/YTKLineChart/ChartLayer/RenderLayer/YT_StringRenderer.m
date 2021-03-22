//
//  YT_StringRenderer.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/31.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_StringRenderer.h"
#import "YT_StockChartConstants.h"

@interface YT_StringRenderer ()

/**
 * 绘制文字参数
 */
@property (nonatomic, strong) NSMutableDictionary * param;

@end

@implementation YT_StringRenderer
/**
 * 初始化
 */
- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _param = [NSMutableDictionary dictionary];
        _radius = 1.0f;
        _limitRect = CGRectZero;
    }
    return self;
}

/**
 * 绘制文字字体
 */
- (void)setFont:(UIFont *)font {
    _font = font;
    if (font) {
        [_param setObject:font forKey:NSFontAttributeName];
    }else{
        [_param removeObjectForKey:NSFontAttributeName];
    }
}

/**
 * 绘制文字颜色
 */
- (void)setColor:(UIColor *)color {
    _color = color;
    if (color) {
        [_param setObject:color forKey:NSForegroundColorAttributeName];
    }else{
        [_param removeObjectForKey:NSFontAttributeName];
    }
}

/**
 * 绘制方法
 */
- (void)drawInContext:(CGContextRef)ctx {
    CGSize size = [_string sizeWithAttributes:_param];
    size = CGSizeMake(size.width + _edgeInsets.left + _edgeInsets.right, size.height + _edgeInsets.top + _edgeInsets.bottom);
    
    CGPoint ratioPoint = YT_RATIO_POINT_CONVERT(_offSetRatio);
    CGPoint drawPoint = CGPointMake(_point.x + _offset.width, _point.y + _offset.height);
    CGPoint origin = CGPointMake(drawPoint.x + size.width * ratioPoint.x, drawPoint.y + size.height * ratioPoint.y);
    
    CGRect fillRect = CGRectZero;
    fillRect.origin = origin;
    fillRect.size = size;
    
    // 有限制区域 并且 超出 限制 绘制区域
    if (!CGRectIsEmpty(_limitRect)) {
        
        CGFloat min_x_l = CGRectGetMinX(_limitRect);
        CGFloat max_x_l = CGRectGetMaxX(_limitRect);
        
        CGFloat min_y_l = CGRectGetMinY(_limitRect);
        CGFloat max_y_l = CGRectGetMaxY(_limitRect);
        
        CGFloat min_x = CGRectGetMinX(fillRect);
        CGFloat max_x = CGRectGetMaxX(fillRect);
        
        CGFloat min_y = CGRectGetMinY(fillRect);
        CGFloat max_y = CGRectGetMaxY(fillRect);
        
        if (min_x < min_x_l) min_x = min_x_l;
        if (max_x > max_x_l) max_x = max_x_l;
        
        if (min_y < min_y_l) min_y = min_y_l;
        if (max_y > max_y_l) max_y = max_y_l;
        
        fillRect = CGRectMake(min_x, min_y, max_x - min_x , max_y - min_y);
    }
    
    CGRect textRect = UIEdgeInsetsInsetRect(fillRect, _edgeInsets);
    
    if (_fillColor) {
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:fillRect cornerRadius:_radius];
        CGContextAddPath(ctx, path.CGPath);
        CGContextSetFillColorWithColor(ctx, _fillColor.CGColor);
        CGContextFillPath(ctx);
        CGContextStrokePath(ctx);
    }
    
    UIGraphicsPushContext(ctx);
//    [_string drawAtPoint:textRect.origin withAttributes:_param];
    [_string drawInRect:textRect withAttributes:_param];
    UIGraphicsPopContext();
}
@end
