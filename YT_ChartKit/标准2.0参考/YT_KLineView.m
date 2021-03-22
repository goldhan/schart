//
//  YT_KLineView.m
//  YT_Phone
//
//  Created by yt_liyanshan on 2017/9/14.
//  Copyright © 2017年 kds. All rights reserved.
//

#import "YT_KLineView.h"
#import "KDS_KxMenu.h"
#import <mach/mach_time.h>
#import "KDS_SupportFunManager.h"
#import "stock_kline_data+YT_stock_kline_data.h"
#import <math.h>
#import "stock_kline_data+YT_NFloat.h"
#import "YT_KLineDataSource.h"
#import "YT_LineChartDrawer.h"
#import "YT_KLineViewConst.h"
#import "YT_BarChartDrawer.h"

@interface YT_KLineView () <KDS_CALayerDelegate> {
    CGContextRef    context_;
    
    KDS_CALayer         *gridLayer_;            // 背景表格层
    KDS_CALayer         *zbLayer_;             // 指标层
    KDS_CALayer         *kLineLayer_;           // k线层
    KDS_CALayer         *crossLayer_;           // 十字线层
    KDS_CALayer         *fuQuanLayer_;          // 复权层
    KDS_CALayer         *KLineMALayer_;         // k线均线数值
    
    CGRect       drawChartRect_;        // 图表区域
    CGRect          kLineChartRect_;       // K线框区域
    CGRect          kLineMARect_;          // K线均线文字区域
    CGRect          fuQuanButtonRect_;     // 复权按钮区域
    CGRect          volChartRect_;         // 成交量框区域
   
    UILabel         *label_KLineValue1_;     // k线Y轴第一个的数值
    UILabel         *label_KLineValue2_;     // k线Y轴第二个的数值
    UILabel         *label_KLineValue3_;     // k线Y轴第三个的数值
    UILabel         *label_KLineValue4_;     // k线Y轴第四个的数值
    UILabel         *label_KLineValue5_;     // k线Y轴第五个的数值
    
    
    UILabel         *rightlabel_KLineValue1_;     // k线Y轴右侧第一个的数值
    UILabel         *rightlabel_KLineValue2_;     // k线Y轴右侧第二个的数值
    UILabel         *rightlabel_KLineValue3_;     // k线Y轴右侧第三个的数值
    UILabel         *rightlabel_KLineValue4_;     // k线Y轴右侧第四个的数值
    UILabel         *rightlabel_KLineValue5_;     // k线Y轴右侧第五个的数值
    
    UILabel         *label_VOLValue1_;       // 成交量Y轴第一个的数值
    UILabel         *label_VOLValue2_;       // 成交量Y轴第二个的数值
    
    UILabel         *label_CrossLineLeft;       // 十字线左边
    UILabel         *label_CrossLineRight;      // 十字线右边
    
    NSInteger       pos_;                    // k线显示起始索引
    
    BOOL            shouldCrossLine_;      //是否应该显示十字线，十字线总开关
    BOOL            bShowCrossLine_;          // 是否显示十字线
    NSInteger       nCrossIndex_;             // 十字线对应的k线数据在数组中的索引
    CGFloat         fCrossIndexXPos_;         // 十字线中心x坐标
    CGFloat         fCrossIndexYPos_;         // 十字线中心y坐标
    
    CGFloat         itemWidth_;               // K线柱体宽度
    
//    BOOL            bSwiped;                  // 是否已经拖拽过
    
    NSInteger nKLineCount_;    // K线的根数
    
    // vol
    YT_BarChartDrawer  *vorBarChartDrawer_;     //成交量框区域画柱状图者
    YT_LineChartDrawer *vorLineChartDrawer_;    //成交量框区域画线图者
    NSArray<UIColor *> * _maColorArr;           //均线颜色数组
    
    // k
    YT_LineChartDrawer *kLineChartDrawer_;      //成交量框区域画线图者
    
    //拖动手势
    CGFloat   translateX_ZeroPos;
    NSInteger shouldMove;
}

@property(nonatomic,strong)YT_KLineDataSource *klineDataSoure;
@end

@implementation YT_KLineView

+(Class)layerClass{return [CAShapeLayer class];}

- (id)initWithFrame:(CGRect)frame {if (self = [super initWithFrame:frame]) {[self makeDefConfig];}return self;}

-(void)makeDefConfig{
    _coordinatelineColor = [YT_SkinCollector ytColor_07].yt_color;
    _upTextColor = [YT_SkinCollector ytColor_01].yt_color;
    _downTextColor = [YT_SkinCollector ytColor_02].yt_color;
    _normalTextColor = [YT_SkinCollector ytColor_11].yt_color;
    _xFont = [UIFont ytFont_h];
    _yFont = [UIFont ytFont_g];
    _maColorArr = @[kTecColor_MA5,kTecColor_MA10,kTecColor_MA20];
    
    pos_ = 0;
    nCrossIndex_ = 0;
    
    _KLineDirect = YT_KLineDirect_Ver;
    _zhiBiaoType = KDS_ZBType_VOL;
    
    itemWidth_ = koriginItemWidth;
//    fYValueFont_ = [UIFont kds_fontWithName:kFontName_Four size:[self recalculateFloat:10]];    // YValue的字体
    
    _klineDataSoure = [[YT_KLineDataSource alloc]init];
    
    [self createYValueLabels];
    
    // 点击手势
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    tapRecognizer.numberOfTouchesRequired = 1;
    tapRecognizer.numberOfTapsRequired = 2;
    [self addGestureRecognizer:tapRecognizer];
}

/**
 *  重新计算float值（适配屏幕、横竖屏）
 *
 *  @param fFloat 原值
 *
 *  @return 计算后得值
 */
- (CGFloat)recalculateFloat:(CGFloat)fFloat {
    if (_KLineDirect == YT_KLineDirect_Ver) {
        return getAutoSize(fFloat);
    } else {
        return getAutoSize_Hor(fFloat);
    }
}
#pragma mark 布局界面

-(void)layoutSubviews_Ver{
    CGFloat fator = kAutoSizeScaleX_;
#define FIX(a) ((a)*fator)
    UIEdgeInsets inset = UIEdgeInsetsMake(0, FIX(10), FIX(7), FIX(10));
    drawChartRect_ = UIEdgeInsetsInsetRect(self.bounds, inset);
    fator = self.frame.size.height/(23+180+45+66);
    //FIX(23) -> 314 -180 -45 -66
     //顶部均线文字
    CGRect  maTextRect = CGRectMake(drawChartRect_.origin.x, drawChartRect_.origin.y,  drawChartRect_.size.width, FIX(23));
//    kLineMARect_ = CGRectMake(kLeft_Pading, kTop_Pading, kKLineMAWidth, KKLineMAHeight);
    kLineMARect_ = maTextRect;
    kLineMARect_.size.width = kKLineMAWidth;
    //180 45 66 V
    //k线区域
    kLineChartRect_ = drawChartRect_;
    kLineChartRect_.size.height = FIX(180);
    kLineChartRect_.origin.y += maTextRect.size.height;
    //中间部分
    fuQuanButtonRect_ = CGRectMake(drawChartRect_.origin.x,
                                   CGRectGetMaxY(kLineChartRect_),
                                   drawChartRect_.size.width,
                                   FIX(45));
    
    //成交量栏
    volChartRect_ = CGRectMake(drawChartRect_.origin.x,
                               CGRectGetMaxY(fuQuanButtonRect_),
                               drawChartRect_.size.width,
                               FIX(66));
    
    CGRect rect = CGRectMake(kLineChartRect_.origin.x + FIX(kTextInsetPad), kLineChartRect_.origin.y, 50, label_KLineValue1_.font.lineHeight);
    label_KLineValue1_.frame = rect;
//    CGFloat gridHeight = kLineChartRect_.size.height / kGridLineNumber_KLine;
    rect.origin.y = CGRectGetMidY(kLineChartRect_)-rect.size.height;
    label_KLineValue3_.frame = rect;
    rect.origin.y = CGRectGetMaxY(kLineChartRect_)-rect.size.height;
    label_KLineValue5_.frame = rect;
//    label_KLineValue2_.hidden = YES;
//    label_KLineValue4_.hidden = YES;
    
    rect.origin.y = volChartRect_.origin.y;
    label_VOLValue1_.frame = rect;
    rect.origin.y += volChartRect_.size.height-rect.size.height;
    label_VOLValue2_.frame = rect;
    
#undef FIX
}


-(void)layoutSubviews_Hor{
    CGFloat fator =1;
    if (kScreen_Width>kScreen_Height) {
         fator = kScreen_Width/kBASESCREENHEIGHT;
    }else{
        fator = kScreen_Height/kBASESCREENHEIGHT;
    }
#define FIX(a) ((a)*fator)
    UIEdgeInsets inset = UIEdgeInsetsMake(0, FIX(0), FIX(0), FIX(0));
    drawChartRect_ = UIEdgeInsetsInsetRect(self.bounds, inset);//画图区域
    fator = self.frame.size.height/(144+44+55);
    //顶部均线文字
    CGRect  maTextRect = CGRectMake(drawChartRect_.origin.x, drawChartRect_.origin.y,  drawChartRect_.size.width, FIX(23));
    //    kLineMARect_ = CGRectMake(kLeft_Pading, kTop_Pading, kKLineMAWidth, KKLineMAHeight);
    kLineMARect_ = maTextRect;
    //k线区域
    kLineChartRect_ = drawChartRect_;
    kLineChartRect_.size.height = FIX(144);
    //中间部分
    fuQuanButtonRect_ = CGRectMake(drawChartRect_.origin.x,
                                   CGRectGetMaxY(kLineChartRect_),
                                   drawChartRect_.size.width,
                                   FIX(44));
    
    //成交量栏
    volChartRect_ = CGRectMake(drawChartRect_.origin.x,
                               CGRectGetMaxY(fuQuanButtonRect_),
                               drawChartRect_.size.width,
                               FIX(55));
    
    CGRect rect = CGRectMake(kLineChartRect_.origin.x + FIX(kTextInsetPad), kLineChartRect_.origin.y, 50, label_KLineValue1_.font.lineHeight);
    label_KLineValue1_.frame = rect;
    //    CGFloat gridHeight = kLineChartRect_.size.height / kGridLineNumber_KLine;
    rect.origin.y = CGRectGetMidY(kLineChartRect_)-rect.size.height;
    label_KLineValue3_.frame = rect;
    rect.origin.y = CGRectGetMaxY(kLineChartRect_)-rect.size.height;
    label_KLineValue5_.frame = rect;
    //    label_KLineValue2_.hidden = YES;
    //    label_KLineValue4_.hidden = YES;
    
    rect.origin.y = volChartRect_.origin.y;
    label_VOLValue1_.frame = rect;
    rect.origin.y += volChartRect_.size.height-rect.size.height;
    label_VOLValue2_.frame = rect;
    
#undef FIX
}

/**
 *  设置界面元素位置
 */
- (void)layoutSubviews {

    if (_KLineDirect == YT_KLineDirect_Ver) {
        [self layoutSubviews_Ver];
    } else {
        // 横屏
        [self layoutSubviews_Hor];
    }
    
    self.layer.contentsScale = [[UIScreen mainScreen] scale];
    if (!gridLayer_) {
        gridLayer_ = [[KDS_CALayer alloc] init];
        gridLayer_.KDS_CALayerDelegate = self;
        gridLayer_.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:gridLayer_];
    }
    if (!zbLayer_) {
        zbLayer_ = [[KDS_CALayer alloc] init];
        zbLayer_.KDS_CALayerDelegate = self;
        zbLayer_.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:zbLayer_];
    }
    if (!kLineLayer_) {
        kLineLayer_ = [[KDS_CALayer alloc] init];
        kLineLayer_.KDS_CALayerDelegate = self;
        kLineLayer_.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:kLineLayer_];
    }
    if (!KLineMALayer_) {
        KLineMALayer_ = [[KDS_CALayer alloc] init];
        KLineMALayer_.KDS_CALayerDelegate = self;
        KLineMALayer_.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:KLineMALayer_];
    }
    if (!crossLayer_) {
        crossLayer_ = [[KDS_CALayer alloc] init];
        crossLayer_.KDS_CALayerDelegate = self;
        crossLayer_.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:crossLayer_];
    }
    if (!fuQuanLayer_) {
        fuQuanLayer_ = [[KDS_CALayer alloc] init];
        fuQuanLayer_.KDS_CALayerDelegate = self;
        fuQuanLayer_.contentsScale = [[UIScreen mainScreen] scale];
        [self.layer addSublayer:fuQuanLayer_];
    }
    
    // 表格背景
    gridLayer_.bounds = self.bounds;
    gridLayer_.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    [gridLayer_ setNeedsDisplay];
    
    // 成交量层
    CGRect rect = fuQuanButtonRect_;
    rect.size.height += volChartRect_.size.height;
    zbLayer_.bounds = rect;
    zbLayer_.position = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    // 复权按钮区域  包括k线时间
    fuQuanLayer_.bounds = fuQuanButtonRect_;
    fuQuanLayer_.position = CGPointMake(fuQuanButtonRect_.size.width/2+fuQuanButtonRect_.origin.x, fuQuanButtonRect_.size.height/2+fuQuanButtonRect_.origin.y);
    
    // K线层
    kLineLayer_.bounds = kLineChartRect_;
    kLineLayer_.position = CGPointMake(kLineChartRect_.size.width/2+kLineChartRect_.origin.x, kLineChartRect_.size.height/2+kLineChartRect_.origin.y);
    
    KLineMALayer_.bounds = kLineMARect_;
    KLineMALayer_.position = CGPointMake(kLineMARect_.size.width/2+kLineMARect_.origin.x, kLineMARect_.size.height/2+kLineMARect_.origin.y);
    
    // 十字线
    crossLayer_.bounds = self.bounds;
    crossLayer_.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    
}

- (void)KDS_CALayerDrawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    if (layer == gridLayer_) {
        [self drawGrid:ctx];
    }else if (layer == zbLayer_) {
        if (nKLineCount_ > 0) {
            switch (_zhiBiaoType) {
                case KDS_ZBType_VOL:
                    [self drawVol:ctx];
                    break;
                case KDS_ZBType_MACD:
                    [self drawMACD:ctx];
                    break;
                case KDS_ZBType_DMI:
                    [self drawDMI:ctx];
                    break;
                case KDS_ZBType_WR:
                    [self drawWR:ctx];
                    break;
                case KDS_ZBType_BOLL:
                    [self drawBOLL:ctx];
                    break;
                case KDS_ZBType_KDJ:
                    [self drawKDJ:ctx];
                    break;
                case KDS_ZBType_OBV:
                    [self drawOBV:ctx];
                    break;
                case KDS_ZBType_RSI:
                    [self drawRSI:ctx];
                    break;
                case KDS_ZBType_SAR:
                    [self drawSAR:ctx];
                    break;
                case KDS_ZBType_DMA:
                    [self drawDMA:ctx];
                    break;
                case KDS_ZBType_VR:
                    [self drawVR:ctx];
                    break;
                case KDS_ZBType_CR:
                    [self drawCR:ctx];
                    break;
                    
                default:
                    break;
            }
        }
    }else if (layer == kLineLayer_) {
        if (nKLineCount_ > 0) {
            [self drawKLine:ctx];
        }
    }else if (layer == KLineMALayer_) {
        if (nKLineCount_ > 0) {
            [self drawKLineMAText:ctx];
        }
    }else if (layer == crossLayer_) {
        if (nKLineCount_ > 0) {
            if (bShowCrossLine_ && nCrossIndex_>=0) {
                [self drawCrossLine:ctx];
            }
        }
    }else if (layer == fuQuanLayer_) {
        if (nKLineCount_ > 0) {
            [self drawFuQuan:ctx];
        }
    }
}

#pragma mark 绘制基本界面
/**
 *  绘制背景表格
 */
- (void)drawGrid:(CGContextRef)ctx {
    CGFloat gridHeight = kLineChartRect_.size.height / kGridLineNumber_KLine;
    CGFloat x = kLineChartRect_.origin.x;
    CGFloat y = kLineChartRect_.origin.y + gridHeight;
    NSInteger   i;
    
    //颜色定义部分，并设置画笔颜色
    UIColor *lineColor = _coordinatelineColor;
    CGContextSetLineWidth(ctx, .5f);
    CGContextSetStrokeColorWithColor(ctx,lineColor.CGColor);
    
    // 绘制K线背景表格
    CGContextStrokeRect(ctx, kLineChartRect_);
    // 横线
    for (i = 0; i < kGridLineNumber_KLine-1; i++) {
        CGContextMoveToPoint(ctx, x, y);
        CGContextAddLineToPoint(ctx, x + kLineChartRect_.size.width, y);
        CGContextStrokePath(ctx);
        y += gridHeight;
    }
    
    if (self.KLineDirect == YT_KLineDirect_Ver) {
         CGContextStrokeRect(ctx, fuQuanButtonRect_);
    }

    // 绘制成交量背景表格
//    CGRect rect = CGRectMake(volChartRect_.origin.x, volChartRect_.origin.y, volChartRect_.size.width, volChartRect_.size.height);
    CGContextStrokeRect(ctx, volChartRect_);
    // 横线
    y = CGRectGetMidY(volChartRect_);
    CGContextMoveToPoint(ctx, x, y);
    CGContextAddLineToPoint(ctx, x + kLineChartRect_.size.width, y);
    CGContextStrokePath(ctx);
}

/**
 *  创建Y轴值Label
 */
- (void)createYValueLabels {
    CGRect rect = CGRectZero;
//    UIFont *valueFont = [UIFont kds_fontWithName:kFontName_Four size:kFontSize_6];
//    UIColor *textColor = skinColor(@"FSKLine_Color_KLineTecWhite");   //字体颜色
    UIFont *valueFont  = _yFont;
    UIColor *textColor = _normalTextColor;
    label_KLineValue1_ = [UILabel kds_createLable:rect
                                             Text:nil
                                      TextAliType:NSTextAlignmentLeft
                                             Font:valueFont
                                            Color:_upTextColor
                                        BackColor:nil];
    
    label_KLineValue3_ = [UILabel kds_createLable:rect
                                             Text:nil
                                      TextAliType:NSTextAlignmentLeft
                                             Font:valueFont
                                            Color:_normalTextColor
                                        BackColor:nil];
    
    label_KLineValue5_ = [UILabel kds_createLable:rect
                                             Text:nil
                                      TextAliType:NSTextAlignmentLeft
                                             Font:valueFont
                                            Color:_downTextColor
                                        BackColor:nil];
    
    self.FQSeletcButton = [UIButton kds_createButton:rect
                                           ButtonTag:1000
                                         ButtonTitle:@"设置"
                                    ButtonTitleColor:[UIColor whiteColor]
                                     ButtonTitleFont:_xFont
                                              target:self
                                            selector:@selector(pushToSettingPage)];
    self.FQSeletcButton.backgroundColor = skinColor(@"FSKLine_Color_SettingButton");
    self.FQSeletcButton.hidden = YES;
    
//    rightlabel_KLineValue1_ = [UILabel kds_createLable:rect
//                                                  Text:nil
//                                           TextAliType:NSTextAlignmentLeft
//                                                  Font:valueFont
//                                                 Color:textColor
//                                             BackColor:nil];
    
    label_VOLValue1_ = [UILabel kds_createLable:rect
                                           Text:nil
                                    TextAliType:NSTextAlignmentLeft
                                           Font:valueFont
                                          Color:textColor
                                      BackColor:nil];
    
    label_VOLValue2_ = [UILabel kds_createLable:rect
                                           Text:nil
                                    TextAliType:NSTextAlignmentLeft
                                           Font:valueFont
                                          Color:textColor
                                      BackColor:nil];
    
    UIFont *textFont = [UIFont kds_fontWithName:kFontName_Four size:kFontSize_4];
    
    label_CrossLineLeft = [UILabel kds_createLable:rect
                                              Text:nil
                                       TextAliType:NSTextAlignmentCenter
                                              Font:textFont
                                             Color:textColor
                                         BackColor:skinColor(@"HangQing_BackColor_ListTable")];
    label_CrossLineLeft.hidden = YES;
    label_CrossLineRight = [UILabel kds_createLable:rect
                                               Text:nil
                                        TextAliType:NSTextAlignmentCenter
                                               Font:textFont
                                              Color:textColor
                                          BackColor:skinColor(@"HangQing_BackColor_ListTable")];
    label_CrossLineLeft.hidden = YES;
    [self addSubview:label_KLineValue1_];
//    [self addSubview:label_KLineValue2_];
    [self addSubview:label_KLineValue3_];
//    [self addSubview:label_KLineValue4_];
    [self addSubview:label_KLineValue5_];
    [self addSubview:self.FQSeletcButton];
//    [self addSubview:rightlabel_KLineValue1_];
//    [self addSubview:rightlabel_KLineValue2_];
//    [self addSubview:rightlabel_KLineValue3_];
//    [self addSubview:rightlabel_KLineValue4_];
//    [self addSubview:rightlabel_KLineValue5_];
    [self addSubview:label_VOLValue1_];
    [self addSubview:label_VOLValue2_];
    [self addSubview:label_CrossLineLeft];
    [self addSubview:label_CrossLineRight];
}

#pragma mark 绘制K线
- (void)drawKLine:(CGContextRef)ctx {
    NSInteger maxPointAppearCount = 0;  //记录划线时最高成交点出现过的次数，显示第一处价格
    NSInteger minPointAppearCount = 0;  //记录划线时最低成交点出现过的次数，显示第一处价格
   /******绘制蜡烛线*****/
    CGFloat fHeight = kLineChartRect_.size.height;
    CGFloat fItemWidth = [self getItemWidth];
    CGFloat fItemHalfWidth = fItemWidth / 2;
    CGFloat fBottom = kLineChartRect_.origin.y + kLineChartRect_.size.height;
    CGFloat newx;
    CGFloat newd, newg, newo, newc;   //最低价、最高价、开盘价、收盘价的y坐标
    
    CGFloat fPrice = self.klineDataSoure.maxPrice->fValue - self.klineDataSoure.minPrice->fValue;
    stock_kline_data *kxData = nil;
    NSInteger i=0;
    for (i=pos_; i<YT_KLineView_SHOWENDINDEX; i++) {
   
        kxData = [self.klineRep.klineDataArrArray objectAtIndex:i];
        newx = kLineChartRect_.origin.x + [self getItemWidth]*(i-pos_);
        
        NFloat *fZdcj = kxData.fZdcj;
        NFloat *fZgcj = kxData.fZgcj;
        NFloat *fOpen = kxData.fOpen;
        NFloat *fClose = kxData.fClose;
        
        if (0.0f == fPrice) {
            newd = 0;
            newg = 0;
            newo = 0;
            newc = 0;
        } else {
            newd = fBottom - (fZdcj->fValue - self.klineDataSoure.minPrice->fValue) * fHeight / fPrice;
            newg = fBottom - (fZgcj->fValue - self.klineDataSoure.minPrice->fValue) * fHeight / fPrice;
            newo = fBottom - (fOpen->fValue - self.klineDataSoure.minPrice->fValue) * fHeight / fPrice;
            newc = fBottom - (fClose->fValue - self.klineDataSoure.minPrice->fValue) * fHeight / fPrice;
        }
        
        //        //颜色绘制规则：先收盘（现价）和 开盘价比较，一样的话，收盘价和左收价比较
        //        NSInteger com = [NFloat compare:kxData.nClose :kxData.nOpen];
        //        if (com == 0) {
        //            color = [KDS_PublicMethod getColorWithValueString:[kxData.nClose toString] baseValueString:[kxData.nYClose toString]];
        //        }else {
        //            color = [KDS_PublicMethod getColorWithValueString:[kxData.nClose toString] baseValueString:[kxData.nOpen toString]];
        //        }
        NFloatCompare compare = [fClose compare:fOpen];
        UIColor *color = [self getDrawColorWithCompare:compare];
        CGContextSetStrokeColorWithColor(ctx, color.CGColor);
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        
        // 美国线
        if (/* DISABLES CODE */ (NO)) {
            // 显示全部点数 变为美国线
            CGContextBeginPath(ctx);
            CGContextMoveToPoint(ctx, newx + fItemHalfWidth, newc);
            CGContextAddLineToPoint(ctx, newx + fItemWidth, newc);
            if ([NFloat compare:fZgcj :fZdcj] > 0) {
                CGContextMoveToPoint(ctx, newx + fItemHalfWidth, newg);
                CGContextAddLineToPoint(ctx, newx + fItemHalfWidth, newd);
            }
            CGContextStrokePath(ctx);
        } else {
            // K线
            CGContextBeginPath(ctx);
            //中间竖线:最高，最低
            if ([NFloat compare:fZgcj :fZdcj] > 0) {
                CGContextMoveToPoint(ctx, newx + fItemHalfWidth, newg);
                CGContextAddLineToPoint(ctx, newx + fItemHalfWidth, MIN(newo, newc));
                CGContextMoveToPoint(ctx, newx + fItemHalfWidth, newd);
                CGContextAddLineToPoint(ctx, newx + fItemHalfWidth, MAX(newo, newc));
                CGContextStrokePath(ctx);
            }
            //矩形:开盘，收盘,实心的绿,空心的红
            if (compare==NFloatCompare_Negative) {
                CGContextFillRect(ctx, CGRectMake(newx+kKLineItemGap, newo, fItemWidth-2*kKLineItemGap, newc - newo));
            } else if (compare==NFloatCompare_Plus) {
                CGContextStrokeRect(ctx, CGRectMake(newx+kKLineItemGap, newo, fItemWidth-2*kKLineItemGap, newc - newo));
            } else {
                if (isnan(newo)) {
                    newo = 0.0;
                }
                CGContextMoveToPoint(ctx, newx, newo);
                CGContextAddLineToPoint(ctx, newx + fItemWidth, newo);
                CGContextStrokePath(ctx);
            }
            
        }
        
        /****在最高价格、最低价格处展示展示价格******/
        if ([KDS_SupportFunManager shareInstance].bSupportShownKLineViewMaxAndMinPoint) {
            if ([NFloat compare:self.klineDataSoure.maxPrice :fZgcj] == 0) {
                if (maxPointAppearCount == 0) {
                    CGContextSetLineWidth(ctx, 1.0);
                    CGContextSetStrokeColorWithColor(ctx, UIColor.whiteColor.CGColor);
                    
                    //判断当前点是屏幕左侧还是右侧
                    CGFloat newLineEndX; //指向最小价格的线段的终止坐标
                    CGFloat newStrBeginX;
                    if (newx <= kLineChartRect_.origin.x + kLineChartRect_.size.width/2) {
                        newLineEndX = newx + fItemHalfWidth + 20;
                        newStrBeginX = newx + fItemHalfWidth + 20;
                    } else {
                        newLineEndX = newx + fItemHalfWidth - 20;
                        newStrBeginX = newx + fItemHalfWidth - 40;
                    }
                    //画指向线
                    CGContextMoveToPoint(ctx, newx + fItemHalfWidth, newg);
                    CGContextAddLineToPoint(ctx, newLineEndX,newg);
                    
                    //            写文字
                    [NSString kds_drawAtPoint:CGPointMake(newStrBeginX, newg) withFont:_xFont withColor:[UIColor whiteColor] withString:[NSString stringWithFormat:@"%.2f",fZgcj->fValue]];
                    
                    CGContextStrokePath(ctx);
                    maxPointAppearCount ++;
                }
            }
            if ([NFloat compare:self.klineDataSoure.minPrice :fZdcj] == 0) {
                if (minPointAppearCount == 0) {
                    CGContextSetLineWidth(ctx, 1.0);
                    CGContextSetStrokeColorWithColor(ctx, UIColor.whiteColor.CGColor);
                    
                    //判断当前点是屏幕左侧还是右侧
                    CGFloat newLineEndX; //指向最小价格的线段的终止坐标
                    CGFloat newStrBeginX;
                    if (newx <= kLineChartRect_.origin.x + kLineChartRect_.size.width/2) {
                        newLineEndX = newx + fItemHalfWidth + 20;
                        newStrBeginX = newx + fItemHalfWidth + 20;
                    } else {
                        newLineEndX = newx + fItemHalfWidth - 20;
                        newStrBeginX = newx + fItemHalfWidth - 40;
                    }
                    //画指向线
                    CGContextMoveToPoint(ctx, newx + fItemHalfWidth, newd);
                    CGContextAddLineToPoint(ctx, newLineEndX,newd);
                    
                    //            写文字
                    [NSString kds_drawAtPoint:CGPointMake(newStrBeginX, newd - 10) withFont:_xFont withColor:[UIColor whiteColor] withString:[NSString stringWithFormat:@"%.2f",fZdcj->fValue]];
                    CGContextStrokePath(ctx);
                    minPointAppearCount ++;
                }
            }
        }
    }
    /**********绘制均线***************/
    YT_LineChartDrawer * drawer = [self getKLineChartDrawer];
    if ([KDS_SystemSetManager bSupportKLineMLineSet]) {
        
        //均线设置模型数组
        NSMutableArray *maLineSetArray = [KDS_SystemSetManager getMALineSetArray];
        [drawer.lines removeAllObjects];
        for (int i = 0; i < [maLineSetArray count]; i++) {
            KDS_MALineSetModel *model = [maLineSetArray objectAtIndex:i];
            //状态为1表示设置界面该均线设置状态为开启
            if(model.isOpen) {
                if (i>=5) break;
                NSString * keyPath = [NSString stringWithFormat:@"cache_customMA%zd",i+1];
                UIColor * color = self.klineDataSoure.array_colors[i];
                @weakify(self)
                YT_LineChartLine * line = [YT_LineChartLine lineChartLineColor:color drawStrategy:kLineChartDrawStrategyDrawAllFixZeroToNil parseLineDataBlock:^NFloat *(YT_LineChartLine *line, NSInteger index) {
                    stock_kline_data *techData = [weak_self.klineRep.klineDataArrArray objectAtIndex:index];
                    return [techData valueForKeyPath:keyPath];
                }];
                [drawer.lines addObject:line];
            }
        }
    } else {
        drawer.lines = [self getLinesColor:self.klineDataSoure.array_colors drawStrategy:kLineChartDrawStrategyDrawAllFixZeroToNil keyPath:@"MA1",@"MA2",@"MA3",nil];

    }
     [drawer drawInContext:ctx];
    
    /********设置Y轴数值************/
    NFloat *gridUnit = [NFloat div:[NFloat sub:self.klineDataSoure.maxPrice :self.klineDataSoure.minPrice] Integer:kGridLineNumber_KLine];
    NFloat *gridValue = [NFloat sub:self.klineDataSoure.maxPrice:gridUnit];
    
    label_KLineValue1_.text = [self.klineDataSoure.maxPrice toString];
    label_KLineValue2_.text = [gridValue toString];
    gridValue = [NFloat sub:gridValue :gridUnit];
    label_KLineValue3_.text = [gridValue toString];
    gridValue = [NFloat sub:gridValue :gridUnit];
    label_KLineValue4_.text = [gridValue toString];
    label_KLineValue5_.text = [self.klineDataSoure.minPrice toString];
    
    gridUnit = [NFloat div:[NFloat sub:self.klineDataSoure.maxZDF :self.klineDataSoure.minZDF] Integer:kGridLineNumber_KLine];
    gridValue = [NFloat sub:self.klineDataSoure.maxZDF:gridUnit];
    NFloat *value = [NFloat mul:self.klineDataSoure.maxZDF Integer:100];
    rightlabel_KLineValue1_.text = [KDS_PublicMethod stringByAppendingPercent:value];
    UIColor *color =[self getDrawColorWithCompare:self.klineDataSoure.maxZDF.compare];
    rightlabel_KLineValue1_.textColor = color;
    
    value = [NFloat mul:gridValue Integer:100];
    rightlabel_KLineValue2_.text = [KDS_PublicMethod stringByAppendingPercent:value];
    color =[self getDrawColorWithCompare:gridValue.compare];
    rightlabel_KLineValue2_.textColor = color;
    
    gridValue = [NFloat sub:gridValue :gridUnit];
    value = [NFloat mul:gridValue Integer:100];
    rightlabel_KLineValue3_.text = [KDS_PublicMethod stringByAppendingPercent:value];
    color =[self getDrawColorWithCompare:gridValue.compare];
    rightlabel_KLineValue3_.textColor = color;
    
    gridValue = [NFloat sub:gridValue :gridUnit];
    value = [NFloat mul:gridValue Integer:100];
    rightlabel_KLineValue4_.text = [KDS_PublicMethod stringByAppendingPercent:value];
//    color = [KDS_PublicMethod getColorWithValueString:[gridValue toString]];
    color =[self getDrawColorWithCompare:gridValue.compare];
    rightlabel_KLineValue4_.textColor = color;
    
    value = [NFloat mul:self.klineDataSoure.minZDF Integer:100];
    rightlabel_KLineValue5_.text = [KDS_PublicMethod stringByAppendingPercent:value];
    color =[self getDrawColorWithCompare:self.klineDataSoure.minZDF.compare];
    rightlabel_KLineValue5_.textColor = color;
}

/**********绘制均线文字***************/
- (void)drawKLineMAText:(CGContextRef)ctx {
    stock_kline_data *kxData = kxData = [self getShowCrossLineKLineData];
 
    // 绘制MA5/MA10/MA30文字及对应值
    if ([KDS_SystemSetManager bSupportKLineMLineSet]) {
 
        //均线设置模型数组
        NSMutableArray *maLineSetArray = [KDS_SystemSetManager getMALineSetArray];
        //绘设置的线并设置ma的“:”后的内容
        CGFloat origin_x = kLineMARect_.origin.x + kTextInsetPad;
        CGFloat nPoint_X = origin_x;
        for (int i = 0; i < [maLineSetArray count]; i++) {
            
            KDS_MALineSetModel *model = [maLineSetArray objectAtIndex:i];
            NSString *klValue = model.MALineNum;
            // 设置界面该均线设置状态为开启
            if(model.isOpen) {
                if (i>=5) break;
                NSString * keyPath = [NSString stringWithFormat:@"cache_customMA%zd",i+1];
                NFloat *nfData = [kxData valueForKey:keyPath];
                if(nfData == nil) nfData = [NFloat zeroWithDigit:2];
        
                UIGraphicsPushContext(ctx);
                UIColor *color = self.klineDataSoure.array_colors[i];
                NSString *maValue;
                if (nPoint_X == origin_x) {
                    maValue = [NSString stringWithFormat:@"MA%@:",klValue];
                } else {
                    maValue = [NSString stringWithFormat:@"%@:",klValue];
                }
                NSString *maString = [maValue stringByAppendingString:[nfData toString]];
                CGContextSetFillColorWithColor(ctx, color.CGColor);
                [NSString kds_drawAtPoint:CGPointMake(nPoint_X, kLineMARect_.origin.y) withFont:_xFont withColor:color withString:maString];
                
                CGSize fontSize = [NSString kds_stringSize:maString withTextFont:_xFont];
                if (YT_KLineDirect_Ver == _KLineDirect) { // 竖屏
                    nPoint_X += fontSize.width + [self recalculateFloat:5];
                } else {
                    nPoint_X += fontSize.width + [self recalculateFloat:15];
                }
            }
        }
        
    } else {
        if(!kxData)return;
        UIGraphicsPushContext(ctx);
        NSString * ma5 = [@"MA5:" stringByAppendingString:[kxData.MA1 toString]];
        NSString * ma10 = [@"MA10:" stringByAppendingString:[kxData.MA2 toString]];
        NSString * ma30 = [@"MA30:" stringByAppendingString:[kxData.MA3 toString]];
        [self _drawTextsHor:@[ma5,ma10,ma30] useColors:self.klineDataSoure.array_colors font:_xFont atPoint:CGPointMake(kLineMARect_.origin.x + kTextInsetPad, kLineMARect_.origin.y) itemMarget:5 context:ctx];
    }
}


- (void)drawCrossLine:(CGContextRef)ctx {
    
    UIColor *color = skinColor(@"FSKLine_Color_FSHorCrossLine");
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    CGContextSetLineWidth(ctx, 1);

    // 横线
    if (fCrossIndexYPos_>=kLineChartRect_.origin.y&&fCrossIndexYPos_<=CGRectGetMaxY(kLineChartRect_)) {
        CGContextMoveToPoint(ctx, kLineChartRect_.origin.x, fCrossIndexYPos_);
        CGContextAddLineToPoint(ctx, kLineChartRect_.origin.x+kLineChartRect_.size.width, fCrossIndexYPos_);
        CGContextStrokePath(ctx);
        
        // 左侧收盘价
        CGFloat fMaxPrice = self.klineDataSoure.maxPrice->fValue;
        CGFloat fMinPrice = self.klineDataSoure.minPrice->fValue;
        CGFloat percent = (fCrossIndexYPos_-kTop_Pading) / kLineChartRect_.size.height;
        CGFloat value = fMaxPrice - (fMaxPrice-fMinPrice)*percent;
        //        UIColor *textColor = [KDS_PublicMethod getColorWithValueString:[NSString stringWithFormat:@"%lf", value]];
        CGRect labelFrame = CGRectMake(2, fCrossIndexYPos_ - 7.5, kLeft_Pading-2, 15);
        [label_CrossLineLeft setFrame:labelFrame];
        label_CrossLineLeft.text = [NSString stringWithFormat:@"%.2lf", value];
        //        label_CrossLineLeft.textColor = textColor;
        label_CrossLineLeft = (UILabel *)[UIView kds_setCornerRadius:2 withBorderColor:color WithView:label_CrossLineLeft];
        label_CrossLineLeft.hidden = NO;
        // 右侧涨跌
        labelFrame.origin.x = kLineChartRect_.size.width+kLineChartRect_.origin.x;
        [label_CrossLineRight setFrame:labelFrame];
        CGFloat fMaxZDF = self.klineDataSoure.maxZDF->fValue;
        CGFloat fMinZDF = self.klineDataSoure.minZDF->fValue;
        value = (fMaxZDF - (fMaxZDF - fMinZDF)*percent)*100;
        UIColor *textColor = [KDS_PublicMethod getColorWithValueString:[NSString stringWithFormat:@"%lf", value]];
        label_CrossLineRight.text = [NSString stringWithFormat:@"%.2lf%%", value];
        label_CrossLineRight.textColor = textColor;
        label_CrossLineLeft.textColor = textColor;
        label_CrossLineRight = (UILabel *)[UIView kds_setCornerRadius:2 withBorderColor:color WithView:label_CrossLineRight];
        label_CrossLineRight.hidden = NO;
        
    }else{
        label_CrossLineLeft.hidden = YES;
        label_CrossLineRight.hidden = YES;
    }

    // 竖线
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, fCrossIndexXPos_, kLineChartRect_.origin.y);
    CGContextAddLineToPoint(ctx, fCrossIndexXPos_, kLineChartRect_.origin.y + kLineChartRect_.size.height + volChartRect_.size.height + fuQuanButtonRect_.size.height);
    CGContextStrokePath(ctx);
}

#pragma mark 绘制复权(中间部分)
- (void)drawFuQuan:(CGContextRef)ctx {
    // 绘制时间
    float x = 0;
    float y = fuQuanButtonRect_.origin.y + kTextInsetPad;
    //开始时间
    stock_kline_data *techData = nil;
    techData = [self.klineRep.klineDataArrArray objectAtIndex:pos_];
    NSMutableString *strTimeBegin = [NSMutableString stringWithFormat:@"%d", techData.nDate];
    //结束时间
    NSInteger endIndex = pos_+[self maxNumberOfShow];
    BOOL needAjustEndTime = NO;
    if(nKLineCount_  < (pos_ + [self maxNumberOfShow])) {
        //绘制结束时间时，需要考虑绘制的时间的位置，k线可能没有铺满格子的时候
        endIndex = nKLineCount_;
        needAjustEndTime = YES;
    }
    techData = [self.klineRep.klineDataArrArray objectAtIndex:endIndex-1];
    NSMutableString * strTimeEnd = [NSMutableString stringWithFormat:@"%d", techData.nDate];
    CGFloat strTimeEndTextW = [NSString kds_stringSize:strTimeEnd withTextFont:_xFont].width;
    CGFloat max_x = volChartRect_.origin.x + volChartRect_.size.width - strTimeEndTextW - kTextInsetPad;
    
    //添加设置按钮(可设置自定义均线、复权)
    if ([self shouldShowSettingButton]) {
        CGFloat buttonWidth = 28.0f;//25
        CGFloat buttonHeight = 18.0f;//14
        x = max_x - (buttonWidth + 5);
        [self.FQSeletcButton setFrame:CGRectMake(max_x - (buttonWidth + 5), y, buttonWidth, buttonHeight)];
        self.FQSeletcButton.hidden = NO;
    }else{
        self.FQSeletcButton.hidden = YES;
    }
    
    UIColor *timeColor = [UIColor ytColor_10];
    //绘制开始时间
    UIGraphicsPushContext(ctx);
    x = volChartRect_.origin.x +kTextInsetPad ;
    [NSString kds_drawAtPoint:CGPointMake(x, y) withFont:_xFont withColor:timeColor withString:strTimeBegin];
    //绘制结束时间
    if(needAjustEndTime) {
        x = volChartRect_.origin.x + endIndex * [self getItemWidth]- strTimeEndTextW/2;
        CGFloat min_x = volChartRect_.origin.x +kTextInsetPad +[NSString kds_stringSize:strTimeBegin withTextFont:_xFont].width +kTextInsetPad;
        x = MAX(min_x, x);
        x = MIN(max_x, x);
        if (self.FQSeletcButton.hidden==NO&&x>=self.FQSeletcButton.left&&x<=self.FQSeletcButton.right) {
            x = max_x;
        }
    }else{
        x = max_x;
    }
    [NSString kds_drawAtPoint:CGPointMake(x, y) withFont:_xFont withColor:timeColor withString:strTimeEnd];
}

#pragma mark 绘制成交量与指标
- (void)drawVol:(CGContextRef)ctx {
//    // 绘制成交量柱状图
    YT_BarChartDrawer * barDrawer =   [self getVolBarChartDrawer];
    barDrawer.maxValueOfTop = self.klineDataSoure.maxCJL;
    [barDrawer drawKlinDataArr:self.klineDataSoure.klineRep.klineDataArrArray inContext:ctx];
    
    // 绘制成交量均线
    YT_LineChartLine * line = [self makeLineStrokColor:_maColorArr[0] data:self.klineDataSoure.array_TechMA1];
    YT_LineChartLine * line2 = [self makeLineStrokColor:_maColorArr[1] data:self.klineDataSoure.array_TechMA2];

    YT_LineChartDrawer * drawer = [self getVolLineChartDrawer];
    drawer.maxValueOfTop =self.klineDataSoure.maxCJL;
    drawer.minValueOfBottom = [NFloat zero];
    drawer.lines = [@[line,line2] mutableCopy];
    drawer.nPos = 0;
    [drawer calculatePame];
    [drawer drawInContext:ctx];
    
   // 其他(名、左右y轴值、时间)
   [self _drawVolChartTitle:@"VOL(5,10)" context:ctx];
    
    // 设置成交量Y轴数据
    label_VOLValue1_.text = [self.klineDataSoure.maxCJL toString];
    label_VOLValue2_.text = @"0";
    
    if (bShowCrossLine_) {
        stock_kline_data *kxData = [self getShowCrossLineKLineData];
        if(kxData == nil)return;
    
        NFloat *fTech1;
        NFloat *fTech2;
        NFloat *fTech3;
        for (NSInteger i = 0; i < kxData.nTechArray_Count; i++) {
            if (0 == i) {
                fTech2 = (NFloat *)[kxData.fTechArray objectAtIndex:i];
            } else if (1 == i) {
                fTech3 = (NFloat *)[kxData.fTechArray objectAtIndex:i];
            }
        }
        // 取当天的成交量为读取数值，暂时屏蔽之前的数据
        fTech1 = [NFloat initWithValue:kxData.nCjss];
//        UIGraphicsPushContext(ctx);
        NSMutableArray * strings  = [NSMutableArray array];
        NSString *tmp;
        if (![[fTech1 toString] isEqualToString:kNullStr]) {
            if (_bIsHK){
                tmp = [NSString stringWithFormat:@"%@%@",[fTech1 toString],getString(@"HQ_GGXQ_Unit_Gu")];
            } else {
                tmp = [NSString stringWithFormat:@"%@%@",[fTech1 toString],getString(@"HQ_GGXQ_Unit_Shou")];
            }
        }
        [strings addObject:tmp];
        tmp = [@"MAVOL5:" stringByAppendingString:[fTech2 toString]];[strings addObject:tmp];
        tmp = [@"MAVOL10:" stringByAppendingString:[fTech3 toString]];[strings addObject:tmp];
        NSArray * colors=  @[[UIColor blackColor],_maColorArr[0],_maColorArr[1]];
        [self _drawTextsHor:strings useColors:colors font:_yFont atPoint:volChartRect_.origin itemMarget:5 context:ctx];
    }
}

/**
 *
 *  华龙小金没有的指标：DMI、RSI、SAR、BOLL
 *  华龙小金多余的指标：DMA、VR、CR（以后如果有添加可以参考）
 *  可以参考华龙小金绘制的指标：VOL(完成)、MACD、WR、KDJ、OBV
 *
 */
- (void)drawMACD:(CGContextRef)ctx {
    
    // 绘制成交量均线
    YT_LineChartLine * line = [self makeLineStrokColor:_maColorArr[0] data:self.klineRep.klineDataArrArray];
    line.drawStrategy = kLineChartDrawStrategyDrawAll;
    @weakify(self)
    [line setParseLineDataBlock:^NFloat *(YT_LineChartLine *line, NSInteger index) {
        stock_kline_data *techData = [weak_self.klineRep.klineDataArrArray objectAtIndex:index];
        return techData.cache_DIF;
    }];
    YT_LineChartLine * line2 = [self makeLineStrokColor:_maColorArr[1] data:nil];
    line2.drawStrategy = kLineChartDrawStrategyDrawAll;
    [line2 setParseLineDataBlock:^NFloat *(YT_LineChartLine *line, NSInteger index) {
        stock_kline_data *techData = [weak_self.klineRep.klineDataArrArray objectAtIndex:index];
        return techData.cache_DEA;
    }];
    YT_LineChartLine * line3 = [self makeLineStrokColor:_maColorArr[2] data:nil];
    line3.lineType = kLineChartLayerLineTypeGird;
    [line3 setParseLineDataBlock:^NFloat *(YT_LineChartLine *line, NSInteger index) {
        stock_kline_data *techData = [weak_self.klineRep.klineDataArrArray objectAtIndex:index];
        return techData.cache_MACD;
    }];
    
    YT_LineChartDrawer * drawer = [self getVolLineChartDrawer];
    drawer.lines = [@[line,line2,line3] mutableCopy];
    [drawer calculatePame];
    [drawer drawInContext:ctx];
    
    // 其他(名、左右y轴值、时间)
    [self _drawVolChartTitle:@"MACD(12,26,9)" context:ctx];
    
    // 设置成交量Y轴数据
    label_VOLValue1_.text = [self.klineDataSoure.maxTech toString];
    label_VOLValue2_.text = [self.klineDataSoure.minTech toString];
    
    if (bShowCrossLine_) {
        stock_kline_data *kxData = [self getShowCrossLineKLineData];
        if(kxData == nil)  return;
        NFloat *fTech1 = kxData.cache_DIF;
        NFloat *fTech2 = kxData.cache_DEA;
        NFloat *fTech3 = kxData.cache_MACD;
        
//        UIGraphicsPushContext(ctx);
        NSMutableArray * strings  = [NSMutableArray array];
        NSString *tmp = [@"DIF:" stringByAppendingString:[fTech1 toString]];[strings addObject:tmp];
        tmp = [@"DEA:" stringByAppendingString:[fTech2 toString]];[strings addObject:tmp];
        tmp = [@"MACD:" stringByAppendingString:[fTech3 toString]];[strings addObject:tmp];
//        NSArray * colors=  @[_maColorArr[0],_maColorArr[1],_maColorArr[2]];
        [self _drawTextsHor:strings useColors:_maColorArr font:_yFont atPoint:volChartRect_.origin itemMarget:5 context:ctx];
    }

}

- (void)drawDMI:(CGContextRef)ctx {
    NSLog(@"DMI");
    [self drawVol:ctx];
    
    // 计算技术指标
    // 绘制技术指标线
    // 其他(名、左右y轴值、时间)
}

- (void)drawWR:(CGContextRef)ctx {
    
    // 绘制线
    YT_LineChartLine * line = [self makeLineStrokColor:_maColorArr[0] data:self.klineRep.klineDataArrArray];
    line.drawStrategy = kLineChartDrawStrategyIgnorePreZero;
    @weakify(self)
    [line setParseLineDataBlock:^NFloat *(YT_LineChartLine *line, NSInteger index) {
        stock_kline_data *techData = [weak_self.klineRep.klineDataArrArray objectAtIndex:index];
        return techData.cache_WR10;
    }];
    YT_LineChartLine * line2 = [self makeLineStrokColor:_maColorArr[1] data:nil];
    line2.drawStrategy = kLineChartDrawStrategyIgnorePreZero;
    [line2 setParseLineDataBlock:^NFloat *(YT_LineChartLine *line, NSInteger index) {
        stock_kline_data *techData = [weak_self.klineRep.klineDataArrArray objectAtIndex:index];
        return techData.cache_WR6;
    }];
    
    YT_LineChartDrawer * drawer = [self getVolLineChartDrawer];
    drawer.lines = [@[line,line2] mutableCopy];
    [drawer calculatePame];
    [drawer drawInContext:ctx];
    
    // 其他(名、左右y轴值、时间)
    [self _drawVolChartTitle:@"WR(10,6)" context:ctx];
    // 设置Y轴数据
    label_VOLValue1_.text = [self.klineDataSoure.maxTech toString];
    label_VOLValue2_.text = [self.klineDataSoure.minTech toString];
    if (bShowCrossLine_) {
        stock_kline_data *kxData = [self getShowCrossLineKLineData];
        if(kxData == nil) return;
        NFloat *fTech1 = kxData.cache_WR10;
        NFloat *fTech2 = kxData.cache_WR6;

        NSMutableArray * strings  = [NSMutableArray array];
        NSMutableArray * colors = [NSMutableArray array];
        if (fTech1) {
            NSString *tmp = [@"WR1:" stringByAppendingString:[fTech1 toString]];[strings addObject:tmp];
            [colors addObject:_maColorArr[0]];
        }
        if (fTech2) {
            NSString *tmp = [@"WR2:" stringByAppendingString:[fTech2 toString]];[strings addObject:tmp];
            [colors addObject:_maColorArr[1]];
        }
        [self _drawTextsHor:strings useColors:colors font:_yFont atPoint:volChartRect_.origin itemMarget:5 context:ctx];
    }
    
}

- (void)drawBOLL:(CGContextRef)ctx {
    // 计算技术指标
//    [self calculateTechValueFromIndex:0 toIndex:nKLineCount_ - 1];
    NSInteger i = 0;
    CGFloat fHeight = volChartRect_.size.height;
    CGFloat fItemWidth = [self getItemWidth];
    CGFloat fItemHalfWidth = fItemWidth / 2;
    CGFloat fBottom = volChartRect_.size.height + volChartRect_.origin.y;
    CGFloat newx;
    CGFloat newd, newg, newo, newc;   //最低价、最高价、开盘价、收盘价的y坐标
    
    CGFloat fPrice = self.klineDataSoure.maxTech->fValue - self.klineDataSoure.minTech->fValue;
    stock_kline_data *kxData = nil;
    
    NSInteger end = YT_KLineView_SHOWENDINDEX;
    // 绘制美国线 BOLL
    for (i=pos_; i<end; i++) {
  
        kxData = [self.klineRep.klineDataArrArray objectAtIndex:i];
        
        NFloat *fZdcj = kxData.fZdcj;
        NFloat *fZgcj = kxData.fZgcj;
        NFloat *fOpen = kxData.fOpen;
        NFloat *fClose = kxData.fClose;
        
        newx = volChartRect_.origin.x + fItemWidth *(i - pos_);
        if (0.0f == fPrice) {
            newd = 0;
            newg = 0;
            newo = 0;
            newc = 0;
        } else {
            newd = fBottom - (fZdcj->fValue - self.klineDataSoure.minTech->fValue) * fHeight / fPrice;
            newg = fBottom - (fZgcj->fValue - self.klineDataSoure.minTech->fValue) * fHeight / fPrice;
            newo = fBottom - (fOpen->fValue - self.klineDataSoure.minTech->fValue) * fHeight / fPrice;
            newc = fBottom - (fClose->fValue - self.klineDataSoure.minTech->fValue) * fHeight / fPrice;
        }
        
        UIColor *color;
        if ([NFloat compare:fClose :fOpen] >= 0) {
            // 不涨跌默认红色
            color = _upTextColor;
        }else{
            color = _downTextColor;
        }
        CGContextBeginPath(ctx);
        CGContextSetStrokeColorWithColor(ctx, color.CGColor);   //设置边框色
        CGContextSetFillColorWithColor(ctx, color.CGColor);     //设置填充色
        
        // BOLL美国线
        //绿线
        //收盘价到中线
        CGContextMoveToPoint(ctx, newx + fItemHalfWidth, newc);
        CGContextAddLineToPoint(ctx, newx + fItemWidth, newc);
        //开盘价到中线
        CGContextMoveToPoint(ctx, newx + fItemHalfWidth, newo);
        CGContextAddLineToPoint(ctx, newx, newo);
        //最高到最低连线
        CGContextMoveToPoint(ctx, newx + fItemHalfWidth, newd);
        CGContextAddLineToPoint(ctx, newx + fItemHalfWidth, newg);
        CGContextStrokePath(ctx);
    }
    
    // 绘制技术指标线
    YT_LineChartDrawer * drawer = [self getVolLineChartDrawer];
    drawer.lines = [self getLinesColor:_maColorArr drawStrategy:kLineChartDrawStrategyDrawAll keyPath:@"cache_BOLL_Mid",@"cache_BOLL_Upper",@"cache_BOLL_Lower", nil];
    [drawer calculatePame];
    [drawer drawInContext:ctx];
    
    // 其他(名、左右y轴值、时间)
    [self _drawVolChartTitle:@"BOLL(20,2)" context:ctx];
    if (!bShowCrossLine_)  {
        stock_kline_data *kData = [self getShowCrossLineKLineData];
        if(kData == nil)return;
        NFloat *fTech1 = kData.cache_BOLL_Mid;
        NFloat *fTech2 = kData.cache_BOLL_Upper;
        NFloat *fTech3 = kData.cache_BOLL_Lower;
        NSMutableArray * strings  = [NSMutableArray array];
        if(fTech1){
             NSString *tmp = [@"MID:" stringByAppendingString:[fTech1 toString]];[strings addObject:tmp];
              tmp = [@"UPP:" stringByAppendingString:[fTech2 toString]];[strings addObject:tmp];
              tmp = [@"LOW:" stringByAppendingString:[fTech3 toString]];[strings addObject:tmp];
        }
        NSArray * colors=  @[_maColorArr[0],_maColorArr[1]];
        [self _drawTextsHor:strings useColors:colors font:_yFont atPoint:volChartRect_.origin itemMarget:5 context:ctx];
    }
    
    // 设置成交量Y轴数据
    label_VOLValue1_.text = [self.klineDataSoure.maxTech toString];
    label_VOLValue2_.text = [self.klineDataSoure.minTech toString];
}

- (void)drawKDJ:(CGContextRef)ctx {
    // 计算技术指标
//    [self calculateTechValueFromIndex:0 toIndex:nKLineCount_ - 1];
    // 绘制技术指标线
    YT_LineChartDrawer * drawer = [self getVolLineChartDrawer];
    drawer.lines = [self getLinesColor:_maColorArr drawStrategy:kLineChartDrawStrategyDrawAll keyPath:@"cache_K",@"cache_D",@"cache_J", nil];
    [drawer calculatePame];
    [drawer drawInContext:ctx];
    
    // 其他(名、左右y轴值、时间)
    [self _drawVolChartTitle:@"KDJ(9,3,3)" context:ctx];
    // 设置成交量Y轴数据
    label_VOLValue1_.text = [self.klineDataSoure.maxTech toString];
    label_VOLValue2_.text = [self.klineDataSoure.minTech toString];
    
    if (bShowCrossLine_) {
        stock_kline_data *kxData = [self getShowCrossLineKLineData];
        if(kxData == nil) return;
        NFloat *fTech1 = kxData.cache_K;
        NFloat *fTech2 = kxData.cache_D;
        NFloat *fTech3 = kxData.cache_J;
       
        NSMutableArray * strings  = [NSMutableArray array];
        NSString *tmp = [@"K:" stringByAppendingString:[fTech1 toString]];[strings addObject:tmp];
        tmp = [@"D:" stringByAppendingString:[fTech2 toString]];[strings addObject:tmp];
        tmp = [@"J:" stringByAppendingString:[fTech3 toString]];[strings addObject:tmp];
        [self _drawTextsHor:strings useColors:_maColorArr font:_yFont atPoint:volChartRect_.origin itemMarget:5 context:ctx];
        [self _drawTextsHor:strings useColors:_maColorArr font:_yFont atPoint:volChartRect_.origin itemMarget:5 context:ctx];
    }
}

- (void)drawOBV:(CGContextRef)ctx {
    
    // 绘制技术指标线
    YT_LineChartDrawer * drawer = [self getVolLineChartDrawer];
    drawer.lines = [self getLinesColor:_maColorArr drawStrategy:kLineChartDrawStrategyDrawAll keyPath:@"cache_OBV",@"cache_OBV_MA30",nil];
    [drawer calculatePame];
    [drawer drawInContext:ctx];
    
    // 其他(名、左右y轴值、时间)
    [self _drawVolChartTitle:@"OBV(30)" context:ctx];
    // 设置成交量Y轴数据
    label_VOLValue1_.text = [self.klineDataSoure.maxTech toString];
    label_VOLValue2_.text = [self.klineDataSoure.minTech toString];
    
    if (bShowCrossLine_) {
        stock_kline_data *kxData = [self getShowCrossLineKLineData];
        if(kxData == nil) return;
        NFloat *fTech1 = kxData.cache_OBV;
        NFloat *fTech2 = kxData.cache_OBV_MA30;
        
        NSMutableArray * strings  = [NSMutableArray array];
        NSString *tmp = [@"OBV:" stringByAppendingString:[fTech1 toString]];[strings addObject:tmp];
        if(fTech2){
          tmp = [@"MOBV:" stringByAppendingString:[fTech2 toString]];[strings addObject:tmp];
        }
        [self _drawTextsHor:strings useColors:_maColorArr font:_yFont atPoint:volChartRect_.origin itemMarget:5 context:ctx];
    }
}

- (void)drawRSI:(CGContextRef)ctx {
    // 计算技术指标
//    [self calculateTechValueFromIndex:0 toIndex:nKLineCount_ - 1];
    // 绘制技术指标线
    YT_LineChartDrawer * drawer = [self getVolLineChartDrawer];
    drawer.lines = [self getLinesColor:_maColorArr drawStrategy:kLineChartDrawStrategyDrawAll keyPath:@"cache_RSI6",@"cache_RSI12",@"cache_RSI24", nil];
    [drawer calculatePame];
    [drawer drawInContext:ctx];
    
    // 其他(名、左右y轴值、时间)
     [self _drawVolChartTitle:@"RSI(6,12,24)" context:ctx];
    
    if (bShowCrossLine_) {
        stock_kline_data *kxData = [self getShowCrossLineKLineData];
        if(kxData == nil)return;
        NSMutableArray * strings  = [NSMutableArray array];NSString *tmp;
        tmp = [self string:@"RSI1:" append:kxData.cache_RSI6];[strings addObject:tmp];
        tmp = [self string:@"RSI2:" append:kxData.cache_RSI12];[strings addObject:tmp];
        tmp = [self string:@"RSI3:" append:kxData.cache_RSI24];[strings addObject:tmp];
        [self _drawTextsHor:strings useColors:_maColorArr font:_yFont atPoint:volChartRect_.origin itemMarget:5 context:ctx];
    }
    
    // 设置成交量Y轴数据
    label_VOLValue1_.text = [self.klineDataSoure.maxTech toString];
    label_VOLValue2_.text = [self.klineDataSoure.minTech toString];
}

- (void)drawSAR:(CGContextRef)ctx {
    NSLog(@"SAR");
    [self drawVol:ctx];
    
    // 计算技术指标
    // 绘制技术指标线
    // 其他(名、左右y轴值、时间)
}

- (void)drawDMA:(CGContextRef)ctx {
    
//    [self calculateTechValueFromIndex:0 toIndex:nKLineCount_ - 1];
    
    // 绘制技术指标线
    YT_LineChartLine * line = [self makeLineStrokColor:_maColorArr[0] data:self.klineRep.klineDataArrArray];
    line.drawStrategy = kLineChartDrawStrategyDrawAll;
    @weakify(self)
    [line setParseLineDataBlock:^NFloat *(YT_LineChartLine *line, NSInteger index) {
        stock_kline_data *techData = [weak_self.klineRep.klineDataArrArray objectAtIndex:index];
        return techData.cache_DMA;
    }];
    YT_LineChartLine * line2 = [self makeLineStrokColor:_maColorArr[1] data:nil];
    line2.drawStrategy = kLineChartDrawStrategyDrawAll;
    [line2 setParseLineDataBlock:^NFloat *(YT_LineChartLine *line, NSInteger index) {
        stock_kline_data *techData = [weak_self.klineRep.klineDataArrArray objectAtIndex:index];
        return techData.cache_DMA_MA10;
    }];
    YT_LineChartDrawer * drawer = [self getVolLineChartDrawer];
    drawer.lines = [@[line,line2] mutableCopy];
    [drawer calculatePame];
    [drawer drawInContext:ctx];

    // 其他(名、左右y轴值、时间)
    [self _drawVolChartTitle:@"DMA(10,50,10)" context:ctx];
    // 设置成交量Y轴数据
    label_VOLValue1_.text = [self.klineDataSoure.maxTech toString];
    label_VOLValue2_.text = [self.klineDataSoure.minTech toString];
    
    if (bShowCrossLine_) {
        stock_kline_data *kxData = [self getShowCrossLineKLineData];
        if(kxData == nil)
            return;
        NFloat *fTech1= kxData.cache_DMA;
        NFloat *fTech2 = kxData.cache_DMA_MA10;
        NSString *tmp;
        NSMutableArray * strings  = [NSMutableArray array];
        NSMutableArray * colors = [NSMutableArray array];
        tmp = [self string:@"DIF:" append:fTech1];
        if(tmp){
            [strings addObject:tmp];
            [colors addObject:_maColorArr[0]];
        }
        tmp = [self string:@"DIFMA:" append:fTech2];
        if(tmp){
            [strings addObject:tmp];
            [colors addObject:_maColorArr[1]];
        }
        [self _drawTextsHor:strings useColors:colors font:_yFont atPoint:volChartRect_.origin itemMarget:5 context:ctx];
    }

}

//TODO::有疑问
- (void)drawVR:(CGContextRef)ctx {
    
    // 绘制成交量均线
    YT_LineChartLine * line = [self makeLineStrokColor:_maColorArr[0] data:self.klineRep.klineDataArrArray];
    @weakify(self)
    [line setParseLineDataBlock:^NFloat *(YT_LineChartLine *line, NSInteger index) {
        stock_kline_data *techData = [weak_self.klineRep.klineDataArrArray objectAtIndex:index];
        return techData.cache_VR;
    }];
    YT_LineChartLine * line2 = [self makeLineStrokColor:_maColorArr[1] data:nil];
    [line2 setParseLineDataBlock:^NFloat *(YT_LineChartLine *line, NSInteger index) {
        stock_kline_data *techData = [weak_self.klineRep.klineDataArrArray objectAtIndex:index];
        return techData.cache_VR_MA6;
    }];
    
    YT_LineChartDrawer * drawer = [self getVolLineChartDrawer];
    drawer.lines = [@[line,line2] mutableCopy];
    [drawer calculatePame];
    [drawer drawInContext:ctx];
    
    // 其他(名、左右y轴值、时间)
    [self _drawVolChartTitle:@"VR(26,6)" context:ctx];
    // 设置成交量Y轴数据
    label_VOLValue1_.text = [self.klineDataSoure.maxTech toString];
    label_VOLValue2_.text = [self.klineDataSoure.minTech toString];
    
    if (bShowCrossLine_){
        stock_kline_data *kxData = [self getShowCrossLineKLineData];
        if(kxData == nil)return;
        NFloat *fTech1 = kxData.cache_VR;
        NFloat *fTech2 = kxData.cache_VR_MA6;
        NSMutableArray * strings  = [NSMutableArray array];
        NSString *tmp = [NSString stringWithFormat:@"VR:%0.2f",fTech1->fValue];[strings addObject:tmp];
        if(fTech2){
            tmp = [NSString stringWithFormat:@"MAVR:%0.2f",fTech2->fValue];[strings addObject:tmp];
        }
        NSArray * colors=  @[_maColorArr[0],_maColorArr[1]];
        [self _drawTextsHor:strings useColors:colors font:_yFont atPoint:volChartRect_.origin itemMarget:5 context:ctx];
    
    }

}

//TODO::有疑问
- (void)drawCR:(CGContextRef)ctx {
    // 绘制技术指标线
    YT_LineChartDrawer * drawer = [self getVolLineChartDrawer];
    drawer.lines = [self getLinesColor:_maColorArr drawStrategy:kLineChartDrawStrategyDrawAll keyPath:@"cache_CR",@"cache_CR_MA1",@"cache_CR_MA2", nil];
    [drawer calculatePame];
    [drawer drawInContext:ctx];
    
    // 其他(名、左右y轴值、时间)
    [self _drawVolChartTitle:@"CR(26,10,20)" context:ctx];
//    [self _drawVolChartTitle:@"CR(26,10,20,40,62)" context:ctx];
    // 设置成交量Y轴数据
    label_VOLValue1_.text = [self.klineDataSoure.maxTech toString];
    label_VOLValue2_.text = [self.klineDataSoure.minTech toString];
    
    if (bShowCrossLine_) {
        stock_kline_data *kxData = [self getShowCrossLineKLineData];
        if(kxData == nil)return;
        NSMutableArray * strings  = [NSMutableArray array];NSString *tmp;
        tmp = [self string:@"CR:" append:kxData.cache_CR];[strings addObject:tmp];
        if(kxData.cache_CR_MA1){tmp = [self string:@"MA1:" append:kxData.cache_CR_MA1];[strings addObject:tmp];}
        if(kxData.cache_CR_MA2){tmp = [self string:@"MA2:" append:kxData.cache_CR_MA2];[strings addObject:tmp];}
        [self _drawTextsHor:strings useColors:_maColorArr font:_yFont atPoint:volChartRect_.origin itemMarget:5 context:ctx];
    }
}

#pragma mark - drawTool

/**
 绘制成交栏区域标题
 @param string 标题字符串
 */
-(void)_drawVolChartTitle:(NSString *)string context:(CGContextRef)ctx{
    UIColor * textColor = _normalTextColor;
    UIFont  * textFont = _yFont;
    CGPoint drawPoint = volChartRect_.origin;
    drawPoint.x += kTextInsetPad;
    drawPoint.y =  drawPoint.y - textFont.lineHeight - kTextInsetPad/2;
    CGContextSetStrokeColorWithColor(ctx, textColor.CGColor);
    [NSString kds_drawAtPoint:drawPoint withFont:textFont withColor:textColor withString:string];
}

/**
 绘制水平方向文字数组
 @param strings 标题字符串数组
 */
-(void)_drawTextsHor:(NSArray<NSString *> *)strings useColors:(NSArray<UIColor *> *)colors font:(UIFont*)font atPoint:(CGPoint)point itemMarget:(CGFloat)margin context:(CGContextRef)ctx{
    NSInteger count = MIN(strings.count, colors.count);
    for (int i = 0 ; i<count; i++) {
        UIColor * color = colors[i];
        NSString *tmp  = strings[i];
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        [NSString kds_drawAtPoint:point withFont:font withColor:color withString:tmp];
        CGFloat offset = [NSString kds_stringSize:tmp withTextFont:font].width + margin;
        point.x += offset;
//        point =  CGContextGetPathCurrentPoint(ctx);
//        point.x +=margin;
    }
}

-(NSString *)string:(NSString *)pre append:(NFloat*)value{
    if (value) {
        return  [pre stringByAppendingString:[value toString]];
    }
    return nil;
}

-(YT_BarChartDrawer *)getVolBarChartDrawer{
    if (!vorBarChartDrawer_) {
        vorBarChartDrawer_ = [[YT_BarChartDrawer alloc]init];
        vorBarChartDrawer_.drawRect = volChartRect_;
    }
    vorBarChartDrawer_.itemWidth = [self getItemWidth];
    vorBarChartDrawer_.maxNumberOfShowing = [self maxNumberOfShow];
    vorBarChartDrawer_.nPos = pos_;
    return vorBarChartDrawer_;
}

-(YT_LineChartDrawer*)getVolLineChartDrawer{
    if (!vorLineChartDrawer_) {
        vorLineChartDrawer_ = [[YT_LineChartDrawer alloc]init];
        vorLineChartDrawer_.drawRect = volChartRect_;
    }
    vorLineChartDrawer_.xAxisWidth = [self getItemWidth];
    vorLineChartDrawer_.maxShowCount = [self maxNumberOfShow];
    vorLineChartDrawer_.nPos = pos_;
    vorLineChartDrawer_.maxValueOfTop =self.klineDataSoure.maxTech;
    vorLineChartDrawer_.minValueOfBottom = self.klineDataSoure.minTech;
    return vorLineChartDrawer_;
}

-(YT_LineChartDrawer*)getKLineChartDrawer{
    if (!kLineChartDrawer_) {
        kLineChartDrawer_ = [[YT_LineChartDrawer alloc]init];
        kLineChartDrawer_.drawRect = kLineChartRect_;
    }
    kLineChartDrawer_.xAxisWidth = [self getItemWidth];
    kLineChartDrawer_.maxShowCount = [self maxNumberOfShow];
    kLineChartDrawer_.dataCount = self.klineDataSoure.klineRep.klineDataArrArray.count;
    kLineChartDrawer_.nPos = pos_;
    kLineChartDrawer_.maxValueOfTop =self.klineDataSoure.maxPrice;
    kLineChartDrawer_.minValueOfBottom = self.klineDataSoure.minPrice;
    [kLineChartDrawer_ calculatePame];
    return kLineChartDrawer_;
}

-(YT_LineChartLine *)makeLineStrokColor:(UIColor *)color data:(NSArray*)data{
    YT_LineChartLine * line = [YT_LineChartLine new];
    line.strokColor = color;
    line.lineData = data;
    return line;
}

/*
-(NSMutableArray<YT_LineChartLine *> *)getLinesColors:(NSArray<UIColor*> *)colors drawStrategy:(YT_LineChartDrawStrategy)drawStrategy keyPaths:(NSArray<NSString*> *)keyPaths{
    NSInteger count = 0;
    if (colors.count<keyPaths.count) {
        count = colors.count;
    }else{
        count = keyPaths.count;
    }
    NSMutableArray *lineArray = [NSMutableArray array];
    for (NSInteger i = 0; i<count; i++) {
        @weakify(self)
        NSString * keyPath = keyPaths[i];
        UIColor * color = colors[i];
        YT_LineChartLine * line = [YT_LineChartLine lineChartLineColor:color drawStrategy:drawStrategy parseLineDataBlock:^NFloat *(YT_LineChartLine *line, NSInteger index) {
            stock_kline_data *techData = [weak_self.klineRep.klineDataArrArray objectAtIndex:index];
            return [techData valueForKeyPath:keyPath];
        }];
        line.lineData = self.klineRep.klineDataArrArray;
        [lineArray addObject:line];
    }
    return lineArray;
}
*/

#pragma mark getLinesWithKeyPath:
-(NSMutableArray<YT_LineChartLine *> *)getLinesColor:(NSArray<UIColor*> *)colors drawStrategy:(YT_LineChartDrawStrategy)drawStrategy keyPath:(NSString *)keyPath,...NS_REQUIRES_NIL_TERMINATION{
    NSMutableArray *lineArray = [[NSMutableArray alloc]init];
    if(keyPath){
         @weakify(self)
        YT_LineChartLine * line = [YT_LineChartLine lineChartLineColor:colors[0] drawStrategy:drawStrategy parseLineDataBlock:^NFloat *(YT_LineChartLine *line, NSInteger index) {
            stock_kline_data *techData = [weak_self.klineRep.klineDataArrArray objectAtIndex:index];
            return [techData valueForKeyPath:keyPath];
        }];
        line.lineData = self.klineRep.klineDataArrArray;
        [lineArray addObject:line];
        
        va_list params;
        va_start(params,keyPath);   //得到第一个可变参数地址
        NSString *arg;
        for (NSInteger i = 1; (arg = va_arg(params, NSString *))&&i<colors.count; i++) {
            @weakify(self)
             YT_LineChartLine * line = [YT_LineChartLine lineChartLineColor:colors[i] drawStrategy:drawStrategy parseLineDataBlock:^NFloat *(YT_LineChartLine *line, NSInteger index) {
                stock_kline_data *techData = [weak_self.klineRep.klineDataArrArray objectAtIndex:index];
                return [techData valueForKeyPath:arg];
            }];
            [lineArray addObject:line];
        }
        va_end(params);
    }
    return lineArray;
}

-(UIColor*)getDrawColorWithCompare:(NFloatCompare)compare{
    UIColor * color;
    if (compare==NFloatCompare_Plus) {
        color = _upTextColor;
    }else if (compare==NFloatCompare_Negative){
        color = _downTextColor;
    }else{
        color = _normalTextColor;
    }
    return color;
}

/**
 是否应该显示设置按钮
 */
-(BOOL)shouldShowSettingButton{
    //竖屏下，支持设置自定义均线，或者支持设置复权就要显示设置按钮
    return YT_KLineDirect_Ver == _KLineDirect&&([KDS_SystemSetManager bSupportKLineMLineSet]||[KDS_SystemSetManager bSupportFSKLineFQ]);
}

/**
 *  绘制均线/技术指标线
 */
- (void)drawChartLine:(NSMutableArray *)data
                     :(NSInteger)ndataSize
                     :(NSInteger)nPos
                     :(UIColor *)color
                     :(CGRect)drawRect
                     :(NFloat *)maxValueOfTop
                     :(NFloat *)minValueOfBottom
                     :(NSInteger)countOfWidth
                     :(NSInteger)lineType
                     :(CGContextRef)ctx {
    if (data == nil || [data count] == 0 || countOfWidth < 1)
        return;
    
    if ([NFloat compare:maxValueOfTop :minValueOfBottom] <= 0) {
        return;
    }
    
    CGFloat perX = [self getItemWidth];
    //    CGFloat nBaseY = 1000;
    CGFloat maxZf = [NFloat sub:maxValueOfTop :minValueOfBottom]->fValue;
    
    //    CGFloat perY;
    //    if (0.0f == maxZf) {
    //        perY = 0;
    //    } else {
    //        perY = drawRect.size.height * nBaseY / maxZf;
    //    }
    //    while (perY == 0) {
    //        nBaseY *= 100;
    //        perY = drawRect.size.height * nBaseY / maxZf;
    //    }
    CGContextSetLineWidth(ctx, 1.0f);
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextSetStrokeColorWithColor(ctx, color.CGColor);
    
    CGFloat oldX = drawRect.origin.x + perX/2;
    NFloat *floatData = [data objectAtIndex:nPos];;
    CGFloat oldY;
    if (0.0f == maxZf) {
        oldY = 0;
    } else {
        oldY = drawRect.origin.y + drawRect.size.height - [NFloat sub:floatData :minValueOfBottom]->fValue * drawRect.size.height / maxZf;
    }
    
    CGFloat newX = 0, newY = 0, bottomY = 0;
    
    NSInteger nDataSize = ndataSize;
    NSInteger i = 0;
    for (i = 0; i < nDataSize && i < countOfWidth; i++) {
        if (i >= ([data count] - nPos) || ndataSize <= i+nPos) {  //加入此判断 zl
            continue;
        }
        floatData = [data objectAtIndex:i+nPos];
        newX = drawRect.origin.x + perX/2 + perX * i;
        if (0.0f == maxZf) {
            newY = 0;
        } else {
            newY = drawRect.origin.y + drawRect.size.height - [NFloat sub:floatData :minValueOfBottom]->fValue * drawRect.size.height / maxZf;
        }
        
        if (newX > drawRect.origin.x &&
            newX < (drawRect.origin.x + drawRect.size.width) &&
            newY > drawRect.origin.y &&
            newY < (drawRect.origin.y + drawRect.size.height)) {
            
            switch (lineType) {
                case 0:
                    if (oldX > drawRect.origin.x &&
                        oldX < (drawRect.origin.x + drawRect.size.width) &&
                        oldY > drawRect.origin.y &&
                        oldY < (drawRect.origin.y + drawRect.size.height)) {
                        
                        if (nPos < i + pos_) {
                            CGContextBeginPath(ctx);
                            CGContextMoveToPoint(ctx, oldX, oldY);
                            CGContextAddLineToPoint(ctx, newX, newY);
                            CGContextStrokePath(ctx);
                        }
                    }
                    break;
                    
                case 1:
                    if (0.0f == maxZf) {
                        bottomY = 0;
                    } else {
                        bottomY = drawRect.origin.y + drawRect.size.height - [NFloat sub:[NFloat zero] :minValueOfBottom]->fValue * drawRect.size.height / maxZf;
                    }
                    if (bottomY > newY) {
                        CGContextSetStrokeColorWithColor(ctx, kLineColor_Red.CGColor);
                    } else {
                        CGContextSetStrokeColorWithColor(ctx, kLineColor_Green.CGColor);
                    }
                    CGContextBeginPath(ctx);
                    CGContextMoveToPoint(ctx, newX, bottomY);
                    CGContextAddLineToPoint(ctx, newX, newY);
                    CGContextStrokePath(ctx);
                    break;
            }
            oldX = newX;
            oldY = newY;
        }
    }
}

#pragma mark - 计算函数
/**
 *  获取每个柱子的宽度
 */
- (CGFloat)getItemWidth {
    return itemWidth_;
}

/**
 *  获取界面能显示K线数量最大数
 */
- (NSInteger)maxNumberOfShow{
    if (self.klineRep.klineDataArrArray == nil) {
        return 0;
    }
    return floor(kLineChartRect_.size.width / [self getItemWidth]);
}

/**
 * 需要显示的K线数量
 */
-(NSInteger)numberOfShowing{
    return MAX(0,YT_KLineView_SHOWENDINDEX-pos_);
}

/*  获取十字线时选择的 K 线数据 */
- (stock_kline_data *)getShowCrossLineKLineData {
    stock_kline_data *kxData = nil;
    if(bShowCrossLine_ && nCrossIndex_ + pos_ < nKLineCount_) {
        kxData = [self.klineRep.klineDataArrArray objectAtIndex:nCrossIndex_+pos_];
    } else {
        kxData = [self.klineRep.klineDataArrArray lastObject];
    }
    return kxData;
}

#pragma mark - core

-(void)changePosAndResetAllIfNeed:(NSInteger)pos{
    pos_ = pos;
    [self.klineDataSoure changePosAndResetAllDataIfNeed:pos_];
    
    [zbLayer_ setNeedsDisplay];
    //    [zbLayer_ displayIfNeeded];
    [fuQuanLayer_ setNeedsDisplay];
    //    [fuQuanLayer_ displayIfNeeded];
    [kLineLayer_ setNeedsDisplay];
    //    [kLineLayer_ displayIfNeeded];
    [KLineMALayer_ setNeedsDisplay];
    
}

// 设置指标类型
- (void)setZhiBiaoType:(KDS_ZBType)zhiBiaoType {
    _zhiBiaoType = zhiBiaoType;
    self.klineDataSoure.zhiBiaoType = zhiBiaoType;
    [self.klineDataSoure calculateZhiBiao];
    [zbLayer_ setNeedsDisplay];
}

/**
 *  改变K线数据，重新绘制界面
 *
 *  @param klineRep
 */
- (void)setKlineRep:(stock_kline_rep *)klineRep {
    
    self.klineDataSoure.klineRep = klineRep;
    
    nKLineCount_ = klineRep.klineDataArrArray_Count;
    
    itemWidth_ = koriginItemWidth;
    
    // 需要显示的K线数量
    NSInteger numberOfShowing = [self maxNumberOfShow];
    self.klineDataSoure.klineNumberOfShowing = numberOfShowing;
    
    [self.klineDataSoure calculateInitParm];
    
    // 显示的数据的范围 使K线显示最新数据
    pos_ = YT_KLineView_MAXPOS;
    [self changePosAndResetAllIfNeed:pos_];
}

-(stock_kline_rep *)klineRep{
    return self.klineDataSoure.klineRep;
}

- (void)setKLineDirect:(YT_KLineDirect)KLineDirect {
    _KLineDirect = KLineDirect;
    
    if (YT_KLineDirect_Hor == _KLineDirect) {
        // 缩放手势
        UIPinchGestureRecognizer* pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
        [self addGestureRecognizer:pinchRecognizer];
        
        // 长按手势
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPressRecognizer.minimumPressDuration = 0.35;
        [self addGestureRecognizer:longPressRecognizer];
         shouldCrossLine_ = YES;//十字线总开关
        
        // 拖动手势
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        panRecognizer.minimumNumberOfTouches = 1;
        panRecognizer.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:panRecognizer];
        
    }
    
    [self layoutSubviews];
}

#pragma mark - 手势处理
/**
 *  处理缩放事件
 *
 *  @param sender 手势
 */
- (void)scale:(UIPinchGestureRecognizer *)sender {
    static CGFloat zeroScale = 0.0f;
    static CGFloat locPt_X = -1;
    static CGFloat beginItemWidth = 5.0f;
    if ([sender state] == UIGestureRecognizerStateBegan) {
        zeroScale = sqrtf([sender scale]) -1;
        locPt_X = [sender locationInView:self].x;
        beginItemWidth = itemWidth_;
    }
    else if ([sender state] == UIGestureRecognizerStateChanged&&locPt_X>0) {
        // 处理缩放
        CGFloat ges_s = sqrtf([sender scale]);
        CGFloat scale = ges_s - zeroScale;
        CGFloat itemWidth = beginItemWidth *scale;
        if (scale >= 1) {
            // 放大
            if (itemWidth>kMaxItemWidth) {
                zeroScale =  ges_s -  kMaxItemWidth/beginItemWidth;
                itemWidth = kMaxItemWidth;
            }
        }else {
            // 缩小
            if (itemWidth<kMinItemWidth) {
                zeroScale =  ges_s -  kMinItemWidth/beginItemWidth;
                itemWidth = kMinItemWidth;
            }
        }
        
        [self calculateParamAfterScaleAt:locPt_X resetItemWidth:itemWidth];
    }
    else if ([sender state] == UIGestureRecognizerStateEnded) {
        zeroScale = 0.0f;
    }
}

/**
 *  计算缩放
 */
- (void)calculateParamAfterScaleAt:(CGFloat)loc resetItemWidth:(CGFloat)itemWidth{
    if (loc>0) {
        CGFloat width = (loc - kLineChartRect_.origin.x);
        NSInteger itemNumber = width/itemWidth_;
        width = itemNumber * itemWidth_;//防止抖动，要保持一个点相对不动
        NSInteger  scaleCenterPos = itemNumber+pos_;
        itemNumber =width/itemWidth;
        itemWidth = width/itemNumber;//防止抖动，要保持一个点相对不动
        pos_ = scaleCenterPos - itemNumber;
    }
//    BOOL isBigger = itemWidth>=itemWidth_;
    itemWidth_ = itemWidth;
    // 需要显示的K线数量
    NSInteger numberOfShowing = [self maxNumberOfShow];
    self.klineDataSoure.klineNumberOfShowing = numberOfShowing;
//    if (isBigger) {//放大
//        放大要计算Y轴，还是要过changePosAndResetAllIfNeed
//        [zbLayer_ setNeedsDisplay];
//        [fuQuanLayer_ setNeedsDisplay];
//        [kLineLayer_ setNeedsDisplay];
//        [KLineMALayer_ setNeedsDisplay];
//    }else{
//    }
    pos_ = MAX(0, pos_);
    pos_ = MIN(pos_, YT_KLineView_MAXPOS);
    [self changePosAndResetAllIfNeed:pos_];
}


/**
 *  处理拖动事件
 *
 *  @param recognizer 手势
 */
- (void)pan:(UIPanGestureRecognizer *)recognizer {
    if (YT_KLineDirect_Ver == _KLineDirect) { // 竖屏
        
    } else {  // 横屏
        if (recognizer.state ==UIGestureRecognizerStateBegan) {
            CGPoint translation = [recognizer translationInView:self];
             translateX_ZeroPos = -translation.x - pos_*itemWidth_;//自然方向,的反向
             CGPoint pt = [recognizer locationInView:self];
            shouldMove = CGRectContainsPoint(kLineChartRect_, pt);
        }
        if (shouldMove) {
            CGPoint translation = [recognizer translationInView:self];
            NSInteger movePos = (-translation.x-translateX_ZeroPos + itemWidth_*0.5)/itemWidth_;//自然方向,的反向
//            NSLog(@"movePos@%zd",movePos);
//            NSLog(@"movePos,translation@%lf",translation.x);
            if (movePos<0) {
                movePos = 0;
                translateX_ZeroPos = -translation.x;
            }else{
                NSInteger max = YT_KLineView_MAXPOS;
                if (movePos>max) {
                    movePos = max;
                    translateX_ZeroPos = -translation.x -  max * itemWidth_;
                }
            }
             pos_ = movePos;
            [self changePosAndResetAllIfNeed:pos_];
            if (recognizer.state ==UIGestureRecognizerStateEnded) {
                if (translation.x>0) { // right 手指往右移动
                    [self loadMoreDataIfNeed];
                }
            }
        }
    }
}

-(void)loadMoreDataIfNeed{
//                                    if ([KDS_SupportFunManager shareInstance].bHistoryKLineView) {
//                                        //增加滑动下载k线代码
//                                        if (pos_ == 0) {
//                                            if (_delegate && [_delegate respondsToSelector:@selector(KLineViewLoadHistoryDataWithCurrentDate:withTime:)]) {
//                                                [_delegate KLineViewLoadHistoryDataWithCurrentDate:self.historyToDate withTime:self.historyTime];
//                                            }
//                                        }
//                                    }
}

/**
 *  处理长按事件
 *
 *  @param recognizer 手势
 */
- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
    if ([recognizer state] == UIGestureRecognizerStateBegan) {
        if (shouldCrossLine_) {
            CGPoint pt = [recognizer locationInView:self];
            if (CGRectContainsPoint(kLineChartRect_, pt)) {
                bShowCrossLine_ = YES;
                [self showCrossLineAtPoint:pt];
                if (_delegate && [_delegate respondsToSelector:@selector(KLineViewTouchDataIndex:bTouching:)]) {
                    [_delegate KLineViewTouchDataIndex:nCrossIndex_+pos_ bTouching:YES];
                }
            }
        }

    } else if ([recognizer state] == UIGestureRecognizerStateChanged) {
        if (shouldCrossLine_&&bShowCrossLine_) {
             CGPoint pt = [recognizer locationInView:self];
             [self showCrossLineAtPoint:pt];
             if (_delegate && [_delegate respondsToSelector:@selector(KLineViewTouchDataIndex:bTouching:)]) {
                    [_delegate KLineViewTouchDataIndex:nCrossIndex_+pos_ bTouching:YES];
            }
        }
    } else if ([recognizer state] == UIGestureRecognizerStateEnded) {
        if (shouldCrossLine_) {
            //无论在不在蜡烛图范围，只要手离开就执行
            if (_delegate && [_delegate respondsToSelector:@selector(KLineViewTouchDataIndex:bTouching:)]) {
                [_delegate KLineViewTouchDataIndex:nCrossIndex_+pos_ bTouching:NO];
            }
            bShowCrossLine_ = NO;
            nCrossIndex_ = 0;
            label_CrossLineLeft.hidden = YES;
            label_CrossLineRight.hidden = YES;
            [crossLayer_ setNeedsDisplay];
            [zbLayer_ setNeedsDisplay];
            [KLineMALayer_ setNeedsDisplay];
        }
    }
}

-(void)showCrossLineAtPoint:(CGPoint)pt{
    CGFloat itemW = [self getItemWidth];
    nCrossIndex_ = (pt.x - kLineChartRect_.origin.x)/itemW;
    if (nCrossIndex_ >= [self numberOfShowing]) {
        nCrossIndex_ = [self numberOfShowing] -1;
    }
    if (nCrossIndex_<0) {
        nCrossIndex_ =0;
    }
    CGFloat newx = kLineChartRect_.origin.x + itemW*nCrossIndex_;
    fCrossIndexXPos_ = newx + [self getItemWidth]/2;
    fCrossIndexYPos_ = pt.y;
  
    [crossLayer_ setNeedsDisplay];
    [zbLayer_ setNeedsDisplay];
    [KLineMALayer_ setNeedsDisplay];
}

/**
 *  横屏双击事件
 */
- (void)tap:(UITapGestureRecognizer *)recognizer {
    if (YT_KLineDirect_Ver == _KLineDirect) { // 竖屏
        
    }
    else {  // 横屏
        // 双击事件
        if (recognizer.numberOfTapsRequired == 2) {
            if (_delegate && [_delegate respondsToSelector:@selector(KLineViewHandleTapFromRecognizer:bChange:)]) {
                [_delegate KLineViewHandleTapFromRecognizer:YT_KLineDirect_Ver bChange:YES];
            }
        }
    }
}

/**
 *  竖屏点击事件
 */
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch* touch = (UITouch*)[touches anyObject];
    CGPoint pt = [touch locationInView:self];
    
    if (YT_KLineDirect_Ver == _KLineDirect) {
        if (CGRectContainsPoint(volChartRect_, pt)) {
            if (_delegate && [_delegate respondsToSelector:@selector(KLIneViewTouchAtZBarea:)]) {
                [_delegate KLIneViewTouchAtZBarea:YT_KLineDirect_Hor];
            }
        } else {
            
            if (_delegate && [_delegate respondsToSelector:@selector(KLineViewHandleTapFromRecognizer:bChange:)]) {
                [_delegate KLineViewHandleTapFromRecognizer:YT_KLineDirect_Hor bChange:YES];
            }
        }
        
    } else {
        if (CGRectContainsPoint(volChartRect_, pt)) {
            if (_delegate && [_delegate respondsToSelector:@selector(KLIneViewTouchAtZBarea:)]) {
                [_delegate KLIneViewTouchAtZBarea:YT_KLineDirect_Hor];
            }
        }
    }
}

//点击复权设置后push到设置界面
- (void)pushToSettingPage {
    if (_delegate && [_delegate respondsToSelector:@selector(SetButtonClick)]) {
        [_delegate SetButtonClick];
    }
}

#ifdef DEBUG
-(void)dealloc{
    NSLog(@"完美谢幕%@",NSStringFromClass(self.class));
}
#endif
@end
