//
//  YT_KLineDataSource.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/9.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_KLineDataSource.h"
#import "YT_KLineCalculator.h"
#import "YT_KLineDataCalculateCache.h"

#pragma mark - YT_KlineModel

#pragma mark YT_KlineMAExplain
@implementation YT_KlineMAExplain
@end
#pragma mark YT_TechZBExplain
@implementation YT_TechZBExplain
- (void)setZbType:(YT_ZBType)zbType {
    _zbType = zbType;
    [self resetForZBType];
}
- (void)resetForZBType {
    self.axisParam =  YT_MakeCoordinateAxisParamZero();
}
@end

#pragma mark - YT_KLineDataSource

@interface YT_KLineDataSource ()
{
//    NSUInteger klineDataArrayHash; /// 记录 klineDataArray 的 hash 值 , 用于判断计算数据是否有效
    YT_RSICalculateArgv _RSICalculateArgv; ///< 计算辅助
}

#pragma mark klineChart(主图)
@property (nonatomic, assign) YT_KLineCoordinateAxisParam  klineAxisParam; ///< k线某范围内的坐标参数
@property (nonatomic, assign) YT_CoordinateAxisParam  klineCAxisParam;      ///< k线蜡烛图某范围内的坐标参数
/**
 注意这个值不是k线MA 在range范围的最大最小值而是 在range中需要和klineCAxisParam比较得出klineAxisParam的参考参数
 */
@property (nonatomic, assign) YT_CoordinateAxisParam  klineMAAxisParam;     ///< k线MA某范围内的坐标参数

#pragma mark techZBChart (attachedTechZBChart 技术指标附图)

@property (nonatomic, strong) NSMutableArray<YT_TechZBExplain *> *attachedTechZBs; ///< 技术指标


#pragma mark 计算结果
@property (nonatomic, strong) YT_KlineDataCalculateCacheManager * cacheManager; ///< 计算结果缓存数据

@end

@implementation YT_KLineDataSource

#pragma mark - getter & seter

- (YT_ZBType)techZBType {
    YT_TechZBExplain * techOne = self.attachedTechZBs.firstObject;
    if (techOne) {
        return techOne.zbType;
    }
    return 99999;
}

- (void)setTechZBType:(YT_ZBType)techZBType {
    YT_TechZBExplain * techOne = self.attachedTechZBs.firstObject;
    if (techOne) {
        techOne.zbType = techZBType;
    }
}

- (YT_CoordinateAxisParam)techAxisParam {
    YT_TechZBExplain * techOne = self.attachedTechZBs.firstObject;
    if (techOne)   return techOne.axisParam;
    return YT_MakeCoordinateAxisParamZero();
}

- (NSArray<YT_TechZBExplain *> *)attachedTechZBArray {
    return _attachedTechZBs;
}

#pragma mark - init
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self readyContext];
        [self makeDefData];
    }
    return self;
}

-(void)readyContext {
    _attachedTechZBs = [NSMutableArray array];
    YT_TechZBExplain * techOne = [[YT_TechZBExplain alloc] init];
    [_attachedTechZBs addObject:techOne];
}

-(void)makeDefData{
    
    _displayRange = NSMakeRange(0, 0);

    YT_KLineCoordinateAxisParam klineAxisParam;
    klineAxisParam.range.location = 0;
    klineAxisParam.range.length = 0;
    _klineAxisParam = klineAxisParam;
    
    YT_CoordinateAxisParam axisYParam = YT_MakeCoordinateAxisParamZero();
    _klineCAxisParam = axisYParam;
    _klineMAAxisParam = axisYParam;
    
    [_attachedTechZBs enumerateObjectsUsingBlock:^(YT_TechZBExplain * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.axisParam = YT_MakeCoordinateAxisParamZero();
    }];

}

#pragma mark - public func

#pragma mark 引导计算

-(void)resetKlineDataArray:(NSArray <id <YT_StockKlineData>> *)klineDataArray {
    YT_KlineDataCalculateCacheManager * cacheManager = [YT_KlineDataCalculateCacheManager cacheManagerWithCacheArrayCount:klineDataArray.count];
    
    self.klineDataArray = klineDataArray;
    self.cacheManager = cacheManager;
    
    [self makeDefData];
}

-(void)changeTechZBTypeAndResetAllDataIfNeed:(YT_ZBType)zhiBiaoType {
    
    YT_CoordinateAxisParam axisYParam_tech = YT_MakeCoordinateAxisParamZero();
   //计算指标 & axisYParam
   [self calculateZhiBiao:zhiBiaoType range:self.displayRange reuseAxisParam:&axisYParam_tech dataArray:self.klineDataArray cacheManager:self.cacheManager];

    YT_TechZBExplain * techOne = self.attachedTechZBs.firstObject;
    if (techOne)  {
        techOne.zbType = zhiBiaoType;
        techOne.axisParam = axisYParam_tech;
    }
}

- (void)changeDisplayRangeAndResetAllDataIfNeed:(NSRange)displayRange {
    //计算 kline closs ma
    [self calculateKlineCustomMA:self.klineDataArray range:displayRange cacheManager:self.cacheManager];
    
    //计算 kline axisYParam
    [self t_calculateKLineCCoordinateAxisYParam:self.klineDataArray range:displayRange reuseParam:&_klineCAxisParam];
    [self t_calculateNeedBeCompareKLineMACoordinateAxisYParam:displayRange reuseParam:&_klineMAAxisParam cacheManager:self.cacheManager];
    YT_KLineCoordinateAxisParam axisYParam = [self calculateKLineCoordinateAxisYParam:self.klineDataArray cAxisParam:_klineCAxisParam kMAAxisParam:_klineMAAxisParam];
    
    //计算指标 & axisYParam
    [self calculateAttachedTechZBs:displayRange];
    
    self.klineAxisParam = axisYParam;
    self.displayRange = displayRange;
}

/**
 *  重置 klineZBMAExplain 并计算,耗时操作
 */
- (void)changeKlineZBMAExplainAndResetAllDataIfNeed:(NSArray<YT_KlineMAExplain *>*)explainArray {
    
    //计算 kline closs ma
    NSArray<YT_KlineMAExplain *> * explainArrayOld = [self klineZBMAExplainArray];
    NSMutableArray * usefulNumArr = [NSMutableArray array];
    BOOL allSame = (explainArrayOld.count == explainArray.count);
    for (int i  = 0 ; i < explainArray.count ; i++) {
        YT_KlineMAExplain *explain = [explainArray objectAtIndex:i];
        NSInteger index = explain.index;
        if (i < explainArrayOld.count) {
            YT_KlineMAExplain *explainOld = [explainArrayOld objectAtIndex:i];
            if (explainOld.day == explain.day && explainOld.index == index) {
                [usefulNumArr addObject:[NSNumber numberWithInteger:index]];
                continue;
            }
        }
       allSame = NO;
       self.cacheManager.readyRange_Closs_MA[index] = NSMakeRange(0, 0);
       [self calculateKlineCustomMA:self.klineDataArray range:self.displayRange cacheManager:self.cacheManager days:explain.day saveIndex:explain.index];
       [usefulNumArr addObject:[NSNumber numberWithInteger:index]];
    }
    
    if (allSame) return;

    for (int i = 0 ; i < self.cacheManager.readyRange_Closs_MA_count; i++) {
        if (![usefulNumArr containsObject:[NSNumber numberWithInt:i]]) {
            self.cacheManager.readyRange_Closs_MA[i] = NSMakeRange(0, 0);
        }
    }
    //计算 kline axisYParam
    _klineMAAxisParam = YT_MakeCoordinateAxisParamZero();
    [self t_calculateNeedBeCompareKLineMACoordinateAxisYParam:self.displayRange reuseParam:&_klineMAAxisParam cacheManager:self.cacheManager];
    YT_KLineCoordinateAxisParam axisYParam = [self calculateKLineCoordinateAxisYParam:self.klineDataArray cAxisParam:_klineCAxisParam kMAAxisParam:_klineMAAxisParam];
    
    self.klineAxisParam = axisYParam;
    self.klineZBMAExplainArray = explainArray;
}

#pragma mark 多附图指标 引导计算

/// 新增需要计算的附图指标，neddCaculate 是否需要计算，返回索引
- (YT_TechZBExplain *)addAttachedTechZB:(YT_ZBType)zbType neddCaculate:(BOOL)neddCaculate {
    YT_TechZBExplain * tech = [[YT_TechZBExplain alloc] init];
    tech.zbType = zbType;
    [self.attachedTechZBs addObject:tech];
    if (neddCaculate) {
        YT_CoordinateAxisParam axisParam = tech.axisParam;
        [self calculateZhiBiao:zbType range:self.displayRange reuseAxisParam:&axisParam dataArray:self.klineDataArray cacheManager:self.cacheManager];
        tech.axisParam = axisParam;
    }
    return tech;
}

/// 删除图指标类型
- (BOOL)removeAttachedTechZB:(YT_TechZBExplain *)zbExplain cleanCahe:(BOOL)cleanCahe {
    NSInteger count = self.attachedTechZBs.count;
    [self.attachedTechZBs removeObject:zbExplain];
    BOOL rs = self.attachedTechZBs.count < count;
    if (cleanCahe && rs) {
        [self tryCleanCacheIfNotUse:zbExplain.zbType];
    }
    return rs;
}

/// 改变副图指标类型 返回是否成功
- (BOOL)changeAttachedTechZB:(YT_TechZBExplain *)zbExplain to:(YT_ZBType)zbType neddCaculate:(BOOL)neddCaculate cleanCahe:(BOOL)cleanCahe {
    YT_ZBType removeZBType = zbExplain.zbType;
    if (removeZBType == zbType) return NO;
    if (neddCaculate) {
        YT_CoordinateAxisParam axisParam = zbExplain.axisParam;
        [self calculateZhiBiao:zbType range:self.displayRange reuseAxisParam:&axisParam dataArray:self.klineDataArray cacheManager:self.cacheManager];
        zbExplain.axisParam = axisParam;
    }
    zbExplain.zbType = zbType;
    
    if (cleanCahe) {
        [self tryCleanCacheIfNotUse:removeZBType];
    }
    return YES;
}

#pragma mark - pri func

- (void)calculateAttachedTechZBs:(NSRange)displayRange {
    [self.attachedTechZBs enumerateObjectsUsingBlock:^(YT_TechZBExplain * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         YT_CoordinateAxisParam axisParam = obj.axisParam;
         [self calculateZhiBiao:obj.zbType range:displayRange reuseAxisParam:&axisParam dataArray:self.klineDataArray cacheManager:self.cacheManager];
         obj.axisParam = axisParam;
    }];
}

- (void)tryCleanCacheIfNotUse:(YT_ZBType)zbType {
    __block BOOL needKeep = NO;
    [self.attachedTechZBs enumerateObjectsUsingBlock:^(YT_TechZBExplain * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.zbType == zbType) {
            needKeep = YES;
            * stop = YES;
        }
    }];
    if (NO == needKeep) {
        //TODO: 待续
//      self.cacheManager cleanCache
    }
}

#pragma mark - calculate

#pragma mark  zhiBiao

// 计算各种技术指标需要的值
-(void)calculateZhiBiao:(YT_ZBType)zBType range:(NSRange)range reuseAxisParam:(YT_CoordinateAxisParam *)axisParam dataArray:(NSArray <id <YT_StockKlineData>> *)klineDataArray  cacheManager:(YT_KlineDataCalculateCacheManager *)cacheManager {
    
    switch (zBType) {
        case YT_ZBType_MACD: {
            [self getMACDFrom:klineDataArray range:range reuseAxisParam:axisParam cacheManager:cacheManager];
        }
            break;
        case YT_ZBType_DMI:
            [self getDMIFrom:klineDataArray range:range reuseAxisParam:axisParam cacheManager:cacheManager];
            break;
        case YT_ZBType_WR: {
            [self getWRFrom:klineDataArray range:range reuseAxisParam:axisParam cacheManager:cacheManager];
        }
            break;
            
        case YT_ZBType_VR: {
            [self getVRFrom:klineDataArray range:range reuseAxisParam:axisParam cacheManager:cacheManager];
        }
            break;

        case YT_ZBType_CR: {
            [self getCRFrom:klineDataArray range:range reuseAxisParam:axisParam cacheManager:cacheManager];
        }
            break;

        case YT_ZBType_BOLL: {
            [self getBOLLFrom:klineDataArray range:range reuseAxisParam:axisParam cacheManager:cacheManager];
        }

            break;
        case YT_ZBType_KDJ: {
            [self getKDJFrom:klineDataArray range:range reuseAxisParam:axisParam cacheManager:cacheManager];
        }
            break;
        case YT_ZBType_OBV: {
            [self getOBVFrom:klineDataArray range:range reuseAxisParam:axisParam cacheManager:cacheManager];
        }
            break;
        case YT_ZBType_RSI: {
            [self getRSIFrom:klineDataArray range:range reuseAxisParam:axisParam cacheManager:cacheManager];
        }
            break;
//        case YT_ZBType_SAR:
//            break;
        case YT_ZBType_DMA: {
            [self getDMAFrom:klineDataArray range:range reuseAxisParam:axisParam cacheManager:cacheManager];
        }
            break;
        case YT_ZBType_BIAS: {
            [self getBIASFrom:klineDataArray range:range reuseAxisParam:axisParam cacheManager:cacheManager];
        }
            break;
        case YT_ZBType_CCI: {
            [self getCCIFrom:klineDataArray range:range reuseAxisParam:axisParam cacheManager:cacheManager];
        }
            break;
        case YT_ZBType_VOL: {
            [self getVOLFrom:klineDataArray range:range reuseAxisParam:axisParam cacheManager:cacheManager];
        }
            break;
        default:
            break;
    }
}


- (void)getMACDFrom:(NSArray <id <YT_StockKlineData>> *)klineDataArray range:(NSRange)range reuseAxisParam:(YT_CoordinateAxisParam *)axisParam cacheManager:(YT_KlineDataCalculateCacheManager *)cacheManager {
    // 计算MACD并储存
    NSInteger toIndex = range.location + range.length;
    // MACD 要从0算到结束
    NSInteger fromIndex = cacheManager.readyRange_MACD.location == 0 ? cacheManager.readyRange_MACD.length : 0;
    if (fromIndex < toIndex) {
        NSRange caculaterRange = NSMakeRange(fromIndex, toIndex - fromIndex);
        [YT_MACDCalculator calculateMACD:klineDataArray range:caculaterRange handleUsingBlock:^id<YT_StockMACDHandle> _Nonnull(NSUInteger idx) {
            return (id<YT_StockMACDHandle>)[cacheManager.cacheArray objectAtIndex:idx];
        } progress:^(NSUInteger location, id<YT_StockMACDHandle>  _Nonnull result) {
        } complete:^(NSRange rsRange, NSError * _Nullable error) {
            cacheManager.readyRange_MACD = NSMakeRange(0, rsRange.location + rsRange.length);
        }];
    }
    
    //从新计算显示范围内的最大最小值
    [YT_KLineCalculator usePatternSetMaxMin:axisParam range:range init:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        YT_KlineDataCalculateCache * kdata_one = [cacheManager.cacheArray objectAtIndex:range.location];
        axis->max = kdata_one.cache_DIF; // 赋初始值
        axis->min = kdata_one.cache_DIF; // 赋初始值
    } progress:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        YT_KlineDataCalculateCache * kdata_one = [cacheManager.cacheArray objectAtIndex:idx];
        YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_DIF, idx);
        YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_DEA, idx);
        YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_MACD, idx);
    }];
    
}

- (void)getOBVFrom:(NSArray <id <YT_StockKlineData>> *)klineDataArray range:(NSRange)range reuseAxisParam:(YT_CoordinateAxisParam *)axisParam cacheManager:(YT_KlineDataCalculateCacheManager *)cacheManager {
    // 计算OBV并储存 要从0算到结束

    //要从0算到结束
    NSInteger toIndex = range.location + range.length;
    NSInteger fromIndex = cacheManager.readyRange_OBV.location + cacheManager.readyRange_OBV.length;
    if (fromIndex < toIndex) {
        NSRange caculaterRange = NSMakeRange(fromIndex, toIndex - fromIndex);
        [YT_OBVCalculator calculateOBV:klineDataArray range:caculaterRange handleUsingBlock:^id<YT_StockOBVHandle>(NSUInteger idx) {
            return (id<YT_StockOBVHandle>)[cacheManager.cacheArray objectAtIndex:idx];
        } complete:^(NSRange rsRange, NSError *error) {
            cacheManager.readyRange_OBV = NSMakeRange(0, rsRange.location + rsRange.length);
        }];
    }
    
    // 从新计算显示范围内的最大最小值
    [YT_KLineCalculator usePatternSetMaxMin:axisParam range:range init:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        YT_KlineDataCalculateCache * kdata_one = [cacheManager.cacheArray objectAtIndex:idx];
        axis->max = kdata_one.cache_OBV; // 赋初始值
        axis->min = kdata_one.cache_OBV; // 赋初始值
    } progress:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        YT_KlineDataCalculateCache * kdata_one = [cacheManager.cacheArray objectAtIndex:idx];
        YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_OBV, idx);
        YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_OBVM, idx);
    }];
}

- (void)getKDJFrom:(NSArray <id <YT_StockKlineData>> *)klineDataArray range:(NSRange)range reuseAxisParam:(YT_CoordinateAxisParam *)axisParam cacheManager:(YT_KlineDataCalculateCacheManager *)cacheManager {
    // 计算BOLL并储存
    NSInteger toIndex = range.location + range.length;
    NSInteger fromIndex = cacheManager.readyRange_KDJ.location + cacheManager.readyRange_KDJ.length;
    if (fromIndex < toIndex) {
        NSRange caculaterRange = NSMakeRange(fromIndex, toIndex - fromIndex);
        [YT_KDJCalculator calculateKDJ:klineDataArray range:caculaterRange handleUsingBlock:^id<YT_StockKDJHandle> _Nonnull(NSUInteger idx) {
            return (id<YT_StockKDJHandle>)[cacheManager.cacheArray objectAtIndex:idx];
        } progress:^(NSUInteger location, id<YT_StockKDJHandle>  _Nonnull result) {
        } complete:^(NSRange rsRange, NSError * _Nullable error) {
            cacheManager.readyRange_KDJ = NSMakeRange(0, rsRange.location + rsRange.length);
        }];
    }
    
    //从新计算显示范围内的最大最小值
    [YT_KLineCalculator usePatternSetMaxMin:axisParam range:range init:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        YT_KlineDataCalculateCache *kdata_one = [cacheManager.cacheArray objectAtIndex:range.location];
        axis->max = kdata_one.cache_K; // 赋初始值
        axis->min = kdata_one.cache_K; // 赋初始值
    } progress:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        YT_KlineDataCalculateCache * kdata_one = [cacheManager.cacheArray objectAtIndex:idx];
        YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_K, idx);
        YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_D, idx);
        YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_J, idx);
    }];
}

- (void)getWRFrom:(NSArray <id <YT_StockKlineData>> *)klineDataArray range:(NSRange)range reuseAxisParam:(YT_CoordinateAxisParam *)axisParam cacheManager:(YT_KlineDataCalculateCacheManager *)cacheManager {
    // 计算WR并储存
    NSInteger toIndex = range.location + range.length;
    NSInteger fromIndex = cacheManager.readyRange_WR.location + cacheManager.readyRange_WR.length;
    if (fromIndex < toIndex) {
        NSRange caculaterRange = NSMakeRange(fromIndex, toIndex - fromIndex);
        [YT_WRCalculator calculateWR:klineDataArray range:caculaterRange handleUsingBlock:^id<YT_StockWRHandle> _Nonnull(NSUInteger idx) {
            return (id<YT_StockWRHandle>)[cacheManager.cacheArray objectAtIndex:idx];
        } progress:^(NSUInteger location, id<YT_StockWRHandle>  _Nonnull result) {
        } complete:^(NSRange rsRange, NSError * _Nullable error) {
            cacheManager.readyRange_WR = NSMakeRange(0, rsRange.location + rsRange.length);
        }];
    }
    
    //从新计算显示范围内的最大最小值
    [YT_KLineCalculator usePatternSetMaxMin:axisParam range:range init:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        YT_KlineDataCalculateCache *kdata_one = [cacheManager.cacheArray objectAtIndex:range.location];
        axis->max = kdata_one.cache_WR10; // 赋初始值
        axis->min = kdata_one.cache_WR6; // 赋初始值
    } progress:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        YT_KlineDataCalculateCache * kdata_one = [cacheManager.cacheArray objectAtIndex:idx];
        YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_WR10, idx);
        YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_WR6, idx);
    }];
    
}

- (void)getBOLLFrom:(NSArray <id <YT_StockKlineData>> *)klineDataArray range:(NSRange)range reuseAxisParam:(YT_CoordinateAxisParam *)axisParam cacheManager:(YT_KlineDataCalculateCacheManager *)cacheManager {
    // 计算BOLL并储存 没必要从头算不过从头算代码简单👌
    NSInteger toIndex = range.location + range.length;
    NSInteger fromIndex = cacheManager.readyRange_BOLL.location + cacheManager.readyRange_BOLL.length;
    if (fromIndex < toIndex) {
        NSRange caculaterRange = NSMakeRange(fromIndex, toIndex - fromIndex);
        [YT_BOLLCalculator calculateBOLL:klineDataArray range:caculaterRange handleUsingBlock:^id<YT_StockBOLLHandle> _Nonnull(NSUInteger idx) {
            return (id<YT_StockBOLLHandle>)[cacheManager.cacheArray objectAtIndex:idx];
        } complete:^(NSRange rsRange, NSError * _Nullable error) {
            cacheManager.readyRange_BOLL = NSMakeRange(0, rsRange.location + rsRange.length);
        }];
    }
    
    //从新计算显示范围内的最大最小值
    //算蜡烛线最大最小值
    YT_CoordinateAxisParam klineCAxisParam = self.klineCAxisParam;
    if (!NSEqualRanges(klineCAxisParam.range, range)) {
        [self t_calculateKLineCCoordinateAxisYParam:klineDataArray range:range reuseParam:&klineCAxisParam];
    }
    
    //算上行最大值
    [YT_KLineCalculator findIdxUsePatternCallBlockWithReuseRange:axisParam->range reuseIdx:axisParam->maxIndex range:range init:^(NSUInteger idx) {
        axisParam->max = YTSCFLOAT_MIN;
    } progress:^(NSUInteger idx) {
        YT_KlineDataCalculateCache * kdata_one = [cacheManager.cacheArray objectAtIndex:idx];
        YTSCFloat compareOne = kdata_one.cache_BOLL_Upper;
        if (compareOne != YTSCFLOAT_NULL && compareOne > axisParam->max) { //算max compareOne!=YTSCFLOAT_NULL 可略
            axisParam->max = compareOne;axisParam->maxIndex = idx;
        }
    }];
    
    //算下行最小值
    [YT_KLineCalculator findIdxUsePatternCallBlockWithReuseRange:axisParam->range reuseIdx:axisParam->minIndex range:range init:^(NSUInteger idx) {
        axisParam->min = YTSCFLOAT_MAX;
    } progress:^(NSUInteger idx) {
        YT_KlineDataCalculateCache * kdata_one = [cacheManager.cacheArray objectAtIndex:idx];
        YTSCFloat compareOne = kdata_one.cache_BOLL_Lower;
        if (compareOne != YTSCFLOAT_NULL && compareOne < axisParam->min) {
            axisParam->min = compareOne;axisParam->minIndex = idx;
        }
    }];
    
    if (klineCAxisParam.max > axisParam->max) {
        axisParam->max = klineCAxisParam.max;axisParam->maxIndex = klineCAxisParam.maxIndex;
    }
    
    if (klineCAxisParam.min < axisParam->min) {
        axisParam->min = klineCAxisParam.min;axisParam->minIndex = klineCAxisParam.minIndex;
    }
//    NSLog(@"max %lf, min%lf" ,axisParam->max,axisParam->min);
    axisParam->range = range;
}

- (void)getDMIFrom:(NSArray <id <YT_StockKlineData>> *)klineDataArray range:(NSRange)range reuseAxisParam:(YT_CoordinateAxisParam *)axisParam cacheManager:(YT_KlineDataCalculateCacheManager *)cacheManager {
    // 计算DMI并储存
    NSInteger toIndex = range.location + range.length;
    NSInteger fromIndex = cacheManager.readyRange_DMI.location + cacheManager.readyRange_DMI.length;
    if (fromIndex < toIndex) {
        NSRange caculaterRange = NSMakeRange(fromIndex, toIndex - fromIndex);
        [YT_DMICalculator calculateDMI:klineDataArray range:caculaterRange handleUsingBlock:^id<YT_StockDMIHandle> _Nonnull(NSUInteger idx) {
            return (id<YT_StockDMIHandle>)[cacheManager.cacheArray objectAtIndex:idx];
        } complete:^(NSRange rsRange, NSError * _Nullable error) {
            cacheManager.readyRange_DMI = NSMakeRange(0, rsRange.location + rsRange.length);
        }];
    }
    
    //从新计算显示范围内的最大最小值
    [YT_KLineCalculator usePatternSetMaxMin:axisParam range:range init:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        axis->max = YTSCFLOAT_MIN; // 赋初始值
        axis->min = YTSCFLOAT_MAX; // 赋初始值
    } progress:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        YT_KlineDataCalculateCache * kdata_one = [cacheManager.cacheArray objectAtIndex:idx];
        if (kdata_one.cache_PDI != YTSCFLOAT_NULL) {
            YT_CoordinateAxisParamSetMaxMinAfterCompare2(axis, kdata_one.cache_PDI, idx);
            YT_CoordinateAxisParamSetMaxMinAfterCompare2(axis, kdata_one.cache_MDI, idx);
    
            if (kdata_one.cache_ADX != YTSCFLOAT_NULL) {
                YT_CoordinateAxisParamSetMaxMinAfterCompare2(axis, kdata_one.cache_ADX, idx);
               if (kdata_one.cache_ADXR != YTSCFLOAT_NULL) {
                   YT_CoordinateAxisParamSetMaxMinAfterCompare2(axis, kdata_one.cache_ADXR, idx);
                }
            }
        }
    }];
}

- (void)getVRFrom:(NSArray <id <YT_StockKlineData>> *)klineDataArray range:(NSRange)range reuseAxisParam:(YT_CoordinateAxisParam *)axisParam cacheManager:(YT_KlineDataCalculateCacheManager *)cacheManager {
    // 计算 vr
    NSInteger toIndex = range.location + range.length;
    NSInteger fromIndex = cacheManager.readyRange_VR.location + cacheManager.readyRange_VR.length;
    if (fromIndex < toIndex) {
        NSRange caculaterRange = NSMakeRange(fromIndex, toIndex - fromIndex);
        [YT_VRCalculator calculateVR:klineDataArray range:caculaterRange handleUsingBlock:^id<YT_StockVRHandle> _Nonnull(NSUInteger idx) {
             return (id<YT_StockVRHandle>)[cacheManager.cacheArray objectAtIndex:idx];
        } complete:^(NSRange rsRange, NSError * _Nullable error) {
            cacheManager.readyRange_VR = NSMakeRange(0, rsRange.location + rsRange.length);
        }];
    }
    
    //从新计算显示范围内的最大最小值
    NSInteger loc_s = MAX(range.location, [YT_VRCalculator minAccurateVRIndex]);
    NSInteger len_s = range.location + range.length - loc_s;
    if (len_s > 0) {
    
        [YT_KLineCalculator usePatternSetMaxMin:axisParam range:NSMakeRange(loc_s, len_s) init:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
            YT_KlineDataCalculateCache * kdata_one = [cacheManager.cacheArray objectAtIndex:range.location];
            axis->max = kdata_one.cache_VR; // 赋初始值
            axis->min = kdata_one.cache_VR; // 赋初始值
        } progress:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
            YT_KlineDataCalculateCache * kdata_one = [cacheManager.cacheArray objectAtIndex:idx];
            YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_VR, idx);
        }];
        
        NSInteger minAccurateVRMAIndex = [YT_VRCalculator minAccurateVRIndex] + DAYS_MAVR - 1;
        NSInteger maNeedCompareTo = loc_s + MIN(DAYS_MAVR, len_s); // ma 只需要比较部分范围就行。
        NSInteger maNeedCompareForm = MAX(loc_s, minAccurateVRMAIndex);
        for (NSInteger i = maNeedCompareForm; i < maNeedCompareTo; i++) {
            YT_KlineDataCalculateCache * kdata_one = [cacheManager.cacheArray objectAtIndex:i];
            YT_CoordinateAxisParamSetMaxMinAfterCompare(axisParam, kdata_one.cache_VR_MA6, i);
        }
        
    }else {
        axisParam->max = 0;
        axisParam->min = 0;
    }

}

- (void)getCRFrom:(NSArray <id <YT_StockKlineData>> *)klineDataArray range:(NSRange)range reuseAxisParam:(YT_CoordinateAxisParam *)axisParam cacheManager:(YT_KlineDataCalculateCacheManager *)cacheManager {
    // 计算CR并储存 从头算（从index0开始算）
    NSInteger toIndex = range.location + range.length;
    NSInteger fromIndex = cacheManager.readyRange_CR.location + cacheManager.readyRange_CR.length;
    if (fromIndex < toIndex) {
        NSRange caculaterRange = NSMakeRange(fromIndex, toIndex - fromIndex);
        [YT_CRCalculator calculateCR:klineDataArray range:caculaterRange handleUsingBlock:^id<YT_StockCRHandle> _Nonnull(NSUInteger idx) {
            return (id<YT_StockCRHandle>)[cacheManager.cacheArray objectAtIndex:idx];
        } complete:^(NSRange rsRange, NSError * _Nullable error) {
            cacheManager.readyRange_CR = NSMakeRange(0, rsRange.location + rsRange.length);
        }];
    }
    
    //从新计算显示范围内的最大最小值
    [YT_KLineCalculator usePatternSetMaxMin:axisParam range:range init:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        YT_KlineDataCalculateCache *kdata_one = [cacheManager.cacheArray objectAtIndex:range.location];
        axis->max = kdata_one.cache_CR; // 赋初始值
        axis->min = kdata_one.cache_CR; // 赋初始值
    } progress:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        YT_KlineDataCalculateCache * kdata_one = [cacheManager.cacheArray objectAtIndex:idx];
        YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_CR, idx);
        if (kdata_one.cache_CR_MA10 != YTSCFLOAT_NULL)
        YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_CR_MA10, idx);
        if (kdata_one.cache_CR_MA20 != YTSCFLOAT_NULL)
        YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_CR_MA20, idx);
        /*
        if (kdata_one.cache_CR_MA40 != YTSCFLOAT_NULL)
        [YT_KLineCalculator setMaxMin:axis afterCompare:kdata_one.cache_CR_MA40 idx:idx];
        if (kdata_one.cache_CR_MA62 != YTSCFLOAT_NULL)
        [YT_KLineCalculator setMaxMin:axis afterCompare:kdata_one.cache_CR_MA62 idx:idx];
         */
    }];
    
}

- (void)getRSIFrom:(NSArray <id <YT_StockKlineData>> *)klineDataArray range:(NSRange)range reuseAxisParam:(YT_CoordinateAxisParam *)axisParam cacheManager:(YT_KlineDataCalculateCacheManager *)cacheManager {
    // 计算RSI并储存
    NSInteger toIndex = range.location + range.length;
    NSInteger fromIndex = cacheManager.readyRange_RSI.location + cacheManager.readyRange_RSI.length;
    if (fromIndex < toIndex) {
        NSRange caculaterRange = NSMakeRange(fromIndex, toIndex - fromIndex);
        [YT_RSICalculator calculateRSI:klineDataArray prevArgv:&_RSICalculateArgv range:caculaterRange handleUsingBlock:^id<YT_StockRSIHandle> _Nonnull(NSUInteger idx) {
             return (id<YT_StockRSIHandle>)[cacheManager.cacheArray objectAtIndex:idx];
        } complete:^(NSRange rsRange, NSError * _Nullable error) {
            cacheManager.readyRange_RSI = NSMakeRange(0, rsRange.location + rsRange.length);
        }];
    }
    
    //从新计算显示范围内的最大最小值
    [YT_KLineCalculator usePatternSetMaxMin:axisParam range:range init:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        YT_KlineDataCalculateCache * kdata_one = [cacheManager.cacheArray objectAtIndex:idx];
        axis->max = kdata_one.cache_RSI6; // 赋初始值
        axis->min = kdata_one.cache_RSI6; // 赋初始值
    } progress:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        YT_KlineDataCalculateCache * kdata_one = [cacheManager.cacheArray objectAtIndex:idx];
        YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_RSI6, idx);
        YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_RSI12, idx);
        YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_RSI24, idx);
    }];
}

- (void)getBIASFrom:(NSArray <id <YT_StockKlineData>> *)klineDataArray range:(NSRange)range reuseAxisParam:(YT_CoordinateAxisParam *)axisParam cacheManager:(YT_KlineDataCalculateCacheManager *)cacheManager {
    // 计算BIAS并储存
    NSInteger toIndex = range.location + range.length;
    NSInteger fromIndex = cacheManager.readyRange_BIAS.location + cacheManager.readyRange_BIAS.length;
    if (fromIndex < toIndex) {
        NSRange caculaterRange = NSMakeRange(fromIndex, toIndex - fromIndex);
        [YT_BIASCalculator calculateBIAS:klineDataArray range:caculaterRange handleUsingBlock:^id<YT_StockBIASHandle> _Nonnull(NSUInteger idx) {
            return (id<YT_StockBIASHandle>)[cacheManager.cacheArray objectAtIndex:idx];
        } progress:^(NSUInteger location, id<YT_StockBIASHandle>  _Nonnull result) {
        } complete:^(NSRange rsRange, NSError * _Nullable error) {
            cacheManager.readyRange_BIAS = NSMakeRange(0, rsRange.location + rsRange.length);
        }];
    }
    
    //从新计算显示范围内的最大最小值
    [YT_KLineCalculator usePatternSetMaxMin:axisParam range:range init:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        axis->max = YTSCFLOAT_MIN; // 赋初始值
        axis->min = YTSCFLOAT_MAX; // 赋初始值
    } progress:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        YT_KlineDataCalculateCache * kdata_one = [cacheManager.cacheArray objectAtIndex:idx];
        if (kdata_one.cache_BIAS6 != YTSCFLOAT_NULL)
        YT_CoordinateAxisParamSetMaxMinAfterCompare2(axis, kdata_one.cache_BIAS6, idx);
        if (kdata_one.cache_BIAS12 != YTSCFLOAT_NULL)
        YT_CoordinateAxisParamSetMaxMinAfterCompare2(axis, kdata_one.cache_BIAS12, idx);
        if (kdata_one.cache_BIAS24 != YTSCFLOAT_NULL)
        YT_CoordinateAxisParamSetMaxMinAfterCompare2(axis, kdata_one.cache_BIAS24, idx);
    }];
}

- (void)getDMAFrom:(NSArray <id <YT_StockKlineData>> *)klineDataArray range:(NSRange)range reuseAxisParam:(YT_CoordinateAxisParam *)axisParam cacheManager:(YT_KlineDataCalculateCacheManager *)cacheManager {
    // 计算DMA并储存
    NSInteger toIndex = range.location + range.length;
    NSInteger fromIndex = cacheManager.readyRange_DMA.location + cacheManager.readyRange_DMA.length;
    if (fromIndex < toIndex) {
        NSRange caculaterRange = NSMakeRange(fromIndex, toIndex - fromIndex);
        [YT_DMACalculator calculateDMA:klineDataArray range:caculaterRange handleUsingBlock:^id<YT_StockDMAHandle> _Nonnull(NSUInteger idx) {
            return (id<YT_StockDMAHandle>)[cacheManager.cacheArray objectAtIndex:idx];
        } complete:^(NSRange rsRange, NSError * _Nullable error) {
            cacheManager.readyRange_DMA = NSMakeRange(0, rsRange.location + rsRange.length);
        }];
    }
    
    //从新计算显示范围内的最大最小值
    [YT_KLineCalculator usePatternSetMaxMin:axisParam range:range init:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        YT_KlineDataCalculateCache *kdata_one = [cacheManager.cacheArray objectAtIndex:range.location];
        axis->max = kdata_one.cache_DMA; // 赋初始值
        axis->min = kdata_one.cache_DMA; // 赋初始值
    } progress:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        YT_KlineDataCalculateCache * kdata_one = [cacheManager.cacheArray objectAtIndex:idx];
        YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_DMA, idx);
        YT_CoordinateAxisParamSetMaxMinAfterCompare(axis, kdata_one.cache_AMA, idx);
    }];
    
}

- (void)getCCIFrom:(NSArray <id <YT_StockKlineData>> *)klineDataArray range:(NSRange)range reuseAxisParam:(YT_CoordinateAxisParam *)axisParam cacheManager:(YT_KlineDataCalculateCacheManager *)cacheManager {
    // 计算CCI并储存
    NSInteger toIndex = range.location + range.length;
    NSInteger fromIndex = cacheManager.readyRange_CCI.location + cacheManager.readyRange_CCI.length;
    if (fromIndex < toIndex) {
        NSRange caculaterRange = NSMakeRange(fromIndex, toIndex - fromIndex);
        [YT_CCICalculator calculateCCI:klineDataArray range:caculaterRange handleUsingBlock:^id<YT_StockCCIHandle> _Nonnull(NSUInteger idx) {
            return (id<YT_StockCCIHandle>)[cacheManager.cacheArray objectAtIndex:idx];
        } progress:^(NSUInteger location, id<YT_StockCCIHandle>  _Nonnull result) {
        } complete:^(NSRange rsRange, NSError * _Nullable error) {
            cacheManager.readyRange_CCI = NSMakeRange(0, rsRange.location + rsRange.length);
        }];
    }
    
    //从新计算显示范围内的最大最小值
    [YT_KLineCalculator usePatternSetMaxMin:axisParam range:range init:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        axis->max = YTSCFLOAT_MIN; // 赋初始值
        axis->min = YTSCFLOAT_MAX; // 赋初始值
    } progress:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        YT_KlineDataCalculateCache * kdata_one = [cacheManager.cacheArray objectAtIndex:idx];
        if (kdata_one.cache_CCI != YTSCFLOAT_NULL) {
            YT_CoordinateAxisParamSetMaxMinAfterCompare2(axis, kdata_one.cache_CCI, idx);
        }
    }];
}

- (void)getVOLFrom:(NSArray <id <YT_StockKlineData>> *)klineDataArray range:(NSRange)range reuseAxisParam:(YT_CoordinateAxisParam *)axisParam cacheManager:(YT_KlineDataCalculateCacheManager *)cacheManager {
    // 使用服务器直接下发数据nTech, 不需要计算
    
    // 成交量最小固定为 0
    (*axisParam).min = 0;
    (*axisParam).minIndex = NSIntegerMax;
    
    //从新计算显示范围内的最大值
    [YT_KLineCalculator findIdxUsePatternCallBlockWithReuseRange:axisParam->range reuseIdx:axisParam->maxIndex range:range init:^(NSUInteger idx) {
         axisParam->max = 0; // 赋初始值
    } progress:^(NSUInteger idx) {
        id<YT_StockKlineData> kdata_one = [klineDataArray objectAtIndex:idx];
        YTSCFloat cjsl = kdata_one.yt_volumeOfTransactions;
        YTSCFloat cjsl_ma1 = kdata_one.yt_techMA1;
        YTSCFloat cjsl_ma2 = kdata_one.yt_techMA2;
        if (cjsl > axisParam->max) {
            axisParam->max = cjsl;axisParam->maxIndex = idx;
        }
        if (cjsl_ma1 > axisParam->max) {
            axisParam->max = cjsl_ma1;axisParam->maxIndex = idx;
        }
        if (cjsl_ma2 > axisParam->max) {
            axisParam->max = cjsl_ma2;axisParam->maxIndex = idx;
        }
    }];
     axisParam->range = range;
}

#pragma mark  kline CoordinateAxisYParam

/**
 *  计算需要显示的数据的最大和最小参数，确定Y轴数值以及蜡烛线的位置等 - C
 */
- (void)t_calculateKLineCCoordinateAxisYParam:(NSArray <id <YT_StockKlineData>> *)klineDataArray range:(NSRange)range reuseParam:(YT_CoordinateAxisParam *)reuseParam {
    
    // 计算最大价格
    [YT_KLineCalculator findIdxUsePatternCallBlockWithReuseRange:reuseParam->range reuseIdx:reuseParam->maxIndex range:range init:^(NSUInteger idx) {
        reuseParam->max = YTSCFLOAT_MIN; // 赋初始值
    } progress:^(NSUInteger idx) {
        id<YT_StockKlineData> kxData = [klineDataArray objectAtIndex:idx];
        YTSCFloat zgcj = kxData.yt_highPrice;
        if (zgcj > reuseParam->max) {
//            NSLog(@"maxnPrice %f",zgcj);
            reuseParam->max = zgcj; reuseParam->maxIndex = idx;
        }
    }];
    // 计算最小价格
    [YT_KLineCalculator findIdxUsePatternCallBlockWithReuseRange:reuseParam->range reuseIdx:reuseParam->minIndex range:range init:^(NSUInteger idx) {
        reuseParam->min = YTSCFLOAT_MAX; // 赋初始值
    } progress:^(NSUInteger idx) {
        id<YT_StockKlineData> kxData = [klineDataArray objectAtIndex:idx];
        YTSCFloat zdcj = kxData.yt_lowPrice;
        if (zdcj < reuseParam->min) {
//            NSLog(@"minPrice %f",zdcj);
            reuseParam->min = zdcj; reuseParam->minIndex = idx;
        }
    }];
//    NSLog(@"maxnPrice %f",reuseParam->max);
//    NSLog(@"minPrice %f",reuseParam->min);
    reuseParam->range = range;
}

/**
 *  计算需要显示的数据的最大和最小参数，确定Y轴数值以及蜡烛线的位置等 - MA
 */
- (void)t_calculateKLineMACoordinateAxisYParam:(NSRange)range reuseParam:(YT_CoordinateAxisParam *)reuseParam cacheManager:(YT_KlineDataCalculateCacheManager *)cacheManager{
    NSArray<YT_KlineMAExplain *> * explainArr = [self klineZBMAExplainArray];
    NSArray<YT_KlineDataCalculateCache *> * cacheArray = cacheManager.cacheArray;
    [YT_KLineCalculator usePatternSetMaxMin:reuseParam range:range init:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        axis->max = YTSCFLOAT_MIN; // 赋初始值
        axis->min = YTSCFLOAT_MAX; // 赋初始值
    } progress:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
        YT_KlineDataCalculateCache * kdata_one = [cacheArray objectAtIndex:idx];
        for (YT_KlineMAExplain *explain in explainArr) {
            YTSCFloat afloat = kdata_one.cache_Closs_MA[explain.index];
            if (afloat != YTSCFLOAT_NULL) {
                 YT_CoordinateAxisParamSetMaxMinAfterCompare2(axis, afloat, idx);
            }
        }
    }];
}

/**
 *  计算需要显示的数据的最大和最小参数，确定Y轴数值以及蜡烛线的位置等 - MA
 */
- (void)t_calculateNeedBeCompareKLineMACoordinateAxisYParam:(NSRange)range reuseParam:(YT_CoordinateAxisParam *)reuseParam cacheManager:(YT_KlineDataCalculateCacheManager *)cacheManager{
    
    if (!(YT_RangeContainLocation(range, reuseParam->maxIndex) && YT_RangeContainLocation(range, reuseParam->minIndex))) {
        reuseParam->max = YTSCFLOAT_MIN; // 赋初始值
        reuseParam->min = YTSCFLOAT_MAX; // 赋初始值
        reuseParam->range = NSMakeRange(0, 0);
    }
    
    NSArray<YT_KlineMAExplain *> * explainArr = [self klineZBMAExplainArray];
    NSArray<YT_KlineDataCalculateCache *> * cacheArray = cacheManager.cacheArray;
    
    YT_CoordinateAxisParam param;
    NSUInteger days;NSUInteger from;NSUInteger to;NSUInteger len;NSRange needBeComRange;
    for (YT_KlineMAExplain *explain in explainArr) {
        days = explain.day;
        if (days < 1) {
            continue;
        }
        
        len = range.length;
        len = MIN(days -1, len);
        from = range.location;
        to = from + len;
        from = MAX(days -1, from);
        len = to > from ? to - from : 0;
        if (len == 0) {
            continue;
        }
        needBeComRange.location  = from;
        needBeComRange.length = len;
        param = * reuseParam;
        
        [YT_KLineCalculator usePatternSetMaxMin:&param range:needBeComRange init:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
            axis->max = YTSCFLOAT_MIN; // 赋初始值
            axis->min = YTSCFLOAT_MAX; // 赋初始值
        } progress:^(NSUInteger idx ,YT_CoordinateAxisParam *axis) {
            YT_KlineDataCalculateCache * kdata_one = [cacheArray objectAtIndex:idx];
            YTSCFloat afloat = kdata_one.cache_Closs_MA[explain.index];
            YT_CoordinateAxisParamSetMaxMinAfterCompare2(axis, afloat, idx);
        }];
        
        if(param.max > reuseParam->max) {
            reuseParam->max = param.max;
            reuseParam->maxIndex = param.maxIndex;
        }
        
        if(param.min < reuseParam->min) {
            reuseParam->min = param.min;
            reuseParam->minIndex = param.minIndex;
        }
    }
    reuseParam -> range = range;
//    NSLog(@"====xx %@",NSStringFormCoordinateAxisParam(*reuseParam));
}

- (YT_KLineCoordinateAxisParam)calculateKLineCoordinateAxisYParam:(NSArray <id <YT_StockKlineData>> *)klineDataArray cAxisParam:(YT_CoordinateAxisParam)cAxisParam kMAAxisParam:(YT_CoordinateAxisParam)maAxisParam {
    
    YT_KLineCoordinateAxisParam rsAxisParam;
    
    NSRange range = cAxisParam.range;
    id<YT_StockKlineData> firstData;
    
    if (range.location < klineDataArray.count) {
        firstData = [klineDataArray objectAtIndex:range.location];
    }
    
    YTSCFloat maxPrice = cAxisParam.max;
    YTSCFloat minPrice = cAxisParam.min;
    
    NSUInteger  maxPriceIndex = cAxisParam.maxIndex;
    NSUInteger  minPriceIndex = cAxisParam.minIndex;
    
    if( NSEqualRanges(maAxisParam.range,range) ){
        if (maAxisParam.max > maxPrice) {
            maxPrice = maAxisParam.max;
            maxPriceIndex = maAxisParam.maxIndex;
//            NSLog(@"maxPrice %f",maxPrice);
        }
        
        if (maAxisParam.min < minPrice) {
            minPrice = maAxisParam.min;
            minPriceIndex = maAxisParam.minIndex;
//            NSLog(@"minPrice %f",minPrice);
        }
    }
//     NSLog(@"maxPrice %f",maxPrice);
//     NSLog(@"minPrice %f",minPrice);
    // 计算最大/最低涨幅
    YTSCFloat open = firstData.yt_openPrice;
    YTSCFloat maxZDF = (maxPrice - open) / open;
    YTSCFloat minZDF = (minPrice - open) / open;
    
    rsAxisParam.maxPrice = maxPrice ;rsAxisParam.maxPriceIndex = maxPriceIndex;
    rsAxisParam.minPrice = minPrice ;rsAxisParam.minPriceIndex = minPriceIndex;
    rsAxisParam.maxZDF = maxZDF ;rsAxisParam.minZDF = minZDF;
    
    rsAxisParam.range = range;
    return rsAxisParam;
}

#pragma mark Kline CustomMA

-(NSArray<YT_KlineMAExplain *> *)klineZBMAExplainArray {
    if (!_klineZBMAExplainArray) {
        _klineZBMAExplainArray = [self klineZBMAExplainArrayDefault];
    }
    return _klineZBMAExplainArray;
}

-(NSArray<YT_KlineMAExplain *> *)klineZBMAExplainArrayDefault {
    
    NSMutableArray * arr = [NSMutableArray array];
    YT_KlineMAExplain * oneExplain = [[YT_KlineMAExplain alloc] init];
    oneExplain.index = 0;
    oneExplain.day = 5;
    [arr addObject:oneExplain];
    
    oneExplain = [[YT_KlineMAExplain alloc] init];
    oneExplain.index = 1;
    oneExplain.day = 10;
    [arr addObject:oneExplain];
    
    oneExplain = [[YT_KlineMAExplain alloc] init];
    oneExplain.index = 2;
    oneExplain.day = 30;
    [arr addObject:oneExplain];
    
    return arr;
}

- (void)calculateKlineCustomMA:(NSArray <id <YT_StockKlineData>> *)klineDataArray range:(NSRange)range cacheManager:(YT_KlineDataCalculateCacheManager *)cacheManager {
    NSArray<YT_KlineMAExplain *> * arr = [self klineZBMAExplainArray];
    for (YT_KlineMAExplain *explain in arr) {
        [self calculateKlineCustomMA:klineDataArray range:range cacheManager:cacheManager days:explain.day saveIndex:explain.index];
    }
}

- (void)calculateKlineCustomMA:(NSArray <id <YT_StockKlineData>> *)klineDataArray range:(NSRange)range cacheManager:(YT_KlineDataCalculateCacheManager *)cacheManager days:(NSInteger)days saveIndex:(NSInteger)index{
    if (range.length == 0) return;
    if (index < 0 || index >= 5) return; // k线蜡烛线一共存储的坑只有5个
    if (days < 1 || days > klineDataArray.count) return; // days == count 有且只有一个值
   
    BOOL reuseNetKLineMA = NO;
    if (reuseNetKLineMA) {
        
        if (days == 5){
            //5日均线，用默认值
//            for (NSInteger i = nStart; i<nEnd; i++) {
//                stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:i];
//                [kxData setValue:kxData.MA1 forKeyPath:keyPath];
//            }
        }else if (days == 10){
            //10日均线，用默认值
//            for (NSInteger i = nStart; i<nEnd; i++) {
//                stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:i];
//                [kxData setValue:kxData.MA2 forKeyPath:keyPath];
//            }
        }else if (days == 30){
            //30日均线，用默认值
//            for (NSInteger i = nStart; i<nEnd; i++) {
//                stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:i];
//                [kxData setValue:kxData.MA3 forKeyPath:keyPath];
//            }
        }
    }
    
    if (days == 1){
        //均线定义为1日，直接用收盘价表示
        for (NSInteger i = range.location; i< range.location + range.length; i++) {
            id<YT_StockKlineData> kxData = [klineDataArray objectAtIndex:i];
            YT_KlineDataCalculateCache * cache = [cacheManager.cacheArray objectAtIndex:i];
            cache.cache_Closs_MA[index] = kxData.yt_closePrice;
            cacheManager.readyRange_Closs_MA[index] = range;
        }
    }else{
        
        NSRange rs_rg = NSMakeRange(0, 0);
        rs_rg = [self usePatternCaculaterRange:range readyRange:cacheManager.readyRange_Closs_MA[index] caculaterBlock:^NSRange(NSRange needCaculaterRange) {
            __block NSRange rsRange  = NSMakeRange(0, 0);
            [klineDataArray calculateMA:days range:needCaculaterRange usingGetterSel:@selector(yt_closePrice) progress:^(NSUInteger location, YTSCFloat maValue) {
                YT_KlineDataCalculateCache * cache = [cacheManager.cacheArray objectAtIndex:location];
                cache.cache_Closs_MA[index] = maValue;
            } complete:^(NSRange maValueRange, NSError * _Nullable error) {
                rsRange = maValueRange;
            }];
            return rsRange;
        }];
        cacheManager.readyRange_Closs_MA[index] = rs_rg;
        
    }
}

#pragma mark - tool

/**
  使用固定的模式调用 caculaterBlock 优化计算

 @param range 计算范围
 @param readyRange 已经计算完毕的范围
 @param caculaterBlock 计算代码块
 @return 计算结果范围
 */
- (NSRange)usePatternCaculaterRange:(NSRange)range readyRange:(NSRange)readyRange caculaterBlock:(NSRange(NS_NOESCAPE^)(NSRange needCaculaterRange))caculaterBlock {
  
    NSRange needRange = YT_RangeUnionRange(range, readyRange);
//    NSLog(@"youhuajisuan needRange %@",NSStringFromRange(needRange));
    
    NSRange needCaRange1 = NSMakeRange(0, 0);
    NSRange needCaRange2 = NSMakeRange(0, 0);
    YT_RangeSubRange2(needRange, readyRange,&needCaRange1,&needCaRange2);
    NSInteger needCaCount = needCaRange1.length + needCaRange2.length;
    
    NSRange rsRange = readyRange;
//    NSLog(@"youhuajisuan readyRange %@",NSStringFromRange(readyRange));
    if (needCaCount < range.length) { //优化计算书比重置计算数少
        BOOL isSuc = YES; //优化计算是否成功
        if(needCaRange1.length > 0) {
//            NSLog(@"youhuajisuan needCaRange1 %@",NSStringFromRange(needCaRange1));
            NSRange rsRange_t =  caculaterBlock(needCaRange1);
//            NSLog(@"youhuajisuan rsRange_t1 %@",NSStringFromRange(rsRange_t));
            rsRange = [self range:rsRange appendRangeIfCan:rsRange_t isSuc:&isSuc];
        }
        if(isSuc && needCaRange2.length > 0) {
            NSRange rsRange_t =  caculaterBlock(needCaRange2);
            rsRange = [self range:rsRange appendRangeIfCan:rsRange_t isSuc:&isSuc];
        }
        if (isSuc == YES) {
//            NSLog(@"youhuajisuan rsRange %@",NSStringFromRange(range));
            return rsRange;
        }
    }
    // 优化计算失败 直接计算目标范围的值并赋值
//    rsRange =  caculaterBlock(range);
//    NSLog(@"youhuajisuan shi bai");
    return  caculaterBlock(range);
}


/**
 当头尾相连返回拼接结果 否则返回range1
 */
- (NSRange)range:(NSRange)range appendRangeIfCan:(NSRange)range1 isSuc:(BOOL *)suc{
    if (range.location == range1.location + range1.length) {
        range.location = range1.location;
        range.length += range1.length;
        *suc = YES;
    }else if (range.location + range.length == range1.location) {
        range.length += range1.length;
        *suc = YES;
    }else{
        *suc = NO;
    }
    return range;
}
@end
