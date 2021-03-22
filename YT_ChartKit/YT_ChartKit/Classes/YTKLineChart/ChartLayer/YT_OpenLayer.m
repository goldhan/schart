//
//  YT_OpenLayer.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/6/1.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_OpenLayer.h"

@implementation YT_OpenLayer

- (void)drawInContext:(CGContextRef)ctx {
    
    // 消除锯齿
    CGContextSetShouldAntialias(ctx, YES);
    
    self.shouldRasterize = YES;
    self.rasterizationScale = [[UIScreen mainScreen] scale];
    
    if (_yt_openLayerDelegate && [_yt_openLayerDelegate respondsToSelector:@selector(yt_drawOpenLayer:inContext:)]) {
        [_yt_openLayerDelegate yt_drawOpenLayer:self inContext:ctx];
    }
}

/**
 *  重写actionForKey，防止重绘界面时出现的延时动画
 */
- (id<CAAction>)actionForKey:(NSString *)event {
    if ([event isEqualToString:@"contents"])
    {
        return nil;
    }
    return [super actionForKey:event];
}

@end
