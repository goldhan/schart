//
//  YT_BarCharDrawer.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2017/9/20.
//  Copyright © 2017年 kds. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YT_BarChartDrawer : NSObject

/**有默认值*/
@property(nonatomic,strong)UIColor *upStrokColor;
@property(nonatomic,strong)UIColor *downStrokColor;
@property(nonatomic,assign)CGFloat  strokWidth;
@property(nonatomic,assign)CGFloat itemGap;//间隙*0.5

@property(nonatomic,strong)NFloat *minValueOfBottom;
@property(nonatomic,strong)NFloat *maxValueOfTop;

/**需要赋值*/
@property(nonatomic,assign)CGRect drawRect;
@property(nonatomic,assign)CGFloat itemWidth;
@property(nonatomic,assign)NSInteger nPos;
@property(nonatomic,assign)NSInteger maxNumberOfShowing;

-(void)drawKlinDataArr:(NSArray<stock_kline_data *> *)klineDataArr inContext:(CGContextRef)ctx;

@end
