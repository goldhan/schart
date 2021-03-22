//
//  YT_OpenLayer.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/6/1.
//  Copyright © 2018年 kds. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@protocol YT_OpenLayerDelegate <NSObject>

- (void)yt_drawOpenLayer:(CALayer *)layer inContext:(CGContextRef)ctx;

@end


@interface YT_OpenLayer : CALayer

@property (weak) id<YT_OpenLayerDelegate> yt_openLayerDelegate;

@end
