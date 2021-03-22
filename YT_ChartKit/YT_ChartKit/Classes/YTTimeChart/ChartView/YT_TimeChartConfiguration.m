//
//  CoreGraphics_demo
//
//  Created by zhanghao on 2018/7/6.
//  Copyright © 2018年 snail-z. All rights reserved.
//

#import "YT_TimeChartConfiguration.h"
#import "UIFont+YT_Use.h"

@implementation YT_TimeChartConfiguration

+ (instancetype)defaultConfiguration {
    YT_TimeChartConfiguration *configuration = [YT_TimeChartConfiguration new];
    configuration.chartType = YT_TimeChartTypeDefault;
    
    // 港股最大242 (9:30~11:30 13:00~15:00，每分钟一条数据，共计242条)
    configuration.maxDataCount = 242;
    
    configuration.topGap = 5;
    configuration.dateGap = 5;
    configuration.riverGap = 20;
    configuration.bottomGap = 20;
    configuration.proportionOfHeight = 0.65;
    
    configuration.gridLineWidth = 1 / [UIScreen mainScreen].scale;
    configuration.gridLineColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.7];
    configuration.dashLineWidth = 1;
    configuration.dashLineColor = [UIColor orangeColor];
    configuration.dashLinePattern = @[@5, @3];
    
    configuration.yAxisTimeSegments = 2;
    configuration.yAxisVolumeSegments = 2;
    configuration.yAxisTimeTextColors = @[[UIColor redColor], [UIColor greenColor], [UIColor lightGrayColor], [UIColor lightGrayColor]];
    
    configuration.volumeBarGap = 1 / [UIScreen mainScreen].scale;
    configuration.volumeRiseColor = [UIColor redColor];
    configuration.volumeFallColor = [UIColor greenColor];
    configuration.volumeFlatColor = [UIColor lightGrayColor];
    
    configuration.timeLineWith = 1;
    configuration.timeLineColor = [UIColor lightGrayColor];
    configuration.timeLineFillColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
//    configuration.timeGradientColors = @[(__bridge id)[UIColor redColor].CGColor, (__bridge id)[UIColor yellowColor].CGColor, (__bridge id)[UIColor blueColor].CGColor];
    
    configuration.avgTimeLineWidth = 1;
    configuration.avgTimeLineColor = [UIColor orangeColor];
    
    configuration.crosswireLineColor = [UIColor darkGrayColor];
    configuration.crosswireLineWidth = 1.f / [UIScreen mainScreen].scale;
    configuration.crosswireTextColor = [UIColor darkGrayColor];
    configuration.crosswireBackRiseColor = configuration.volumeRiseColor;
    configuration.crosswireBackFallColor = configuration.volumeFallColor;
    configuration.crosswireBackDateColor = [UIColor whiteColor];
    
    configuration.textFont = [UIFont yt_fontWithName:@"Thonburi" size:11];
    
    /// 2.0 添加配制 begin
    configuration.nFigureNum = 1;
    configuration.crosswireCentralPointMark = NO;
    configuration.timeOverlayLineColor = [UIColor redColor];
    configuration.timeOverlayOtherLineColor = [UIColor magentaColor];
    /// 2.0 添加配制 end
    
    return configuration;
}

@end
