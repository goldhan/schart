//
//  YT_StringArrayRenderer.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/6/1.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_StringArrayRenderer.h"
#import "YT_StockChartConstants.h"

@interface YT_StringArrayRenderer ()

@property (nonatomic, strong) NSMutableDictionary * param;

@property (nonatomic, copy) NSString *(^stringBlock)(CGPoint point, NSInteger index, NSInteger count);
@end

@implementation YT_StringArrayRenderer

/**
 * 初始化
 */
- (instancetype)init {
    self = [super init];
    
    if (self) {
        _param = [NSMutableDictionary dictionary];
        _stringArray = [NSMutableArray array];
        _stringPoints = [NSMutableArray array];
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
    
    NSInteger count = self.stringPoints.count;
    
    if (self.stringBlock) {
        [self.stringArray removeAllObjects];
        for (int i = 0; i < count; i++) {
            CGPoint point = [self.stringPoints objectAtIndex:i].CGPointValue;
            NSString * string = self.stringBlock(point, i, count);
            if (string) {
                [self.stringArray addObject:string];
            }else{
                [self.stringArray addObject:@""];
            }
        }
    }else{
        if (self.stringArray.count < count) {
            count = self.stringArray.count;
        }
    }
    [self t_drawInContext:ctx count:count];
}


- (void)t_drawInContext:(CGContextRef)ctx count:(NSInteger)count {
    
    if ( !self.fixSizeBlockUntilLimitSize || (_limitSize.width == 0 &&  _limitSize.height == 0)) {
         [self t_drawInContext:ctx count:count font:self.font];
         return;
    }
    
    UIFont * minFont = self.font;
    CGPoint ratioPoint = YT_RATIO_POINT_CONVERT(_offSetRatio);
    NSMutableDictionary * stringAttributes = [NSMutableDictionary dictionaryWithDictionary:_param];
    
    UIGraphicsPushContext(ctx);
    for (int i = 0; i < count; i++) {
        
        CGPoint point = [self.stringPoints objectAtIndex:i].CGPointValue;
        NSString * string = [self.stringArray objectAtIndex:i];
        if (!string || string.length == 0) {
            continue;
        }
        
        if (self.colorsBlock) {      // 多色值
            UIColor * color = self.colorsBlock(self, i);
            [stringAttributes setObject:color forKey:NSForegroundColorAttributeName];
        }
        
        CGSize size = [string sizeWithAttributes:stringAttributes];
        BOOL stop = NO;
        UIFont * afont = self.font;
        if (_limitSize.width != 0 && size.width > _limitSize.width) {
            while (size.width > _limitSize.width && stop == NO && afont.pointSize > 1) {
                afont = self.fixSizeBlockUntilLimitSize(string, afont ,&stop);
                [stringAttributes setObject:afont forKey:NSFontAttributeName];
                size = [string sizeWithAttributes:stringAttributes];
            }
        }
        if (_limitSize.height != 0) {
            while (size.height > _limitSize.height && stop == NO && afont.pointSize > 1) {
                afont = self.fixSizeBlockUntilLimitSize(string, afont ,&stop);
                [stringAttributes setObject:afont forKey:NSFontAttributeName];
                size = [string sizeWithAttributes:stringAttributes];
            }
        }
        if (afont.pointSize < minFont.pointSize) {
            minFont = afont;
        }
        
        CGPoint offSetRatio = ratioPoint;
        if (self.offSetRatiosBlock) {
            offSetRatio = self.offSetRatiosBlock(self, i);
        }
        
        CGSize textOffSet = self.offset;
        if (self.offsetsBlock) {
            textOffSet = self.offsetsBlock(self, i);
        }
        
        point = CGPointMake(point.x + size.width * offSetRatio.x, point.y + size.height * offSetRatio.y);
        point = CGPointMake(point.x + textOffSet.width, point.y + textOffSet.height);
        [string drawAtPoint:point withAttributes:stringAttributes];
    }
    UIGraphicsPopContext();
    
    if (self.textKeepSameFont && minFont != self.font) {
        [self t_drawInContext:ctx count:count font:self.font];
    }
}


- (void)t_drawInContext:(CGContextRef)ctx count:(NSInteger)count font:(UIFont *)font {

    CGPoint ratioPoint = YT_RATIO_POINT_CONVERT(_offSetRatio);
    
    NSMutableDictionary * stringAttributes = [NSMutableDictionary dictionaryWithDictionary:_param];
    if(font) [stringAttributes setObject:font forKey:NSFontAttributeName];
    
    UIGraphicsPushContext(ctx);
    for (int i = 0; i < count; i++) {
        
        CGPoint point = [self.stringPoints objectAtIndex:i].CGPointValue;
        NSString * string = [self.stringArray objectAtIndex:i];
        if (!string || string.length == 0) {
            continue;
        }
        
        if (self.colorsBlock) {      // 多色值
            UIColor * color = self.colorsBlock(self, i);
            [stringAttributes setObject:color forKey:NSForegroundColorAttributeName];
        }
        
        CGSize size = [string sizeWithAttributes:stringAttributes];
 
        CGPoint offSetRatio = ratioPoint;
        if (self.offSetRatiosBlock) {
            offSetRatio = self.offSetRatiosBlock(self, i);
        }
        
        CGSize textOffSet = self.offset;
        if (self.offsetsBlock) {
            textOffSet = self.offsetsBlock(self, i);
        }
        
        point = CGPointMake(point.x + size.width * offSetRatio.x, point.y + size.height * offSetRatio.y);
        point = CGPointMake(point.x + textOffSet.width, point.y + textOffSet.height);
        [string drawAtPoint:point withAttributes:stringAttributes];
    }
    UIGraphicsPopContext();
}


/**
 * 增加轴关键点以及文字
 *
 * @param string 文字
 * @param point 点
 */
- (void)addString:(NSString *)string point:(CGPoint)point {
    if (string == nil) { return; }
    
    [self.stringArray addObject:string];
    [self.stringPoints addObject:[NSValue valueWithCGPoint:point] ];
}

/**
 * 清除所有附加文字
 */
- (void)removeAllPointString {
    [self.stringArray removeAllObjects];
    [self.stringPoints removeAllObjects];
}

- (void)setStringBlock:(NSString *(^)(CGPoint, NSInteger, NSInteger))stringBlock {
    _stringBlock = stringBlock;
}

#pragma mark - tool

+(NSMutableArray<NSValue *> *)pointArrayFormPoint:(CGPoint)fPoint toPoint:(CGPoint)tPoint sepCount:(NSUInteger)sepCount offset:(CGPoint)offset {
    NSMutableArray<NSValue *> * pointArray = [NSMutableArray array];
    
   CGPoint rsPoint = CGPointMake(fPoint.x + offset.x, fPoint.y + offset.y);
   [pointArray addObject:[NSValue valueWithCGPoint:rsPoint]];
    
   CGFloat y_dis = (tPoint.y - fPoint.y) / sepCount;
   CGFloat x_dis = (tPoint.x - fPoint.x) / sepCount;
    
   for (int i = 1; i < sepCount; i++) {
       CGPoint rsPoint = CGPointMake(fPoint.x + x_dis * i + offset.x, fPoint.y + y_dis * i + offset.y);
       [pointArray addObject:[NSValue valueWithCGPoint:rsPoint]];
   }
    
   CGPoint rsPoint2 = CGPointMake(tPoint.x + offset.x, tPoint.y + offset.y);
   [pointArray addObject:[NSValue valueWithCGPoint:rsPoint2]];
    
   return pointArray;
}

//-(void)dealloc {
//    NSLog(@"dealloc %@",self.class);
//}

@end
