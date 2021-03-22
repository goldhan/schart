//
//  YT_KLineViewConstDefind.h
//  KDS_Phone
//
//  Created by yt_liyanshan on 2017/9/20.
//  Copyright © 2017年 kds. All rights reserved.
//

#ifndef YT_KLineViewConst_h
#define YT_KLineViewConst_h


#define kGridLineNumber_KLine 4       // k线区域分为4等份
#define kGridLineNumber_VOL  2       // 成交量区域分为2等份
#define kLeft_Pading        [self recalculateFloat:35]      // 左侧间隙，留给数值用
#define kRight_Pading       [self recalculateFloat:8]      // 右侧间隙
#define kRight_Value_Pading  [self recalculateFloat:35]         // 横屏右侧数值间隙
#define kTop_Pading         [self recalculateFloat:5]           // 顶部间隙
#define kBottom_Pading      [self recalculateFloat:5]          // 底部间隙
#define kFuQuanBtnHeight    [self recalculateFloat:16]        // 复权按钮区域高度
#define kZoomItemWidth     .5           // 一次缩小item宽度
#define kMinItemWidth       [self recalculateFloat:3]           // 最小的item宽度
#define kMaxItemWidth       [self recalculateFloat:15]           // 最大的item宽度
#define koriginItemWidth    [self recalculateFloat:5]            // 最初的记忆（item宽度）
#define kZoomNumber         4           // 一次缩放或者扩大数量
#define kMoveNumber         3           // 一次移动数量
#define kTagLeftLabel       0XEE88      // 十字线左侧labeltag
#define kTagRightLabel       0XEE89      // 十字线右侧labeltag
#define kKLineItemGap       .5           // K线柱子之间的间隙
#define kKLineMAWidth        [self recalculateFloat:300]        // 均线文字区域宽度
#define kKLineHorMAWidth     [self recalculateFloat:500]        // 均线文字区域宽度
#define KKLineMAHeight       [self recalculateFloat:30]         // 均线文字区域高度

#define kRSVDays                  9
#define kEMA12Days                12
#define kEMA26Days                26
#define kDIFDays                  9

#define kTecColor_Yellow        skinColor(@"HangQing_Color_KLineTechYellow")
#define kTecColor_Purple        skinColor(@"HangQing_Color_KLineTechPurple")
#define kTecColor_Green         skinColor(@"HangQing_Color_KLineTechGreen")
#define kTecColor_Gray          skinColor(@"HangQing_Color_KLineTechGray")
//#define kTecColor_White         skinColor(@"HangQing_Color_KLineTechWhite")
#define kTecColor_White         skinColor(@"HangQing_Color_KLineTechGray")
#define kLineColor_Green        skinColor(@"HangQing_Color_KLineGreen")
#define kLineColor_Red          skinColor(@"HangQing_Color_KLineRed")


#define kTecColor_MA5           [YT_SkinCollector ytColor_13].yt_color
#define kTecColor_MA10          [YT_SkinCollector ytColor_14].yt_color
#define kTecColor_MA20          [YT_SkinCollector ytColor_16].yt_color
#define kTecColor_MA30          skinColor(@"FSKLine_Color_KLineMA30")
#define kTecColor_MA60          skinColor(@"FSKLine_Color_KLineMA30")

const CGFloat kTextInsetPad = 5 ; ///< 文字距离边框的位置

#define kTextColor skinColor(@"FSKLine_FontColor_SegmentNor") //技术指标数据颜色

#define YT_KLineView_MAXPOS MAX(0, (nKLineCount_ - self.maxNumberOfShow)) //最大索引取值
#define YT_KLineView_SHOWENDINDEX MIN((pos_ + self.maxNumberOfShow),nKLineCount_) //显示结束end
#endif /* YT_KLineViewConst_h */
