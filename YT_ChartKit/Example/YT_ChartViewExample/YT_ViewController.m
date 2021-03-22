//
//  YT_ViewController.m
//  YT_StockChartViewExample
//
//  Created by 李燕山 on 06/26/2018.
//  Copyright (c) 2018 李燕山. All rights reserved.
//

#import "YT_ViewController.h"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

@interface YT_ViewController ()

@end


@implementation YT_ViewController

#pragma mark - 初始化

- (void)viewDidLoad {
    self.navigationItem.title = @"Charts";
    
    self.table = [[UITableView alloc] initWithFrame:self.view.frame];
    self.table.delegate = self;
    self.table.dataSource = self;
    self.table.separatorColor = [UIColor whiteColor];
    
    [self.view addSubview:_table];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 背景色
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    // 导航栏字体
    NSDictionary * dictionaryNavi = @{NSForegroundColorAttributeName : [UIColor blackColor]};
    [self.navigationController.navigationBar setTitleTextAttributes:dictionaryNavi];
}

#pragma mark - 各个视图

- (NSArray *)sectionAry {
    return @[@"Chart", @"StockChart"];
}

- (NSArray *)rowAry {
    return @[@[@"IOBarChartView", @"LineBarChartView", @"NTPieView", @"MDLineView", @"LineChartView"], @[@"TimeChartView", @"KLineChartView"]];
}

- (NSDictionary *)pushDictionary {
    return @{@"IOBarChartView" : @"IOBarChartViewController",
             @"LineBarChartView" : @"LineBarChartViewController",
             @"NTPieView" : @"NTPieViewController",
             @"MDLineView" : @"MDLineViewController",
             @"LineChartView":@"KLineViewController",
             @"TimeChartView" : @"KTimeViewController",
             @"KLineChartView":@"KLineViewController" };
}

#pragma mark - tableView Delegate && DataSource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *lable = [[UILabel alloc] init];
    lable.font = [UIFont systemFontOfSize:20];
    lable.text = [NSString stringWithFormat:@"    %@", self.sectionAry[section]];
    lable.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
    
    return lable;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.rowAry[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [self.rowAry[indexPath.section] objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *selectStr = [self.rowAry[indexPath.section] objectAtIndex:indexPath.row];
    NSString *className = [[self pushDictionary] objectForKey:selectStr];
    Class class_vc = NSClassFromString(className);
    UIViewController *vc;
    if (class_vc) {
        vc = [[class_vc alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        if (className && className.length != 0 && [self respondsToSelector:@selector(className)]) {
            UIView *chartView;
            [self performSelector:@selector(className)];
            vc = [[UIViewController alloc] init];
            UIViewController *vc = [[UIViewController alloc] init];
            vc.title = selectStr;
            [vc.view addSubview:chartView];
            [self.navigationController pushViewController:vc animated:NO];
        }
    }
}

@end
