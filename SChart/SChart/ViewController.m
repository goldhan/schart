//
//  ViewController.m
//  SChart
//
//  Created by Gold on 2021/3/20.
//

#import "ViewController.h"
#import "RenderView.h"

@interface ViewController ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) RenderView *renderView;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    CGFloat rw = boxNum*boxW;
    CGFloat rh = boxRow*boxH;
    NSMutableArray *datas = [NSMutableArray array];
    int boxRowTemp = 0;
    bool isEdge = false;
    CGFloat tempH = 0;
    for (int i = boxNum; i > 0; i--) {
        
        CGFloat tempY = boxRowTemp * boxH;
        if (tempY + boxH > rh) {
            boxRowTemp = 0;
            tempY = boxRowTemp * boxH;
        }
        if (tempY + boxH > rh || tempY == 0) {
            isEdge = !isEdge;
        }
        if (isEdge) {
            tempY = rh - boxH * boxRowTemp;
        }
        CGPoint p = CGPointMake(rw - boxW * i, tempY);
        boxRowTemp++;
        [datas addObject: NSStringFromCGPoint(p)];
    }
    NSLog(@"%@",datas);
    
    CGRect rect = self.scrollView.frame;
    _renderView = [[RenderView alloc] initWithFrame:rect];
    _renderView.datas = datas;
    _renderView.scrollView = _scrollView;
    _renderView.backgroundColor = UIColor.clearColor;
    //    renderView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_renderView];
    [self.view addSubview:self.scrollView];
    [_renderView.layer setNeedsDisplay];
    rect.origin = CGPointMake(0, 0);
    
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
   
    if (scrollView.contentOffset.x >=0 && scrollView.contentOffset.x <= scrollView.contentSize.width - scrollView.frame.size.width ) {
        [_renderView.layer setNeedsDisplay];
//        NSLog(@"%@",NSStringFromCGPoint(scrollView.contentOffset));
    }
   
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        
        //        _scrollView.backgroundColor = [UIColor lightGrayColor];
        CGFloat height = boxH * boxRow;
        _scrollView.frame = CGRectMake(0, 74, ScreenW, height);
        _scrollView.delegate = self;
        CGFloat w = boxNum*boxW;
        
        _scrollView.contentSize = CGSizeMake(w, height);
        _scrollView.contentOffset = CGPointMake(w - ScreenW, 0);
        //        UITabBar *bar = [[UITabBar alloc]init];
        //        bar.translucent;
    }
    return  _scrollView;
}

@end
