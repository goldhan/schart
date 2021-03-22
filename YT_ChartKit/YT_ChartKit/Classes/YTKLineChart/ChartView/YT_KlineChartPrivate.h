//
//  YT_KlineChartPrivate.h
//  Pods
//
//  Created by yt_liyanshan on 2018/9/5.
//

#import "YT_KLineChart.h"
#import "YT_ChartScaler.h"
#import "YT_TechZBChartContext.h"

//Tip: 当需要检查 YT_KLineChart (Private) 中的方法是否实现的时候可以把 Private 去掉，并注释掉属性声明
@interface YT_KLineChart (Private)

@property (nonatomic, strong) YT_KLineDataSource * kLineDataSource; ///<k线数据

@property (nonatomic, strong) YT_CandlestickLayer * candleLayer;  ///< 蜡烛线
@property (nonatomic, strong) CAShapeLayer * gridLayer_const;   ///< 网格层0 frame 等于scrollView的frame
@property (nonatomic, strong) CAShapeLayer * gridLayer_scroll; ///< 网格层1 内部坐标系 和scrollView的内部坐标系相同

@property (nonatomic, strong) YT_StockChartCanvas * stringLayer;  ///< k线坐标文字
@property (nonatomic, strong) YT_CrissCrossQueryView * crissQueryView;     ///< 查价层

@property (nonatomic, strong) YT_KlineExtremePointRenderer * candleExtremeRenderer;   ///< 蜡烛线极值点绘制器
@property (nonatomic, strong) YT_StringArrayRenderer * axisXStrRenderer;   ///< X轴渲染 （时间轴） k，v 公有
@property (nonatomic, strong) YT_StringArrayRenderer * kAxisYStrRenderer;    ///< K线Y轴
@property (nonatomic, strong) YT_StringArrayRenderer * kAxisYStrRendererRight;   ///< K线Y轴 Right

#pragma mark  KLine_MA图层
//kLineIndexLayer KLine_MA
@property (nonatomic, strong) YT_KLineMALayer * kLineIndexLayer;
@property (nonatomic, strong) UILabel * lableKLineIndex;

#pragma mark scaler
@property (nonatomic, strong) YT_ChartScaler * kScaler;     ///<kLineScaler
// YT_AxisYParser axisYParser = YT_AxisYParserMake(self.kLineDataSource.klineAxisParam.maxZDF, self.kLineDataSource.klineAxisParam.minZDF, self.kScaler.chartRect);
@property (nonatomic, copy) YT_AxisYParser kScalerAxisZDFParser;  ///< kLineScaler Exten 涨跌幅换算 点换涨跌幅

#pragma mark  浮点型格式化参数
@property (nonatomic, assign) YT_FloatFormat kFloatFormat; ///<  文字推荐显示

#pragma mark 手势
@property (nonatomic, assign) CGFloat currentZoom;  ///< 当前缩放比例
@property (nonatomic, assign) CGFloat zoomCenterSpacingLeft;    ///< 缩放中心K线位置距离左边的距离
@property (nonatomic, assign) NSUInteger zoomCenterIndex;     ///< 中心点k线

#pragma mark 刷新
@property (nonatomic, assign) BOOL isLoadingMore;       ///< 是否在刷新状态
@property (nonatomic, assign) BOOL isWaitPulling;       ///< 是否正在等待刷新

#pragma mark  附图部分
@property (nonatomic, strong) NSMutableArray<YT_TechZBChartContext *> *techZBChartContexts; ///< 技术指标

#pragma mark  layout
@property (nonatomic, assign) CGRect chartDrawWindowFrame;
@property (nonatomic, assign) UIEdgeInsets chartDrawInsets;

@property (nonatomic, assign) CGRect kDrawWindowFrame;
@property (nonatomic, assign) UIEdgeInsets kDrawInsets;

#pragma mark 实时更新

- (void)updateChartWithPos:(NSInteger)pos;
- (void)updateChartWithPos:(NSInteger)pos itemOff:(BOOL)itemOff;
/* 重绘path */
- (void)updateSubLayer;
/* 未长按 */
- (void)updateIndexStringForIndex:(NSInteger)index;
/* 长按 */
- (void)updateIndexStringForIndexUnderFocus:(NSInteger)index;
/** 实时更新背景层 - X横轴设置**/
- (void)ex_updateGridLayerAxisXWithRange:(NSRange)range rect:(CGRect)dateRect;

#pragma mark action

- (void)addGestureRecognizer;

/** 长按十字星 */
- (void)longPress:(UILongPressGestureRecognizer *)recognizer;

/** 更新十字星查价框 */
- (NSInteger)updateQueryLayerWithPoint:(CGPoint)velocity;

/** 长按时回调 */
- (void)longPressInKChartOfIndex:(NSInteger)index;

/** 长按结束 */
- (void)longPressInKChartDidEnded;

- (void)singleTap:(UITapGestureRecognizer *)gesture;
- (void)singleTapInKChart;
- (void)singleTapInVChart:(NSInteger)index;

/** 指标切换回调 switchButtonBlock bOpen 是否打开 index：附图的索引 */
- (void)techZBSwitchButtonBack:(BOOL)bOpen techIndex:(NSInteger)index ;

#pragma mark tool

- (NSRange)visibleRangeForCurrentOffsetX;
/** candleLayer 上的点 获取点对应的数据 */
- (NSInteger)indexFromConvertPonitX:(CGFloat)x;
/** candleLayer 上的点 获取点对应的数据 */
- (NSInteger)indexVisiableFromConvertPonitX:(CGFloat)x;
/** view 上的点 获取点对应的数据 */
- (NSInteger)indexVisiableFromConvertViewPonit:(CGPoint)point;
/**获取 item index 对应 view 上的 点的 x*/
- (CGFloat)viewPointXFormKLineIndex:(NSInteger)index;
/**获取 item index 对应 view 上的 点*/
- (CGPoint)viewPointFormKLineIndex:(NSInteger)index price:(double)aflaot;
/** view 判断点所在的区域 */
- (BOOL)viewPointIsInChart:(CGPoint)point;

#pragma mark other

- (YT_TechZBChartContext *)makeTechZBChartContext:(YT_TechZBExplain *)zbExplain;
@end
