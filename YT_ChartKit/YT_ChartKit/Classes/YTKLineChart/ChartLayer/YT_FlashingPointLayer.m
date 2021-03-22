//
//  FlashingPointLayer.m
//  ertwae
//
//  Created by yt_liyanshan on 2017/9/14.
//  Copyright © 2017年 kds. All rights reserved.
//

#import "YT_FlashingPointLayer.h"


@interface YT_FlashingPointLayer ()<CAAnimationDelegate>

//圆形
@property(nonatomic,assign)CGFloat pointSize;

@property(nonatomic,assign)CGFloat flashingPointSize;

@property(nonatomic,weak)CAShapeLayer * pointLayer;

@property(nonatomic,weak)CAShapeLayer * flashingPointLayer;

@property(nonatomic,weak)CAShapeLayer * animLayer;

@property(nonatomic,assign)NSInteger animProgress;
@end


@implementation YT_FlashingPointLayer

+(instancetype)flashingPointLayer{
    YT_FlashingPointLayer * layer = [YT_FlashingPointLayer layer];
    layer.pointColor = [UIColor redColor];
    [layer setBounds:CGRectMake(0, 0, 10, 10)];
    return layer;
}


-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    self.pointSize = self.frame.size.width/3;
    self.flashingPointSize = self.frame.size.width;
    if (!_pointLayer) {
        [self drawLayer];
    }
    [self startAnimation];
}

-(void)drawLayerIfNeed{
    if (_pointLayer) {
        [self drawLayer];
    }
}

-(void)drawLayer{
    [self drawAnim];
    [self drawPoint];
    [self drawFlashingPoint];
}

-(UIColor *)flashingPointColor{
    if (!_flashingPointColor&&_pointColor) {
        return [_pointColor colorWithAlphaComponent:0.5];
    }
    return _flashingPointColor;
}

#pragma mark - draw

-(void)drawPoint{
    if (_pointLayer) {
        [_pointLayer removeFromSuperlayer];
    }
    CGFloat radius = self.pointSize*0.5f;
    //圆
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointZero
                                                              radius:radius
                                                          startAngle:0
                                                            endAngle:M_PI * 2
                                                           clockwise:YES];
    
    CAShapeLayer *layer       = [CAShapeLayer layer];
    layer.path          = circlePath.CGPath;
    layer.fillColor     = self.pointColor.CGColor;
    layer.zPosition     = 2;
    CGPoint position = CGPointMake(self.frame.size.width *0.5, self.frame.size.height *0.5);
    layer.position = position;
    
    [self addSublayer:layer];
    _pointLayer = layer;
}


-(void)drawFlashingPoint{
    if (_flashingPointLayer) {
        [_flashingPointLayer removeFromSuperlayer];
    }
    CGFloat radius = self.flashingPointSize*0.5f;
    //圆
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointZero
                                                              radius:radius
                                                          startAngle:0
                                                            endAngle:M_PI * 2
                                                           clockwise:YES];
    
    CAShapeLayer *layer       = [CAShapeLayer layer];
    layer.path          = circlePath.CGPath;
    layer.fillColor     = self.flashingPointColor.CGColor;
    layer.zPosition     = 0;
    CGPoint position = CGPointMake(self.frame.size.width *0.5, self.frame.size.height *0.5);
    layer.position = position;
    
    [self addSublayer:layer];
    _flashingPointLayer = layer;
}


-(void)drawAnim{
    if (_animLayer) {
        [_animLayer removeFromSuperlayer];
    }
    // CGFloat radius = (self.flashingPointSize - self.pointSize)/4 + self.pointSize/2;
    CGFloat radius = self.flashingPointSize/2 * 0.95;
    //圆
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointZero
                                                              radius:radius
                                                          startAngle:0
                                                            endAngle:M_PI * 2
                                                           clockwise:YES];
    
    CAShapeLayer *layer       = [CAShapeLayer layer];
    layer.path          = circlePath.CGPath;
    layer.fillColor     = [[UIColor whiteColor] colorWithAlphaComponent:0.1].CGColor;
    layer.zPosition     = 1;
    CGPoint position = CGPointMake(self.frame.size.width *0.5, self.frame.size.height *0.5);
    layer.position = position;
    layer.opacity = 1;
    
    [self addSublayer:layer];
    _animLayer = layer;
}


#pragma mark - Animation

-(void)startAnimation{
    if (self.animProgress !=0) {
        return;
    }
    CGFloat duration = 0.3;
    [CATransaction begin];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = duration;
    animation.repeatCount = 1;
    animation.fromValue = @(0);
    animation.toValue = @1;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction =  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.delegate = self;
    [_flashingPointLayer addAnimation:animation forKey:@"scale"];
    
    //扩散效果
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation1.duration = duration;
    animation1.repeatCount = 1;
    animation1.fromValue = @(0);
    animation1.toValue = @1;
    animation1.fillMode = kCAFillModeForwards;
    animation1.timingFunction =  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_animLayer addAnimation:animation1 forKey:@"scale"];
    [CATransaction commit];
    self.animProgress = 1;
    /*
    __weak typeof (self) wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wself startAnimation2];
    });
     */
}

-(void)startAnimation2{
    if (self.animProgress !=1) {
        return;
    }
    CGFloat duration = 0.5;
    [CATransaction begin];
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = duration;
    animation.repeatCount = 1;
    animation.fromValue = @(1);
    animation.toValue = @0;
    
    CABasicAnimation *animation_ = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation_.duration = duration;
    animation_.repeatCount = 1;
    animation_.fromValue = @(1);
    animation_.toValue = @0.95;
    
    CAAnimationGroup * group = [CAAnimationGroup animation];
    group.duration = duration;
    group.repeatCount = 1;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    group.timingFunction =  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [group setAnimations:@[animation,animation_]];
    group.delegate = self;
    [_flashingPointLayer addAnimation:group forKey:@"opacity"];
    
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation1.duration = duration;
    animation1.repeatCount = 1;
    animation1.fromValue = @1;
    animation1.toValue = @0;
    animation1.removedOnCompletion = NO;
    animation1.fillMode = kCAFillModeForwards;
    animation1.timingFunction =  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [_animLayer addAnimation:animation1 forKey:@"opacity"];
    [CATransaction commit];
    self.animProgress = 2;
    /*
    __weak typeof (self) wself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((duration + 1)* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wself.animLayer removeAllAnimations];
        [wself.flashingPointLayer removeAllAnimations];
        [wself startAnimation];
    });
     */
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if(!self.superlayer){
        [self freeAnimation];
        return;
    };
    if (self.animProgress == 1) {
        [self startAnimation2];
       // NSLog(@"startAnimation2");
    }else if (self.animProgress == 2) {
       //  NSLog(@"startAnimation");
        __weak typeof (self) wself = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [wself.animLayer removeAllAnimations];
            [wself.flashingPointLayer removeAllAnimations];
            wself.animProgress = 0;
            [wself startAnimation];
        });
    }
}

-(void)freeAnimation{
    self.animProgress = 0;
    [_flashingPointLayer removeAllAnimations];
    [_animLayer removeAllAnimations];
}

-(void)removeFromSuperlayer{
    [super removeFromSuperlayer];
    [self freeAnimation];
}

/*
-(void)dealloc{
    NSLog(@"deallocssss");
}
*/

@end
