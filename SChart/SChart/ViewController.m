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
  
    CGRect rect = self.scrollView.frame;
    _renderView = [[RenderView alloc] initWithFrame:rect];
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
