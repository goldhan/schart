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
   
//    int screenNum = self.scrollView.contentSize.width / layer.frame.size.width;
//    int sum = screenNum * 10;
//    NSLog(@"%d %lf",screenNum, self.scrollView.contentOffset.x);
    int Offset = self.scrollView.contentSize.width - self.scrollView.contentOffset.x;
    
    NSArray *nowDatas = [self getNowRenderDatas];
    NSLog(@"%@", nowDatas);
    
//    int num = 10;
    NSMutableArray *temp = [NSMutableArray array];
    for (int i = 0; i < nowDatas.count; i++) {
        CGPoint p = CGPointFromString(nowDatas[i]);
        p.x -= Offset;
        p.x = kScreenWidth - p.x;
//        CGPoint newP = [self.scrollView convertPoint:p toView:self];
        [temp addObject:NSStringFromCGPoint(p)];
        int y = arc4random() % 200 - 20;
        CGContextSetFillColorWithColor(ctx, UIColor.blueColor.CGColor);
//        CGRect rect = CGRectMake(kScreenWidth - kWidth * (i + 1), y, kWidth, 20);
        CGRect rect = CGRectMake(p.x, p.y, kWidth, 20);
        CGContextAddRect(ctx, rect);
        CGContextFillPath(ctx);
    }
    
    NSLog(@"%@", temp);
 

}
- (NSArray *)getNowRenderDatas {
    int x = self.scrollView.contentSize.width - self.scrollView.contentOffset.x;
    int w = (int)kWidth;
    int num =  x%w == 0 ? x / w : x / w + 1;
//    NSLog(@"%ld", num);
    if (num <= self.datas.count - num){
        
        if (num == 0) {
            return [self.datas subarrayWithRange:NSMakeRange(0, 10)];
        }
        return [self.datas subarrayWithRange:NSMakeRange(num, 10)];
    } else {
        return [self.datas subarrayWithRange:NSMakeRange(self.datas.count - 10, 10)];
    }
    
}
@end
