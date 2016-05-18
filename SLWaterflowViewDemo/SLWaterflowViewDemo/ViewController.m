//
//  ViewController.m
//  SLWaterflowViewDemo
//
//  Created by CHEUNGYuk Hang Raymond on 16/5/18.
//  Copyright © 2016年 CHEUNGYuk Hang Raymond. All rights reserved.
//

#import "ViewController.h"
#import "SLWaterflowView.h"
#import "SLWaterflowViewCell.h"

@interface ViewController ()<SLWaterflowDataSource, SLWaterflowDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SLWaterflowView *waterflow = [[SLWaterflowView alloc] init];
    waterflow.frame = self.view.bounds;
    waterflow.dataSource = self;
    waterflow.delegate = self;
    [self.view addSubview:waterflow];
    
    //刷新数据
    //首次运行的时候，让程序自动加载reloadData方法,不需要手动调入,达到和UITableView一样的效果,解决办法就是在SLWaterflowView方法中添加- (void)willMoveToSuperview:(UIView *)newSuperview方法
    //    [waterflow reloadData];
}

#pragma mark -- <SLWaterflowDataSource>
- (NSUInteger)numberOfCellsInWaterflowView:(SLWaterflowView *)waterflowView {
    
    return 50;
}

- (SLWaterflowViewCell *)waterflowView:(SLWaterflowView *)waterflowView cellAtIndex:(NSUInteger)index {
    
    static NSString *cellID = @"cell";
    SLWaterflowViewCell *cell = [waterflowView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[SLWaterflowViewCell alloc] init];
        cell.identifier = cellID;
        
        UILabel *label = [[UILabel alloc] init];
        label.frame = CGRectMake(0, 0, 30, 30);
        label.text = [NSString stringWithFormat:@"%lu", (unsigned long)index];
        [cell addSubview:label];
    }
    cell.backgroundColor = SLRandomColor;
    return cell;
}

#pragma mark -- <UIScrollViewDelegate>
//设置index位置的cell的高度
- (CGFloat)waterflowView:(SLWaterflowView *)waterflowView heightAtIndex:(NSUInteger)index {
    
    switch (index % 3) {
        case 0: return 70;
        case 1: return 100;
        case 2: return 80;
        default: return 90;
    }
}
//监听index位置cell的点击
- (void)waterflowView:(SLWaterflowView *)waterflowView didSelectedAtIndex:(NSUInteger)index {
    
    NSLog(@"%lu", (unsigned long)index);
}
//设置cell四周的距离
- (CGFloat)waterflowView:(SLWaterflowView *)waterflowView marginForType:(SLWaterflowViewMarginType)type {
    
    switch (type) {
        case SLWaterflowViewMarginTypeTop:
        case SLWaterflowViewMarginTypeBottom:
        case SLWaterflowViewMarginTypeLeft:
        case SLWaterflowViewMarginTypeRight:
            return 20;
        default: return 10;
    }
}
@end
