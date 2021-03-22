//
//  YT_KLineChart+Extend.m
//  yt_liyanshan
//
//  Created by yt_liyanshan on 2018/9/19.
//

#import "YT_KLineChart+Extend.h"
#import "YT_KlineChartPrivate.h"
#import "YT_StringArrayRenderer.h"
#import "YT_StockChartConstants.h"
#import "YT_CandlestickLayer.h"
#import "YT_KLineDataSource.h"
#import "YT_KLChartIndexCalculatConfige.h"

@implementation YT_KLineChart (Extend)

#pragma mark 实时更新Ex

- (BOOL)klineIsFullDrawWidow {
    return (self.config.kShapeWidth + self.config.kShapeInterval) * self.kLineArray.count < self.kDrawWindowFrame.size.width;
}


/** 实时更新背景层 - X横轴设置**/
- (void)ex_updateGridLayerAxisXWithRange:(NSRange)range rect:(CGRect)dateRect {
    if (range.length == 0) return;
    //开始时间
    id <YT_StockKlineData> techData = nil;
    techData = [self.kLineArray objectAtIndex:range.location];
    NSString *strTimeBegin = [NSString stringWithFormat:@"%d", techData.yt_DateYmd];
    //结束时间
    NSInteger endIndex = range.location + range.length -1;
    techData = [self.kLineArray objectAtIndex:endIndex];
    NSString * strTimeEnd = [NSString stringWithFormat:@"%d", techData.yt_DateYmd];
    
    if (!self.axisXStrRenderer.offSetRatiosBlock) {
        [self.axisXStrRenderer setOffSetRatiosBlock:^CGPoint(YT_StringArrayRenderer *renderer, NSInteger index) {
            if (index == 0) {
                return  YT_RATIO_POINT_CONVERT(YTRatioBottomRight);
            }
            return YT_RATIO_POINT_CONVERT(YTRatioBottomLeft);
        }];
    }
    
    // X横轴设置
    [self.axisXStrRenderer removeAllPointString];
    
    CGPoint point = CGPointMake(0, CGRectGetMinY(dateRect));
    
    for (NSInteger i = 0 ; i < 2; i++) {
        NSString * title = i == 0? strTimeBegin:strTimeEnd;
        point.x =  CGRectGetMinX(dateRect) + i * CGRectGetWidth(dateRect);
        [self.axisXStrRenderer addString:title point:point];
    }
}

#pragma mark - drawGridLayerAxisX 一

- (void)drawGridLayerAxisXRange:(NSRange)range rect:(CGRect)dateRect {
    
    self.axisXStrRenderer.offSetRatio = YTRatioBottomRight;
    
    CGFloat midRectHeight =  dateRect.size.height;  // 区域高度
    if (!self.axisXStrRenderer.offsetsBlock) {
        [self.axisXStrRenderer setOffsetsBlock:^CGSize(YT_StringArrayRenderer *renderer, NSInteger index) {
            CGFloat offy = (midRectHeight - renderer.font.lineHeight)/2;
            if (index == 0) {
                return  CGSizeMake(0, offy);
            }
//            NSLog(@"rect font %@ TH%f FH%f",renderer.font,midRectHeight, renderer.font.lineHeight);
            return  CGSizeMake(0, offy);
        }];
    }
    
    // 绘制时间
    CGFloat textInsetPad = [self textInsetPadLR];
    CGFloat x_min = CGRectGetMinX(dateRect) + textInsetPad;
    CGFloat x_max = CGRectGetMaxX(dateRect) - textInsetPad;
    CGFloat y = CGRectGetMinY(dateRect);
    
    //开始时间
    id <YT_StockKlineData> techData = nil;
    techData = [self.kLineArray objectAtIndex:range.location];
    NSString *strTimeBegin = [self stringWithDateInt:techData.yt_DateYmd];
    //结束时间
    NSInteger endIndex = range.location + range.length -1;
    techData = [self.kLineArray objectAtIndex:endIndex];
    NSString * strTimeEnd = [self stringWithDateInt:techData.yt_DateYmd];
    
    UIFont *xfont = self.axisXStrRenderer.font;
    CGFloat strTimeEndTextW = [self stringSize:strTimeEnd font:xfont].width;
    x_max -= (strTimeEndTextW);
    
    // X横轴设置
    [self.axisXStrRenderer removeAllPointString];
    
    BOOL constTimeText = [self constTimeText];
    //绘制结束时间时，需要考虑绘制的时间的位置，k线可能没有铺满格子的时候;
    BOOL needAjustEndTime = [self klineIsFullDrawWidow];
    
    //绘制开始时间
    CGFloat x = x_min;
    if (!constTimeText) {
        x = [self viewPointXFormKLineIndex:range.location] - (self.config.kShapeWidth + self.config.kShapeInterval) * 0.5 + textInsetPad;
        x = MAX(x_min, x);
    }
    [self.axisXStrRenderer addString:strTimeBegin point:CGPointMake(x,y)];
    
    //绘制结束时间
    x = x_max;
    if(!constTimeText && needAjustEndTime) {
        x = [self viewPointXFormKLineIndex:endIndex] - strTimeEndTextW/2;
        x_min += (10.0f + [self stringSize:strTimeEnd font:xfont].width);
        x = MAX(x_min, x);
        x = MIN(x_max, x);
    }
    [self.axisXStrRenderer addString:strTimeEnd point:CGPointMake(x,y)];
}

#pragma mark 配置Func

- (CGFloat)textInsetPadLR {
    return 5;
}

- (BOOL)constTimeText {
    return YES;
}

#pragma mark - drawGridLayerAxisX 二

- (void)drawGridLayerAxisXRange:(NSRange)range rect:(CGRect)dateRect needShowDates:(NSMutableIndexSet *)datesIndexs {
    
    if (datesIndexs == nil) return;
    
    self.axisXStrRenderer.offSetRatio = YTRatioBottomRight;
    
    CGFloat midRectHeight =  dateRect.size.height;  // 区域高度
    if (!self.axisXStrRenderer.offsetsBlock) {
        [self.axisXStrRenderer setOffsetsBlock:^CGSize(YT_StringArrayRenderer *renderer, NSInteger index) {
            CGFloat offy = (midRectHeight - renderer.font.lineHeight)/2;
            if (index == 0) {
                return  CGSizeMake(0, offy);
            }
            return  CGSizeMake(0, offy);
        }];
    }
    
    // X横轴设置
    [self.axisXStrRenderer removeAllPointString];
    
    CGFloat textInsetPad = 0;
    CGFloat x_min = CGRectGetMinX(dateRect) + textInsetPad;
    CGFloat x_max = CGRectGetMaxX(dateRect) - textInsetPad;
    CGFloat x = x_min;
    CGFloat y = CGRectGetMinY(dateRect);
    
    UIFont *xfont = self.axisXStrRenderer.font;
    id <YT_StockKlineData> techData = nil;
    
    //网格路径
    CGMutablePathRef ref = CGPathCreateMutable();
    //网格竖线偏移量
    CGPoint linePointOff = [self.scrollView convertPoint:CGPointZero fromView:self];
    
    NSUInteger currentIndex = [datesIndexs firstIndex];
    while (currentIndex != NSNotFound) {
        
        // 日期线在k线数据中的位置
        NSInteger index = currentIndex;
        if (index >= self.kLineArray.count) {   // 容错，避免崩溃
            break;
        }
        techData = [self.kLineArray objectAtIndex:index];
        NSString * sDate = [self stringWithDateInt:techData.yt_DateYmd];
        if (!sDate || sDate.length == 0) {
            goto NextR;
        }
      
        CGSize dateTextSize = [self stringSize:sDate font:xfont];
        CGFloat fDatelineX = [self viewPointXFormKLineIndex:index];  // 日期线所在x
        
        x =  fDatelineX - dateTextSize.width/2;
        if (x < x_min || x + dateTextSize.width > x_max) {  // 超出区域不绘制
            goto NextR;
        }
        // 绘制文字
        [self.axisXStrRenderer addString:sDate point:CGPointMake(x,y)];
        
        // 绘制网格x
        CGFloat xline = fDatelineX;
        CGPoint Apoint = CGPointMake(xline, CGRectGetMinY(self.kDrawWindowFrame));
        CGPoint Bpoint = CGPointMake(xline, CGRectGetMaxY(self.kDrawWindowFrame));
        Apoint.x += linePointOff.x;Apoint.y += linePointOff.y;
        Bpoint.x += linePointOff.x;Bpoint.y += linePointOff.y;
        CGPathAddYTLine(ref, NULL, Apoint, Bpoint);
        
        for (int i = 0; i < self.techZBChartContexts.count; i++) {
            YT_TechZBChartContext * obj = self.techZBChartContexts[i];
            Apoint = CGPointMake(xline, CGRectGetMinY(obj.drawWindowFrame));
            Bpoint = CGPointMake(xline, CGRectGetMaxY(obj.drawWindowFrame));
            Apoint.x += linePointOff.x;Apoint.y += linePointOff.y;
            Bpoint.x += linePointOff.x;Bpoint.y += linePointOff.y;
            CGPathAddYTLine(ref, NULL, Apoint, Bpoint);
        }
        
    NextR:
        currentIndex = [datesIndexs indexGreaterThanIndex:currentIndex];
    }
Out:
    self.gridLayer_scroll.path = ref;
    CGPathRelease(ref);
}


/**
 计算需要显示日期/时间线的索引值
 
 @param dateLineIndexSet 计算结果
 @param dateOps  控制比较日期，1则最终比较的是20161207格式，100则最终比较的是201612
 @param range 显示的Kline的范围
 @param minWidthGap 日期最小间隔
 */
- (void)calculateNeedShowDates:(NSMutableIndexSet *)dateLineIndexSet comparedOps:(NSInteger)dateOps range:(NSRange)range minWidthGap:(CGFloat)minWidthGap {
    
    [dateLineIndexSet removeAllIndexes];   // 清空之前的日期线索引
    if (range.length == 0) return;
    
    // 计算每一个日期线的索引值
    NSInteger lastCompareDate = 0;   // 用于比较日期
    NSInteger lastUseDateIndex = -1;
    
    CGPoint startPoint  = CGPointMake(CGRectGetMinX(self.kDrawWindowFrame), 0);
    startPoint = [self.layer convertPoint:startPoint toLayer:(CALayer *)self.candleLayer];
//    YT_AxisXParser axisXParser =  self.kScaler.axisXParser;
    CGFloat   lastUseDateLineX =  startPoint.x;  // 计算出最后一根日期线的x位置
    
    NSInteger nMinCount = range.location +  range.length;
    
    // 第0个k线不绘制日期线
    id<YT_StockKlineData> kxData = [self.kLineArray objectAtIndex:range.location];
    lastCompareDate = kxData.yt_DateYmd /dateOps;
    
    for (NSInteger i = range.location +1; i < nMinCount; i++) {
        kxData = [self.kLineArray objectAtIndex:i];
        NSInteger nYear_Month = kxData.yt_DateYmd / dateOps;   // 201612
        //lastCompareDate != 0 ?
        if (nYear_Month != 0 && nYear_Month != lastCompareDate) {  // 如果两个k线的年月不同则需要绘制日期线
            
            CGFloat dateLineX = [self viewPointXFormKLineIndex:i];
            CGFloat dateLineGap = dateLineX - lastUseDateLineX;
            lastCompareDate = nYear_Month; // ::A
            
            // 如果两根日期线之间间距过小而且还没有一根日期线，则不绘制
            if (lastUseDateIndex > 0 && dateLineGap <= minWidthGap) {
                continue;
            }
            lastUseDateIndex = i;
            lastUseDateLineX = dateLineX;
            //            lastCompareDate = nYear_Month; // ::B //A 和 B在不同的地方写这句效果不一样
            [dateLineIndexSet addIndex:i];
        }
    }
}

#pragma mark 配置Func


#pragma mark - Tool


- (CGSize)stringSize:(NSString *)string font:(UIFont *)textFont {
    CGSize size = CGSizeZero;
    if ([string length] <= 0 || !textFont) {
        return size;
    }
    return [string sizeWithAttributes:@{NSFontAttributeName:textFont}];
}

- (NSString *)stringWithDateInt:(int32_t)date {
    return [NSString stringWithFormat:@"%d", date];
}

#pragma mark - changeCandleLayerStyle

- (void)changeCandleLayerStyle:(YT_CandleLayerStyle)style {
    if (self.candleLayerStyle == style) {
        return;
    }
    
    BOOL needUpdate = NO;
    if (style == YT_CandleLayerStyleCloss) {
        self.candleLayer.drawStyle = YT_CandlesDrawStyleLine;
        needUpdate = YES;
    }
    else if (style == YT_CandleLayerStyleAmerican) {
        self.candleLayer.drawStyle = YT_CandlesDrawStyleAB;
         needUpdate = YES;
    }else {
        if (style == YT_CandleLayerStyleCandleAllFill) {
            self.candleLayer.candleStyleOps = (YT_CandleStyleOpsRiseFull | YT_CandleStyleOpsFallFull | YT_CandleStyleOpsHoldFull);
        }else {
            self.candleLayer.candleStyleOps = (YT_CandleStyleOpsFallFull | YT_CandleStyleOpsHoldFull);;
        }
        if (self.candleLayer.drawStyle != YT_CandlesDrawStyleCandles) {
             self.candleLayer.drawStyle = YT_CandlesDrawStyleCandles;
            needUpdate = YES;
        }
    }
    
    if (needUpdate) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self updateChartForDIdReplacedKlineDataAtLast:0 withKlineData:nil];
        [CATransaction commit];
    }
}

- (YT_CandleLayerStyle)candleLayerStyle {
    if (self.candleLayer.drawStyle == YT_CandlesDrawStyleLine) {
        return YT_CandleLayerStyleCloss;
    }
    if (self.candleLayer.drawStyle == YT_CandlesDrawStyleAB) {
        return YT_CandleLayerStyleAmerican;
    }
    if (self.candleLayer.drawStyle == YT_CandlesDrawStyleCandles) {
        if (self.candleLayer.candleStyleOps == (YT_CandleStyleOpsRiseFull | YT_CandleStyleOpsFallFull | YT_CandleStyleOpsHoldFull)) {
             return YT_CandleLayerStyleCandleAllFill;
        }
        return YT_CandleLayerStyleCandleHalfFill;
    }
    return YT_CandleLayerStyleNone;
}

#pragma mark - 重设指标计算参数后更新指标图

/**
 清除指标计算结果
 */
- (void)cleanKLDataSourceAboutAttachedTechZB {
    //更新dataSource 和初始化数据容器
    [self.kLineDataSource.cacheManager cacheArrayInsertObjsAtIndex0:0];
    [self.kLineDataSource makeDefData];
}

/** 重设指标计算参数后更新指标图 */
- (void)updateChartIfNeedForResetKLCalculatConfige:(nullable YT_KLChartIndexCalculatConfige *)confige {
    YT_KLChartIndexCalculatConfige * sharedConfige = [YT_KLChartIndexCalculatConfige sharedConfige];
    if (confige && confige != sharedConfige) {
        [sharedConfige  resetConfige:confige];
    }
    __block BOOL needUpdate = NO;
    [self.attachedTechZBArray enumerateObjectsUsingBlock:^(id<YT_TechZBChartContextAbstract>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([sharedConfige hadChangedForZBType:obj.zbType]) {
            needUpdate = YES;
            * stop = YES;
        }
    }];
    [sharedConfige cleanChangedStatus];
    if (needUpdate) {
        [self cleanKLDataSourceAboutAttachedTechZB];
        [self updateSubLayer];
    }
}
@end
