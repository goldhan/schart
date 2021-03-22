//
//  CoreGraphics_demo
//
//  Created by zhanghao on 2018/7/6.
//  Copyright © 2018年 snail-z. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YT_TimeBaseChart : UIView

@property (nonatomic, strong, readonly) CALayer *contentChartLayer;
@property (nonatomic, strong, readonly) CALayer *contentTextLayer;

/** 初始化子视图 */
- (void)sublayerInitialization;
@end
