//
//  YT_TechZBChartContext.m
//  Pods
//
//  Created by yt_liyanshan on 2018/9/5.
//

#import "YT_TechZBChartContext.h"
#import "YT_ChartScaler.h"
#import "YT_IndexLayer.h"

#import "YT_StockChartCanvas.h"
#import "YT_StringArrayRenderer.h"
#import "YT_KLineDataSource.h"
#import "YT_KLineChart.h"
//#import "YT_KLineChart+Layouter.h"

@interface YT_TechZBChartContext () <YT_TechZBChartContextAbstract>
@property (nonatomic, assign) YT_ZBType zbType;  ///< volum区域 指标类型
@end

@implementation YT_TechZBChartContext

- (instancetype)init
{
    self = [super init];
    if (self) {
        _indexInfoLable = [UILabel new];
        _axisStrRenderer = [[YT_StringArrayRenderer alloc] init];
        _floatFormat = YTFloatFormatDefault();
        _scaler = [[YT_ChartScaler alloc] init];
        _zbType = YT_ZBType_VOL;
        
        _switchButtonView = [YT_SwitchButtonChartView new];
        _switchButtonView.backgroundColor = [UIColor clearColor];
        _switchButtonView.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        __weak typeof(self) wself = self;
        self.nextZBTypeBlock = ^YT_ZBType(YT_ZBType zbType) {
            return [wself nextVolumZBType:zbType];
        };
    }
    return self;
}

- (void)dealloc {
    [self clearContext];
}

- (void) clearContext {
    if (self.indexLayer) {
        [self.indexLayer removeFromSuperlayer];
        self.indexLayer = nil;
    }
    if (self.indexInfoLable) {
        [self.indexInfoLable removeFromSuperview];
        self.indexInfoLable = nil;
    }
    if (self.switchButtonView) {
        [self.switchButtonView removeFromSuperview];
        self.switchButtonView = nil;
    }
    if (self.axisStrRenderer && self.stringCanvas) {
        [self.stringCanvas removeRenderer:self.axisStrRenderer];
    }
}


- (void)setStringCanvas:(YT_StockChartCanvas *)stringCanvas {
    YT_StockChartCanvas *old = _stringCanvas;
    _stringCanvas = stringCanvas;
    if (!self.axisStrRenderer) return;
    if (old) {
        [old removeRenderer:self.axisStrRenderer];
    }
    if (stringCanvas) {
        [stringCanvas addRenderer:self.axisStrRenderer];
    }
}

- (BOOL)resetIndexLayerIfNeeded:(YT_ZBType)zbType {
    if (self.indexLayer && self.zbType == zbType) {
        return YES;
    }
    return [self resetIndexLayer:self.zbExplain.zbType force:YES];
}

- (BOOL)resetIndexLayer:(YT_ZBType)zbType force:(BOOL)force{
    
    CALayer *oldLayer = _indexLayer;
    CALayer<YT_IndexLayerProtocol> * volumIndexLayer = [self madeVolumIndexLayer:zbType];
    
    if (!volumIndexLayer) {
        if (force) {
             volumIndexLayer = (CALayer<YT_IndexLayerProtocol> *)[[YT_BaseIndexLayer alloc] init];
        }else{
            return NO;
        }
    }
    // 转移设置
    volumIndexLayer.chartScaler = self.scaler;
    
    if (oldLayer) {
        volumIndexLayer.frame = oldLayer.frame;
        YT_ReleaseLayerAsync(oldLayer);
        oldLayer = nil;
    }
    _zbType = zbType;
    _indexLayer = volumIndexLayer;
    
    if (_zbTypeChangedBlock) { _zbTypeChangedBlock(zbType); }
//    __weak typeof(self) wself = self;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (wself.zbTypeChangedBlock) { wself.zbTypeChangedBlock(zbType); }
//    });
    return YES;;
}

static inline void YT_ReleaseLayerAsync(CALayer * layer){
    if (layer) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            [layer class];
        });
    }
}

- (CALayer<YT_IndexLayerProtocol> *)madeVolumIndexLayer:(YT_ZBType)zbType {
    switch (zbType) {
        case YT_ZBType_MACD:
            return [[YT_MACDLayer alloc] init];
        case YT_ZBType_KDJ:
            return [[YT_KDJLayer alloc] init];
        case YT_ZBType_VR:
            return [[YT_VRLayer alloc] init];
        case YT_ZBType_DMA:
            return [[YT_DMALayer alloc] init];
        case YT_ZBType_WR:
            return [[YT_WRLayer alloc] init];
        case YT_ZBType_BOLL: {
            return [[YT_BOLLLayer alloc] init];
        }
        case YT_ZBType_RSI:
            return [[YT_RSILayer alloc] init];
        case YT_ZBType_DMI:
            return [[YT_DMILayer alloc] init];
        case YT_ZBType_BIAS:
            return [[YT_BIASLayer alloc] init];
        case YT_ZBType_CCI:
            return [[YT_CCILayer alloc] init];
        case YT_ZBType_CR:
            return [[YT_CRLayer alloc] init];
        case YT_ZBType_OBV:
            return [[YT_OBVLayer alloc] init];
        case YT_ZBType_VOL: {
            return [[YT_VOLLayer alloc] init];
        }
        default:
            return nil;
    }
}

- (YT_ZBType)nextVolumZBType:(YT_ZBType)zbType {
    NSArray <NSNumber *> * arr_ZBType = @[@(YT_ZBType_VOL),@(YT_ZBType_MACD),@(YT_ZBType_DMI),@(YT_ZBType_WR),@(YT_ZBType_BOLL),
                                          @(YT_ZBType_KDJ),@(YT_ZBType_OBV),@(YT_ZBType_RSI),@(YT_ZBType_SAR),@(YT_ZBType_DMA),
                                          @(YT_ZBType_VR),@(YT_ZBType_CR),@(YT_ZBType_CCI),@(YT_ZBType_BIAS)];
    
    NSUInteger indexNext = [arr_ZBType indexOfObject:[NSNumber numberWithUnsignedInteger:zbType]] + 1;
    if (indexNext >= arr_ZBType.count) indexNext = 0;
    return (YT_ZBType)[arr_ZBType objectAtIndex:indexNext].unsignedIntegerValue;
}

#pragma mark -

- (void)updateIndexLayerWithRange:(NSRange)range {
    
//    CGRect volumBounds = YT_EdgeInsetsExRectBounds(self.drawWindowFrame, self.drawInsets);
//    self.scaler.chartRect = volumBounds;
    self.scaler.max = self.zbExplain.axisParam.max;
    self.scaler.min = self.zbExplain.axisParam.min;
    [self.scaler updateAxisY];
    
    self.indexLayer.textDecimalPlaces = self.floatFormat.decimalPlaces;
    self.indexLayer.textUnits = self.floatFormat.units;
    [self.indexLayer updateLayerWithRange:range];
}

#pragma mark -

- (void) textAdjustDigitInChart:(double)v template:(YT_FloatFormat)floatFormat{
    double span =  self.zbExplain.axisParam.max - self.zbExplain.axisParam.min;
    floatFormat.decimalPlaces = YT_TEXT_ADJUST_DIGIT(v, floatFormat.decimalPlaces, span);
    self.floatFormat = floatFormat;
}

@end
