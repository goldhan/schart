//
//  YT_KLChartIndexCalculatConfige.h
//  KL
//
//  Created by yt_liyanshan on 2018/11/29.
//

#import "YT_KLChartIndexCalculatConfige.h"
#import <objc/message.h>

@interface YT_KLChartIndexCalculatConfige()
@property(nonatomic,strong) NSMutableSet * zbTypeChangedStatusSet;
@end

@implementation YT_KLChartIndexCalculatConfige

- (NSMutableSet *)zbTypeChangedStatusSet {
    if (!_zbTypeChangedStatusSet) {
        _zbTypeChangedStatusSet = [[NSMutableSet alloc] init];
    }
    return _zbTypeChangedStatusSet;
}

+ (instancetype)sharedConfige
{
    static id sharedConfige = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedConfige = [[self alloc] initDefaultConfige];
    });
    return sharedConfige;
}

- (instancetype)initDefaultConfige
{
    self = [super init];
    if (self) {
        [self resetDefaultConfige];
    }
    return self;
}

- (void)resetDefaultConfige {
    /*** VOL **/
    _vol_ma5 = 5;
    _vol_ma10 = 10;
    _vol_ma20 = 20;
    
    /*** MACD **/
    _macd_ema12 = 12;
    _macd_ema26 = 26;
    _macd_dif_ema9 = 9;
    
    /*** KDJ **/
    _kdj_rsv = 9;
    _kdj_rsv_ema3 = 3;
    _kdj_k_ema3 = 3;
    
    /*** VR **/
    _vr_days26 = 26;
    _vr_ma6 = 6;
    
    /*** BIAS **/
    _bias_days6 = 6;
    _bias_days12 = 12;
    _bias_days24 = 24;
    
    /*** DMA **/
    _dma_ma10 = 10;
    _dma_ma50 = 50;
    _dma_dif_ma10 = 10;
    
    /*** CCI **/
    _cci_days14 = 14;
    
    /*** DMI **/
    _dmi_adx6 = 6;
    _dmi_di14 = 14;
//    _dmi_adxr6 = 6;
    
    /*** WR **/
    _wr_days6 = 6;
    _wr_days10 = 10;
    
    /*** RSI **/
    _rsi_days6 = 6;
    _rsi_days12 = 12;
    _rsi_days24 = 24;
    
    /*** BOLL **/
    _boll_days20 = 20;
    _boll_p2 = 2;
    
    /*** CR **/
    _cr_days26 = 26;
    _cr_ma10 = 10;
    _cr_ma20 = 20;
    _cr_ma40 = 40;
    _cr_ma62 = 62;

    /*** OBV **/
    _obv_days30 = 30;
}

//- (void)setMacd_ema12:(int)macd_ema12 {
//    if (_macd_ema12 == macd_ema12)return;
//    _macd_ema12 = macd_ema12;
//    [self.zbTypeChangedStatusSet addObject:[NSNumber numberWithInteger:YT_ZBType_MACD]];
//}
#define YT_KLSETOW(Name, name, type) \
- (void)set##Name:(int)name { \
    if (_##name == name) return; \
    _##name = name; \
    [self.zbTypeChangedStatusSet addObject:[NSNumber numberWithInteger:type]]; \
}

YT_KLSETOW(Vol_ma5, vol_ma5, YT_ZBType_VOL)
YT_KLSETOW(Vol_ma10, vol_ma10, YT_ZBType_VOL)
YT_KLSETOW(Vol_ma20, vol_ma20, YT_ZBType_VOL)


YT_KLSETOW(Macd_ema12, macd_ema12, YT_ZBType_MACD)
YT_KLSETOW(Macd_ema26, macd_ema26, YT_ZBType_MACD)
YT_KLSETOW(Macd_dif_ema9, macd_dif_ema9, YT_ZBType_MACD)


YT_KLSETOW(Kdj_rsv, kdj_rsv, YT_ZBType_KDJ)
YT_KLSETOW(Kdj_rsv_ema3, kdj_rsv_ema3, YT_ZBType_KDJ)
YT_KLSETOW(Kdj_k_ema3, kdj_k_ema3, YT_ZBType_KDJ)


YT_KLSETOW(Vr_days26, vr_days26, YT_ZBType_VR)
YT_KLSETOW(Vr_ma6, vr_ma6, YT_ZBType_VR)


YT_KLSETOW(Bias_days6, bias_days6, YT_ZBType_BIAS)
YT_KLSETOW(Bias_days12, bias_days12, YT_ZBType_BIAS)
YT_KLSETOW(Bias_days24, bias_days24, YT_ZBType_BIAS)


YT_KLSETOW(Dma_ma10, dma_ma10, YT_ZBType_DMA)
YT_KLSETOW(Dma_ma50, dma_ma50, YT_ZBType_DMA)
YT_KLSETOW(Dma_dif_ma10, dma_dif_ma10, YT_ZBType_DMA)


YT_KLSETOW(Cci_days14, cci_days14, YT_ZBType_CCI)


YT_KLSETOW(Dmi_di14, dmi_di14, YT_ZBType_DMI)
YT_KLSETOW(Dmi_adx6, dmi_adx6, YT_ZBType_DMI)
//YT_KLSETOW(Dmi_adxr6, dmi_adxr6, YT_ZBType_DMI)


YT_KLSETOW(Wr_days10, wr_days10, YT_ZBType_WR)
YT_KLSETOW(Wr_days6, wr_days6, YT_ZBType_WR)


YT_KLSETOW(Rsi_days6, rsi_days6, YT_ZBType_RSI)
YT_KLSETOW(Rsi_days12, rsi_days12, YT_ZBType_RSI)
YT_KLSETOW(Rsi_days24, rsi_days24, YT_ZBType_RSI)


YT_KLSETOW(Boll_days20, boll_days20, YT_ZBType_BOLL)
YT_KLSETOW(Boll_p2, boll_p2, YT_ZBType_BOLL)


YT_KLSETOW(Cr_days26, cr_days26, YT_ZBType_CR)
YT_KLSETOW(Cr_ma10, cr_ma10, YT_ZBType_CR)
YT_KLSETOW(Cr_ma20, cr_ma20, YT_ZBType_CR)
YT_KLSETOW(Cr_ma40, cr_ma40, YT_ZBType_CR)
YT_KLSETOW(Cr_ma62, cr_ma62, YT_ZBType_CR)


YT_KLSETOW(Obv_days30, obv_days30, YT_ZBType_OBV)

//+(void)load {
//
//    YT_KLChartIndexCalculatConfige * co = [[YT_KLChartIndexCalculatConfige alloc] initDefaultConfige];
//    co.macd_ema12 = 1000;
//    NSLog(@"had change%d",[co hadChangedForZBType:YT_ZBType_MACD]);
//    co.kdj_rsv = 1000;
//    NSLog(@"had change%d",[co hadChangedForZBType:YT_ZBType_KDJ]);
//    co.vr_ma6 = 1000;
//    NSLog(@"had change%d",[co hadChangedForZBType:YT_ZBType_VR]);
//}

#undef YT_KLSETOW

#pragma mark -

- (BOOL)hadChanged {
    if (!_zbTypeChangedStatusSet) {
        return NO;
    }
    if (self.zbTypeChangedStatusSet.count == 0) {
        return NO;
    }
    return YES;
}

- (BOOL)hadChangedForZBType:(YT_ZBType)zbType {
    if (!_zbTypeChangedStatusSet) {
        return NO;
    }
    NSNumber * number = [NSNumber numberWithInteger:zbType];
    return [self.zbTypeChangedStatusSet containsObject:number];
}

- (void)cleanChangedStatus {
    if (_zbTypeChangedStatusSet) {
        [self.zbTypeChangedStatusSet removeAllObjects];
    }
}

- (void)resetConfige:(YT_KLChartIndexCalculatConfige *)confige {
    NSMutableDictionary * dic = [confige t_getObjectKeyValues];
    [self setValuesForKeysWithDictionary:dic];
}

- (id)copyWithZone:(NSZone *)zone {
    YT_KLChartIndexCalculatConfige * config = [[self.class allocWithZone:zone] init];
    [config resetConfige:self];
    [config cleanChangedStatus];
    return config;
}

#pragma mark - tool

- (NSMutableDictionary*)t_getObjectKeyValues
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([self class], &propsCount);//获得属性列表
    for (int i = 0; i < propsCount; i++) {
        objc_property_t prop = props[i];
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];//获得属性的名称
        id value = [self valueForKey:propName];//kvc读值
        if(value == nil) {
            value = [NSNull null];
        }
        [dic setObject:value forKey:propName];
    }
    [dic removeObjectForKey:@"zbTypeChangedStatusSet"];
    return dic;
}

@end
