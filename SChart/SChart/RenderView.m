//
//  RenderView.m
//  SChart
//
//  Created by Gold on 2021/3/20.
//

#import "RenderView.h"
#define kWidth UIScreen.mainScreen.bounds.size.width / 10
#define kScreenWidth UIScreen.mainScreen.bounds.size.width
@implementation RenderView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx {
   
    int screenNum = self.scrollView.contentSize.width / layer.frame.size.width;
    int sum = screenNum * 10;
    NSLog(@"%d %lf",screenNum, self.scrollView.contentOffset.x);
    
//    int num = 10;
    
    for (int i = 0; i < 10; i++) {
        int y = arc4random() % 200 - 20;
        CGContextSetFillColorWithColor(ctx, UIColor.blueColor.CGColor);
        CGRect rect = CGRectMake(kScreenWidth - kWidth * (i + 1), y, kWidth, 20);
        CGContextAddRect(ctx, rect);
        CGContextFillPath(ctx);
    }
 

}

@end
