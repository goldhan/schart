//
//  YT_KLineDataSource.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2017/9/15.
//  Copyright © 2017年 kds. All rights reserved.
//

#import "YT_KLineDataSource.h"
#import "stock_kline_data+YT_NFloat.h"
#import "stock_kline_data+YT_stock_kline_data.h"
#import "YT_KLineDataCalculateCache.h"

#define kRSVDays                  9
#define kEMA12Days                12
#define kEMA26Days                26
#define kDIFDays                  9
#define kCR26Days                 26

#define kTecColor_CustomKline1  skinColor(@"FSKLine_Color_CustomKLine1")
#define kTecColor_CustomKline2  skinColor(@"FSKLine_Color_CustomKLine2")
#define kTecColor_CustomKline3  skinColor(@"FSKLine_Color_CustomKLine3")
#define kTecColor_CustomKline4  skinColor(@"FSKLine_Color_CustomKLine4")
#define kTecColor_CustomKline5  skinColor(@"FSKLine_Color_CustomKLine5")

#define MIN_HASMA_INSDEX(MA_Day) ((MA_Day)-1) //能算平均值的最小索引，周期A

struct YT_CalculateRange {
    NSUInteger nStart;
    NSUInteger nEnd;
};
typedef struct YT_CalculateRange YT_CalculateRange;

@interface YT_KLineDataSource ()
{

    NFloat *fk, *fd, *fj;                         // KDJ计算需要的变量
    NFloat *fEMA12, *fEMA26, *fDIF, *fDEA, *startKFloat, *endKFloat;// MACD计算需要的变量
    NFloat *fOBV_Value1, *fOBV_Value2;           // OBV计算需要的变量
    NFloat *fWR10, *fWR6;                      // WR
    NFloat *fVR_Value1, *fVR_Value2;           // VR，VR6天平均值
    NFloat *fCR_Value1;                        // CR
    NFloat *tempKFloat;
    NFloat *fMA10, *fMA50, *fDMA_Value1, *fDMA_Value2;  // DMA
    
    NFloat *fBOLLUPPER, *fBOLLLOWER;            // BOLL
    NFloat *RSI6, *RSI12, *RSI24;               // RSI
    
    /***除了计算RSI，其他方法不可重用，记录lastHasRSIIndex索引下的数据,为计算lastHasRSIIndex+1使用**/
    NFloat *SMAMAX_RSI6, *SMAMAX_RSI12, *SMAMAX_RSI24,  *SMAABS_RSI6, *SMAABS_RSI12, *SMAABS_RSI24;  // RSI
    
    NSInteger nKLineCount_;    // K线的根数
    
    /********控制计算的句柄**********/
    NSInteger lastHasMACDIndex;
    BOOL  zhibiao_MACD_needReCaculate;
    NSInteger lastHasKDJIndex;
    BOOL  zhibiao_KDJ_needReCaculate;
    NSInteger lastHasOBVIndex;
    BOOL  zhibiao_OBV_needReCaculate;
    NSInteger lastHasRSIIndex;
    BOOL  zhibiao_RSI_needReCaculate;
    /********控制计算的句柄**********/
    
}
@end

@implementation YT_KLineDataSource


#pragma mark - init
+(instancetype)klineDataSourceWithKlineRep:(stock_kline_rep *)klineRep pos:(NSInteger)pos{
    YT_KLineDataSource * dataSource = [[self alloc] init];
    dataSource.klineRep = klineRep;
    [dataSource setValue:@(pos) forKey:@"pos"];
    return dataSource;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self makeDefData];
    }
    return self;
}

-(void)makeDefData{
    
    _array_TechMA1 = [NSMutableArray array];
    _array_TechMA2 = [NSMutableArray array];
    _array_TechMA3 = [NSMutableArray array];
    
    _maxPrice = [[NFloat alloc] init];
    _minPrice = [[NFloat alloc] init];
    _maxZDF = [[NFloat alloc] init];
    _minZDF = [[NFloat alloc] init];
    _maxCJL = [[NFloat alloc] init];
    _maxTech = [[NFloat alloc] init];
    _minTech = [[NFloat alloc] init];
    
    _pos = 0;
    _zhiBiaoType = -1;
}

#pragma mark - getter

-(NSMutableArray *)array_TechMA1{
    if (_array_TechMA1.count==0) {
        for (NSInteger i = _pos; i < (_pos + self.klineNumberOfShowing); i++) {
            if (i >= nKLineCount_)  break;
            stock_kline_data *klineData = [_klineRep.klineDataArrArray objectAtIndex:i];
            if(klineData.fTechArray.count>0){
                //                NFloat *nTech = (NFloat *)[klineData.fTechArray objectAtIndex:0];
                NFloat *nTech = klineData.TechMA1;
                [_array_TechMA1 addObject:nTech];
            }
        }
    }
    return _array_TechMA1;
}


-(NSMutableArray *)array_TechMA2{
    if (_array_TechMA2.count==0) {
        for (NSInteger i = _pos; i < (_pos + self.klineNumberOfShowing); i++) {
            if (i >= nKLineCount_)  break;
            stock_kline_data *klineData = [_klineRep.klineDataArrArray objectAtIndex:i];
            if(klineData.fTechArray.count>1){
                NFloat *nTech = klineData.TechMA2;
                [_array_TechMA2 addObject:nTech];
            }
        }
    }
    return _array_TechMA2;
}

-(NSMutableArray *)array_TechMA3{
    if (_array_TechMA3.count==0) {
        for (NSInteger i = _pos; i < (_pos + self.klineNumberOfShowing); i++) {
            if (i >= nKLineCount_)  break;
            stock_kline_data *klineData = [_klineRep.klineDataArrArray objectAtIndex:i];
            if(klineData.fTechArray.count>2){
                NFloat *nTech = klineData.TechMA3;
                [_array_TechMA3 addObject:nTech];
            }
        }
    }
    return _array_TechMA3;
}

-(NSMutableArray *)array_colors{
    if (!_array_colors) {
        _array_colors = [@[kTecColor_CustomKline1,
                           kTecColor_CustomKline2,
                           kTecColor_CustomKline3,
                           kTecColor_CustomKline4,
                           kTecColor_CustomKline5]
                           mutableCopy];
    }
    return _array_colors;
}

#pragma mark - setter
/**
 *  改变K线数据，重新绘制界面
 *
 *  @param klineRep
 */
- (void)setKlineRep:(stock_kline_rep *)klineRep {
    _klineRep = klineRep;
    nKLineCount_ = _klineRep.klineDataArrArray_Count;
    [self setLianShiZhiBiaoNeedReCaculate];
}

/**
 * KlineRep 在插入数组到0索引后，必须调用，重新赋值KlineRep也必须调用
 * 设置链式指标需要重新计算
 */
-(void)setLianShiZhiBiaoNeedReCaculate{
    lastHasMACDIndex = 0;
    zhibiao_MACD_needReCaculate = YES;
    lastHasKDJIndex = 0;
    zhibiao_KDJ_needReCaculate = YES;
    lastHasOBVIndex = 0;
    zhibiao_OBV_needReCaculate = YES;
    lastHasRSIIndex = 0;
    zhibiao_RSI_needReCaculate = YES;
}

/**
 赋值技术指标_minTech、_maxTech
 @param fValue1 比较值
 @param force -》不管原来的MaxTech，MinTech 用fValue1直接赋值
 @param tips: 当均值完全来自于当前数据时例如（1~100索引的当前数据得出 5~100的5日均值数据）均值不超过当前数据的最大最小区间不用判断
 @param tips: 但是当均值不完全来自当前数据时例如（1~100索引的当前数据 和 1~100的5日均值数据）1~4均值数据和-4~0原始数据有关，均值有可能超过当前数据的最大最小区间所以要判断均值的最大和最小
 */
- (void)setMaxTechMinTechAfterCompare:(NFloat *)fValue{
     if(!fValue)return;
    if ([NFloat compare:_minTech :fValue] > 0) {
        [_minTech changeValue:fValue];
    }else if ([NFloat compare:_maxTech :fValue] < 0){
         [_maxTech changeValue:fValue];
    }
}

- (void)setMaxTechMinTech:(NFloat *)fValue{
    if(!fValue)return;
    [_minTech changeValue:fValue];
    [_maxTech changeValue:fValue];
}

#pragma mark -  public func

-(void)calculateInitParm{
//    [self changePosAndResetAllDataIfNeed:_pos];
//    [self calculateKineCoordinateAxisYParam];//计算上半部分Y轴
//    [self calculateZhiBiao];//计算指标
    if ([KDS_SystemSetManager bSupportKLineMLineSet]) {
        [self calculateCustomMA];
    }
}


-(void)calculateZhiBiao{
    if(_klineRep)
    [self calculateTechValueFromIndex:_pos toIndex:MIN((self.pos + self.klineNumberOfShowing), nKLineCount_)];
}

/**
 *  计算需要显示的数据的最大和最小参数，确定Y轴数值以及蜡烛线的位置等
 */
- (void)calculateKineCoordinateAxisYParam {
    // 需要显示的K线数量
    NSInteger numberOfShowing = self.klineNumberOfShowing;
    
    [_maxPrice changeValue:0 :0 :0];
    [_minPrice changeValue:0 :0 :0];
    [_maxZDF changeValue:0 :0 :0];
    [_minZDF changeValue:0 :0 :0];
    [_maxCJL changeValue:0 :0 :0];
    
    if (nKLineCount_ > 0&&_pos< nKLineCount_) {
        stock_kline_data *firstData = [_klineRep.klineDataArrArray objectAtIndex:_pos];
        
        // 计算最大/最小价格/最大成交量
        _maxPrice = firstData.fZgcj;
        _minPrice = firstData.fZdcj;
        _maxCJL = firstData.fCjss;
        for (NSInteger i = _pos+1; i < (_pos + numberOfShowing); i++) {
            if (i >= nKLineCount_)
                break;
            stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:i];
            _maxPrice = [NFloat max:_maxPrice :kxData.fZgcj];
            _minPrice = [NFloat min:_minPrice :kxData.fZdcj];
            _maxCJL= [NFloat toCopy:[NFloat max:_maxCJL :kxData.fCjss]];
        }
        
        // 计算最大/最低涨幅
        NFloat *fOpen = firstData.fOpen;
        _maxZDF = [NFloat div:[NFloat sub:_maxPrice :fOpen] :fOpen];
        _minZDF = [NFloat div:[NFloat sub:_minPrice :fOpen] :fOpen];
        
    }
}

-(void)changePosAndResetAllDataIfNeed:(NSInteger)pos{
    _pos = pos;
    [self calculateKineCoordinateAxisYParam];//计算上半部分Y轴
    [self calculateZhiBiao];//计算指标
    
    [_array_TechMA1 removeAllObjects];
    [_array_TechMA2 removeAllObjects];
    [_array_TechMA3 removeAllObjects];
    
}

/**
 *  KlineRep 在插入数组到0索引后，必须优先调用
 */
-(void)insertKlineDataAtKlineRepZeroIndexHandle:(NSInteger)Count{
    [self setLianShiZhiBiaoNeedReCaculate];
    //CR等指标，优化缓存可以在这里做。。。
}

// 计算各种技术指标需要的值
#pragma mark -  core calculate
/**
 计算各种技术指标需要的值
 
 @param nStart 开始x坐标，包含
 @param nEnd 结束x坐标，不包含
 */
- (void)calculateTechValueFromIndex:(NSInteger)nStart toIndex:(NSInteger)nEnd {
    
    [_maxTech changeValue:0 :0 :0];
    [_minTech changeValue:0 :0 :0];
    
    switch (_zhiBiaoType) {
        case KDS_ZBType_MACD: {
            [self getMACDFrom:nStart toIndex:nEnd];
        }
            break;
        case KDS_ZBType_DMI:
            
            break;
        case KDS_ZBType_WR: {
            [self getWRForm:nStart toIndex:nEnd];
        }
            break;
            
        case KDS_ZBType_VR: {
            [self getVRFrom:nStart toIndex:nEnd];
        }
            break;
            
        case KDS_ZBType_CR: {
            [self getCRFrom:nStart toIndex:nEnd];
        }
            break;
            
        case KDS_ZBType_BOLL: {
            [self getBOLLFrom:nStart toIndex:nEnd];
        }
            
            break;
        case KDS_ZBType_KDJ: {
            [self getKDJFrom:nStart toIndex:nEnd];
        }
            break;
        case KDS_ZBType_OBV: {
            [self getOBVFrom:nStart toIndex:nEnd];
        }
            break;
        case KDS_ZBType_RSI: {
            [self getRSIFrom:nStart toIndex:nEnd];
        }
            break;
        case KDS_ZBType_SAR:
            break;
        case KDS_ZBType_DMA: {
            [self getDMAFrom:nStart toIndex:nEnd];
        }
            break;
        default:
            break;
    }
}


#pragma mark  VR
/**
 VR
 @param nStart 包含
 @param nEnd 不包含
 */
-(void)getVRFrom:(NSInteger)nStart toIndex:(NSInteger)nEnd{
    NSInteger nDay = 26;//计算vr参数周期
    NSInteger nMaxDays = 6;//vr平均值周期6 (6-1 ，1为当天)
    
    NSInteger i = nStart - nMaxDays + 1;
    if(i<0)i = 0;
    
    BOOL needMa = NO;
    for (; i < nEnd; i++) {
        [self CalculateVR:nDay :i];
        stock_kline_data *kxData = self.klineRep.klineDataArrArray[i];
        kxData.cache_VR = fVR_Value1;
        [self setMaxTechMinTechAfterCompare:fVR_Value1];
        if (needMa||(needMa = i>=nStart&&i>=(nMaxDays-1))) {
            kxData.cache_VR_MA6 = [self calculateMA:i day:nMaxDays item:^NFloat *(stock_kline_data *kxData) {
                return kxData.cache_VR;
            }];
//            [self setTech:fVR_Value1 :fVR_Value2 :nil :nil :nil :i];//在全局计算下平均值不可能超出fVR_Value1值区间
        }
    }
}

#pragma mark  WR

-(void)getWRForm:(NSInteger)nStart toIndex:(NSInteger)nEnd{
//    [_minTech changeValue:10000 :0 :0];
    NSInteger i = nStart;
    //算出第一个值
    for (; i< nEnd; i++) {
        stock_kline_data *kxData = self.klineRep.klineDataArrArray[i];
        kxData.cache_WR6 = [self CalculateWR :i :6];
        kxData.cache_WR10 = [self CalculateWR :i :10];
        if (kxData.cache_WR6) {
            [self setMaxTechMinTech:kxData.cache_WR6];
            [self setMaxTechMinTechAfterCompare:kxData.cache_WR10];
            i++;
            break;
        }
        if (kxData.cache_WR10){
            [self setMaxTechMinTech:kxData.cache_WR10];
            i++;
            break;
        }
    }
    //算后续
    for (; i< nEnd; i++) {
        stock_kline_data *kxData = self.klineRep.klineDataArrArray[i];
        kxData.cache_WR6 = [self CalculateWR :i :6];
        kxData.cache_WR10 = [self CalculateWR :i :10];
        [self setMaxTechMinTechAfterCompare: kxData.cache_WR6];
        [self setMaxTechMinTechAfterCompare: kxData.cache_WR10];
    }
}

#pragma mark MACD

-(void)getMACDFrom:(NSInteger)nStart toIndex:(NSInteger)nEnd{
    if(_klineRep.klineDataArrArray.count<=0)return;
    stock_kline_data *kdata_one;
    stock_kline_data *kdata_two;
    NSInteger i = 0;
    if (zhibiao_MACD_needReCaculate) {
        kdata_one = [_klineRep.klineDataArrArray objectAtIndex:0];
        kdata_one.cache_EMA12 = kdata_one.fClose;
        kdata_one.cache_EMA26 = kdata_one.fClose;
        kdata_one.cache_DIF = [NFloat zero];//[NFloat sub:fEMA12 :fEMA26];
        kdata_one.cache_DEA = kdata_one.cache_DIF;//[NFloat toCopy:kdata_one.cache_DIF];
        kdata_one.cache_MACD =kdata_one.cache_DIF;// [NFloat zero];
//        [self setMaxTechMinTech:kdata_one.cache_DIF];
//        [self setMaxTechMinTechAfterCompare:kdata_one.cache_DEA];
//        [self setMaxTechMinTechAfterCompare:kdata_one.cache_MACD];
        
        for (i = 1; i < nEnd; i++) {
            kdata_two = [_klineRep.klineDataArrArray objectAtIndex:i];
            [self calculateMACD:kdata_two withLastKdata:kdata_one];
//            [self setMaxTechMinTechAfterCompare:kdata_two.cache_DIF];
//            [self setMaxTechMinTechAfterCompare:kdata_two.cache_DEA];
//            [self setMaxTechMinTechAfterCompare:kdata_two.cache_MACD];
            kdata_one = kdata_two;
        }
        zhibiao_MACD_needReCaculate = NO;
    }else{
        if (lastHasMACDIndex==0) {
            zhibiao_MACD_needReCaculate = YES;
            [self getMACDFrom:nStart toIndex:nEnd];
        }
         i = lastHasMACDIndex;
        kdata_one = [_klineRep.klineDataArrArray objectAtIndex:i];
        for (i+=1; i < nEnd; i++) {
            kdata_two = [_klineRep.klineDataArrArray objectAtIndex:i];
            [self calculateMACD:kdata_two withLastKdata:kdata_one];
//            [self setMaxTechMinTechAfterCompare:kdata_two.cache_DIF];
//            [self setMaxTechMinTechAfterCompare:kdata_two.cache_DEA];
//            [self setMaxTechMinTechAfterCompare:kdata_two.cache_MACD];
            kdata_one = kdata_two;
        }
    }
     lastHasMACDIndex = i-1;
    
    //从新计算显示范围内的最大最小值
    kdata_one = [_klineRep.klineDataArrArray objectAtIndex:nStart];
    [self setMaxTechMinTech:kdata_one.cache_DIF];
    for (NSInteger a = nStart; a<nEnd; a++) {
        kdata_one = [_klineRep.klineDataArrArray objectAtIndex:a];
        [self setMaxTechMinTechAfterCompare:kdata_one.cache_DIF];
        [self setMaxTechMinTechAfterCompare:kdata_one.cache_DEA];
        [self setMaxTechMinTechAfterCompare:kdata_one.cache_MACD];
    }
    
}

#pragma mark KDJ

-(void)getKDJFrom:(NSInteger)nStart toIndex:(NSInteger)nEnd{

    NSInteger i = 0;
    if (zhibiao_KDJ_needReCaculate) {
        fk = [[NFloat alloc] init:50 * 100 :2 :0];//50.00
        fd = [[NFloat alloc] init:50 * 100 :2 :0];
        fj = [[NFloat alloc] init:50 * 100 :2 :0];
        for (; i <nEnd; i++) {
            [self calculateKDJ:i];
            stock_kline_data *kdata_one = [_klineRep.klineDataArrArray objectAtIndex:i];
            kdata_one.cache_K = fk;
            kdata_one.cache_D = fd;
            kdata_one.cache_J = fj;
        }
        zhibiao_KDJ_needReCaculate = NO;
    }else{
        if (lastHasKDJIndex==0) {
            zhibiao_KDJ_needReCaculate = YES;
            [self getKDJFrom:nStart toIndex:nEnd];
        }
        i = lastHasKDJIndex;
        stock_kline_data *kdata_one = [_klineRep.klineDataArrArray objectAtIndex:i];
        fk = kdata_one.cache_K;
        fd = kdata_one.cache_D;
        fj = kdata_one.cache_J;
        for (i+=1; i < nEnd; i++) {
            [self calculateKDJ:i];
            kdata_one = [_klineRep.klineDataArrArray objectAtIndex:i];
            kdata_one.cache_K = fk;
            kdata_one.cache_D = fd;
            kdata_one.cache_J = fj;
        }
    }
    lastHasKDJIndex = i-1;
    
    //从新计算显示范围内的最大最小值
//    [_minTech changeValue:0 :0 :0];
//    [_maxTech changeValue:100 :0 :0];
    stock_kline_data *kdata_one = [_klineRep.klineDataArrArray objectAtIndex:nStart];
    [self setMaxTechMinTech:kdata_one.cache_K];
    for (NSInteger a = nStart; a<nEnd; a++) {
        kdata_one = [_klineRep.klineDataArrArray objectAtIndex:a];
        [self setMaxTechMinTechAfterCompare:kdata_one.cache_K];
        [self setMaxTechMinTechAfterCompare:kdata_one.cache_D];
        [self setMaxTechMinTechAfterCompare:kdata_one.cache_J];
    }
}

#pragma mark OBV

-(void)getOBVFrom:(NSInteger)nStart toIndex:(NSInteger)nEnd{
    YT_CalculateRange range= [self rangeFrom:nStart toIndex:nEnd];
    
    if (zhibiao_OBV_needReCaculate) {
        fOBV_Value1 = [[NFloat alloc]init:0 :0 :0];
        range.nStart = 0;
        lastHasOBVIndex = [self _calculataOBVRun:range];
        zhibiao_OBV_needReCaculate = NO;
    }else{
        if (lastHasOBVIndex==0) {
            zhibiao_OBV_needReCaculate = YES;
            [self getOBVFrom:nStart toIndex:nEnd];
        }
        stock_kline_data *kdata_one = [_klineRep.klineDataArrArray objectAtIndex:lastHasOBVIndex];
        fOBV_Value1 = kdata_one.cache_OBV;
        range.nStart = lastHasOBVIndex+1;
        lastHasOBVIndex = [self _calculataOBVRun:range];
    }
    //从新计算显示范围内的最大最小值
    stock_kline_data *kdata_one = [_klineRep.klineDataArrArray objectAtIndex:nStart];
    [self setMaxTechMinTech:kdata_one.cache_OBV];
    for (NSInteger a = nStart; a<nEnd; a++) {
        kdata_one = [_klineRep.klineDataArrArray objectAtIndex:a];
        [self setMaxTechMinTechAfterCompare:kdata_one.cache_OBV];
        [self setMaxTechMinTechAfterCompare:kdata_one.cache_OBV_MA30];
    }
}

-(NSInteger)_calculataOBVRun:(YT_CalculateRange)range{
    NSInteger nDay_MA = 30;
    NSInteger i = range.nStart;
    BOOL needMA = NO;
    stock_kline_data*  kdata_one;
    for (; i < range.nEnd; i++) {
        if ([self CalculateOBV:i:YES]) {
            kdata_one = [_klineRep.klineDataArrArray objectAtIndex:i];
            kdata_one.cache_OBV = fOBV_Value1;
            if (needMA||(needMA = i >= nDay_MA-1)) {
                kdata_one.cache_OBV_MA30 = [self calculateMA:i day:nDay_MA item:^NFloat *(stock_kline_data *kxData) {
                    return  kxData.cache_OBV;
                }];
            }
        }else{
            NSAssert1(nil, @"CalculateOBV返回false这里不该来%s",__func__);
        }
    }
    return  i-1;
}

#pragma mark RSI
-(void)getRSIFrom:(NSInteger)nStart toIndex:(NSInteger)nEnd{
    YT_CalculateRange range= [self rangeFrom:nStart toIndex:nEnd];
    NSInteger i = 0;
    stock_kline_data *kdata_one;
    if (zhibiao_RSI_needReCaculate) {
        int date = [NFloat dataWith:0.01 :0 :2];//0.01
        
        SMAMAX_RSI6 = [NFloat initWithValue:date];
        SMAMAX_RSI12 = [NFloat initWithValue:date];
        SMAMAX_RSI24 = [NFloat initWithValue:date];
        
        SMAABS_RSI6 = [NFloat initWithValue:date];
        SMAABS_RSI12 = [NFloat initWithValue:date];
        SMAABS_RSI24 = [NFloat initWithValue:date];
        range.nStart = 0;
        for (; i<nEnd; i++) {
            [self calculateRSI:i];
            kdata_one = [_klineRep.klineDataArrArray objectAtIndex:i];
            kdata_one.cache_RSI6 = RSI6;
            kdata_one.cache_RSI12 = RSI12;
            kdata_one.cache_RSI24 = RSI24;
        }
        zhibiao_RSI_needReCaculate = NO;
    }else{
        if (lastHasRSIIndex==0) {
            zhibiao_RSI_needReCaculate = YES;
            [self getRSIFrom:nStart toIndex:nEnd];
        }
        i = lastHasRSIIndex+1;
        for (; i<nEnd; i++) {
            [self calculateRSI:i];
            kdata_one = [_klineRep.klineDataArrArray objectAtIndex:i];
            kdata_one.cache_RSI6 = RSI6;
            kdata_one.cache_RSI12 = RSI12;
            kdata_one.cache_RSI24 = RSI24;
        }
    }
    lastHasRSIIndex = i-1;
    
    //从新计算显示范围内的最大最小值
    kdata_one = [_klineRep.klineDataArrArray objectAtIndex:nStart];
    [self setMaxTechMinTech:kdata_one.cache_RSI6];
    for (NSInteger a = nStart; a<nEnd; a++) {
        kdata_one = [_klineRep.klineDataArrArray objectAtIndex:a];
        [self setMaxTechMinTechAfterCompare:kdata_one.cache_RSI6];
        [self setMaxTechMinTechAfterCompare:kdata_one.cache_RSI12];
        [self setMaxTechMinTechAfterCompare:kdata_one.cache_RSI24];
    }
    
}

#pragma mark DMA
-(void)getDMAFrom:(NSInteger)nStart toIndex:(NSInteger)nEnd{
    NSInteger day10 = 10;
    NSInteger day50 = 50;
    NSInteger minStarIndex = day50 -1;//算DMA的最小索引
    NSInteger minStarMAIndex = minStarIndex + 9;//9 = 10 - 1(算10天平均值，则最少从9开始)
    NSInteger i = MAX(minStarIndex, nStart -9);//nStart -9 因为要算nStart的MA10，所以要往前推9
    BOOL needMa = NO;
    BOOL needSetMAXMIN_DMA = NO;
    BOOL needSetMAXMIN_DMA_MA10 = YES;
    stock_kline_data*  kdata_one;
    for (;i < nEnd; i++) {
        kdata_one = [_klineRep.klineDataArrArray objectAtIndex:i];
        if (!kdata_one.cache_DMA) {
            fMA10 = [self CalculateMA:i :day10 :false :0];
            fMA50 = [self CalculateMA:i :day50 :false :0];
            kdata_one.cache_DMA = [NFloat sub:fMA10 :fMA50];
        }
        if(needSetMAXMIN_DMA){
            [self setMaxTechMinTechAfterCompare:kdata_one.cache_DMA];//第1+次先比较后赋值
        }else{
            needSetMAXMIN_DMA = i>=nStart;
            if (needSetMAXMIN_DMA)[self setMaxTechMinTech:kdata_one.cache_DMA];//第1次直接赋值
        }
        if (needMa||(needMa = i>=minStarMAIndex)) {
            if(!kdata_one.cache_DMA_MA10)
            kdata_one.cache_DMA_MA10 = [self calculateMA:i day:day10 item:^NFloat *(stock_kline_data *kxData) {
                return kxData.cache_DMA;
            }];
            if(needSetMAXMIN_DMA_MA10&&(needSetMAXMIN_DMA_MA10=i<nStart+9))
            [self setMaxTechMinTechAfterCompare:kdata_one.cache_DMA];
        }
    }
}

#pragma mark CR
//TODO: 这里有点疑问,偏移?
-(void)getCRFrom:(NSInteger)nStart toIndex:(NSInteger)nEnd{
    NSInteger MA_Day1 = 10;//平均值天数
    NSInteger MA_Day2 = 20;
    NSInteger MA_Day3 = 40;
    NSInteger MA_Day4 = 62;
    
    NSInteger MA_OffDay1 =[self _CR_MA_Day_OffDay:MA_Day1];//X轴上的偏移
    NSInteger MA_OffDay2 =[self _CR_MA_Day_OffDay:MA_Day2];
    NSInteger MA_OffDay3 =[self _CR_MA_Day_OffDay:MA_Day3];
    NSInteger MA_OffDay4 =[self _CR_MA_Day_OffDay:MA_Day4];
    
    NSInteger MA_Day1_MinIndex =MIN_HASMA_INSDEX(MA_Day1)+MA_OffDay1;//计算平均值的最小索引
    NSInteger MA_Day2_MinIndex =MIN_HASMA_INSDEX(MA_Day2)+MA_OffDay2;
    NSInteger MA_Day3_MinIndex =MIN_HASMA_INSDEX(MA_Day3)+MA_OffDay3;
    NSInteger MA_Day4_MinIndex =MIN_HASMA_INSDEX(MA_Day4)+MA_OffDay4;

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSInteger MA_canIgnoreCompare1 =MA_Day1_MinIndex+nStart;//可以不比较的值，选最大最小用
    NSInteger MA_canIgnoreCompare2 =MA_Day2_MinIndex+nStart;
    NSInteger MA_canIgnoreCompare3 =MA_Day3_MinIndex+nStart;
    NSInteger MA_canIgnoreCompare4 =MA_Day4_MinIndex+nStart;
    
    BOOL needMA1= NO,needMA2= NO,needMA3= NO,needMA4= NO;
#pragma clang diagnostic pop
    stock_kline_data*  kdata_one;

    NSInteger i = nStart - MA_Day2_MinIndex;//**** 算需要的CR的起始索引
    if(i<0)i = 0;
    for (; i<nStart; i++) {//计算MA需要的CR
        kdata_one = [_klineRep.klineDataArrArray objectAtIndex:i];
        //计算CR
//        if (!kdata_one.cache_CR){
        /*因为准确的CR需要kCR26Days +1 个完整数据才能计算所以数据插入0得重新算部分数据，这里干脆每次都重算,
         可以考虑之后优化方案：在索引0插入数据N个后，循环N~(kCR26Days +1+N) 赋值kdata_one.cache_CR = nil,
         循环N+off~(kCR26Days +1+MA_Day+N+off)赋值cache_CR——MA = nil*/
            [self CalculateCR:i];
            kdata_one.cache_CR = fCR_Value1;
//        }
    }
    //预设置
    [self CalculateCR:nStart];
    [self setMaxTechMinTech:fCR_Value1];
    
    for (; i<nEnd; i++) {//nStart - nEnd
         kdata_one = [_klineRep.klineDataArrArray objectAtIndex:i];
        //计算CR
//        if (!kdata_one.cache_CR){
            [self CalculateCR:i];
            kdata_one.cache_CR = fCR_Value1;
//        }
        //设置最大最小值
        [self setMaxTechMinTechAfterCompare:kdata_one.cache_CR];
        
        //计算CR——MA
        if (needMA1||(needMA1 = i>=MA_Day1_MinIndex)) {
//            if (!kdata_one.cache_CR_MA1) {
                NSInteger target_i = i - MA_OffDay1;
                kdata_one.cache_CR_MA1= [self calculateMA:target_i day:MA_Day1 item:^NFloat *(stock_kline_data *kxData) {
                    return kxData.cache_CR;
                }];
//            }
            if(i<MA_canIgnoreCompare1)[self setMaxTechMinTechAfterCompare:kdata_one.cache_CR_MA1];
        }
        if (needMA2||(needMA2 = i>=MA_Day2_MinIndex)) {
//            if (!kdata_one.cache_CR_MA2) {
                NSInteger target_i = i - MA_OffDay2;
                kdata_one.cache_CR_MA2= [self calculateMA:target_i day:MA_Day2 item:^NFloat *(stock_kline_data *kxData) {
                    return kxData.cache_CR;
                }];
//            }
            if(i<MA_canIgnoreCompare2)[self setMaxTechMinTechAfterCompare:kdata_one.cache_CR_MA2];
        }
      /*//目前需求只有2个
        if (needMA3||(needMA3 = i>=MA_Day3_MinIndex)) {
            //if (!kdata_one.cache_CR_MA3) {
                NSInteger target_i = i - MA_OffDay3;
                kdata_one.cache_CR_MA3= [self calculateMA:target_i day:MA_Day3 item:^NFloat *(stock_kline_data *kxData) {
                    return kxData.cache_CR;
                }];
           // }
            if(i<MA_canIgnoreCompare3)[self setMaxTechMinTechAfterCompare:kdata_one.cache_CR_MA3];
        }
        
        if (needMA4||(needMA4 = i>=MA_Day4_MinIndex)) {
           // if (!kdata_one.cache_CR_MA4) {
                NSInteger target_i = i - MA_OffDay4;
                kdata_one.cache_CR_MA4= [self calculateMA:target_i day:MA_Day4 item:^NFloat *(stock_kline_data *kxData) {
                    return kxData.cache_CR;
                }];
           // }
            if(i<MA_canIgnoreCompare4)[self setMaxTechMinTechAfterCompare:kdata_one.cache_CR_MA4];
        }
        */
    }

}

/**
 CR算出平平均之后，要对算出的值做X轴上的偏移
 在图上的感觉就是把一个波形往X轴方向偏移offDay的位置
 波形偏移有两个方案
 1.在算得结果后偏移offDay储存数据算的i索引的数据存在i+offDay(或在i索引算i-offDay的数据，我用这个方式)
 2.画图的时候偏移取值，如画i的索引的时候，取i-offDay的数据）
 @param MA_Day 平均值周期
 @return offDay X轴偏移量
 */
-(NSInteger)_CR_MA_Day_OffDay:(NSInteger)MA_Day{
    return MA_Day*2/5 + 1;
}

#pragma mark BOLL
-(void)getBOLLFrom:(NSInteger)nStart toIndex:(NSInteger)nEnd{
    int N = 20;
    int P = 2;
    //UPPER: MID + P*STD(CLOSE,N);
    //LOWER: MID - P*STD(CLOSE,N);
    
    NSInteger i = MAX(N-1, nStart);
    if (i>=nEnd) return;
    stock_kline_data*  kdata_one = [_klineRep.klineDataArrArray objectAtIndex:i];
    if (!kdata_one.cache_BOLL_Mid) {
        NFloat* mid = [self CalculateMA:i :N :false :0];//20日收盘的平均值
        kdata_one.cache_BOLL_Mid = mid;
        //样本方差STD(CLOSE,N)
        NFloat *meanSquare = [self CalculateBOLL:i withDay:N withMid:mid];
        kdata_one.cache_BOLL_Upper = [NFloat add:mid :[NFloat mul:meanSquare Integer:P]];
        kdata_one.cache_BOLL_Lower = [NFloat sub:mid :[NFloat mul:meanSquare Integer:P]];
    }
    [self setMaxTechMinTech:kdata_one.cache_BOLL_Mid];
    [self setMaxTechMinTechAfterCompare:kdata_one.cache_BOLL_Upper];
    [self setMaxTechMinTechAfterCompare:kdata_one.cache_BOLL_Lower];
    i+=1;
    for (; i < nEnd; i++) {
        kdata_one = [_klineRep.klineDataArrArray objectAtIndex:i];
        if (!kdata_one.cache_BOLL_Mid) {
            NFloat* mid = [self CalculateMA:i :N :false :0];//20日收盘的平均值
            kdata_one.cache_BOLL_Mid = mid;
            //样本方差STD(CLOSE,N)
            NFloat *meanSquare = [self CalculateBOLL:i withDay:N withMid:mid];
            kdata_one.cache_BOLL_Upper = [NFloat add:mid :[NFloat mul:meanSquare Integer:P]];
            kdata_one.cache_BOLL_Lower = [NFloat sub:mid :[NFloat mul:meanSquare Integer:P]];
        }
        [self setMaxTechMinTechAfterCompare:kdata_one.cache_BOLL_Mid];
        [self setMaxTechMinTechAfterCompare:kdata_one.cache_BOLL_Upper];
        [self setMaxTechMinTechAfterCompare:kdata_one.cache_BOLL_Lower];
    }
}

#pragma mark k --CustomMA
- (void)calculateCustomMAFrom:(NSInteger)nStart toIndex:(NSInteger)nEnd day:(NSInteger)days saveIndex:(NSInteger)index{
//    stock_kline_data *techData ;
//    techData.cache_customMA1
    if (index<0||index>=5) return;
    NSString * keyPath = [NSString stringWithFormat:@"cache_customMA%zd",index+1];
    
    if (days<=0){
        
    }else if (days == 1){
       //均线定义为1日，直接用收盘价表示
        for (NSInteger i = nStart; i<nEnd; i++) {
            stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:i];
            [kxData setValue:kxData.fClose forKeyPath:keyPath];
        }
    }else if (days == 5){
         //5日均线，用默认值
        for (NSInteger i = nStart; i<nEnd; i++) {
            stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:i];
            [kxData setValue:kxData.MA1 forKeyPath:keyPath];
        }
    }else if (days == 10){
         //10日均线，用默认值
        for (NSInteger i = nStart; i<nEnd; i++) {
            stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:i];
            [kxData setValue:kxData.MA2 forKeyPath:keyPath];
        }
    }else if (days == 30){
        //30日均线，用默认值
        for (NSInteger i = nStart; i<nEnd; i++) {
            stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:i];
            [kxData setValue:kxData.MA3 forKeyPath:keyPath];
        }
    }else if (days>nKLineCount_){
        //设定的均线日期大于实际取得的收盘价天数，则无均线值
    }else{
        YT_CalculateRange range = [self rangeFrom:nStart toIndex:nEnd];
        [self calculateMA:range day:days ex:YES item:^NFloat *(stock_kline_data *kxData) {
            return kxData.fClose;
        } save:^(stock_kline_data *kxData, NSInteger calculateIndex, NFloat *calculateRs) {
            [kxData setValue:calculateRs forKeyPath:keyPath];
        }];
    }
    
}
- (void)calculateCustomMA{
    NSMutableArray *maLineSetArray = [KDS_SystemSetManager getMALineSetArray];
    for (int i = 0; i < [maLineSetArray count]; i++) {
        KDS_MALineSetModel *model = [maLineSetArray objectAtIndex:i];
        NSInteger day;
        if (model.isOpen) {
            day = [model.MALineNum integerValue];
            [self calculateCustomMAFrom:0 toIndex:nKLineCount_ day:day saveIndex:i];
        }
    }
}

#pragma mark - calculateTool

- (void)calculateMACD:(NSInteger)index {
    if (!_klineRep.klineDataArrArray || index >= nKLineCount_)
        return;
    
    stock_kline_data *kdata = [_klineRep.klineDataArrArray objectAtIndex:index];
    NFloat *fClose = kdata.fClose;
    
    fEMA12 = [NFloat mul:fEMA12 Integer:kEMA12Days-1];
    fEMA12 = [NFloat div:fEMA12 Integer:kEMA12Days+1];
    startKFloat = [NFloat mul:fClose Integer:2];
    startKFloat = [NFloat div:startKFloat Integer:kEMA12Days+1];
    fEMA12 = [NFloat add:fEMA12 :startKFloat];
    
    fEMA26 = [NFloat mul:fEMA26 Integer:kEMA26Days-1];
    fEMA26 = [NFloat div:fEMA26 Integer:kEMA26Days+1];
    startKFloat = [NFloat mul:fClose Integer:2];
    startKFloat = [NFloat div:startKFloat Integer:kEMA26Days+1];
    fEMA26 = [NFloat add:fEMA26 :startKFloat];
    
    fDIF    = [NFloat sub:fEMA12 :fEMA26];
    
    //fDEA 是fDIF的加权平均数？
    fDEA    = [NFloat div:[NFloat mul:fDEA Integer:kDIFDays-1] Integer:kDIFDays+1];
    startKFloat = [NFloat mul:fDIF Integer:2];
    startKFloat = [NFloat div:startKFloat Integer:kDIFDays+1];
    fDEA    = [NFloat add:fDEA :startKFloat];
}

- (void)calculateMACD:(stock_kline_data *)kdata withLastKdata:(stock_kline_data *)lastkdata{
    @autoreleasepool {
        NFloat *fClose = kdata.fClose;
        NFloat * onePart ,* twoPart;
        
        onePart = [NFloat mul:lastkdata.cache_EMA12 Integer:kEMA12Days-1];
        onePart = [NFloat div:onePart Integer:kEMA12Days+1];
        twoPart = [NFloat mul:fClose Integer:2];
        twoPart = [NFloat div:twoPart Integer:kEMA12Days+1];
        kdata.cache_EMA12 = [NFloat add:onePart :twoPart];
        
        onePart = [NFloat mul:lastkdata.cache_EMA26 Integer:kEMA26Days-1];
        onePart = [NFloat div:onePart Integer:kEMA26Days+1];
        twoPart = [NFloat mul:fClose Integer:2];
        twoPart = [NFloat div:twoPart Integer:kEMA26Days+1];
        kdata.cache_EMA26 = [NFloat add:onePart :twoPart];
        
        kdata.cache_DIF    = [NFloat sub:kdata.cache_EMA12 :kdata.cache_EMA26];
        
        //fDEA 是fDIF的加权平均数？
        onePart    = [NFloat div:[NFloat mul:lastkdata.cache_DEA Integer:kDIFDays-1] Integer:kDIFDays+1];
        twoPart = [NFloat mul:kdata.cache_DIF Integer:2];
        twoPart = [NFloat div:twoPart Integer:kDIFDays+1];
        kdata.cache_DEA    = [NFloat add:onePart :twoPart];
        
        onePart = [NFloat mul:kdata.cache_DIF Integer:2];
        twoPart = [NFloat mul: kdata.cache_DEA Integer:2];
        kdata.cache_MACD = [NFloat sub:onePart :twoPart];
    }
}


- (void)calculateKDJ:(NSInteger)nIndex {
    if (!_klineRep.klineDataArrArray || nIndex >= nKLineCount_)return;
@autoreleasepool {
        stock_kline_data *kdata = [_klineRep.klineDataArrArray objectAtIndex:nIndex];
        stock_kline_data *kdata1 = nil;
    
        NFloat *rsv = [NFloat zero];
        NFloat *h = kdata.fZgcj;
        NFloat *l = kdata.fZdcj;
        NFloat *c = kdata.fClose;
    
        //n日RSV = (Cn - Ln) / (Hn - Ln) * 100
        //Cn为第n日收盘价；Ln为n日内的最低价；Hn为n日内的最高价。默认n为9，明显的RSV值始终在1—100间波动
        NSInteger nCount = 0;
        for (NSInteger j = nIndex; j >= 0; --j) {
            kdata1 = [_klineRep.klineDataArrArray objectAtIndex:j];
            h = [NFloat max:h :kdata1.fZgcj];
            l = [NFloat min:l :kdata1.fZdcj];
            
            nCount++;
            if (nCount >= kRSVDays)
                break;
        }
    
        if ([NFloat compare:h :l] != 0) {
            rsv = [NFloat mul:[NFloat div:[NFloat sub:c :l] :[NFloat sub:h :l]] Integer:100];
        }
    
        //当日K值 = 2 / 3 * 前一日K值 + 1 / 3 * 当日RSV
        NFloat *nk = [NFloat add:[NFloat div:[NFloat mul:fk Integer:2] Integer:3] :[NFloat div:rsv Integer:3]];
        //当日D值 = 2 / 3 * 前一日D值 + 1 / 3 * 当日K值
        NFloat *nd = [NFloat add:[NFloat div:[NFloat mul:fd Integer:2] Integer:3] :[NFloat div:nk Integer:3]];
        //当日J值 = 3K — 2D
        NFloat *nj = [NFloat sub:[NFloat mul:nk Integer:3] :[NFloat mul:nd Integer:2]];
    
//        [fk changeValue:nk];
//        [fd changeValue:nd];
//        [fj changeValue:nj];
        fk = nk;
        fd = nd;
        fj = nj;
    }
}

- (BOOL)CalculateOBV:(NSInteger)aIndex :(BOOL)bUseLast {
    if (aIndex < 0 || aIndex >= nKLineCount_) {
        return false;
    }
    NFloat *zero = [NFloat zero];
    NFloat *fValueNew = zero;
    
    if (bUseLast && fOBV_Value1) {
        stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:aIndex];
        NFloat *fcjss = kxData.fCjss;
        NFloat *ftodayclose = kxData.fClose;
        
        if (aIndex == 0) {
            fValueNew = fcjss;
        } else {
            kxData = [_klineRep.klineDataArrArray objectAtIndex:aIndex-1];
            NFloat *fyestodayclose = kxData.fClose;
            if([NFloat compare:ftodayclose :fyestodayclose] == 1) {
                fValueNew = [NFloat add:fOBV_Value1 :fcjss];
            } else if([NFloat compare:ftodayclose :fyestodayclose] == -1) {
                fValueNew = [NFloat sub:fOBV_Value1 :fcjss];
            } else {
                fValueNew = fOBV_Value1;
            }
        }
    } else {
        for (NSInteger k = 0; k <= aIndex; k++) {
            stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:k];
            NFloat *ftodayClose = kxData.fClose;
            NFloat *ftodaycjss = kxData.fCjss;
            
            if (0 == k) {
                fValueNew = ftodaycjss;
            } else {
                kxData = [_klineRep.klineDataArrArray objectAtIndex:k-1];
                NFloat *fyestodayClose = kxData.fClose;
                if ([NFloat compare:ftodayClose :fyestodayClose] == 1) {
                    fValueNew = [NFloat add:fValueNew :ftodaycjss];
                } else if ([NFloat compare:ftodayClose :fyestodayClose] == -1) {
                    fValueNew  = [NFloat sub:fValueNew :ftodaycjss];
                }
            }
        }
    }
//    if (fOBV_Value1) {
        fOBV_Value1 = fValueNew;
//    }
    return true;
}

// 计算wr技术指标
- (NFloat *)CalculateWR:(NSInteger)aIndex :(NSInteger)aDay {
    if (aIndex < (aDay-1) || aIndex >= nKLineCount_) {
        return nil;
    }
    NFloat *dH;
    NFloat *dL;
    NFloat *dR;
    NSInteger count = 0;
    stock_kline_data *kxData;
    for (NSInteger k = aIndex; k>=0; k--) {
        kxData = [_klineRep.klineDataArrArray objectAtIndex:k];
        if (aIndex == k) {
            dH = kxData.fZgcj;
            dL = kxData.fZdcj;
        } else {
            if ([NFloat compare:dH :kxData.fZgcj] == -1) {
                dH = kxData.fZgcj;
            }
            if ([NFloat compare:dL :kxData.fZdcj] == 1) {
                dL = kxData.fZdcj;
            }
        }
        count++;
        if (count == aDay || k == 0) {
            stock_kline_data *nKXData = [_klineRep.klineDataArrArray objectAtIndex:aIndex];
            dR = [NFloat div:[NFloat mul:[NFloat sub:dH :nKXData.fClose] Integer:100] :[NFloat sub:dH :dL]];
            return  dR;
        }
    }
    return nil;
}

- (void)CalculateVR:(NSInteger)days :(NSInteger)index {
    if (index < 0 || index >= nKLineCount_) {
        return;
    }
    NFloat *UVS = [NFloat zero];
    NFloat *DVS = [NFloat zero];
    NFloat *PVS = [NFloat zero];
    fVR_Value1 = [NFloat zero];
  
    if (index < days) {
        if (index == 0) {
            stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:index];
            NFloat * curCJSS = kxData.fCjss;//当天成交数量
            PVS = [NFloat add:PVS :curCJSS];
        } else {
            stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:index];
            NFloat * curCJSS = kxData.fCjss;//当天成交数量
            NFloat * curClose = kxData.fClose;//当天收盘价
           
            stock_kline_data *kxDataLast = [_klineRep.klineDataArrArray objectAtIndex:index - 1];
            NFloat *lastClose = kxDataLast.fClose;
            //TODO:  lastClose=kxData.fYclose;?怎么不用
            if ([NFloat compare:curClose:lastClose] == 1) { //上升日
                UVS = [NFloat add:UVS :curCJSS];
            } else if ([NFloat compare:curClose:lastClose] == -1) { //下跌日
                DVS = [NFloat add:DVS :curCJSS];
            } else {
                PVS = [NFloat add:PVS :curCJSS];
            }
        }
    } else {

        for (NSInteger k = index; k >= (index - days) + 1; k--) {
            stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:index];
            NFloat * curCJSS = kxData.fCjss;//当天成交数量
            NFloat * curClose = kxData.fClose;//当天收盘价
            stock_kline_data *kxDataLast = [_klineRep.klineDataArrArray objectAtIndex:k - 1];
            NFloat *lastClose = kxDataLast.fClose;
            if ([NFloat compare:curClose:lastClose] == 1) { //上升日
                UVS = [NFloat add:UVS :curCJSS];
            } else if ([NFloat compare:curClose:lastClose] == -1) { //下跌日
                DVS = [NFloat add:DVS :curCJSS];
            } else {
                PVS = [NFloat add:PVS :curCJSS];
            }
        }
    }

    NFloat *PVS_2 = [NFloat div:PVS Integer:2];
    NFloat *fenmu  = [NFloat add:UVS :PVS_2];//分母
    NFloat *fenzi = [NFloat add:DVS :PVS_2];//分子
    if ([NFloat compare:fenzi :[[NFloat alloc] init:1 :4 :0]] > 0) {//0.0001
        fVR_Value1 = [NFloat div:[NFloat mul:fenmu Integer:100] :fenzi];
        //TODO:::待修
        [fVR_Value1 changeValue:fVR_Value1->fValue :2 :0];//改成小数点2位，单位个位
    }
}

- (BOOL)CalculateVR:(NFloat *)fINTV :(NFloat *)fDETV :(NFloat *)fTV :(NSInteger)aIndex :(BOOL)bUserLast :(int)aDay {
    if (aIndex < 0 || aIndex >= nKLineCount_) {
        return false;
    }

    NFloat* zero = [NFloat zero];

    stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:aIndex];
    if (aIndex < aDay) {
        NFloat *fAmount = kxData.fCjss;
        if (aIndex == 0) {
            fTV = [NFloat add:fTV :fAmount];
        } else {
            NSInteger k = aIndex;
            kxData = [_klineRep.klineDataArrArray objectAtIndex:k];
            NFloat *curClose = kxData.fClose;
            kxData = [_klineRep.klineDataArrArray objectAtIndex:k-1];
            NFloat *lastClose = kxData.fClose;

            if ([NFloat compare:curClose:lastClose] == 1) { //上升日
                fINTV = [NFloat add:fINTV :fAmount];
            } else if ([NFloat compare:curClose:lastClose] == -1) { //下跌日
                fDETV = [NFloat add:fDETV :fAmount];
            } else {
                fTV = [NFloat add:fTV :fAmount];
            }
        }
    } else {
        fINTV = zero;
        fDETV = zero;
        fTV = zero;
        for (NSInteger k = aIndex; k>=(aIndex-aDay)+1; k--) {
            kxData = [_klineRep.klineDataArrArray objectAtIndex:k];
            NFloat *fAmount = kxData.fCjss;
            NFloat *curClose = kxData.fClose;

            kxData = [_klineRep.klineDataArrArray objectAtIndex:k-1];
            NFloat *lastClose = kxData.fClose;

            if ([NFloat compare:curClose:lastClose] == 1) { //上升日
                fINTV = [NFloat add:fINTV :fAmount];
            } else if ([NFloat compare:curClose:lastClose] == -1) { //下跌日
                fDETV = [NFloat add:fDETV :fAmount];
            } else {
                fTV = [NFloat add:fTV :fAmount];
            }
        }
    }
    NFloat *value4      = [[NFloat alloc] init:1 :4 :0];
    NFloat *value2      = [[NFloat alloc] init:2 :0 :0];
    NFloat *tempValue   = [NFloat add:fDETV :[NFloat div:fTV :value2]];
    NFloat *tempValue1  = [NFloat add:fINTV :[NFloat div:fTV :value2]];
    if ([NFloat compare:tempValue:value4] == -1) {
        return  false;
    }
    if (fVR_Value1) {
        fVR_Value1 = [NFloat div:[NFloat mul:tempValue1 Integer:100] :tempValue];
    }
    return  true;
}

- (BOOL)CalculateCR:(NSInteger)aIndex{
    if (aIndex < 0 || aIndex >= nKLineCount_) {
        return false;
    }
    NFloat *zero = [NFloat zero];
    NFloat *fBS =zero;//Σ（H－YM）
    NFloat *fSS =zero;//Σ（YM－L）
    NFloat *fCR;//CR（N日）=fBS÷fSS×100
    
    int count = 0;
    for (NSInteger k = aIndex; k >= 0; k--) {
        stock_kline_data *kxData;
        stock_kline_data *lastkxdata;
        
        if (k <= 0) {
            kxData = [_klineRep.klineDataArrArray objectAtIndex:k];
            lastkxdata = kxData;
        } else {
            kxData = [_klineRep.klineDataArrArray objectAtIndex:k];
            lastkxdata = [_klineRep.klineDataArrArray objectAtIndex:k-1];
        }
        ;
        NFloat *value2 = [[NFloat alloc] init:2 :0 :0];
        //YM:昨日中间价
        NFloat *fTP = [NFloat div:[NFloat add:lastkxdata.fZgcj
                                             :lastkxdata.fZdcj]
                                 :value2];
        
        NFloat *value0 = zero;
        NFloat *tempValue = [NFloat sub:kxData.fZgcj :fTP];
        NFloat *tempValue1 = [NFloat sub:fTP :kxData.fZdcj];
        
        fBS = [NFloat add:fBS :[NFloat max:value0 :tempValue]];
        
        fSS = [NFloat add:fSS :[NFloat max:value0 :tempValue1]];
        
        count++;
        if (count == kCR26Days) {//周期
            break;
        }
    }
    
    NFloat* value4 = [[NFloat alloc] init:1 :4 :0];
    if ([NFloat compare:fSS:value4] == -1) {//小于0.0001
        return  false;
    }
    
    fCR = [NFloat div:[NFloat mul:fBS Integer:100] :fSS];
    fCR_Value1 = fCR;
    return true;
}

- (NFloat *)CalculateBOLL:(NSInteger)index withDay:(int)day withMid:(NFloat *)MA{
    if (index < 0 || index >= nKLineCount_ || day > index + 1) {
        return nil;
    }
    NSInteger count = 0;
    
    //    NFloat *MA = [NFloat zero];
    //    //计算样本全部数据的平均值 MA
    //    for (NSInteger k = index; k >= 0; k--) {
    //        stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:k];
    //            MA = [NFloat add:[NFloat initWithValue:kxData.nClose] :MA];
    //            count++;
    //        if (count == day || k == 0) {
    //            MA = [NFloat div:MA Integer:(k == 0 ? (int)count : (int)day)];
    //            break;
    //        }
    //    }
    
    //每个样本(收盘) 减去样本全部数据的平均值
    NFloat *squareSUMTMP = [NFloat zero];
    for (NSInteger j = index; j >= 0; j--) {
        stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:j];
        NFloat *eachColse = kxData.fClose;
        NFloat *squareSUM = [NFloat mul:[NFloat sub:eachColse :MA] :[NFloat sub:eachColse :MA]];
        squareSUMTMP = [NFloat add:squareSUMTMP :squareSUM];
        count++;
        if (count == day || j == 0) {
            //            squareSUMTMP = [NFloat div:squareSUMTMP Integer:(day - 1)];
            squareSUMTMP = [NFloat div:squareSUMTMP Integer:(j == 0)?(int)(count-1):(int)(day - 1)];
            break;
        }
    }
    //TODO:?
    double fvalue = [NFloat nfloatToFloat:squareSUMTMP];
    double afterSqrt = sqrt(fvalue);
    //    afterSqrt = round(afterSqrt*100000)/100000;   //保留 五位 小数
    int danwei = [NFloat get_units:afterSqrt]; //取单位
    int data = [NFloat dataWith:afterSqrt :danwei :2];
    squareSUMTMP = [NFloat initWithValue:data];
    
    return squareSUMTMP;
}

- (void)calculateRSI:(NSInteger)nIndex {
    if (!_klineRep.klineDataArrArray || nIndex >= nKLineCount_)
        return;
    stock_kline_data *kdata = nil;
    NFloat *zeroFloat = nil;
    NFloat *colse = nil;
    NFloat *yesterdayClose = nil;
    NFloat *maxCloseSubYesterdayClose = nil;
    NFloat *absCloseSubYesterdayClose = nil;
    // RSI$1:SMA(MAX(CLOSE-LC,0),N1,1)/SMA(ABS(CLOSE-LC),N1,1)*100;
    kdata = [_klineRep.klineDataArrArray objectAtIndex:nIndex];
    zeroFloat = [NFloat zero];
    colse = kdata.fClose;
    yesterdayClose = kdata.fYclose;
    maxCloseSubYesterdayClose = [NFloat max:[NFloat sub:colse :yesterdayClose] :zeroFloat];//MAX(CLOSE-LC,0)
    absCloseSubYesterdayClose = [NFloat abs:[NFloat sub:colse :yesterdayClose]];//ABS(CLOSE-LC)
    // SMA(MAX(CLOSE-LC,0),N1,1)
    //当日sma值 = N1-1 / N1 * 前一日sma值 + 1 / N1 * MAX(CLOSE-LC,0)
    //    NFloat *nk = [NFloat add:[NFloat div:[NFloat mul:fk Integer:2] Integer:3] :[NFloat div:rsv Integer:3]];
    NFloat *SMAMAXnRSI6 = [NFloat add:[NFloat div:[NFloat mul:SMAMAX_RSI6 Integer:5] Integer:6] :[NFloat div:maxCloseSubYesterdayClose Integer:6]];
    NFloat *SMAMAXnRSI12 = [NFloat add:[NFloat div:[NFloat mul:SMAMAX_RSI12 Integer:11] Integer:12] :[NFloat div:maxCloseSubYesterdayClose Integer:12]];
    NFloat *SMAMAXnRSI24 = [NFloat add:[NFloat div:[NFloat mul:SMAMAX_RSI24 Integer:23] Integer:24] :[NFloat div:maxCloseSubYesterdayClose Integer:24]];
    
    [SMAMAX_RSI6 changeValue:SMAMAXnRSI6];
    [SMAMAX_RSI12 changeValue:SMAMAXnRSI12];
    [SMAMAX_RSI24 changeValue:SMAMAXnRSI24];
    
    
    // SMA(ABS(CLOSE-LC),N1,1)
    NFloat *SMAABSnRSI6 = [NFloat add:[NFloat div:[NFloat mul:SMAABS_RSI6 Integer:5] Integer:6] :[NFloat div:absCloseSubYesterdayClose Integer:6]];
    NFloat *SMAABSnRSI12 = [NFloat add:[NFloat div:[NFloat mul:SMAABS_RSI12 Integer:11] Integer:12] :[NFloat div:absCloseSubYesterdayClose Integer:12]];
    NFloat *SMAABSnRSI24 = [NFloat add:[NFloat div:[NFloat mul:SMAABS_RSI24 Integer:23] Integer:24] :[NFloat div:absCloseSubYesterdayClose Integer:24]];
    
    [SMAABS_RSI6 changeValue:SMAABSnRSI6];
    [SMAABS_RSI12 changeValue:SMAABSnRSI12];
    [SMAABS_RSI24 changeValue:SMAABSnRSI24];
    
    //RSI6
    NFloat *nRSI6 = [NFloat mul:[NFloat div:SMAMAX_RSI6 :SMAABS_RSI6] Integer:100];
    //RSI12
    NFloat *nRSI12 = [NFloat mul:[NFloat div:SMAMAX_RSI12 :SMAABS_RSI12] Integer:100];
    //RSI24
    NFloat *nRSI24 = [NFloat mul:[NFloat div:SMAMAX_RSI24 :SMAABS_RSI24] Integer:100];
    
    RSI6  = nRSI6;
    RSI12 = nRSI12;
    RSI24 = nRSI24;
//    [RSI6 changeValue:nRSI6];
//    [RSI12 changeValue:nRSI12];
//    [RSI24 changeValue:nRSI24];
}

#pragma mark - calculateTool2

- (NFloat *)CalculateMA:(NSInteger)index :(NSInteger)day :(BOOL)bUseTech :(NSInteger)aTechIndex {
    if (index < 0 || index >= nKLineCount_ || day > index + 1) {
        return nil;
    }
    NSInteger count = 0;
    NFloat *MA = [NFloat zero];
    for (NSInteger k = index; k >= 0; k--) {
        stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:k];
        
        if (bUseTech) {
            switch (aTechIndex) {
                case 0:
                default:
                    MA = [NFloat add:[kxData.fTechArray objectAtIndex:0] :MA];
                    break;
                    
                case 1:
                    MA = [NFloat add:[kxData.fTechArray objectAtIndex:1] :MA];
                    break;
                    
                case 2:
                    MA = [NFloat add:[kxData.fTechArray objectAtIndex:2] :MA];
                    break;
            }
        } else {
            MA = [NFloat add:kxData.fClose :MA];
        }
        count++;
        if (count == day || k == 0) {
            MA = [NFloat div:MA Integer:(k == 0 ? (int)count : (int)day)];
            break;
        }
    }
    return MA;
}


/**
 算平均值
 
 @param index 索引
 @param day 周期
 @param itemBlock 不能为空,取值block
 @return 计算结果
 */
- (NFloat *)calculateMA:(NSInteger)index day:(NSInteger)day item:(NFloat *(^)(stock_kline_data *kxData))itemBlock{
    NSAssert(itemBlock, @" itemBlock 不能为空");
    if (index < 0 || index >= nKLineCount_ || day > index + 1) {
        return nil;
    }
    NSInteger count = 0;
    NFloat *MA = [NFloat zero];
    for (NSInteger k = index; k >= 0; k--) {
        stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:k];
        NFloat* value = itemBlock(kxData);
        MA = [NFloat add:MA :value];
        count++;
        if (count == day || k == 0) {
            MA = [NFloat div:MA Integer:(k == 0 ? (int)count : (int)day)];
            break;
        }
    }
    return MA;
}
/**
 算平均值
 @param range 计算范围
 @param day 周期
 @param itemBlock 不能为空
 @param saveBlock 计算结果，不能为空
 */
- (void)calculateMA:(YT_CalculateRange)range day:(NSInteger)day item:(NFloat *(^)(stock_kline_data *kxData))itemBlock save:(void(^)(stock_kline_data *kxData ,NSInteger calculateIndex,NFloat *calculateRs))saveBlock{
    [self calculateMA:range day:day ex:NO item:itemBlock save:saveBlock];
}

/**
 算平均值
 @param range 计算范围
 @param day 周期
 @param ex 是否扩展计算范围，扩展范围为start~~~end+day-1
 @param itemBlock 不能为空,取值block
 @param saveBlock 计算结果，不能为空,存值block
 */
- (void)calculateMA:(YT_CalculateRange)range day:(NSInteger)day ex:(BOOL)ex item:(NFloat *(^)(stock_kline_data *kxData))itemBlock save:(void(^)(stock_kline_data *kxData ,NSInteger calculateIndex,NFloat *calculateRs))saveBlock{
    NSAssert(itemBlock, @" itemBlock 不能为空");
    NSAssert(saveBlock, @" saveBlock 不能为空");
    NSInteger start = range.nStart;//可计算起点
    NSInteger end = range.nEnd;//可计算结束点
    start = MAX(day-1, start);//计算有结果的最小索引
    if(ex)end = end +day -1;
    end = MIN(nKLineCount_, end);
    if(start>end)return;//没有可计算范围
    NFloat *zoom = [NFloat zero];//和
    NFloat *rsMA = nil;//计算结果
    NSInteger count = 0;
    //计算第一个数据
    for (NSInteger k = start;k >= 0; k--) {//k>start-day&&
        stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:k];
        NFloat* value = itemBlock(kxData);
        zoom = [NFloat add:zoom :value];
        count++;
        if (count == day) {
            rsMA = [NFloat div:zoom Integer:(int)day];
            break;
        }
    }
    if (!rsMA) return;//计算出错
    saveBlock([_klineRep.klineDataArrArray objectAtIndex:start],start,rsMA);
    //计算后续数据
    for (NSInteger k = start+1;k <end; k++) {
        //加下一个数据
        stock_kline_data *kxData = [_klineRep.klineDataArrArray objectAtIndex:k];
        NFloat* value = itemBlock(kxData);
        zoom = [NFloat add:zoom :value];
        //减去第一个数据
        kxData = [_klineRep.klineDataArrArray objectAtIndex:k-day];
        value = itemBlock(kxData);
        zoom = [NFloat sub:zoom :value];
        rsMA = [NFloat div:zoom Integer:(int)day];
        saveBlock([_klineRep.klineDataArrArray objectAtIndex:k],k,rsMA);
    }
}

-(YT_CalculateRange)rangeFrom:(NSInteger)nStart toIndex:(NSInteger)nEnd{
    YT_CalculateRange range;range.nStart = nStart;range.nEnd = nEnd;
    return range;
}

#ifdef DEBUG
-(void)dealloc{
    NSLog(@"完美谢幕%@",NSStringFromClass(self.class));
}
#endif
@end
