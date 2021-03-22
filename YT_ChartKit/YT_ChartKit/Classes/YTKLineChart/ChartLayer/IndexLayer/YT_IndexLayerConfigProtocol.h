//
//  YT_IndexLayerConfigProtocol.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/28.
//  Copyright © 2018年 kds. All rights reserved.
//

#ifndef YT_IndexLayerConfigProtocol_h
#define YT_IndexLayerConfigProtocol_h

///指标层配置基础协议
@protocol YT_IndexLayerConfig
@end

@protocol YT_KLineMALayerConfig <YT_IndexLayerConfig>

@property (nonatomic, assign) CGFloat kLineMALineWidth;
@property (nonatomic, strong) NSArray <UIColor *> *kLineMAColors; // 子层颜色
/**
 历史问题 之后 弃用 kFloat 就不需要这种恶心的转化了  详情看 YT_KLineChartStringFormat.m
 */
@property (nonatomic, assign) float truthfulValueFloat;      ///< 真实数据浮动 一般为 1.000000

@end


@protocol YT_MACDLayerConfig <YT_IndexLayerConfig>

@property (nonatomic, strong) UIColor * riseColor;      ///< 涨颜色
@property (nonatomic, strong) UIColor * fallColor;      ///< 跌颜色

@property (nonatomic, assign) CGFloat volMACDLineWidth;
@property (nonatomic, assign) CGFloat volMACDBarWidth;

@property (nonatomic, strong) UIColor * volMACDColor_DIFF; // 子层颜色
@property (nonatomic, strong) UIColor * volMACDColor_DEA;  // 子层颜色

@end

@protocol YT_KDJLayerConfig <YT_IndexLayerConfig>
@property (nonatomic, assign) CGFloat volKDJLineWidth;
@property (nonatomic, strong) UIColor * volKDJColor_K; // 子层颜色
@property (nonatomic, strong) UIColor * volKDJColor_D; // 子层颜色
@property (nonatomic, strong) UIColor * volKDJColor_J; // 子层颜色
@end

@protocol YT_VRLayerConfig <YT_IndexLayerConfig>
@property (nonatomic, assign) CGFloat volVRLineWidth;
@property (nonatomic, strong) UIColor * volVRColor;     // 子层颜色
@property (nonatomic, strong) UIColor * volVRColor_MA6; // 子层颜色
@end

@protocol YT_BIASLayerConfig <YT_IndexLayerConfig>
@property (nonatomic, assign) CGFloat kLineBIASLineWidth;
@property (nonatomic, strong) UIColor *volBIASColor_BIAS6;  // 子层颜色
@property (nonatomic, strong) UIColor *volBIASColor_BIAS12;  // 子层颜色
@property (nonatomic, strong) UIColor *volBIASColor_BIAS24;  // 子层颜色

@end

@protocol YT_DMALayerConfig <YT_IndexLayerConfig>

@property (nonatomic, assign) CGFloat volDMALineWidth;

@property (nonatomic, strong) UIColor *volDMAColor_DMA;  // 子层颜色
@property (nonatomic, strong) UIColor *volDMAColor_AMA;  // 子层颜色

@end

@protocol YT_CCILayerConfig <YT_IndexLayerConfig>
@property (nonatomic, assign) CGFloat volCCILineWidth;
@property (nonatomic, strong) UIColor *volCCIColor; // 子层颜色
@end

@protocol YT_DMILayerConfig <YT_IndexLayerConfig>
@property (nonatomic, assign) CGFloat volDMILineWidth;
@property (nonatomic, strong) UIColor *volDMIColor_PDI;  // 子层颜色
@property (nonatomic, strong) UIColor *volDMIColor_MDI;  // 子层颜色
@property (nonatomic, strong) UIColor *volDMIColor_ADX;  // 子层颜色
@property (nonatomic, strong) UIColor *volDMIColor_ADXR; // 子层颜色
@end

@protocol YT_WRLayerConfig <YT_IndexLayerConfig>

@property (nonatomic, assign) CGFloat volWRLineWidth;

@property (nonatomic, strong) UIColor *volWRColor_WR10;  // 子层颜色
@property (nonatomic, strong) UIColor *volWRColor_WR6;  // 子层颜色
@end

@protocol YT_RSILayerConfig <YT_IndexLayerConfig>
@property (nonatomic, assign) CGFloat volRSILineWidth;
@property (nonatomic, strong) UIColor *volRSIColor_RSI6;  // 子层颜色
@property (nonatomic, strong) UIColor *volRSIColor_RSI12;  // 子层颜色
@property (nonatomic, strong) UIColor *volRSIColor_RSI24;  // 子层颜色
@end

@protocol YT_BOLLLayerConfig <YT_IndexLayerConfig>
@property (nonatomic, assign) CGFloat volBOLLLineWidth;

@property (nonatomic, strong) UIColor * riseColor;      ///< 涨颜色
@property (nonatomic, strong) UIColor * fallColor;      ///< 跌颜色

@property (nonatomic, strong) UIColor *volBOLLColor_M;  // 子层颜色
@property (nonatomic, strong) UIColor *volBOLLColor_U;  // 子层颜色
@property (nonatomic, strong) UIColor *volBOLLColor_D;  // 子层颜色
@end

@protocol YT_CRLayerConfig <YT_IndexLayerConfig>
@property (nonatomic, assign) CGFloat volCRLineWidth;
@property (nonatomic, strong) UIColor *volCRColor_CR;  // 子层颜色
@property (nonatomic, strong) UIColor *volCRColor_CR_MA10;  // 子层颜色
@property (nonatomic, strong) UIColor *volCRColor_CR_MA20;  // 子层颜色
@property (nonatomic, strong) UIColor *volCRColor_CR_MA40;  // 子层颜色
@property (nonatomic, strong) UIColor *volCRColor_CR_MA62;  // 子层颜色
@end

@protocol YT_OBVLayerConfig <YT_IndexLayerConfig>
@property (nonatomic, assign) CGFloat volOBVLineWidth;
@property (nonatomic, strong) UIColor *volOBVColor;
@property (nonatomic, strong) UIColor *volOBVMColor;
@end

@protocol YT_VOLLayerConfig <YT_IndexLayerConfig>
@property (nonatomic, assign) CGFloat volVOLLineWidth;
@property (nonatomic, assign) CGFloat volVOLBarLineWidth;

@property (nonatomic, strong) UIColor *riseColor;      ///< 涨颜色
@property (nonatomic, strong) UIColor *fallColor;      ///< 跌颜色

@property (nonatomic, strong) UIColor *volVOLColor;   // vol文字颜色
@property (nonatomic, strong) UIColor *volVOLColor_MA1;   // 子层颜色
@property (nonatomic, strong) UIColor *volVOLColor_MA2;  // 子层颜色

//text 文字单位
@property (nonatomic, strong) NSString *volVOLTextUnit;      ///< 手/股 Unit Attached

@end

#endif /* YT_IndexLayerConfigProtocol_h */
