//
//  YT_VolumeSwitchView.m
//  AFNetworking
//
//  Created by ChenRui Hu on 2018/8/23.
//

#import "YT_VolumeSwitchView.h"
#import "UIBezierPath+YT_TimeChart.h"
#import "YT_SwitchButtonChartView.h"
#import "UIFont+YT_Use.h"

@interface YT_VolumeSwitchView ()

@property (nonatomic, strong) YT_SwitchButtonChartView *switchButtonView;           // 切换的按钮
@property (nonatomic, strong)      UILabel *contentLabel;           // 后面量等的文字
@end

@implementation YT_VolumeSwitchView

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
    if(!_textFont) _textFont = [UIFont systemFontOfSize:12];
    _textColor = [UIColor grayColor];
}

- (void)commonInitialization {
    _switchButtonView = [YT_SwitchButtonChartView new];
    _switchButtonView.backgroundColor = [UIColor clearColor];
    _switchButtonView.titleEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
    _switchButtonView.textFont = _textFont;
    _switchButtonView.textColor = _textColor;
    
    _switchButtonView.switchButtonBlock = ^(BOOL bOpen) {
        if (self.switchButtonBlock) {
            self.switchButtonBlock(bOpen);
        }
    };
    [self addSubview:_switchButtonView];
    
    _contentLabel = [UILabel new];
    _contentLabel.textColor = _textColor;
    _contentLabel.textAlignment = NSTextAlignmentLeft;
    _contentLabel.font = _textFont;
    [self addSubview:_contentLabel];
}

/// 绘制成交量切换图
- (void)drawVolumeSwitchContent:(NSString *)content {
    _contentLabel.text = content;
}

- (void)drawVolumeSwitchButtonName:(NSString *)name {
    [_switchButtonView drawSwitchButtonName:name];
}

#pragma set
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    _switchButtonView.frame = CGRectMake(0, 0, kWidthButton + 2*kLeftEdge, frame.size.height);
    CGFloat fX = CGRectGetMaxX(_switchButtonView.frame) + 8.0f;
    _contentLabel.frame = CGRectMake(fX, 0, frame.size.width - fX, frame.size.height);
}

- (void)setSwitchLineWidth:(CGFloat)switchLineWidth {
    switchLineWidth = switchLineWidth;
    
    _switchButtonView.switchLineWidth = switchLineWidth;
}

- (void)setSwitchLineColor:(UIColor *)switchLineColor {
    _switchLineColor = switchLineColor;
    
    _switchButtonView.switchLineColor = switchLineColor;
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    
    _switchButtonView.textColor = textColor;
    _contentLabel.textColor = textColor;
}

- (void)setTextFont:(UIFont *)textFont {
    _textFont = textFont;
    
    _switchButtonView.textFont = textFont;
    _contentLabel.font = textFont;
}

@end
