//
//  YT_ FlashingPointLayer.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2017/9/14.
//  Copyright © 2017年 kds. All rights reserved.
//  心跳闪动点layer

#import <QuartzCore/QuartzCore.h>

@interface YT_FlashingPointLayer : CAShapeLayer

@property(nonatomic,strong)UIColor *pointColor;
@property(nonatomic,strong)UIColor *flashingPointColor;//不设为pointColor的alpha 0.5

+(instancetype)flashingPointLayer;

-(void)drawLayerIfNeed;
-(void)drawLayer;
-(void)startAnimation;
-(void)freeAnimation;
@end
