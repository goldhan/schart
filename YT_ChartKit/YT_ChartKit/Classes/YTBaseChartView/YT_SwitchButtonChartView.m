//
//  YT_SwitchButtonChartView.m
//  YT_ChartKit
//
//  Created by ChenRui Hu on 2018/12/24.
//

#import "YT_SwitchButtonChartView.h"
#import "UIBezierPath+YT_TimeChart.h"
#import "UIFont+YT_Use.h"

@interface YT_SwitchButtonChartView ()

@property (nonatomic, strong) CAShapeLayer *switchBorderLayer;      // 切换按钮边框层
@property (nonatomic, strong) CAShapeLayer *markLayer;              // 小三角层
@property (nonatomic, strong)     UIButton *switchButton;           // 切换的按钮
@end

@implementation YT_SwitchButtonChartView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self defaultInitialization];
        [self commonInitialization];
    }
    return self;
}

- (void)defaultInitialization {
    _switchLineWidth = 0.5;
    _switchLineColor = [UIColor grayColor];
    _textFont = [UIFont ytPingFangFontOfSize:12];
     if (!_textFont) _textFont = [UIFont systemFontOfSize:12];
    _textColor = [UIColor grayColor];
}

- (void)commonInitialization {
    _switchBorderLayer = [CAShapeLayer layer];
    _switchBorderLayer.fillColor = [UIColor clearColor].CGColor;
    _switchBorderLayer.strokeColor = _switchLineColor.CGColor;
    _switchBorderLayer.lineWidth = _switchLineWidth;
    [self.layer addSublayer:_switchBorderLayer];
    
    _markLayer = [CAShapeLayer layer];
    _markLayer.fillColor = _textColor.CGColor;
    _markLayer.strokeColor = _textColor.CGColor;
    _markLayer.lineWidth = _switchLineWidth;
    [self.layer addSublayer:_markLayer];
    
    _switchButton = [UIButton new];
    _switchButton.backgroundColor = [UIColor clearColor];
    _switchButton.titleLabel.font = _textFont;
    [_switchButton setTitleColor:_textColor forState:UIControlStateNormal];
    [_switchButton addTarget:self action:@selector(switchButtion) forControlEvents:UIControlEventTouchUpInside];
    [_switchButton setTitleEdgeInsets:_titleEdgeInsets];
    [self addSubview:_switchButton];
}

- (void)drawSwitchLayer {
    // 绘制切换按钮边框层
    CGFloat fHeight = 16.0f;
    CGFloat fWidth = kWidthButton;
    CGRect borderReact = (CGRect){.origin.x = kLeftEdge, .origin.y = (self.frame.size.height - fHeight)/2, .size.width = fWidth, .size.height = fHeight};
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:borderReact cornerRadius:6];
    _switchBorderLayer.path = path.CGPath;
    
    // 小三角的三个点
    fHeight = 5.0f;
    fWidth = 7.0f;
    _markLayer.frame = CGRectMake(borderReact.size.width*47/54.0f, (self.frame.size.height - fHeight)/2, fWidth, fHeight);
    CGPoint A = CGPointMake(0, 0);
    CGPoint B = CGPointMake(A.x + fWidth, A.y);
    CGPoint C = CGPointMake(A.x + fWidth/2, A.y+fHeight);
    UIBezierPath *markPath = [UIBezierPath bezierPath];
    NSArray *points = [NSArray arrayWithObjects:NSStringFromCGPoint(A), NSStringFromCGPoint(B), NSStringFromCGPoint(C), nil];
    [markPath addPolygon:points];
    _markLayer.path = markPath.CGPath;
}

#pragma set
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self drawSwitchLayer];
    _switchButton.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)setSwitchLineWidth:(CGFloat)switchLineWidth {
    _switchLineWidth = switchLineWidth;
    _switchBorderLayer.lineWidth = _switchLineWidth;
    
    _markLayer.lineWidth = _switchLineWidth;
}

- (void)setSwitchLineColor:(UIColor *)switchLineColor {
    _switchLineColor = switchLineColor;
    _switchBorderLayer.strokeColor = _switchLineColor.CGColor;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    _markLayer.fillColor = _textColor.CGColor;
    _markLayer.strokeColor = _textColor.CGColor;
    
    [_switchButton setTitleColor:_textColor forState:UIControlStateNormal];
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    _switchButton.titleLabel.font = _textFont;
}

- (void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets {
    _titleEdgeInsets = titleEdgeInsets;
    [_switchButton setTitleEdgeInsets:_titleEdgeInsets];
}

#pragma button
- (void)switchButtion {
    if(!CATransform3DEqualToTransform(_markLayer.transform , CATransform3DIdentity)) {
        self.bOpen = NO;
        _markLayer.transform =CATransform3DIdentity;
    } else {
        self.bOpen = YES;
        _markLayer.transform = CATransform3DRotate(CATransform3DIdentity, M_PI, 1, 0, 0);
    }
    
    if (self.switchButtonBlock) {
        self.switchButtonBlock(self.bOpen);
    }
}

#pragma mark - public
- (void)closeSwitchButtionMark {
    if (self.bOpen) {
        if(!CATransform3DEqualToTransform(_markLayer.transform , CATransform3DIdentity)) {
            self.bOpen = NO;
            _markLayer.transform = CATransform3DIdentity;
        }
    }
}

- (void)drawSwitchButtonName:(NSString *)name {
    [_switchButton setTitle:name forState:UIControlStateNormal];
}

@end
