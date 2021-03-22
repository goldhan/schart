//
//  YT_KLineChart.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/21.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_KLineChart.h"
//#import "YT_KlineChartPrivate.h"
#import "YT_KLineDataSource.h"
#import "YT_Grid.h"
#import "YT_Line.h"
#import "YT_Candlestick.h"
#import "YT_CandlestickLayer.h"
#import "YT_ChartScaler.h"

#import "YT_lineRectTextLayer.h"

#import "YT_KLineMALayer.h"
#import "YT_CrissCrossQueryView.h"
#import "YT_StockChartCanvas.h"
#import "YT_StringArrayRenderer.h"
#import "YT_KlineExtremePointRenderer.h"
#import "YT_StockChartConstants.h"

#import "YT_TechZBChartContext.h"
#import "YT_IndexLayer.h"

#import "YT_KLineChart+Layouter.h"
#import "YT_KLineChart+Extend.h"

@interface YT_KLineChart () <UIGestureRecognizerDelegate>
{
    BOOL _clossScrollViewScrollResponds;
    BOOL _tempLockScrollEnabled; // 临时变量
}
@property (nonatomic, strong) YT_KLineDataSource * kLineDataSource; ///<k线数据

@property (nonatomic, strong) YT_CandlestickLayer * candleLayer;  ///< 蜡烛线
@property (nonatomic, strong) YT_LineRectTextLayer *closePriceLineLayer; ///> 成交价定位线
@property (nonatomic, strong) CAShapeLayer * gridLayer_const;   ///< 网格层0 frame 等于scrollView的frame
@property (nonatomic, strong) CAShapeLayer * gridLayer_scroll; ///< 网格层1 内部坐标系 和scrollView的内部坐标系相同

@property (nonatomic, strong) YT_StockChartCanvas * stringLayer;  ///< k线坐标文字
@property (nonatomic, strong) YT_StockChartCanvas * stringLayer_scorll;  ///< k线坐标文字2
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

@end

@implementation YT_KLineChart

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        //配置
        _config = [[YT_KLineChartConfiguration alloc] init];

        //网格
        _gridLayer_const      = [[CAShapeLayer alloc] init];
        _gridLayer_scroll     = [[CAShapeLayer alloc] init];
        
        [self.layer insertSublayer:_gridLayer_const atIndex:0];
        [self.scrollView.layer addSublayer:_gridLayer_scroll];
        
        // 坐标轴上文字
        _stringLayer = [[YT_StockChartCanvas alloc] init];
        _stringLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _stringLayer_scorll = [[YT_StockChartCanvas alloc] init];
        _stringLayer_scorll.masksToBounds = NO;
//        [self.layer insertSublayer:_stringLayer atIndex:1];
        [self.layer addSublayer:_stringLayer];
        [self.scrollView.layer addSublayer:_stringLayer_scorll];
        
        //蜡烛线
        _candleLayer   = [[YT_CandlestickLayer alloc] init];
        [self.scrollView.layer addSublayer:_candleLayer];
        
        //成交价定位线
        _closePriceLineLayer = [[YT_LineRectTextLayer alloc] init];
        [self.layer addSublayer:_closePriceLineLayer];
        
        // K指标
        _kLineIndexLayer = [[YT_KLineMALayer alloc] init];
        [self.scrollView.layer addSublayer:_kLineIndexLayer];
        _kLineIndexLayer.configuration = self.config;
        
        //十字线查询层
        _crissQueryView = [[YT_CrissCrossQueryView alloc] init];
        _crissQueryView.hidden = YES;
        [self addSubview:_crissQueryView];
        
        // KLineChart title文字
        _lableKLineIndex = [UILabel new];
        [self addSubview:_lableKLineIndex];
        
        /// 蜡烛线极值点
        _candleExtremeRenderer = [[YT_KlineExtremePointRenderer alloc] init];
        [_stringLayer_scorll addRenderer:_candleExtremeRenderer];
        
        // 坐标轴上文字
        _axisXStrRenderer = [[YT_StringArrayRenderer alloc] init];
        [_stringLayer addRenderer:_axisXStrRenderer];
        _kAxisYStrRenderer = [[YT_StringArrayRenderer alloc] init];
        [self.stringLayer addRenderer:_kAxisYStrRenderer];
        _kAxisYStrRendererRight = [[YT_StringArrayRenderer alloc] init];
        [self.stringLayer addRenderer:_kAxisYStrRendererRight];
   
        _kFloatFormat = YTFloatFormatDefault();
        
        //数据源
        _kLineDataSource = [[YT_KLineDataSource alloc] init];
        _kScaler = [[YT_ChartScaler alloc] init];
        _kScalerAxisZDFParser = YT_AxisYParserMake(0,0,CGRectZero);
        
        // 默认创建 附图一
        YT_TechZBChartContext * techContext = [self makeTechZBChartContext:_kLineDataSource.attachedTechZBArray.firstObject];
        _techZBChartContexts = [NSMutableArray arrayWithObject:techContext];
     
        _currentZoom = -.001f;
        [self addGestureRecognizer];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _stringLayer.frame = self.bounds;
}

/** 设置k线方法 */
- (void)setKLineArray:(NSArray <id <YT_StockKlineData> > *)kLineArray {
    _kLineArray = kLineArray;
    // 初始化数据容器
    [self.kLineDataSource resetKlineDataArray:_kLineArray];
    [self resetKLineAxisxStringTexts:_kLineArray];
}

#pragma mark Attached api

- (NSInteger)attachedTechCount {
    return self.attachedTechZBArray.count;
}
- (void)setAttachedTechCount:(NSInteger)attachedTechCount {
    NSInteger subCount = self.techZBChartContexts.count - attachedTechCount;
    if (subCount > 0) { //remove
        while (subCount > 0) {
            YT_TechZBChartContext * techContext = self.techZBChartContexts.lastObject;
            [self.techZBChartContexts removeLastObject];
            if (techContext.zbExplain) {
                [self.kLineDataSource removeAttachedTechZB:techContext.zbExplain cleanCahe:NO];
            }
            subCount --;
        }
    }else if (subCount < 0) { //add
        while (subCount < 0) {
            [self addAttachedTechZB:YT_ZBType_VOL-subCount display:NO];
            subCount ++;
        }
    }
}

/* 新增需要计算的附图指标 , 返回索引*/
- (NSInteger)addAttachedTechZB:(YT_ZBType)zbType display:(BOOL)display {
    YT_TechZBExplain * zbExplain = [self.kLineDataSource addAttachedTechZB:zbType neddCaculate:display];
    YT_TechZBChartContext * techContext = [self  makeTechZBChartContext:zbExplain];
    [self.techZBChartContexts addObject:techContext];
    if (display) {
        //刷UI
        [self updateChart];
    }
    return _techZBChartContexts.count -1;
}

/* 删除图指标类型 */
- (BOOL)removeAttachedTechZBWithIndex:(NSInteger)index display:(BOOL)display {
    if (index >= self.techZBChartContexts.count) return NO;
    YT_TechZBChartContext * techContext = [self.techZBChartContexts objectAtIndex:index];
    [self.techZBChartContexts removeObjectAtIndex:index];
    if (techContext.zbExplain) {
        [self.kLineDataSource removeAttachedTechZB:techContext.zbExplain cleanCahe:NO];
    }
    if (display) {
         //刷UI
        [techContext clearContext];
        [self updateChart];
    }
    return YES;
}

/* 改变副图指标类型 返回是否成功 */
- (BOOL)setAttachedTechZBWithIndex:(NSInteger)index to:(YT_ZBType)zbType display:(BOOL)display {
    if (index >= self.techZBChartContexts.count) return NO;
     YT_TechZBChartContext * techContext = [self.techZBChartContexts objectAtIndex:index];
     if (techContext.zbExplain) {
         [self.kLineDataSource changeAttachedTechZB:techContext.zbExplain to:zbType neddCaculate:display cleanCahe:NO];
     }
    if (display) {
        [self resetAttachedTechIndexLayer:zbType context:techContext needsDisplay:YES];
    }
    return YES;
}

// _kScaler must no null
- (YT_TechZBChartContext *)makeTechZBChartContext:(YT_TechZBExplain *)zbExplain {
    YT_TechZBChartContext * techContext = [[YT_TechZBChartContext alloc] init];
    YT_ChartYScaler * scaler = [[YT_ChartYScaler alloc] init];
    scaler.xRelyon = self.kScaler;
    techContext.scaler = scaler;
    techContext.stringCanvas = self.stringLayer;
    techContext.zbExplain = zbExplain;
    [self addSubview:techContext.indexInfoLable];
    [self addSubview:techContext.switchButtonView];
    
    __weak typeof(self) wslef = self;
    __weak typeof(techContext) wtechContext = techContext;
    techContext.switchButtonView.switchButtonBlock = ^(BOOL bOpen) {
        NSInteger idx = [wslef.techZBChartContexts indexOfObject:wtechContext];
        if (idx != NSNotFound) {
             [wslef techZBSwitchButtonBack:bOpen techIndex:idx];
        }
    };
    
    return techContext;
}

#pragma mark - switchButtonBlock
/** 指标切换回调 switchButtonBlock bOpen 是否打开 index：附图的索引 */
- (void)techZBSwitchButtonBack:(BOOL)bOpen techIndex:(NSInteger)index {
}
#pragma mark kchart api

/** 切换kline指标 */
- (void)setKLineZBType:(YT_ZBType)volumZBType {
    // 计算指标重置
    // ...
    // 指标层重置/创建指标层
    [self.kLineIndexLayer configLayer];
    [self updateSubLayer];
}

- (void)zoomOrZoomOut:(BOOL) isZoom didEnd:(void (^)(void))didEnd {
    CGFloat kShapeWidth = self.config.kShapeWidth - 1;
    NSLog(@"%lf",self.config.kMinShapeWidth);
    if (isZoom) {
        kShapeWidth = self.config.kShapeWidth + 1;
        if (kShapeWidth + 1 > self.config.kMaxShapeWidth) {
            didEnd();
            if (kShapeWidth > self.config.kMaxShapeWidth) {
                return;
            }
        }
    } else {
        if (kShapeWidth - 1 < self.config.kMinShapeWidth) {
            didEnd();
            if (kShapeWidth < self.config.kMinShapeWidth) {
                return;
            }
        }
    }
    // 极大值极小值
    if (kShapeWidth > self.config.kMaxShapeWidth) {
        //        didEnd();
        kShapeWidth = self.config.kMaxShapeWidth;
    } else if (kShapeWidth < self.config.kMinShapeWidth){
        //        didEnd();
        kShapeWidth = self.config.kMinShapeWidth;
    }
    if (self.config.kShapeWidth == kShapeWidth) return;
    
    self.config.kShapeWidth = kShapeWidth;
    //        self.config.kLineCountVisibale = self.kScaler.chartRect.size.width / kShapeWidth;
    
    _clossScrollViewScrollResponds = YES;
    // 若设置ScrollViewContentSize 时关闭了隐式动画，在边缘缩小是会跳变
    [self configScalerAndUpdateSubLayersFrame];
    _clossScrollViewScrollResponds = NO;
    
    // 定位中间的k线
    CGFloat shape_x = self.kScaler.axisXScaler(_zoomCenterIndex);
    CGFloat offsetX = shape_x - _zoomCenterSpacingLeft;
    
    CGFloat maxoffsetX = self.backScrollViewMaxOffX;
    //        NSLog(@"chart offsetX b contentOffset %@",NSStringFromCGPoint(self.scrollView.contentOffset));
    offsetX = offsetX < 0 ? 0 : (offsetX > maxoffsetX ? maxoffsetX : offsetX);
    //        NSLog(@"chart offsetX %lf stepZoom %lf",offsetX,stepZoom);
    //        NSLog(@"chart offsetX e contentOffset %@",NSStringFromCGPoint(self.scrollView.contentOffset));
    
    [self updateSubLayer];
    // 设置滚动位置
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentSize.width - self.frame.size.width, 0);
}

- (void)moveView:(BOOL) isRight didEnd:(void(^)(void)) didEnd {
    if (self.scrollView.contentSize.width <= self.frame.size.width) {
        didEnd();
        return;
    }
    CGFloat offset = self.scrollView.contentOffset.x + self.config.kShapeWidth;
    if (!isRight) {
        offset = self.scrollView.contentOffset.x - self.config.kShapeWidth;
    }
    if (offset < -self.config.kShapeWidth || offset > (self.scrollView.contentSize.width - self.frame.size.width + self.config.kShapeWidth)) {
        didEnd();
        return;
    }
    if (offset < 0 || offset > (self.scrollView.contentSize.width - self.frame.size.width)) {
        didEnd();
    }
    self.scrollView.contentOffset = CGPointMake(offset, 0);
}

#pragma mark 背景网格层文字/轴线文字设置
- (void)resetKLineAxisxStringTexts:(NSArray <id <YT_StockKlineData> > *)kLineArray {
    _kFloatFormat = YTFloatFormatDefault();
    [self.techZBChartContexts enumerateObjectsUsingBlock:^(YT_TechZBChartContext * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.floatFormat = YTFloatFormatDefault();
    }];
}

#pragma mark - 重置/初始化视图

/** 初始化视图 */
- (void)initChart {
   [self updateChartWithPos:self.kLineArray.count];
}
- (void)updateChart {
    [self updateChartWithPos:-1];
}
- (void)updateChartWithPos:(NSInteger)pos {
    [self updateChartWithPos:pos itemOff:NO];
}

- (void)updateChartWithPos:(NSInteger)pos itemOff:(BOOL)itemOff  {
    if (self.onceShow == NO) {
        self.onceShow = YES;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self _updateChartWithPos:pos itemOff:itemOff];
        [CATransaction commit];
    }else{
        [self _updateChartWithPos:pos itemOff:itemOff];
    }
}

- (void)_updateChartWithPos:(NSInteger)pos itemOff:(BOOL)itemOff {
    // 确定布局位置
    [self updateChartRect];
    
    // 指标层重置/创建指标层
    //    [self resetKLineIndexLayer:_kLineIndexIndex]; 这个不变一直是 closs ma
    [self resetAttachedTechIndexLayerNeedsDisplay:NO];
    
    [self configRendererAndLayer];
    // 绘制固定的网格
    [self updateGridBackLayer];
    if (_kLineArray.count == 0) { return; }
    [self configScalerAndUpdateSubLayersFrame];
    
    //判断是否更新 contentOffset
    if (pos > 0) {
        // 计算显示的在屏幕中的k线
        CGPoint point = CGPointZero;
        point = [self.scrollView.layer convertPoint:point toLayer:self.candleLayer];
        CGPoint contentOffset  = self.scrollView.contentOffset;
        double off_x = contentOffset.x;
        
        if (itemOff) { //#ifdef KLINECHART_UPDATECHART_NEEDITEMOFF #endif
            ///因为外部算的displayRange是roundIndexFromAxisXParser算的所以这里还是这样算
            NSInteger curPos = [self.kScaler roundIndexFromAxisXParser:contentOffset.x - point.x];
            NSInteger offPos = pos - curPos;
            double sub_w = (self.kScaler.shapeWidth + self.kScaler.shapeInterval) * offPos;
            off_x = contentOffset.x + sub_w;
        }else{
            off_x = self.kScaler.axisXScaler(pos) - (self.kScaler.shapeWidth + self.kScaler.shapeInterval) * 0.5;
            off_x += point.x;
        }
        
        CGFloat minoffx = self.backScrollViewMinOffX;
        CGFloat maxoffx = self.backScrollViewMaxOffX;
        if (off_x < minoffx) {
            off_x = minoffx;
        }else if (off_x > maxoffx){
            off_x = maxoffx;
        }
        
        contentOffset.x =  off_x;
        _clossScrollViewScrollResponds = YES;
        [self.scrollView setContentOffset:contentOffset animated:NO];
        _clossScrollViewScrollResponds = NO;
    }
    
    [self updateSubLayer];
}

#pragma mark  public tool 更新数据量后更新视图

/** 插入新的数据后 更新K线图 */
- (void)updateChartForDIdInsetedKlineData:(NSArray <id <YT_StockKlineData> > *)kLineArray {
    //更新dataSource 和初始化数据容器
     [self.kLineDataSource.cacheManager cacheArrayInsertObjsAtIndex0:kLineArray.count];
     [self.kLineDataSource makeDefData];
    //更新位置
    BOOL lockScrollEnabled = NO;
    if (self.scrollView.userInteractionEnabled && self.scrollView.isDragging) { //must
        self.scrollView.userInteractionEnabled = NO;
        lockScrollEnabled = YES;
    }
//    CGFloat contentInset_l =  self.scrollView.contentInset.left;
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGFloat contentSize_w = self.scrollView.contentSize.width;
    [self configScalerAndUpdateSubLayersFrame];
    CGFloat contentSize_afterw = self.scrollView.contentSize.width;
    
//    CGFloat fixOffx = 0;
//    if (contentOffset.x < - contentInset_l) { //scrollview 本身特性 contentOffset.x 小于0时 是更新contentOffset不需要多加偏移否则位置不对,因为会有会有默认回弹 scrollEnabled / userInteractionEnabled = NO。取消了默认回弹?
//        fixOffx = MAX(-contentInset_l, contentOffset.x) + (contentSize_afterw - contentSize_w) ;
//    }
    
     contentOffset.x = contentOffset.x + (contentSize_afterw - contentSize_w);
    _clossScrollViewScrollResponds = YES;
    [self.scrollView setContentOffset:contentOffset animated:NO];
    _clossScrollViewScrollResponds = NO;
    if (lockScrollEnabled) {  //must
        self.scrollView.scrollEnabled = NO;
        self.scrollView.scrollEnabled = YES;
        self.scrollView.userInteractionEnabled = YES;
    }
    //更新layer
    [self updateSubLayer];
}

/** 末尾删除数据个数,并末尾添加K线数据 */
- (void)updateChartForDIdReplacedKlineDataAtLast:(NSInteger)count withKlineData:(NSArray <id <YT_StockKlineData> > *)kLineArray {
    //更新dataSource 和初始化数据容器
    if (count > 0) {
        [self.kLineDataSource.cacheManager cacheArrayDeletObjsAtLast:count];
    }
    if (kLineArray && kLineArray.count >0) {
        [self.kLineDataSource.cacheManager cacheArrayAppendObjectObjs:kLineArray.count];
    }
    [self.kLineDataSource makeDefData];
    //更新contentSize
    [self configScalerAndUpdateSubLayersFrame];
    //更新layer
    [self updateSubLayer];
}

#pragma mark 重置 Attached 视图

- (void)resetAttachedTechIndexLayerNeedsDisplay:(BOOL)display {
    [self.techZBChartContexts enumerateObjectsUsingBlock:^(YT_TechZBChartContext * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self resetAttachedTechIndexLayer:obj.zbType context:obj needsDisplay:display];
    }];
}

- (void)resetAttachedTechIndexLayer:(YT_ZBType)zbType index:(NSUInteger)idx needsDisplay:(BOOL)display {
    if (self.techZBChartContexts.count < idx) return;
    YT_TechZBChartContext * techContext = [self.techZBChartContexts objectAtIndex:idx];
    [self resetAttachedTechIndexLayer:zbType context:techContext needsDisplay:display];
}

- (void)resetAttachedTechIndexLayer:(YT_ZBType)zbType context:(YT_TechZBChartContext*)techContext needsDisplay:(BOOL)display {
    [techContext.indexLayer removeFromSuperlayer]; // 移除旧的
    [techContext resetIndexLayerIfNeeded:zbType];
    CALayer<YT_IndexLayerProtocol> * indexLayer = techContext.indexLayer;
    
    if ([indexLayer conformsToProtocol:@protocol(YT_IndexLayerProtocol)]) {
        indexLayer.configuration = self.config;
        indexLayer.dataArray = self.kLineDataSource.cacheManager.cacheArray;
        if ([indexLayer respondsToSelector:@selector(klineDataArray)]) {
            indexLayer.klineDataArray = self.kLineDataSource.klineDataArray;
        }
        if ([indexLayer respondsToSelector:@selector(dataSource)]) {
            indexLayer.dataSource = self.kLineDataSource;
        }
        [indexLayer configLayer];
    }
    techContext.floatFormat = YTFloatFormatDefault(); //重置floatFormat
    [self.scrollView.layer addSublayer:indexLayer];
    if(display) [self updateSubLayer];
}

#pragma mark -
#pragma mark  基础配置 layerConfig

/** 基础配置渲染器 */
- (void)configRendererAndLayer {
    
    // 绘制文字网格层
    self.gridLayer_const.strokeColor = self.config.gridColor.CGColor;
    self.gridLayer_const.fillColor = [UIColor clearColor].CGColor;
    self.gridLayer_const.lineWidth = .5f;
    self.gridLayer_scroll.strokeColor = self.config.gridColor.CGColor;
    self.gridLayer_scroll.fillColor = [UIColor clearColor].CGColor;
    self.gridLayer_scroll.lineWidth = .5f;
    
    //蜡烛线配置
    self.candleLayer.riseColor = self.config.riseColor;
    self.candleLayer.fallColor = self.config.fallColor;
    self.candleLayer.holdColor = self.config.holdColor;
    self.candleLayer.clossColor = self.config.closslineColor;
    self.candleLayer.clossAreaColor = self.config.closslineAreaColor;
    self.candleLayer.closslineWidth = self.config.closslineWidth;
    
    self.candleLayer.chartScaler = self.kScaler;//
    self.candleLayer.kLineArray = self.kLineArray;//
    [self.candleLayer configLayer];
    
    //成交价定位线
    self.closePriceLineLayer.lineColor = self.config.closePriceLineColor;
    self.closePriceLineLayer.textRectBG = self.config.closePriceLineColor;
    self.closePriceLineLayer.chartScaler = self.kScaler;
    self.closePriceLineLayer.kLineArray = self.kLineArray;
    [self.closePriceLineLayer configLayer];
    
//    k线区域 ma线 (因为在这里 k线区域 的指标layer 不变所以在 基础配置 这里写
    self.kLineIndexLayer.chartScaler = self.kScaler; //
    self.kLineIndexLayer.dataSource = self.kLineDataSource;//
    [self.kLineIndexLayer configLayer];

    //crissQueryView
    self.crissQueryView.yCirssLableLeftOffsetX = 2;
    
//     X横轴设置
    self.axisXStrRenderer.color = self.config.axisXTextColor;
    self.axisXStrRenderer.font = self.config.axisXTextFont;
    self.axisXStrRenderer.offSetRatio = YTRatioBottomCenter;
    
//     Y纵轴设置 - K线
    self.kAxisYStrRenderer.color = self.config.kAxisYTextColor;
    self.kAxisYStrRenderer.font = self.config.kAxisYTextFont;
    self.kAxisYStrRenderer.offSetRatio = YTRatioTopRight;
    
    self.kAxisYStrRendererRight.color = self.config.kAxisYTextColor;
    self.kAxisYStrRendererRight.font = self.config.kAxisYTextFont;
    self.kAxisYStrRendererRight.offSetRatio = YTRatioTopLeft;
    
    __weak typeof(self) weakSelf = self;
    [self.kAxisYStrRenderer setStringBlock:^NSString *(CGPoint point, NSInteger index, NSInteger count) {
        YTSCFloat afloat = 0;
        if (index == 0) {
            afloat = weakSelf.kScaler.max;
        }else if (index == count - 1){
            afloat = weakSelf.kScaler.min;
        }else{
            CGPoint thisPoint = [weakSelf.layer convertPoint:point toLayer:weakSelf.candleLayer];
            afloat = weakSelf.kScaler.axisYParser (thisPoint.y);
        }
        int digit = weakSelf.kFloatFormat.decimalPlaces;
        afloat *= weakSelf.config.truthfulValueFloat;
        return [NSString stringWithFormat:@"%.*lf", digit, afloat];
    }];
    
    [self.kAxisYStrRenderer setColorsBlock:^UIColor *(YT_StringArrayRenderer *renderer, NSInteger index) {
        CGPoint  point = [renderer.stringPoints objectAtIndex:index].CGPointValue;
        CGPoint thisPoint = [weakSelf.layer convertPoint:point toLayer:weakSelf.candleLayer];
        YTSCFloat afloat = weakSelf.kScalerAxisZDFParser(thisPoint.y);
        if (afloat > 0)  {
            return weakSelf.config.riseColor;
        }else if (afloat < 0){
            return weakSelf.config.fallColor;
        }else{
            return weakSelf.config.holdColor;
        }
    }];
    
    [self.kAxisYStrRenderer setOffSetRatiosBlock:^CGPoint(YT_StringArrayRenderer *renderer, NSInteger index) {
        if (index == 0) {
            return  YT_RATIO_POINT_CONVERT(YTRatioBottomRight);
        }
        return YT_RATIO_POINT_CONVERT(YTRatioTopRight);
    }];
    
    [self.kAxisYStrRendererRight setStringBlock:^NSString *(CGPoint point, NSInteger index, NSInteger count) {
        CGPoint thisPoint = [weakSelf.layer convertPoint:point toLayer:weakSelf.candleLayer];
        YTSCFloat afloat = weakSelf.kScalerAxisZDFParser(thisPoint.y) * 100;
        int digit = weakSelf.kFloatFormat.decimalPlaces;
        return [NSString stringWithFormat:@"%+.*lf%%", digit, afloat];
    }];
    
    [self.kAxisYStrRendererRight setColorsBlock:self.kAxisYStrRenderer.colorsBlock];
    
    [self.kAxisYStrRendererRight setOffSetRatiosBlock:^CGPoint(YT_StringArrayRenderer *renderer, NSInteger index) {
        if (index == 0) {
            return  YT_RATIO_POINT_CONVERT(YTRatioBottomLeft);
        }
        return YT_RATIO_POINT_CONVERT(YTRatioTopLeft);
    }];
    
    // 蜡烛线极值点绘制器 candleExtremeRenderer
//    self.candleExtremeRenderer.texColor =
    
    //title lable
    self.lableKLineIndex.font = self.config.lableKLineIndexFont;
    self.lableKLineIndex.textColor = self.config.lableKLineIndexColor;
    
 //----------- 附图 ----
    [self.techZBChartContexts enumerateObjectsUsingBlock:^(YT_TechZBChartContext * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         //     Y纵轴设置 - 成交量
        obj.axisStrRenderer.color =  self.config.vAxisYTextColor;
        obj.axisStrRenderer.font = self.config.vAxisYTextFont;
        obj.axisStrRenderer.offSetRatio = YTRatioTopLeft;
    
        __weak typeof (obj) wObj = obj;
        [obj.axisStrRenderer setStringBlock:^NSString *(CGPoint point, NSInteger index, NSInteger count) {
            YTSCFloat afloat = 0;
            if (index == 0) {
                 afloat =  wObj.scaler.max;
            }else if (index == count - 1){
                afloat =  wObj.scaler.min;
            }else{
                CGPoint thisPoint = [weakSelf.layer convertPoint:point toLayer:wObj.indexLayer];
                afloat = wObj.scaler.axisYParser (thisPoint.y);
            }
            afloat *= weakSelf.config.truthfulValueFloat;
            
            CALayer<YT_IndexLayerProtocol> * volumIndexLayer = wObj.indexLayer;
            if (volumIndexLayer && [volumIndexLayer respondsToSelector:@selector(axisStringWithValue:)]) {
                return [volumIndexLayer axisStringWithValue:afloat];
            }
            int  digit = wObj.floatFormat.decimalPlaces;
            return [NSString stringWithFormat:@"%.*lf",digit, afloat];
        }];
        
        [obj.axisStrRenderer setOffsetsBlock:^CGSize(YT_StringArrayRenderer *renderer, NSInteger index) {
            if (index == 0) {
                return  CGSizeMake(0, renderer.font.lineHeight);
            }
            return CGSizeZero;
        }];
        
        //info lable
        obj.indexInfoLable.font = self.config.lableVolumIndexFont;
        obj.indexInfoLable.textColor = self.config.lableVolumIndexColor;
        obj.switchButtonView.textFont = self.config.lableVolumIndexFont;
        obj.switchButtonView.textColor = self.config.lableVolumIndexColor;
    }];
    
}

#pragma mark 配置测量器 更新contentSize

- (void)configInitScaler:(CGFloat)scWidth {
    //init  self.config.kShapeWidth;
    if (self.config.kShapeWidthInit > 0) {
        self.config.kShapeWidth = self.config.kShapeWidthInit;
//        self.config.kLineCountVisibale = scWidth / self.config.kShapeWidth;
    }else{
        self.config.kShapeWidth =  scWidth / self.config.kLineCountVisibaleInit;
//        self.config.kLineCountVisibale =  self.config.kLineCountVisibaleInit;
    }
    
    // 极大值极小值
    NSInteger maxNum = self.config.kMaxCountVisibale;
    NSInteger minNum = self.config.kMinCountVisibale;
    CGFloat maxShapeWidth2 = scWidth / minNum;
    CGFloat mimShapeWidth2 = scWidth / maxNum;
    
    if (self.config.kMaxShapeWidth > maxShapeWidth2) {
        self.config.kMaxShapeWidth = maxShapeWidth2;
    }
    if (self.config.kMinShapeWidth < mimShapeWidth2) {
        self.config.kMinShapeWidth = mimShapeWidth2;
    }
}

/** 在 k线数量改变后调用重新更新 Scaler 和 更新 subLayersFrame 更新 self.scrollView.contentSize*/
- (void)configScalerAndUpdateSubLayersFrame {
    
    //** 设置 scaler **/
    // 在子layer的坐标系算的 bounds
    CGRect klineBounds = YT_EdgeInsetsExRectBounds(_kDrawWindowFrame, _kDrawInsets);
    
    // 看看是否需要初始化配置
    if (self.config.kShapeWidth <= 0) {
        [self configInitScaler:klineBounds.size.width];
    }
    
    self.kScaler.chartRect = klineBounds;
    self.kScaler.totalShapeCount = self.kLineArray.count;
    self.kScaler.shapeWidth = self.config.kShapeWidth;
    self.kScaler.shapeInterval = self.config.kShapeInterval;
    [self.kScaler updateAxisX];
    
    [self.techZBChartContexts enumerateObjectsUsingBlock:^(YT_TechZBChartContext * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGRect volumBounds = YT_EdgeInsetsExRectBounds(obj.drawWindowFrame, obj.drawInsets);
            obj.scaler.chartRect = volumBounds;
//            obj.scaler.totalShapeCount = self.kLineArray.count;
//            obj.scaler.shapeWidth = self.config.kShapeWidth;
//            obj.scaler.shapeInterval = self.config.kShapeInterval;
//            [obj.scaler updateAxisX];
    }];
    
    /** 求 contentSize **/
    CGRect chartLayer_rect_min = YT_EdgeInsetsExRect(_chartDrawWindowFrame, _chartDrawInsets);
    CGFloat chartLayer_min_w = chartLayer_rect_min.size.width;
    UIEdgeInsets drawInsets = _chartDrawInsets;
    CGSize contentSize = CGSizeMake(self.kScaler.contentWidth + drawInsets.left + drawInsets.right, 0);
    if (contentSize.width < chartLayer_min_w) {
        contentSize.width = chartLayer_min_w;
    }
    CGRect scrollViewFrame = self.scrollView.frame;
    
    /** 求 layerFrame **/
    CGRect klayerFrame = YT_EdgeInsetsExRect(_kDrawWindowFrame, _kDrawInsets);
    klayerFrame.size.width = contentSize.width;
    CGRect lableKLineIndexFrame = [self lableKLineIndexFrame];
    
    // 设置sublayer时关闭隐士动画
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    // 网格
    self.gridLayer_const.frame = scrollViewFrame; // 这层是加在 self.layer 上的
//    self.gridLayer_scroll.bounds = scrollViewContentFrame;
        // 调整 gridLayer_scroll 的布局方式 使得gridLayer_scroll 内部坐标系 和 scrollView的内部坐标系相同
    self.gridLayer_scroll.frame = CGRectMake(0, 0, contentSize.width, CGRectGetHeight(scrollViewFrame));
    self.stringLayer_scorll.frame = CGRectMake(0, 0, contentSize.width, CGRectGetHeight(scrollViewFrame));
    
    self.crissQueryView.frame = _chartDrawWindowFrame;
    
    // K线与K线指标大小
    self.candleLayer.frame = klayerFrame;
    self.kLineIndexLayer.frame = klayerFrame;
    self.lableKLineIndex.frame = lableKLineIndexFrame;
    
    // 成交价定位线
    CGRect closePriceLineLayerF = klayerFrame;
    closePriceLineLayerF.size.width = scrollViewFrame.size.width;
    self.closePriceLineLayer.frame = closePriceLineLayerF;
    
    // 量能区域的指标
    [self.techZBChartContexts enumerateObjectsUsingBlock:^(YT_TechZBChartContext * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect layerFrame = YT_EdgeInsetsExRect(obj.drawWindowFrame, obj.drawInsets);
        layerFrame.size.width = contentSize.width;
        obj.indexLayer.frame = layerFrame;
        obj.indexInfoLable.frame = [self lableVolumIndexFrameAtIndex:idx];
        obj.switchButtonView.frame = CGRectMake(0, obj.indexInfoLable.frame.origin.y, kWidthButton + 2*kLeftEdge, obj.indexInfoLable.frame.size.height);
    }];
    
    [CATransaction commit];
    
    // 滚动大小 这里不能禁止动画，否则缩放手势缩小时跳变
    self.scrollView.contentSize = contentSize;
    
//  使用这种方式 使得 scrollview 的 子 view 和 scrollview 使用相同坐标系
//  _candleLayer.bounds = _kLineChartFrame;
//  _candleLayer.position = CGPointMake(CGRectGetMidX(_kLineChartFrame), CGRectGetMidY(_kLineChartFrame));
}

#pragma mark - 绘制

- (void)updateGridBackLayer {
    
    CGMutablePathRef ref = CGPathCreateMutable();
    // k线网格
    YT_Grid gridKLine = YT_GridRectMake(_kDrawWindowFrame, self.config.kAxisYSplit, 0);
    CGPathAddYTGrid(ref, gridKLine);
    
    // 成交量网格
    [self.techZBChartContexts enumerateObjectsUsingBlock:^(YT_TechZBChartContext * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YT_Grid gridLine = YT_GridRectMake(obj.drawWindowFrame, self.config.vAxisYSplit, 0);
        CGPathAddYTGrid(ref, gridLine);
    }];

    self.gridLayer_const.path = ref;
    CGPathRelease(ref);
}

#pragma mark 实时更新
- (void)updateSubLayer {
    if (self.kLineArray.count == 0) return;
    NSRange range = [self visibleRangeForCurrentOffsetX];
    // 更新视图
    [self updateSubLayer:range];
}

- (void)updateSubLayerIfNeed {
    if (self.kLineArray.count == 0) return;
    NSRange range = [self visibleRangeForCurrentOffsetX];
    if(self.kLineDataSource.displayRange.location ==  range.location && self.kLineDataSource.displayRange.length == range.length){
        [self updateGridLayerWithRange:range];
    }else{
        // 更新视图
        [self updateSubLayer:range];
    }
}

- (void)updateSubLayer:(NSRange)range {
    
    // 计算
    [self.kLineDataSource changeDisplayRangeAndResetAllDataIfNeed:range];
    
    // 调整 文字显示单位和小数点
    _kFloatFormat = [self textAdjustDigitThisInKChart:self.kLineDataSource.klineAxisParam.minPrice];
    [self.techZBChartContexts enumerateObjectsUsingBlock:^(YT_TechZBChartContext * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj textAdjustDigitInChart:obj.zbExplain.axisParam.min template:self.kFloatFormat];
    }];
    
    // 更新视图
    [self updateKLineLayerWithRange:range];
    [self updateVolumLayerWithRange:range];
    [self updateGridLayerWithRange:range];
    
    [self updateIndexStringForIndex:NSMaxRange(range) - 1];
}

/**
 实时更新背景层
 更新 坐标上的文字 以及 网格 中的竖线(网格可变部分)
 */
- (void)updateGridLayerWithRange:(NSRange)range {
   // 更新 坐标上的文字 以及 网格 中的竖线(网格可变部分)

    CGRect kLineChartFrame = _kDrawWindowFrame;
    
// K线Y轴设置
    self.kScalerAxisZDFParser = YT_AxisYParserMake(self.kLineDataSource.klineAxisParam.maxZDF, self.kLineDataSource.klineAxisParam.minZDF, UIEdgeInsetsInsetRect(self.kScaler.chartRect, self.config.kChartTBDrawGap));
    
    YT_Line kLine = YT_LeftLineRect(kLineChartFrame);
    NSMutableArray <NSValue *>* pointArr =  [YT_StringArrayRenderer pointArrayFormPoint:kLine.start toPoint:kLine.end sepCount:self.config.kAxisYSplit offset:CGPointZero];
    self.kAxisYStrRenderer.stringPoints = pointArr;

    YT_Line kLineR = YT_RightLineRect(kLineChartFrame);
    NSMutableArray <NSValue *>* pointArrR =  [YT_StringArrayRenderer pointArrayFormPoint:kLineR.start toPoint:kLineR.end sepCount:self.config.kAxisYSplit offset:CGPointZero];
    self.kAxisYStrRendererRight.stringPoints = pointArrR;
    
// 成交量Y轴设置
    [self.techZBChartContexts enumerateObjectsUsingBlock:^(YT_TechZBChartContext * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YT_Line vLine = YT_RightLineRect(obj.drawWindowFrame);
        NSMutableArray <NSValue *>* vPointArr =  [YT_StringArrayRenderer pointArrayFormPoint:vLine.start toPoint:vLine.end sepCount:self.config.vAxisYSplit offset:CGPointZero];
        obj.axisStrRenderer.stringPoints = vPointArr;
    }];
    
// X横轴设置
    [self ex_updateGridLayerAxisXWithRange:range rect:self.gridAxisXDateTextRect];
    
/// 蜡烛线极值点
    NSInteger maxIndex = self.kLineDataSource.klineCAxisParam.maxIndex;
    NSInteger minIndex = self.kLineDataSource.klineCAxisParam.minIndex;
    
    YTSCFloat max = self.kLineDataSource.klineCAxisParam.max;
    YTSCFloat min = self.kLineDataSource.klineCAxisParam.min;

    _candleExtremeRenderer.drawRect = self.scrollView.bounds;
//    [self viewPointFormKLineIndex:maxIndex price:max];    
    _candleExtremeRenderer.maxPoint = CGPointMake(self.kScaler.axisXScaler(maxIndex) + self.candleLayer.frame.origin.x, self.kScaler.axisYScaler(max) + self.candleLayer.frame.origin.y);
    //[self viewPointFormKLineIndex:minIndex price:min];
    _candleExtremeRenderer.minPoint = CGPointMake(self.kScaler.axisXScaler(minIndex) + self.candleLayer.frame.origin.x, self.kScaler.axisYScaler(min) + self.candleLayer.frame.origin.y);
    
    int digit = self.kFloatFormat.decimalPlaces;;
    _candleExtremeRenderer.maxText = [NSString stringWithFormat:@"%.*lf",digit,max];
    _candleExtremeRenderer.minText = [NSString stringWithFormat:@"%.*lf",digit,min];
    
    [self.stringLayer setNeedsDisplay];
    [self.stringLayer_scorll setNeedsDisplay];
}

/** K线图实时更新 */
- (void)updateKLineLayerWithRange:(NSRange)range
{
    // 计算k线最大最小
//    CGFloat max = FLT_MIN;
//    CGFloat min = FLT_MAX;
//    [_kLineArray getKLineMax:&max min:&min range:range];
//    [_kLineIndexLayer getIndexWithRange:range max:&max min:&min];

    self.kScaler.max = self.kLineDataSource.klineAxisParam.maxPrice;
    self.kScaler.min = self.kLineDataSource.klineAxisParam.minPrice;
    [self.kScaler updateAxisYForInsets:self.config.kChartTBDrawGap];
    
    // 更新k线层
    [self.candleLayer updateLayerWithRange:range];
    
    // 成交价定位线
    [self.closePriceLineLayer updateLayerWithRange:range];
    
    // k线指标
    self.kLineIndexLayer.textDecimalPlaces = self.kFloatFormat.decimalPlaces;
    self.kLineIndexLayer.textUnits = self.kFloatFormat.units;
    [self.kLineIndexLayer updateLayerWithRange:range];
    
    [self.stringLayer setNeedsDisplay];
}

/** 柱状图实时更新 */
- (void)updateVolumLayerWithRange:(NSRange)range {
//    // 计算柱状图最大最小
//    CGFloat max = FLT_MIN;
//    CGFloat min = FLT_MAX;
//    [self.volumIndexLayer getIndexWithRange:range max:&max min:&min];
//    [self.volumIndexLayer updateLayerWithRange:range max:max min:min];
    
    [self.techZBChartContexts enumerateObjectsUsingBlock:^(YT_TechZBChartContext * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj updateIndexLayerWithRange:range];
    }];
    
    [self.stringLayer setNeedsDisplay];
}

/* 未长按 */
- (void)updateIndexStringForIndex:(NSInteger)index {
    self.lableKLineIndex.attributedText = [self.kLineIndexLayer attrStringWithIndex:index];
    [self.techZBChartContexts enumerateObjectsUsingBlock:^(YT_TechZBChartContext * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.indexInfoLable.attributedText = [obj.indexLayer titleAttributedString];
    }];
}

/* 长按 */
- (void)updateIndexStringForIndexUnderFocus:(NSInteger)index {
    self.lableKLineIndex.attributedText = [self.kLineIndexLayer attrStringWithIndex:index];
    [self.techZBChartContexts enumerateObjectsUsingBlock:^(YT_TechZBChartContext * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.indexInfoLable.attributedText = [obj.indexLayer attrStringWithIndex:index];
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_clossScrollViewScrollResponds) return;

    [self updateSubLayerIfNeed];

    if (self.loadMoreBlock) {
        if (scrollView.contentOffset.x < -40) {
            if (!self.isLoadingMore) {
                self.isWaitPulling = YES;
            }
        }else if (self.isWaitPulling &&
                  scrollView.contentOffset.x == 0) {
            self.isLoadingMore = YES;
            self.isWaitPulling = NO;
            self.loadMoreBlock();
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (_clossScrollViewScrollResponds) return;
    if (scrollView.contentOffset.x < 0 || scrollView.contentOffset.x >= self.backScrollViewMaxOffX) {
        return;
    }
    CGFloat minMove = self.kScaler.shapeWidth + self.kScaler.shapeInterval;
    if (minMove == 0) return;
    self.scrollView.contentOffset = CGPointMake(round(self.scrollView.contentOffset.x / minMove) * minMove, 0);
    
    [self updateSubLayerIfNeed];
}

#pragma mark - 属性

/** 结束刷新状态 */
- (void)endLoadingState {
    self.isLoadingMore = NO;
}

#pragma mark - K线手势

- (void)addGestureRecognizer {
    UIPinchGestureRecognizer * pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchesToScale:)];
    [self addGestureRecognizer:pinchGestureRecognizer];
    pinchGestureRecognizer.delegate = self;
    _pinchGesture = pinchGestureRecognizer;
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:longPress];
    longPress.delegate = self;
//    longPress.minimumPressDuration = .2;
    _longPressGesture = longPress;
    
    // 点击手势
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    singleTap.numberOfTouchesRequired = 1;
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    [self addGestureRecognizer:singleTap];
    _singleTapGesture = singleTap;
    
//    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
//    doubleTap.numberOfTouchesRequired = 1;
//    doubleTap.numberOfTapsRequired = 2;
//    [self addGestureRecognizer:doubleTap];
//
//    [singleTap requireGestureRecognizerToFail:doubleTap];
}

/** 缩放手势 */
- (void)pinchesToScale:(UIPinchGestureRecognizer *)recognizer {
    // 放大禁用滚动手势
    if (self.scrollView.scrollEnabled) {
        self.scrollView.scrollEnabled = NO;
        _tempLockScrollEnabled = YES;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        _currentZoom = recognizer.scale;
        if(_tempLockScrollEnabled){
           _tempLockScrollEnabled = NO;
           self.scrollView.scrollEnabled = YES;
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateBegan && _currentZoom != 0.0f) {
        
        recognizer.scale = _currentZoom;
        CGPoint centroidPoint = [recognizer locationInView:self]; //手势重心点
        CGPoint centroidPoint_s = [self.layer convertPoint:centroidPoint toLayer:self.candleLayer];
        //当前缩放的索引 (位置参考值)
        _zoomCenterIndex = [self indexVisiableFromConvertPonitX:centroidPoint_s.x];
        //当前缩放的索引 应该保持的显示位置 缩放后应该回归的位置
        centroidPoint_s.x = self.kScaler.axisXScaler(_zoomCenterIndex);
        _zoomCenterSpacingLeft = centroidPoint_s.x - self.scrollView.contentOffset.x;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGFloat stepZoom = recognizer.scale / _currentZoom;
        _currentZoom = recognizer.scale;
        CGFloat kShapeWidth = (self.config.kShapeWidth + self.config.kShapeInterval) * stepZoom - self.config.kShapeInterval;
        
         // 极大值极小值
        if (kShapeWidth > self.config.kMaxShapeWidth) {
            kShapeWidth = self.config.kMaxShapeWidth;
        }else if (kShapeWidth < self.config.kMinShapeWidth){
            kShapeWidth = self.config.kMinShapeWidth;
        }
        if (self.config.kShapeWidth == kShapeWidth) return;
        
        self.config.kShapeWidth = kShapeWidth;
//        self.config.kLineCountVisibale = self.kScaler.chartRect.size.width / kShapeWidth;
        
        _clossScrollViewScrollResponds = YES;
        // 若设置ScrollViewContentSize 时关闭了隐式动画，在边缘缩小是会跳变
        [self configScalerAndUpdateSubLayersFrame];
        _clossScrollViewScrollResponds = NO;
        
        // 定位中间的k线
        CGFloat shape_x = self.kScaler.axisXScaler(_zoomCenterIndex);
        CGFloat offsetX = shape_x - _zoomCenterSpacingLeft;
        
        CGFloat maxoffsetX = self.backScrollViewMaxOffX;
//        NSLog(@"chart offsetX b contentOffset %@",NSStringFromCGPoint(self.scrollView.contentOffset));
        offsetX = offsetX < 0 ? 0 : (offsetX > maxoffsetX ? maxoffsetX : offsetX);
//        NSLog(@"chart offsetX %lf stepZoom %lf",offsetX,stepZoom);
//        NSLog(@"chart offsetX e contentOffset %@",NSStringFromCGPoint(self.scrollView.contentOffset));
        
        [self updateSubLayer];
        // 设置滚动位置
        self.scrollView.contentOffset = CGPointMake(offsetX, 0);
    }
}

/** 长按十字星 */
- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
    // 放大禁用滚动手势
    if (self.scrollView.scrollEnabled) {
        self.scrollView.scrollEnabled = NO;
        _tempLockScrollEnabled = YES;
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        [self updateSubLayer];
        self.crissQueryView.hidden = YES;
        [self longPressInKChartDidEnded];
        
        if(_tempLockScrollEnabled){
            _tempLockScrollEnabled = NO;
            self.scrollView.scrollEnabled = YES;
        }
    }else if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        CGPoint velocity = [recognizer locationInView:self];
        [self updateQueryLayerWithPoint:velocity];
        self.crissQueryView.hidden = NO;
    }else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint velocity = [recognizer locationInView:self];
        [self updateQueryLayerWithPoint:velocity];
    }
}

/** 更新十字星查价框 */
- (NSInteger)updateQueryLayerWithPoint:(CGPoint)velocity {
    CGPoint velocityInScroll = [self.scrollView convertPoint:velocity fromView:self];
    CGRect rect_k = _kDrawWindowFrame;
    CGFloat max_y = CGRectGetMaxY(rect_k);
    CGFloat min_y = CGRectGetMinY(rect_k);
    
    if (velocityInScroll.y > max_y) {
        velocityInScroll.y = max_y;
    }
    else if (velocityInScroll.y < min_y) {
        velocityInScroll.y = min_y;
    }
    
    CGFloat offx = self.candleLayer.frame.origin.x; //candleLayer 坐标系和 scrollView 坐标系差值
    CGFloat offy = self.candleLayer.frame.origin.y;
    velocityInScroll.x -= offx;
    NSInteger index = [self indexVisiableFromConvertPonitX:velocityInScroll.x];
//    id <YT_StockKlineData> kData = self.kLineArray[index];
//    id <YT_StockKlineData> kData_first = self.kLineArray[self.kLineDataSource.displayRange.location];
    
    velocityInScroll.y -= offy;
    YTSCFloat value = self.kScaler.axisYParser(velocityInScroll.y);
    YTSCFloat value_zdf = self.kScalerAxisZDFParser(velocityInScroll.y);
    UIColor * bgColor = self.config.holdColor;
    if (value_zdf > 0)  {
        bgColor = self.config.riseColor;
    }else if (value_zdf < 0){
        bgColor = self.config.fallColor;
    }
    int digit = self.kFloatFormat.decimalPlaces;
    value *= self.config.truthfulValueFloat;
    NSString * yStringL = [NSString stringWithFormat:@"%.*f",digit, value];
    NSString * yStringR = [NSString stringWithFormat:@"%+.*f%%",digit,value_zdf *100];

    self.crissQueryView.yCirssLableLeft.backgroundColor = bgColor;
    self.crissQueryView.yCirssLableRight.backgroundColor = bgColor;
    self.crissQueryView.yCirssLableLeft.text = yStringL;
    self.crissQueryView.yCirssLableRight.text = yStringR;
    self.crissQueryView.yCirssLableRightOffsetX = self.crissQueryView.bounds.size.width;
    if (self.crissQueryView.bRightLabelOutChart) {
        self.crissQueryView.yCirssLableRightOffsetX += self.crissQueryView.yCirssLableRight.bounds.size.width;
    }
//    [self.crissQueryView.queryView setQueryData:kData];
    
    // x 取 中心
    CGPoint queryVelocity =  CGPointMake(self.kScaler.axisXScaler(index) + offx, velocityInScroll.y + offy);
    CGPoint crissCenter = [self.scrollView convertPoint:queryVelocity toView:self.crissQueryView];
    [self.crissQueryView setCenterPoint:crissCenter];
    [self updateIndexStringForIndexUnderFocus:index];
    
    [self longPressInKChartOfIndex:index];
    return  index;
}

/** 长按时回调 */
- (void)longPressInKChartOfIndex:(NSInteger)index {}

/** 长按结束 */
- (void)longPressInKChartDidEnded {}

- (void)singleTap:(UITapGestureRecognizer *)gesture {
    
    CGPoint velocity = [gesture locationInView:self];
    CGPoint velocityInScrollWindow = [self.gridLayer_const convertPoint:velocity fromLayer:self.layer];
    // k线网格
    CGRect rect_k = _kDrawWindowFrame;
    if (CGRectContainsPoint(rect_k, velocityInScrollWindow)) {
        [self singleTapInKChart];
        return;
    }
    
    // 成交量网格
    [self.techZBChartContexts enumerateObjectsUsingBlock:^(YT_TechZBChartContext * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
          CGRect rect_v = obj.drawWindowFrame;
        if (CGRectContainsPoint(rect_v, velocityInScrollWindow)) {
            [self singleTapInVChart:idx];
            * stop = YES;
        }
    }];
}

- (void)singleTapInKChart {}

- (void)singleTapInVChart:(NSInteger)index {
    if (index >= 0 && index < self.techZBChartContexts.count) {
        YT_TechZBChartContext * cxt = [self.techZBChartContexts objectAtIndex:index];
        if (cxt.nextZBTypeBlock) {
              YT_ZBType next = cxt.nextZBTypeBlock(cxt.zbType);
            [self setAttachedTechZBWithIndex:index to:next display:YES];
        }
    }
}

#pragma mark  UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint velocity = [gestureRecognizer locationInView:self];
    return [self viewPointIsInChart:velocity];
}


#pragma mark - pri tool

- (NSRange)visibleRangeForCurrentOffsetX {
    
    CGPoint point = self.scrollView.contentOffset;
    if (point.x < self.backScrollViewMinOffX) point.x = self.backScrollViewMinOffX;
    point = [self.scrollView.layer convertPoint:point toLayer:self.candleLayer];
    CGFloat max_x = point.x  + _chartDrawWindowFrame.size.width;
//    CGFloat max_x = point.x + self.kScaler.chartRect.size.width;
    
    // 计算显示的在屏幕中的k线
    NSInteger index = [self.kScaler roundIndexFromAxisXParser:point.x]; //==(int)(index_f + 0.5)
    NSInteger toIndex = [self.kScaler roundIndexFromAxisXParser:max_x]; //==(int)(index_f - 0.5) // -1
//    NSInteger len = self.config.kLineCountVisibale;
    NSInteger len = toIndex - index; //  + 1
    
//    NSLog(@"chart visibleRange point %@",NSStringFromCGPoint(point));
//    NSLog(@"chart visibleRange %zd %zd",index,toIndex);
    if (index < 0) {index = 0;}
    else if (index > _kLineArray.count) { index = _kLineArray.count; }
    if (len < 0) {len = 0;}
    else if (index + len > _kLineArray.count) { len = _kLineArray.count - index; }
//    NSLog(@"chart visibleRange range %zd %zd",index,len);
    return NSMakeRange(index, len);
}

/** candleLayer 上的点 获取点对应的数据 */
- (NSInteger)indexFromConvertPonitX:(CGFloat)x{
    NSInteger index = [self.kScaler indexFromAxisXParser:x];
    NSUInteger max = self.kScaler.totalShapeCount - 1;
    NSUInteger min = 0;
    return index > max ? max : index < min ? min :index;
}

/** candleLayer 上的点 获取点对应的数据 */
- (NSInteger)indexVisiableFromConvertPonitX:(CGFloat)x{
    NSInteger index = [self.kScaler indexFromAxisXParser:x];
    NSRange displayRange  = self.kLineDataSource.displayRange;
    NSUInteger max = NSMaxRange(displayRange) -1;
    NSUInteger min = displayRange.location;
    return index > max ? max : index < min ? min :index;
}

/** view 上的点 获取点对应的数据 */
- (NSInteger)indexVisiableFromConvertViewPonit:(CGPoint)point {
    CGPoint point_s = [self.candleLayer convertPoint:point fromLayer:self.layer];
    return  [self indexFromConvertPonitX:point_s.x];
}

/**获取 item index 对应 view 上的 点的 x*/
- (CGFloat)viewPointXFormKLineIndex:(NSInteger)index {
    CGFloat canLayerPointX  = self.kScaler.axisXScaler(index);
    CGPoint point = [self.scrollView convertPoint:CGPointMake(canLayerPointX + self.candleLayer.frame.origin.x, 0) toView:self];
    return point.x;
}

/**获取 item index 对应 view 上的 点*/
- (CGPoint)viewPointFormKLineIndex:(NSInteger)index price:(double)aflaot{
    CGFloat canLayerPointY =  self.kScaler.axisYScaler(aflaot);
    CGFloat canLayerPointX  = self.kScaler.axisXScaler(index);
    CGPoint point = [self.scrollView convertPoint:CGPointMake(canLayerPointX + self.candleLayer.frame.origin.x, canLayerPointY + self.candleLayer.frame.origin.y) toView:self];
    return point;
}

/** view 判断点所在的区域 */
- (BOOL)viewPointIsInChart:(CGPoint)point {
    return CGRectContainsPoint(self.gridLayer_const.frame, point);
}

/**
 因为服务器下发的KFlaot 最多三位小数 特殊的 bGGQQ 使用 约定 浮点的的方式达到4位
 之后可以考虑修改
 */
- (YT_FloatFormat)textAdjustDigitThisInKChart:(double)v {
    YT_FloatFormat rs = self.kFloatFormat;
    double span = self.kLineDataSource.klineAxisParam.maxPrice - self.kLineDataSource.klineAxisParam.minPrice;
    rs.decimalPlaces =  YT_TEXT_ADJUST_DIGIT(v, rs.decimalPlaces, span);
    return rs;
}

#pragma mark - @synthesize ignore this

- (NSArray<id<YT_TechZBChartContextAbstract>> *)attachedTechZBArray {
    return (NSArray<id<YT_TechZBChartContextAbstract>> *)self.techZBChartContexts;
}

@synthesize kLineDataSource = _kLineDataSource;
@synthesize candleLayer = _candleLayer;
@synthesize gridLayer_const = _gridLayer_const;
@synthesize gridLayer_scroll = _gridLayer_scroll;
@synthesize stringLayer = _stringLayer;
@synthesize crissQueryView = _crissQueryView;
@synthesize kLineIndexLayer = _kLineIndexLayer;

@synthesize candleExtremeRenderer = _candleExtremeRenderer;
@synthesize axisXStrRenderer = _axisXStrRenderer;
@synthesize kAxisYStrRenderer = _kAxisYStrRenderer;
@synthesize kAxisYStrRendererRight = _kAxisYStrRendererRight;

@synthesize kFloatFormat = _kFloatFormat;
@synthesize lableKLineIndex = _lableKLineIndex;

@end

