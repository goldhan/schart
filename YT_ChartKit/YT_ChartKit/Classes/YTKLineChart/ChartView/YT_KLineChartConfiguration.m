//
//  YT_KLineChartConfiguration.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/5/28.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_KLineChartConfiguration.h"
#import "YT_KLineMALayer.h"

@interface YT_KLineChartConfiguration() 
@end

@implementation YT_KLineChartConfiguration

- (instancetype)init {
    self = [super init];
    if (self) {
        [self makeDefault];
        [self makeDefault_KLineChart];
        [self makeDefault_KLineMALayer];
        [self makeDefault_VolMACDLayer];
        [self makeDefault_VolKDJLayer];
        [self makeDefault_VolVRLayer];
        [self makeDefault_VolDMALayer];
        [self makeDefault_VolWRLayer];
        [self makeDefault_VolBOLLLayer];
        [self makeDefault_VolRSILayer];
        [self makeDefault_VolDMILayer];
        [self makeDefault_BIASLayer];
        [self makeDefault_VolCCILayer];
        [self makeDefault_VolCRLayer];
        [self makeDefault_VolOBVLayer];
        [self makeDefault_VolVOLLayer];
    }
    return self;
}

- (void)makeDefault {
    _topGap = 20;
    _riverGap = 20;
    _bottomGap = 10;
    _kChartWeight = 10;
    _vChartWeight = 3;
    
    _kAxisYSplit = 2; ///< k线纵轴 默认2
    _vAxisYSplit = 1; ///< k线纵轴 默认1
}


- (void)makeDefault_KLineChart {
    
    _kChartTBDrawGap = UIEdgeInsetsMake(10, 0, 10, 0);
    
    _kShapeInterval = 2;
    _kLineCountVisibaleInit = 60;
//    _kShapeWidthInit = 5;
    
    _kMaxCountVisibale = 120;
    _kMinCountVisibale = 20;
    _kMaxShapeWidth = CGFLOAT_MAX;
    _kMinShapeWidth = CGFLOAT_MIN;
    
    _riseColor = [UIColor colorWithRed:234/255.0 green:82/255.0 blue:83/255.0 alpha:1];
    _fallColor = [UIColor colorWithRed:77/255.0 green:166/255.0 blue:73/255.0 alpha:1];
    _holdColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1];
    _gridColor = [UIColor colorWithRed:225/255.0 green:225/255.0 blue:225/255.0 alpha:1];
    _closePriceLineColor = [UIColor colorWithRed:137/255.0 green:110/255.0 blue:228/255.0 alpha:1];
    
    _closslineColor = [UIColor colorWithRed:0x76/255.0 green:0xB7/255.0 blue:0xFC/255.0 alpha:1];
    _closslineAreaColor = [UIColor colorWithRed:0xEE/255.0 green:0xF8/255.0 blue:0xFD/255.0 alpha:1];
    _closslineWidth = 2;
    
    _lableKLineIndexFont = [UIFont systemFontOfSize:12];
    _lableVolumIndexFont = [UIFont systemFontOfSize:18];
    
    _lableKLineIndexColor = [UIColor blackColor];
    _lableVolumIndexColor = [UIColor blackColor];
    
    _axisXTextFont  = [UIFont systemFontOfSize:14];
    _kAxisYTextFont  = [UIFont systemFontOfSize:14];
    _vAxisYTextFont  = [UIFont systemFontOfSize:14];
    
    _axisXTextColor  = [UIColor blackColor];
    _kAxisYTextColor  = [UIColor blackColor];
    _vAxisYTextColor  = [UIColor blackColor];   
    
    _truthfulValueFloat = 1;
}

- (void)makeDefault_KLineMALayer {
    _kLineMALineWidth  = 1;
    _kLineMAColors     = @[[UIColor redColor] ,[UIColor greenColor],[UIColor grayColor],[UIColor yellowColor],[UIColor blueColor]];
}

- (void)makeDefault_VolMACDLayer {
    _volMACDLineWidth  = 1;
    _volMACDBarWidth   = 1;
    _volMACDColor_DIFF = [UIColor yellowColor];  // 子层颜色
    _volMACDColor_DEA  = [UIColor purpleColor];  // 子层颜色
}

- (void)makeDefault_VolKDJLayer {
    _volKDJLineWidth = 1;
    _volKDJColor_K = [UIColor blueColor]; // 子层颜色
    _volKDJColor_D = [UIColor yellowColor];  // 子层颜色
    _volKDJColor_J = [UIColor purpleColor];  // 子层颜色
}

- (void)makeDefault_VolVRLayer {
    _volVRLineWidth = 1;
    _volVRColor =     [UIColor blueColor]; // 子层颜色
    _volVRColor_MA6 = [UIColor yellowColor];  // 子层颜色
}

- (void)makeDefault_VolDMALayer {
    _volDMALineWidth  = 1;
    _volDMAColor_DMA  = [UIColor blueColor];    // 子层颜色
    _volDMAColor_AMA  = [UIColor yellowColor];  // 子层颜色
}

- (void)makeDefault_VolWRLayer {
    _volWRLineWidth  = 1;
    _volWRColor_WR10 = [UIColor blueColor];    // 子层颜色
    _volWRColor_WR6  = [UIColor yellowColor];  // 子层颜色
}

- (void)makeDefault_VolBOLLLayer {
    _volBOLLLineWidth  = 1;
    _volBOLLColor_M    = [UIColor blueColor];   // 子层颜色
    _volBOLLColor_U    = [UIColor purpleColor]; // 子层颜色
    _volBOLLColor_D    = [UIColor redColor];    // 子层颜色
}

- (void)makeDefault_VolRSILayer {
    _volRSILineWidth   = 1;
    _volRSIColor_RSI6  = [UIColor blueColor];   // 子层颜色
    _volRSIColor_RSI12 = [UIColor purpleColor]; // 子层颜色
    _volRSIColor_RSI24 = [UIColor redColor];    // 子层颜色
}

- (void)makeDefault_VolDMILayer {
    _volDMILineWidth   = 1;
    _volDMIColor_PDI   = [UIColor blueColor];   // 子层颜色
    _volDMIColor_MDI   = [UIColor blackColor];  // 子层颜色
    _volDMIColor_ADX   = [UIColor purpleColor]; // 子层颜色
    _volDMIColor_ADXR  = [UIColor redColor];    // 子层颜色
}

- (void)makeDefault_BIASLayer {
    _kLineBIASLineWidth  = 1;
    _volBIASColor_BIAS6 = [UIColor blueColor];   // 子层颜色
    _volBIASColor_BIAS12 = [UIColor blackColor];   // 子层颜色
    _volBIASColor_BIAS24 = [UIColor purpleColor];   // 子层颜色
}

- (void)makeDefault_VolCCILayer {
    _volCCILineWidth  = 1;
    _volCCIColor      = [UIColor blueColor]; // 子层颜色
}

- (void)makeDefault_VolCRLayer {
    _volCRLineWidth      = 1;
    _volCRColor_CR       = [UIColor blueColor];    // 子层颜色
    _volCRColor_CR_MA10  = [UIColor yellowColor];  // 子层颜色
    _volCRColor_CR_MA20  = [UIColor purpleColor];  // 子层颜色
    _volCRColor_CR_MA40  = [UIColor greenColor];   // 子层颜色
    _volCRColor_CR_MA62  = [UIColor blueColor];    // 子层颜色
}

- (void)makeDefault_VolOBVLayer {
    _volOBVLineWidth = 1;
    _volOBVColor = [UIColor blueColor];
    _volOBVMColor = [UIColor yellowColor];
}

- (void)makeDefault_VolVOLLayer {
    _volVOLLineWidth  = 1;
    _volVOLBarLineWidth = 1;
    _volVOLColor = [UIColor blackColor];   // vol文字颜色
    _volVOLColor_MA1 = [UIColor purpleColor];  // 子层颜色
    _volVOLColor_MA2  = [UIColor yellowColor];  // 子层颜色
    _volVOLTextUnit = @"手";
}

@end
