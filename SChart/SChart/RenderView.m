//
//  RenderView.m
//  SChart
//
//  Created by Gold on 2021/3/20.
//

#import "RenderView.h"
#import "ViewController.h"


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
//    NSLog(@"%d",(int)self.scrollView.contentOffset.x);
    NSArray *nowDatas = [self getNowRenderDatas];
//    CGPoint p = CGPointFromString(nowDatas[0]);
//    int xxx = p.x - self.scrollView.contentOffset.x;
//    NSLog(@"%d", xxx);
//    return;
//    int num = 10;
    NSMutableArray *temp = [NSMutableArray array];
    for (int i = 0; i < nowDatas.count; i++) {
        CGPoint p = CGPointFromString(nowDatas[i]);
        p.x -= self.scrollView.contentOffset.x;
//        p.x = self.frame.size.width - p.x;
//        CGPoint newP = [self.scrollView convertPoint:p toView:self];
        [temp addObject:NSStringFromCGPoint(p)];
        int y = arc4random() % 200 - 20;
        CGContextSetFillColorWithColor(ctx, UIColor.blueColor.CGColor);
//        CGRect rect = CGRectMake(kScreenWidth - kWidth * (i + 1), y, kWidth, 20);
        CGRect rect = CGRectMake(p.x, p.y, boxW, boxH);
        CGContextAddRect(ctx, rect);
        CGContextFillPath(ctx);
    }
    
//    NSLog(@"%@", temp);
 

}
- (NSArray *)getNowRenderDatas {
    int x = self.scrollView.contentSize.width - self.scrollView.contentOffset.x;
    int w = (int)boxW;
    int afterN = self.scrollView.contentOffset.x / boxW;
//    int num =  x%w == 0 ? x / w : x / w + 1;
    int displayNum = (int)self.frame.size.width % w == 0 ? self.frame.size.width / boxW : self.frame.size.width / boxW + 1;
//    NSLog(@"%@",[self.datas subarrayWithRange:NSMakeRange(afterN, displayNum)] );
//    return @[];
    return [self.datas subarrayWithRange:NSMakeRange(afterN, displayNum)];
////    NSLog(@"%ld", num);
//    if (num <= self.datas.count - num){
//
//        if (num == 0) {
//            return [self.datas subarrayWithRange:NSMakeRange(0, displayNum)];
//        }
//        return [self.datas subarrayWithRange:NSMakeRange(num, displayNum)];
//    } else {
//        return [self.datas subarrayWithRange:NSMakeRange(self.datas.count - 10, displayNum)];
//    }
    
}
@end
