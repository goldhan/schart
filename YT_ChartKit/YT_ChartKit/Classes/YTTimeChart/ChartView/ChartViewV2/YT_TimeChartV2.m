//
//  YT_TimeChartV2.m
//  YT_ChartKit
//
//  Created by ChenRui Hu on 2018/8/22.
//

#import "YT_TimeChartV2.h"
#import "YT_TimeChart+YT_TimeTextLayer.h"
#import "YT_TimeChart+Calculator.h"
#import "YT_VolumeSwitchView.h"
#import "YT_TimeOverlayLayer.h"

@interface YT_TimeChartV2 () {
    BOOL bVolumeFigureOpen_;   // 是否打开成交量附图(NO: 不打开  YES: 打开)
    
    BOOL bTradeFigureOpen_;   // 是否打开交易附图(NO: 不打开  YES: 打开)
}

/** 成交量切换图 */
@property (nonatomic, strong) YT_VolumeSwitchView *volumeSwitchView;

/** 买卖切换图 */
@property (nonatomic, strong) YT_VolumeSwitchView *tradeSwitchView;

/** 分时叠加层 */
@property (nonatomic, strong) YT_TimeOverlayLayer *timeOverlayLayer;

@end

@implementation YT_TimeChartV2

#pragma mark - SublayerInitialization

- (void)sublayerInitialization {
    [super sublayerInitialization];
    
    _volumeSwitchView = [YT_VolumeSwitchView new];
    [self addSubview:_volumeSwitchView];
    
    _tradeSwitchView = [YT_VolumeSwitchView new];
    [self addSubview:_tradeSwitchView];
    
    _timeOverlayLayer = [YT_TimeOverlayLayer layer];
    [self.contentChartLayer addSublayer:_timeOverlayLayer];
}

#pragma mark - Update sublayer
- (void)updateSublayerAppearance {
    [super updateSublayerAppearance];
    
    if (bVolumeFigureOpen_) { // 成交量
        _volumeSwitchView.switchLineWidth = self.configuration.switchLineWidth;
        _volumeSwitchView.switchLineColor = self.configuration.switchLineColor;
        _volumeSwitchView.textColor = self.configuration.switchTextColor;
        _volumeSwitchView.textFont = self.configuration.switchTextFont;
        _volumeSwitchView.switchButtonBlock = ^(BOOL bOpen) {
            NSLog(@"成交量是否打开 ---- %d", bOpen);
        };
    }
    if (bTradeFigureOpen_) { // 买卖
        _tradeSwitchView.switchLineWidth = self.configuration.switchLineWidth;
        _tradeSwitchView.switchLineColor = self.configuration.switchLineColor;
        _tradeSwitchView.textColor = self.configuration.switchTextColor;
        _tradeSwitchView.textFont = self.configuration.switchTextFont;
        _tradeSwitchView.switchButtonBlock = ^(BOOL bOpen) {
            NSLog(@"买卖是否打开 ---- %d", bOpen);
        };
    }
    
    _timeOverlayLayer.overlayLineWith = self.configuration.dashLineWidth;
    _timeOverlayLayer.overlayLineColor = self.configuration.timeOverlayLineColor;
    _timeOverlayLayer.otherLineColor = self.configuration.timeOverlayOtherLineColor;
    [_timeOverlayLayer configLayer];
}

#pragma mark - Update drawing layout
- (void)updateDrawRect {
    self.chartRect = (CGRect){.origin.y = self.configuration.topGap, .size.width = self.bounds.size.width, .size.height = self.bounds.size.height - self.configuration.topGap - self.configuration.dateGap};
    
    CGFloat fWidth = self.chartRect.size.width; // 所有子图的宽度
    if (0 == self.configuration.nFigureNum) {  // 无附图
        self.timeRect = (CGRect){.origin.y = self.chartRect.origin.y, .size.width = fWidth, .size.height = self.chartRect.size.height - self.configuration.bottomGap};
        self.riverRect = CGRectZero;
        self.volumeRect = CGRectZero;
        self.tradeSwitchRect = CGRectZero;
        self.tradeRect = CGRectZero;
        self.bottomRect = (CGRect){.origin.y = CGRectGetMaxY(self.timeRect), .size.width = fWidth, .size.height = self.configuration.bottomGap};
    } else if (1 == self.configuration.nFigureNum) {  // 1个附图（添加了成交量）
        self.timeRect = (CGRect){.origin.y = self.chartRect.origin.y, .size.width = fWidth, .size.height = self.chartRect.size.height * self.configuration.proportionOfHeight};
        self.riverRect = (CGRect){.origin.y = CGRectGetMaxY(self.timeRect), .size.width = fWidth, .size.height = self.configuration.riverGap};
        self.volumeRect = (CGRect){.origin.y = CGRectGetMaxY(self.riverRect), .size.width = fWidth, .size.height = self.chartRect.size.height - self.timeRect.size.height - self.riverRect.size.height - self.configuration.bottomGap};
        self.tradeSwitchRect = CGRectZero;
        self.tradeRect = CGRectZero;
        self.bottomRect = (CGRect){.origin.y = CGRectGetMaxY(self.volumeRect), .size.width = fWidth, .size.height = self.configuration.bottomGap};
    } else if (2 == self.configuration.nFigureNum) { // 2个附图（添加了买卖）
        CGFloat fTimeHight = self.chartRect.size.height * self.configuration.proportionOfHeight; // 分时图高度
        CGFloat fFigureHight = (self.chartRect.size.height - fTimeHight - 2*self.configuration.riverGap - self.configuration.bottomGap)/2; // 附图的高度
        self.timeRect = (CGRect){.origin.y = self.chartRect.origin.y, .size.width = fWidth, .size.height = fTimeHight};
        self.riverRect = (CGRect){.origin.y = CGRectGetMaxY(self.timeRect), .size.width = fWidth, .size.height = self.configuration.riverGap};
        self.volumeRect = (CGRect){.origin.y = CGRectGetMaxY(self.riverRect), .size.width = fWidth, .size.height = fFigureHight};
        self.tradeSwitchRect = (CGRect){.origin.y = CGRectGetMaxY(self.volumeRect), .size.width = fWidth, .size.height = self.configuration.riverGap};
        self.tradeRect = (CGRect){.origin.y = CGRectGetMaxY(self.tradeSwitchRect), .size.width = fWidth, .size.height = fFigureHight};
        self.bottomRect = (CGRect){.origin.y = CGRectGetMaxY(self.tradeRect), .size.width = fWidth, .size.height = self.configuration.bottomGap};
    }
    
    [self updateFigureStatus];
}

/// 更新附图显示状态
- (void)updateFigureStatus {
    if (0 == self.configuration.nFigureNum) {  // 无附图
        bVolumeFigureOpen_ = NO;
        bTradeFigureOpen_ = NO;
    } else if (1 == self.configuration.nFigureNum) { // 1个附图（添加了成交量）
        bVolumeFigureOpen_ = YES;
        bTradeFigureOpen_ = NO;
    } else if (2 == self.configuration.nFigureNum) { // 2个附图（添加了买卖）
        bVolumeFigureOpen_ = YES;
        bTradeFigureOpen_ = YES;
    }
}

- (void)updateLayout {
    [super updateLayout];
    self.crosswireView.separationRect = CGRectMake(0, CGRectGetMinY(self.bottomRect), self.timeRect.size.width, self.configuration.bottomGap + self.configuration.dateGap);
    if (bVolumeFigureOpen_) { // 成交量
        if (self.configuration.riverGap == 0) {
            _volumeSwitchView.hidden = YES;
        } else {
            _volumeSwitchView.hidden = NO;
            _volumeSwitchView.frame = self.riverRect;
        }
    } else {
        _volumeSwitchView.hidden = YES;
        self.volumeLayer.hidden = YES;
    }
    if (bTradeFigureOpen_) { // 买卖
        if (self.configuration.riverGap == 0) {
            _tradeSwitchView.hidden = YES;
        } else {
            _tradeSwitchView.hidden = NO;
            _tradeSwitchView.frame = self.tradeSwitchRect;
        }
    } else {
        _tradeSwitchView.hidden = YES;
    }
}
#pragma mark - Draw charts
- (void)drawChart {
    if (self.dataArray) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        [self layoutIfNeeded];
        [self updateDrawRect];
        [self updateLayout];
        [self updateSublayerAppearance];
        
        // 绘制网格
        [self.timeGridLayer updateLayerWithRect:self.timeRect :self.volumeRect :self.tradeRect];
        
        // 绘制文本
        [self drawTimeText];
        
        // 绘制分时
        if (self.configuration.chartType == YT_TimeChartTypeDefault) {
            [self.timeGridLayer drawDateLines:self];
            [self.timeLayer drawTimeChart:self];
            [self drawDateText:self.bottomRect];
        } else if (self.configuration.chartType == YT_TimeChartTypeFiveDay) {
            [self.timeGridLayer drawFiveDateLines];
            [self.timeLayer drawFiveTimeChart:self];
            [self drawFiveDateText:self.bottomRect]; // 注：一定先绘制分时，在 drawFiveTimeChart 计算了日期 fiveDateArray
        }
        
        // 叠加线
        [_timeOverlayLayer drawOverlayLine:self];
        
        [self drawFigureChart];
        [CATransaction commit];
    } else {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        [self layoutIfNeeded];
        [self updateDrawRect];
        [self updateSublayerAppearance];
        // 绘制网格
        [self.timeGridLayer updateLayerWithRect:self.timeRect :self.volumeRect :self.tradeRect];
        [CATransaction commit];
    }
}

/** 绘制附图表 */
- (void)drawFigureChart {
    if (bVolumeFigureOpen_) { // 成交量
        // 绘制成交量文字
        [self drawVolumeText];
        // 绘制成交量
        [self.volumeLayer drawVolumeChart:self];
        // 绘制成交量切换图
        [_volumeSwitchView drawVolumeSwitchButtonName:@"成交量"];
        [self drawVolumeSwitchView:[self.dataArray lastObject]];
    }
    if (bTradeFigureOpen_) { // 买卖
        // 绘制交易切换图
        [_tradeSwitchView drawVolumeSwitchButtonName:@"买卖"];
        [self drawTradeSwitchView:[self.dataArray lastObject]];
    }
}

/** 绘制成交量上面切换文字 */
- (void)drawVolumeSwitchView:(id)obj {
    id<YT_TimeProtocol>object = obj;
    CGPeakValue peak = [self.dataArray yt_peakValueBySel:@selector(yt_timeVolume)];
    NSString *sVolume = [YT_TimeChart axisStringWithValue:object.yt_timeVolume peak:peak];
    NSString *sNew_vol = [YT_TimeChart axisStringWithValue:self.propData.yt_new_vol peak:peak];
    [_volumeSwitchView drawVolumeSwitchContent:[NSString stringWithFormat:@"量: %@  现手: %@", sVolume, sNew_vol]];
}

/** 绘制交易上面切换文字 */
- (void)drawTradeSwitchView:(id)obj {
    id<YT_TimeProtocol>object = obj;
    CGPeakValue peak = [self.dataArray yt_peakValueBySel:@selector(yt_timeVolume)];
    NSString *sVolume = [YT_TimeChart axisStringWithValue:object.yt_timeVolume peak:peak];
    NSString *sNew_vol = [YT_TimeChart axisStringWithValue:self.propData.yt_new_vol peak:peak];
    [_tradeSwitchView drawVolumeSwitchContent:[NSString stringWithFormat:@"总买: %@  总卖: %@", sVolume, sNew_vol]];
}

#pragma mark - UIGestureRecognizerDelegate
- (void)updateCrosswireLayerWithPoint:(CGPoint)p {    
    p.x -= self.timeRect.origin.x; p.y -= self.timeRect.origin.y;
    NSInteger index = [self mapIndexWithPointX:p.x]; // 求对应的时间
    CGFloat centerX = [self getCenterXWithIndex:index]; // 取中心值
    self.crosswireView.spotOfTouched = p;
    
    CGFloat originY = self.timeRect.origin.y + self.configuration.gridLineWidth * 0.5;
    CGFloat ratioY = originY + self.changeRatioPeakValue.max / CGGetPeakDistanceValue(self.changeRatioPeakValue) * self.timeRect.size.height;
    UIColor *(^callbackColor)(CGFloat) = ^(CGFloat y) {
        if (y < ratioY) {
            return self.configuration.crosswireBackRiseColor;
        } else if (y > ratioY) {
            return self.configuration.crosswireBackFallColor;
        }
        return [UIColor darkGrayColor];
    };
    self.crosswireView.textBackgroundColor = callbackColor(p.y + self.timeRect.origin.y);
    self.crosswireView.dateBackgroundColor = self.configuration.crosswireBackDateColor;
    self.crosswireView.centralPoint = CGPointMake(centerX - self.timeRect.origin.x, p.y);
    
    if (CGRectContainsPoint(self.timeRect, p)) { // 获取分时区域对应值
        CGFloat mapValue = [self mapRefValueWithPointY:p.y peak:self.timePeakValue inRect:self.timeRect];
        self.crosswireView.mapYaixsText = [NSString stringWithFormat:@"%.2f", mapValue];
        self.crosswireView.mapYaixsSubjoinText = nil;
    }
    if (CGRectContainsPoint(self.volumeRect, p)) { // 获取成交量区域对应值
        CGPeakValue peak = [self.dataArray yt_peakValueBySel:@selector(yt_timeVolume)];
        CGFloat mapValue = [self mapRefValueWithPointY:p.y peak:peak inRect:self.volumeRect];
        self.crosswireView.mapYaixsText = [YT_TimeChart axisStringWithValue:mapValue peak:peak];
        self.crosswireView.mapYaixsSubjoinText = nil;
    }
    
    [self.crosswireView updateContents];
    if (bVolumeFigureOpen_) { // 成交量切换图上数据
        [self drawVolumeSwitchView:self.dataArray[index]];
    }
    if (bTradeFigureOpen_) { // 买卖切换图上数据
        [self drawTradeSwitchView:self.dataArray[index]];
    }

    if ([self.delegate respondsToSelector:@selector(stockTimeChart:didLongPresOfIndex:)]) {
        [self.delegate stockTimeChart:self didLongPresOfIndex:index];
    }
}
@end
