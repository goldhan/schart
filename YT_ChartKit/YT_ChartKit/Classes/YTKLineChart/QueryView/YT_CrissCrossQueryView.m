//
//  YT_CrissCrossQueryView.m
//  KDS_Phone
//
//  Created by yt_liyanshan on 2018/6/1.
//  Copyright © 2018年 kds. All rights reserved.
//

#import "YT_CrissCrossQueryView.h"
#import "YT_StringRenderer.h"
#import "YT_OpenLayer.h"
#import "YT_Line.h"

#define YT_P_QueryView_Lable_Key    [NSString stringWithFormat:@"%zd", tag]

#pragma mark - 查价框

@interface YT_QueryView ()
@property (nonatomic, strong) NSMutableDictionary * lableDic;
@end

@implementation YT_QueryView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _interval = 3;
        _textFont = [UIFont systemFontOfSize:9];
        _contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
        _lableDic = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (UILabel *)getLableWithTag:(NSInteger)tag {
    [self viewWithTag:tag];
    UILabel * lable = [_lableDic objectForKey:YT_P_QueryView_Lable_Key];
    if (!lable) {
        lable = [[UILabel alloc] init];
        [_lableDic setObject:lable forKey:YT_P_QueryView_Lable_Key];
    }
    return lable;
}

- (void)setQueryData:(id<YT_QueryViewAbstract>)queryData {
    _queryData = queryData;
    
    NSArray * keys = [queryData queryViewKeys];
    NSDictionary * values = [queryData queryViewValuesForKeys];
    NSDictionary * valueColors = [queryData queryViewColorsForValues];
    NSDictionary * keyColors= [queryData queryViewColorsForKeys];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = _textFont.lineHeight;
    
    _size = CGSizeMake(width, height * keys.count + _interval * (keys.count -1) + _contentInset.top + _contentInset.bottom);
    
    CGRect contentRect = CGRectMake(_contentInset.top, _contentInset.left, _size.width - _contentInset.left - _contentInset.right , _size.height - _contentInset.top - _contentInset.bottom);
    
    [keys enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * stop) {
        
        NSInteger t_tag = idx * 2;
        NSInteger v_tag = idx * 2 + 1;
        
        UILabel *t_lable = [self getLableWithTag:t_tag];
        t_lable.font = self->_textFont;
        t_lable.frame = CGRectMake(contentRect.origin.x, contentRect.origin.y + (self->_interval + height) * idx, contentRect.size.width, height);
        t_lable.text = [NSString stringWithFormat:@"%@",obj];
        t_lable.textAlignment = NSTextAlignmentLeft;
        t_lable.textColor = keyColors[obj];
        [self addSubview:t_lable];
        
        UILabel *v_lable = [self getLableWithTag:v_tag];
        v_lable.font = self->_textFont;
        v_lable.frame =  t_lable.frame;
        v_lable.text = [NSString stringWithFormat:@"%@", [values objectForKey:obj]?:@""];
        v_lable.textAlignment = NSTextAlignmentRight;
        v_lable.textColor = valueColors[obj];
        [self addSubview:v_lable];
    }];
}


@end

#pragma mark - 查价视图

@interface YT_CrissCrossQueryView ()<YT_OpenLayerDelegate>

@property (nonatomic, assign) YT_Line xLine;
@property (nonatomic, assign) YT_Line yLine;
@property (nonatomic, assign) BOOL isNeedAnimation;
@property (nonatomic, assign) CGPoint cirssCenter;

@end

@implementation YT_CrissCrossQueryView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.userInteractionEnabled = NO;
//        self.layer.masksToBounds = YES; // 这里 label 为 0 时 会超过 所以不能截掉
        
        _cirssLayer = [[YT_OpenLayer alloc] init];
        _cirssLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _cirssLayer.yt_openLayerDelegate = self;
        
        _cirssLineColor = [UIColor grayColor];
        _cirssLineWidth = 1.f;
        
        _cirssLableColor = [UIColor whiteColor];
        _cirssLableBackColor = [UIColor redColor];
        _cirssLableFont = [UIFont systemFontOfSize:10];
        
        _bRightLabelOutChart = YES;
        
        [self.layer addSublayer:_cirssLayer];
        
        _queryView = [[YT_QueryView alloc] initWithFrame:CGRectMake(0, 0, 120, 0)];
        _queryView.backgroundColor = [UIColor whiteColor];
        _queryView.layer.borderColor = _cirssLineColor.CGColor;
        _queryView.layer.borderWidth = 0.5f;
        [self addSubview:_queryView];
        
        _yCirssLableLeft = [[UILabel alloc] init];
        _yCirssLableLeft.textAlignment = NSTextAlignmentCenter;
        _yCirssLableLeft.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_yCirssLableLeft];
        
        _yCirssLableRight= [[UILabel alloc] init];
        _yCirssLableRight.textAlignment = NSTextAlignmentCenter;
        _yCirssLableRight.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_yCirssLableRight];
        
        _xCirssLable = [[UILabel alloc] init];
        _xCirssLable.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_xCirssLable];
        [self configCirssLable];
        
        CGRect labelFramey = CGRectMake(-1000, 0 ,40, 15);
        CGRect labelFramex = CGRectMake(-1000, 0 ,100, 15);
        
        _yCirssLableLeft.frame = labelFramey;
        _yCirssLableRight.frame = labelFramey;
        
        _xCirssLable.frame = labelFramex;
        
        _yCirssLableLeftOffsetX = CGFLOAT_MIN;
        _yCirssLableRightOffsetX = CGFLOAT_MIN;
        _xCirssLableOffsetY = CGFLOAT_MIN;
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _cirssLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (hidden) {
        _isNeedAnimation = NO;
       [_cirssLayer setNeedsDisplay];
    } else {
        [_cirssLayer setNeedsDisplay];
    }
}

- (void)setYCirssHidden:(BOOL)yCirssHidden {
    _yCirssHidden = yCirssHidden;
    self.yCirssLableLeft.hidden = yCirssHidden;
    self.yCirssLableRight.hidden = yCirssHidden;
}

/** 设置中心点 */
- (void)setCenterPoint:(CGPoint)center {
    
    // 更新线
    _cirssCenter = center;
    _xLine  = YT_LineRectForX(self.cirssLayer.frame, center.x);
    _yLine  = YT_LineRectForY(self.cirssLayer.frame, center.y);
    [_cirssLayer setNeedsDisplay];

    // 更新 label
    UILabel *label;
    CGRect label_rect;
    CGPoint label_point;
    
    label = self.yCirssLableLeft;
    if (label.text.length != 0 && _yCirssHidden == NO) { // if (label.text.length != 0 && _yCirssHidden ==NO)
        label.hidden = NO;
        label_rect = label.frame;
        label_point = CGPointMake(self.yCirssLableLeftOffsetX, center.y - label_rect.size.height/2);
        label_rect.origin = label_point;
        label.frame = label_rect;
    }else{
        label.hidden = YES;
    }
    
    label = self.yCirssLableRight;
    if (label.text.length != 0 && _yCirssHidden == NO) { // if (label.text.length != 0 && _yCirssHidden ==NO)
        label.hidden = NO;
        label_rect = label.frame;
        label_point = CGPointMake(self.yCirssLableRightOffsetX - label_rect.size.width, center.y - label_rect.size.height/2);
        label_rect.origin = label_point;
        label.frame = label_rect;
    }else{
        label.hidden = YES;
    }
    
    label = self.xCirssLable;
    if (label.text.length != 0) {
        label.hidden = NO;
        label_rect = label.frame;
        label_point = CGPointMake(center.x - label_rect.size.width /2, self.xCirssLableOffsetY);
        label_rect.origin = label_point;
        label.frame = label_rect;
    }else{
        label.hidden = YES;
    }
    
    // 更新 QueryView 的位置
    [self updateQueryLayerWithCenter:center];
}

- (void)updateQueryLayerWithCenter:(CGPoint)center {

    CGRect shoulRect = self.queryView.frame;
    BOOL isLeft = NO;
    if (center.x < CGRectGetMinX(self.frame) + self.queryView.frame.size.width) {
        shoulRect = CGRectMake(CGRectGetMaxX(self.frame) - self.queryView.frame.size.width, 0, self.queryView.size.width, self.queryView.size.height);
    }
    else if (center.x >= CGRectGetMaxX(self.frame) - self.queryView.frame.size.width) {
        isLeft = YES;
        shoulRect = CGRectMake(0, 0, self.queryView.size.width, self.queryView.size.height);
    }
    else {
        // 初始化在左边优先
        if (self.queryView.frame.size.height == 0) {
            shoulRect = CGRectMake(0, 0, self.queryView.size.width, self.queryView.size.height);
        }
    }
    
    if (CGRectEqualToRect(self.queryView.frame, shoulRect)) { return; }
    
    self.queryView.frame = shoulRect;
    if (_isNeedAnimation) {
        @autoreleasepool {
            
            CATransition *animation = [CATransition animation];
            [animation setDuration:0.35];
            animation.type = kCATransitionPush;
            animation.subtype = isLeft ? kCATransitionFromLeft:kCATransitionFromRight;
            [self.queryView.layer addAnimation:animation forKey:@"frame"];
        }
    }
    _isNeedAnimation = YES;
}

- (void)yt_drawOpenLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
    if (self.hidden) return;
    if ([layer isEqual:self.cirssLayer]) {
        YT_Line xLine  = _xLine;
        YT_Line yLine  = _yLine;
        
        UIColor *lineColor = self.cirssLineColor;
        CGContextSetStrokeColorWithColor(ctx, lineColor.CGColor);
        CGContextSetLineWidth(ctx, self.cirssLineWidth);
        // 竖线
        CGContextBeginPath(ctx);
        CGContextMoveToPoint(ctx, xLine.start.x, xLine.start.y);
        CGContextAddLineToPoint(ctx, xLine.end.x, xLine.end.y);
        
        // 横线
        if (self.yCirssHidden == NO) {
            CGContextMoveToPoint(ctx, yLine.start.x, yLine.start.y);
            CGContextAddLineToPoint(ctx, yLine.end.x, yLine.end.y);
        }
        CGContextStrokePath(ctx);
    }
}

#pragma mark -

- (CGFloat)yCirssLableLeftOffsetX {
    if (_yCirssLableLeftOffsetX == CGFLOAT_MIN) {
        return CGRectGetMinX(self.bounds);
    }
    return _yCirssLableLeftOffsetX;
}

- (CGFloat)yCirssLableRightOffsetX {
    if (_yCirssLableRightOffsetX == CGFLOAT_MIN) {
        return CGRectGetMaxX(self.bounds);
    }
    return _yCirssLableRightOffsetX;
}

- (CGFloat)xCirssLableOffsetY {
    if (_xCirssLableOffsetY == CGFLOAT_MIN) {
        return CGRectGetMaxY(self.bounds) - 30;
    }
    return _xCirssLableOffsetY;
}

- (void)configCirssLable {
    UIColor *bgColor = self.cirssLableBackColor;
    UIColor *textColor = self.cirssLableColor;
    UIFont *textFont = self.cirssLableFont;
    
    [self t_configLabel:self.yCirssLableLeft bgC:bgColor c:textColor f:textFont r:2];
    [self t_configLabel:self.yCirssLableRight bgC:bgColor c:textColor f:textFont r:2];
    [self t_configLabel:self.xCirssLable bgC:bgColor c:textColor f:textFont r:2];
}

- (void)t_configLabel:(UILabel *)label bgC:(UIColor *)bgColor c:(UIColor *)textColor f:(UIFont *)textFont r:(CGFloat)cornerRadius {
    label.textColor = textColor;
    label.font = textFont;
    label.backgroundColor = bgColor;
    label.layer.masksToBounds = YES;
    label.layer.cornerRadius = cornerRadius;
}
@end
