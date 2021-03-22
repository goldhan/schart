//
//  YT_BarCharDrawer.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2017/9/20.
//  Copyright © 2017年 kds. All rights reserved.
//

#import "YT_BarChartDrawer.h"
#import "stock_kline_data+YT_NFloat.h"
@implementation YT_BarChartDrawer

- (instancetype)init{self = [super init];if (self) { [self makeDefConfig];}return self;}

-(void)makeDefConfig{
    _strokWidth = 1;
    _itemGap = 0.50f;//间隙*0.5
    _maxNumberOfShowing = -1;
    _itemWidth = 1.0f;
    _minValueOfBottom = [NFloat zero];
}

-(UIColor *)upStrokColor{
    if (!_upStrokColor) {
       return  [YT_SkinCollector ytColor_01].yt_color;
    }
    return _upStrokColor;
}

-(UIColor *)downStrokColor{
    if (!_downStrokColor) {
        return [YT_SkinCollector ytColor_02].yt_color;
    }
    return _downStrokColor;
}
-(NSInteger)maxNumberOfShowing{
    if (_maxNumberOfShowing<0) {
        return floorf(_drawRect.size.width/_itemWidth);
    }
    return _maxNumberOfShowing;
}

-(NSInteger)shouldShowBarItemCount:(NSArray *)arr{
    NSInteger dataCount = 0;
    NSInteger showCount = 0;
    if (arr&&[arr isKindOfClass:[NSArray class]]) {
        dataCount = arr.count - _nPos;
    }
    showCount = MIN(dataCount, self.maxNumberOfShowing);
    return showCount;
}

-(void)drawKlinDataArr:(NSArray<stock_kline_data *> *)klineDataArr inContext:(CGContextRef)ctx{
    
    CGFloat fBottom =  CGRectGetMaxY(_drawRect);
    
    // 绘制成交量柱状图
    stock_kline_data *kxData = nil;
    for (NSInteger i=0; i<[self shouldShowBarItemCount:klineDataArr]; i++) {
        
        kxData = [klineDataArr objectAtIndex:i+_nPos];
        if (self.maxValueOfTop->fValue == 0) {
            return;
        }
        NFloat *fCjss = kxData.fCjss;
        NFloat *fClose = kxData.fClose;
        NFloat *fOpen = kxData.fOpen;
        
        CGFloat newx = _drawRect.origin.x + _itemWidth *i;
        CGFloat height = fCjss->fValue * _drawRect.size.height / (self.maxValueOfTop->fValue - self.minValueOfBottom->fValue);
        
        UIColor * color;
        NFloatCompare com = [fClose compare:fOpen];
        if (com == NFloatCompare_Negative) {
            color = self.downStrokColor;
        }else{
            color = self.upStrokColor;// 不涨跌默认红色
        }
        CGContextBeginPath(ctx);
        CGContextSetStrokeColorWithColor(ctx, color.CGColor);   //设置边框色
        CGContextSetFillColorWithColor(ctx, color.CGColor);     //设置填充色
    
        if (_itemWidth > 1) {
            if (com != NFloatCompare_Negative) {   //红色空心
                CGContextStrokeRect(ctx, CGRectMake(newx+_itemGap, fBottom-height, _itemWidth-2*_itemGap, height));
            } else { //绿色实心
                CGContextFillRect(ctx, CGRectMake(newx+_itemGap, fBottom-height, _itemWidth-2*_itemGap, height));
            }
        } else {
            CGContextMoveToPoint(ctx, newx, fBottom-height);
            CGContextAddLineToPoint(ctx, newx, fBottom);
        }
        CGContextStrokePath(ctx);
    }
}

#ifdef DEBUG
-(void)dealloc{
    NSLog(@"完美谢幕%@",NSStringFromClass(self.class));
}
#endif
@end
