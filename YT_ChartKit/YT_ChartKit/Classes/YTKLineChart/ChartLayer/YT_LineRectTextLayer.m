//
//  YT_LineRectTextLayer.m
//  YT_ModuleQuotes_Example
//
//  Created by 韩金 on 2019/1/22.
//  Copyright © 2019 李燕山. All rights reserved.
//

#import "YT_LineRectTextLayer.h"
#import "YT_ChartScaler.h"
#import "YT_StockChartProtocol.h" // 基本 float 协议
#import "YT_KLineDataProtocol.h" // kline数据协议
@interface YT_LineRectTextLayer()
@property (nonatomic, strong) UILabel *textL;
@property (nonatomic, strong) CAShapeLayer * lineLayer;
@end
@implementation YT_LineRectTextLayer
- (instancetype)init
{
    self = [super init];
    if (self) {
        _lineColor = [UIColor blackColor];
        _lineWidth = 1;
        _textColor = [UIColor whiteColor];
        _textRectBG = [UIColor blackColor];
        
        _textL = [[UILabel alloc]init];
        _textL.backgroundColor = _textRectBG;
        _textL.textAlignment = NSTextAlignmentCenter;
        _textL.textColor = _textColor;
        _textL.adjustsFontSizeToFitWidth = true;
        _textL.font = [UIFont systemFontOfSize:12];
        [self addSublayer:_textL.layer];
        
        _lineLayer = [[CAShapeLayer alloc] init];
        _lineLayer.masksToBounds = true;
        [self addSublayer:_lineLayer];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self.sublayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    }];
}

- (void)configLayer {
    _lineLayer.strokeColor = _lineColor.CGColor;
    [_lineLayer setLineWidth:1];
    [_lineLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:2], [NSNumber numberWithInt:3],nil]];
    
    _textL.backgroundColor = _textRectBG;
    _textL.textColor = _textColor;
}

- (void)updateLayerWithRange:(NSRange)range {
    CGMutablePathRef ref = CGPathCreateMutable();
    YT_AxisYScaler axisYScaler = self.chartScaler.axisYScaler;
    YT_AxisXScaler axisXScaler = self.chartScaler.axisXScaler;
    id <YT_StockKlineData> data = [self.kLineArray lastObject];
    
    CGFloat pointX = axisXScaler(self.kLineArray.count - 1);
    CGFloat pointY = axisYScaler(data.yt_closePrice);
    CGFloat textLX = 0;
    CGFloat textLY = pointY;
    if (pointY >= self.chartScaler.chartRect.size.height) {
        pointY = self.chartScaler.chartRect.size.height;
    }
    if (pointY <= 0) {
        pointY = 0;
    }
    if (pointY >= self.chartScaler.chartRect.size.height - 7) {
        textLY = self.chartScaler.chartRect.size.height - 7;
    }
    if (pointY <= 7) {
        textLY = 7;
    }
    CGFloat endLineX = self.frame.size.width;
    if (pointX >= CGRectGetMidX(self.frame)) {
        pointX = 45;
        textLX = 0;
    } else {
        endLineX -= 45;
        pointX = 0;
        textLX = self.frame.size.width - 45;
    }
    
    CGPathMoveToPoint(ref, NULL, pointX, pointY);
    CGPathAddLineToPoint(ref, NULL, endLineX, pointY);
    self.textL.text = [NSString stringWithFormat:@"%.2lf",data.yt_closePrice];
    self.textL.frame = CGRectMake(textLX, textLY - 7, 45, 14);
    self.lineLayer.path = ref;
    CGPathRelease(ref);
}
@end
