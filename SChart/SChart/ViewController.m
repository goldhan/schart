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
    CGFloat aw = UIScreen.mainScreen.bounds.size.width * 20;
    CGFloat w = UIScreen.mainScreen.bounds.size.width / 10;
    NSMutableArray *datas = [NSMutableArray array];
    int xxx = 0;
    bool isr = true;
    for (int i = 200; i > 0; i--) {
        CGPoint p = CGPointMake(aw - w * i, 20 + xxx);
        if (isr) {
            xxx += 20;
        } else {
            xxx -= 20;
        }
        
        if (xxx >= 200) {
            isr = false;
        }
        if (xxx <= 0) {
            isr = true;
        }
        [datas addObject: NSStringFromCGPoint(p)];
    }

  
    CGRect rect = self.scrollView.frame;
    _renderView = [[RenderView alloc] initWithFrame:rect];
    _renderView.datas = datas;
    _renderView.scrollView = _scrollView;
    _renderView.backgroundColor = UIColor.clearColor;
//    renderView.backgroundColor = [UIColor redColor];
    [self.view addSubview:_renderView];
    [self.view addSubview:self.scrollView];
    [_renderView.layer setNeedsDisplay];
//    rect.origin = CGPointMake(0, 0);
   
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
  
    [_renderView.layer setNeedsDisplay];
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        
        _scrollView.frame = CGRectMake(0, 74, UIScreen.mainScreen.bounds.size.width, 300);
        _scrollView.delegate = self;
        _scrollView.contentSize = CGSizeMake(UIScreen.mainScreen.bounds.size.width * 20, 300);
        _scrollView.contentOffset =CGPointMake(UIScreen.mainScreen.bounds.size.width * 20, 0);
        
    }
    return  _scrollView;
}

@end
