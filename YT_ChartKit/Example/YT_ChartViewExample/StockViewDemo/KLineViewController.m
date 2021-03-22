//
//  KLineViewController.m
//  GGCharts
//
//  Created by _ | Durex on 17/7/4.
//  Copyright © 2017年 I really is a farmer. All rights reserved.
//

#import "KLineViewController.h"
#import "HorizontalKLineViewController.h"

@interface KLineViewController ()

@end

@implementation KLineViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.title = @"???";
    
    YT_KLineChart * kChart = [[YT_KLineChart alloc] initWithFrame:CGRectMake(10, 100, [UIScreen mainScreen].bounds.size.width - 20, 300)];
 
//    [self.view addSubview:kChart];
    
    UIBarButtonItem * bar = [[UIBarButtonItem alloc] initWithTitle:@"横屏" style:0 target:self action:@selector(present)];
    self.navigationItem.rightBarButtonItem = bar;
}

- (void)present
{
    [self presentViewController:[HorizontalKLineViewController new] animated:YES completion:nil];
}


@end
