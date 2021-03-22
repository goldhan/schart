//
//  YT_LineChartLayer.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2017/9/19.
//  Copyright © 2017年 kds. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

//UIKIT_EXTERN NSString * const YT_LineChartLayerLineColor;
@interface  YT_LineChartLineConfig :NSObject;
@property(nonatomic,assign)UIColor *strokColor;
@property(nonatomic,assign)CGFloat  strokWidth;
-(void)configContext:(CGContextRef)ctx;
@end

typedef enum : NSUInteger {
    kLineChartLayerLineTypeLine = 0,    ///< 连续的线
    kLineChartLayerLineTypeGird = 1,    ///< 类似柱状图
} YT_LineChartLayerLineType;

typedef enum : NSUInteger {
    kLineChartDrawStrategyIgnoreZero,       ///< 忽略最小值点
    kLineChartDrawStrategyIgnorePreZero,    ///< 忽略最开始的最小值点
    kLineChartDrawStrategyDrawAll,          ///< 绘Auto制在范围内的所有点
    kLineChartDrawStrategyDrawAllFixZeroToNil, ///< 修正0为nil，nil为跳过点，当NFloat数据都为0并且0不在绘制范围认为它是跳过点
    kLineChartDrawStrategyAutoFixZero,      ///< 修正0为nil，nil为跳过点，当NFloat数据都为0并且最小值点等于0时认为它是跳过点
} YT_LineChartDrawStrategy;                 ///< 画线策略

@class YT_LineChartLine;
typedef NFloat* (^YT_LineChartLineParseLineDataBlock)(YT_LineChartLine *line,NSInteger index);

@interface  YT_LineChartLine :YT_LineChartLineConfig;

/* YT_LineChartLine 高级用法实例
 @weakify(self)
 [line setParseLineDataBlock:^NFloat *(YT_LineChartLine *line,NSInteger index) {
     @strongify(self)
     NFloat *nTech = [NFloat zero];
     if (pos_+index<nKLineCount_) {//或者 stock_kline_data *klineData = line.lineData
         stock_kline_data *klineData = [self.klineRep.klineDataArrArray objectAtIndex:pos_+index];
         nTech = [NFloat initWithValue:[klineData.nTechArray valueAtIndex:0]];
     }
     return nTech;
 }];
 一定要保证parseLineDataBlock有数据返回
 */
@property(nonatomic,copy)YT_LineChartLineParseLineDataBlock parseLineDataBlock;
@property(nonatomic,strong)NSArray * lineData;                   ///< 线的数据，不一定需要设置
@property(nonatomic,assign)YT_LineChartLayerLineType lineType;
@property(nonatomic,assign)YT_LineChartDrawStrategy drawStrategy; ///< 画线策略

//kLineChartLayerLineTypeLine
+(YT_LineChartLine *)lineChartLineColor:(UIColor*)color drawStrategy:(YT_LineChartDrawStrategy)drawStrategy parseLineDataBlock:(YT_LineChartLineParseLineDataBlock)block;

@end;


@interface YT_LineChartDrawer : YT_LineChartLineConfig
//坐标系参数t
@property(nonatomic,assign)CGFloat xAxisWidth;  ///< x轴最小单位宽度

@property(nonatomic,assign)NSInteger nPos;      ///< 需要绘制的数据起始索引

@property(nonatomic,assign)NSInteger dataCount; ///< 预设数据个数，可不设
@property(nonatomic,assign)NSInteger maxShowCount; ///< 预设最大绘制的次数，可不设

@property(nonatomic,strong)NFloat *minValueOfBottom; ///< 坐标系y轴最小值
@property(nonatomic,strong)NFloat *maxValueOfTop;    ///< 坐标系y轴最大值

@property(nonatomic,assign)CGRect drawRect;

@property(nonatomic,strong)NSMutableArray<YT_LineChartLine *> *lines;

/**
 * 算useDataCount（nPos后的数据个数）和showCount（需要绘制的次数）
 * useDataCount = _dataCount<0?self.lines.firstObject.lineData.count - _nPos:_dataCount;
 * showCount = _maxShowCount <0?floorf(self.drawRect.size.width/_xAxisWidth):_maxShowCount;
 * showCount = MIN(dataCount, showCount);
 */
-(void)calculatePame;//

-(void)drawInContext:(CGContextRef)ctx;
@end
