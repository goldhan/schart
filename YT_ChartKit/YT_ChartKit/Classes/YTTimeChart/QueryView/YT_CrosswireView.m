//
//  CoreGraphics_demo
//
//  Created by zhanghao on 2018/6/21.
//  Copyright © 2018年 snail-z. All rights reserved.
//

#import "YT_CrosswireView.h"
#import "UIBezierPath+YT_TimeChart.h"
#import "UIFont+YT_Use.h"

@interface YT_CrosswireView ()

@property (nonatomic, strong) CAShapeLayer *crosswireLayer;
@property (nonatomic, strong) UILabel *mapYaixsLabel;
@property (nonatomic, strong) UILabel *mapYaixsSubjoinLabel;
@property (nonatomic, strong) UILabel *mapIndexLabel;

@property (nonatomic, strong) CAShapeLayer *centralPointMarkLayer;  // 交叉点标记层
@end

@implementation YT_CrosswireView

- (void)addShadowWithLayer:(CALayer *)layer {
    layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    layer.shadowOffset = CGSizeMake(2, 2);
    layer.shadowRadius = 5;
    layer.shadowOpacity = 1;
    layer.shouldRasterize = YES;
    layer.rasterizationScale = [UIScreen mainScreen].scale;
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addShadowWithLayer:self.layer];
        [self defaultInitialization];
        [self commonInitialization];
    }
    return self;
}

- (void)defaultInitialization {
    _crosswireLineWidth = 1.f / [UIScreen mainScreen].scale;
    _crosswireLineColor = [UIColor grayColor];
    _textFont = [UIFont yt_fontWithName:@"Thonburi" size:11];
    _textColor = [UIColor blueColor];
    _textEdgePadding = UIOffsetMake(9, 3);
    _textBackgroundColor = [UIColor whiteColor];
    _dateBackgroundColor = [UIColor whiteColor];
    _centralPointColor = [UIColor cyanColor];
    _centralPointRadius = 4;
}

- (void)commonInitialization {
    _crosswireLayer = [CAShapeLayer layer];
    _crosswireLayer.fillColor = [UIColor clearColor].CGColor;
    _crosswireLayer.strokeColor = self.crosswireLineColor.CGColor;
    _crosswireLayer.lineWidth = self.crosswireLineWidth;
    [self.layer addSublayer:_crosswireLayer];
    
    _mapYaixsLabel = [UILabel new];
    _mapYaixsLabel.backgroundColor = self.textBackgroundColor;
    _mapYaixsLabel.textAlignment = NSTextAlignmentCenter;
    _mapYaixsLabel.layer.cornerRadius = 2;
    _mapYaixsLabel.layer.masksToBounds = YES;
    [self addSubview:_mapYaixsLabel];
    
    _mapYaixsSubjoinLabel = [UILabel new];
    _mapYaixsSubjoinLabel.backgroundColor = self.textBackgroundColor;
    _mapYaixsSubjoinLabel.textAlignment = NSTextAlignmentCenter;
    _mapYaixsSubjoinLabel.layer.cornerRadius = 2;
    _mapYaixsSubjoinLabel.layer.masksToBounds = YES;
    [self addSubview:_mapYaixsSubjoinLabel];
    
    _mapIndexLabel = [UILabel new];
    _mapIndexLabel.backgroundColor = self.dateBackgroundColor;
    _mapIndexLabel.textAlignment = NSTextAlignmentCenter;
    _mapIndexLabel.layer.cornerRadius = 2;
    _mapIndexLabel.layer.masksToBounds = YES;
    [self addSubview:_mapIndexLabel];
    
    _centralPointMarkLayer = [CAShapeLayer layer];
    _centralPointMarkLayer.lineWidth = 0;
    [self.layer addSublayer:_centralPointMarkLayer];
}

- (CGSize)sizeFitLabel:(UILabel *)label {
    CGSize size = [label sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    size.width += self.textEdgePadding.horizontal;
    size.height += self.textEdgePadding.vertical;
    return size;
}

- (void)updateYaixsText {
    _mapYaixsLabel.text = self.mapYaixsText;
    _mapYaixsLabel.backgroundColor = self.textBackgroundColor;
    CGSize valueSize = [self sizeFitLabel:_mapYaixsLabel];
    _mapYaixsLabel.frame = (CGRect){.size = valueSize};
    CGFloat valueHalfWidth = valueSize.width * 0.5;
    CGFloat valueHalfHeight = valueSize.height * 0.5;
    CGFloat positionX = valueHalfWidth;
    CGPoint valueCenter = CGPointMake(positionX, self.centralPoint.y);
    if (self.centralPoint.y - valueHalfHeight < self.bounds.origin.y) {
        valueCenter.y = self.bounds.origin.x + valueHalfHeight;
    }
    if (self.centralPoint.y + valueHalfHeight > self.bounds.size.height) {
        valueCenter.y = self.bounds.size.height - valueHalfHeight;
    }
    if (self.centralPoint.y < CGRectGetMinY(self.separationRect)) {
        if (self.centralPoint.y + valueHalfHeight > CGRectGetMinY(self.separationRect)) {
            valueCenter.y = CGRectGetMinY(self.separationRect) - valueHalfHeight;
        }
    } else if (self.centralPoint.y > CGRectGetMaxY(self.separationRect)) {
        if (self.centralPoint.y - valueHalfHeight < CGRectGetMaxY(self.separationRect)) {
            valueCenter.y = CGRectGetMaxY(self.separationRect) + valueHalfHeight;
        }
    }
    
    if (!self.mapYaixsSubjoinText) {
        _mapYaixsSubjoinLabel.hidden = YES;
        // _mapYaixsLabel显示规则(水平方向)：大于self.bounds区域的1/2在左边显示，反之在右边显示
        if (self.spotOfTouched.x < self.bounds.size.width / 2.f) {
            valueCenter.x = self.bounds.size.width - positionX;
        }
    } else {
        _mapYaixsSubjoinLabel.text = self.mapYaixsSubjoinText;
        _mapYaixsSubjoinLabel.backgroundColor = self.textBackgroundColor;
        CGSize valueSize1 = [self sizeFitLabel:_mapYaixsSubjoinLabel];
        _mapYaixsSubjoinLabel.frame = (CGRect){.size = valueSize1};
        _mapYaixsSubjoinLabel.center = CGPointMake(self.bounds.size.width - valueSize1.width * 0.5, valueCenter.y);
    }
    
    _mapYaixsLabel.center = valueCenter;
}

- (void)updateIndexText {
    _mapIndexLabel.text = self.mapIndexText;
    _mapIndexLabel.backgroundColor = self.dateBackgroundColor;
    CGSize dateSize = [self sizeFitLabel:_mapIndexLabel];
    _mapIndexLabel.frame = (CGRect){.size = dateSize};
    CGFloat dateHalfWidth = dateSize.width * 0.5;
    CGFloat dateHalfHeight = dateSize.height * 0.5;
    CGPoint dateCenter = CGPointMake(self.centralPoint.x, self.bounds.size.height + dateHalfHeight + 2); // 再向下偏移2pt间距
    if (self.centralPoint.x - dateHalfWidth < self.bounds.origin.x) {
        dateCenter.x = self.bounds.origin.x + dateHalfWidth;
    }
    if (self.centralPoint.x + dateHalfWidth > self.bounds.size.width) {
        dateCenter.x = self.bounds.size.width - dateHalfWidth;
    }
    
    // 把日期文本放到中间分隔区 - by huchenrui (由于在横屏时日期在最下面被遮挡了)
    dateCenter.y = CGRectGetMaxY(_separationRect);
    _mapIndexLabel.center = dateCenter;
}

- (void)updateContents {
    _crosswireLayer.strokeColor = self.crosswireLineColor.CGColor;
    _crosswireLayer.lineWidth = self.crosswireLineWidth;
    _mapYaixsLabel.font = self.textFont;
    _mapYaixsLabel.textColor = self.textColor;
    _mapYaixsSubjoinLabel.font = self.textFont;
    _mapYaixsSubjoinLabel.textColor = self.textColor;
    _mapIndexLabel.font = self.textFont;
    _mapIndexLabel.textColor = self.textColor;
    
    // 点击竖线是否超出范围
    BOOL bOutside = !CGRectContainsPoint(self.bounds, self.centralPoint) || !CGRectContainsPoint(self.bounds, self.spotOfTouched);
    if (!_bdateHidden) {
        _mapIndexLabel.hidden = bOutside;
    }
    // 点击横线是否超出范围
    _mapYaixsLabel.hidden = !CGRectContainsPoint(self.bounds, self.centralPoint) || CGRectContainsPoint(self.separationRect, self.centralPoint); // 在中间分隔区域隐藏
    _mapYaixsSubjoinLabel.hidden = _mapYaixsLabel.hidden;
    
    [self updateYaixsText];
    [self updateIndexText];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    // 没有超出范围组画竖线
    if (!bOutside) {
        [path addVerticalLine:CGPointMake(self.centralPoint.x, 0) len:CGRectGetMinY(self.separationRect)];
        CGFloat fhight = self.bounds.size.height - CGRectGetMaxY(self.separationRect);
        if (fhight < 0) {
            fhight = 0;
        }
        [path addVerticalLine:CGPointMake(self.centralPoint.x, CGRectGetMaxY(self.separationRect)) len:fhight];
    }
    // 没有超出范围组画横线
    if (!_mapYaixsLabel.hidden) {
        [path addHorizontalLine:CGPointMake(0, self.centralPoint.y) len:self.bounds.size.width];
    }
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _crosswireLayer.path = path.CGPath;
    [CATransaction commit];
    
    if (_bcentralPointMark) {
        [self updateCentralPointMarkLayer];
    }
}

/// 更新交叉点层
- (void)updateCentralPointMarkLayer {
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:_centralPoint radius:_centralPointRadius startAngle:0 endAngle:2*M_PI clockwise:YES];
    _centralPointMarkLayer.path = path.CGPath;
    _centralPointMarkLayer.fillColor = _centralPointColor.CGColor;
}

- (void)setFadeHidden:(BOOL)fadeHidden {
    _fadeHidden = fadeHidden;
    [UIView animateWithDuration:0.15 animations:^{
        self.alpha = fadeHidden ? 0 : 1;
    }];
}

- (void)setBdateHidden:(BOOL)bdateHidden {
    _bdateHidden = bdateHidden;
    _mapIndexLabel.hidden = bdateHidden;
}

- (void)setBcentralPointMark:(BOOL)bcentralPointMark {
    _bcentralPointMark = bcentralPointMark;
}
@end
