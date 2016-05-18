//
//  SLWaterflowView.m
//  瀑布流
//
//  Created by CHEUNGYuk Hang Raymond on 16/5/12.
//  Copyright © 2016年 CHEUNGYuk Hang Raymond. All rights reserved.
//

#define SLWaterflowDefaultColumns 3
#define SLWaterflowDefaultMargin 10
#define SLWaterflowDefaultHeight 70

#import "SLWaterflowView.h"
#import "SLWaterflowViewCell.h"

@interface SLWaterflowView ()

//所有的cell的frame数据
@property (nonatomic, strong) NSMutableArray *cellFrames;
//正在展示的cell(防止用户上下小幅度移动屏幕,造成cell的改变,利用displayingCells字典存储以便重利用)
@property (nonatomic, strong) NSMutableDictionary *displayingCells;
//缓存池(存放离开屏幕的cell)
@property (nonatomic, strong) NSMutableSet *reusableCells;
@end

@implementation SLWaterflowView
@dynamic delegate;

#pragma mark -- 初始化
- (NSMutableArray *)cellFrames {
    
    if (!_cellFrames) {
        _cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}

- (NSMutableDictionary *)displayingCells {
    
    if (!_displayingCells) {
        _displayingCells = [NSMutableDictionary dictionary];
    }
    return _displayingCells;
}

- (NSMutableSet *)reusableCells {
    
    if (_reusableCells) {
        _reusableCells = [NSMutableSet set];
    }
    return _reusableCells;
}

#pragma mark -- 公共接口
- (void)reloadData {
    
    //获得cell的个数
    int numberOfCells = (int)[self.dataSource numberOfCellsInWaterflowView:self];
    
    //获取总列数
    int numberOfColumns = (int)[self numberOfColumns];
    
    //间距
    CGFloat marginT = [self marginForType:SLWaterflowViewMarginTypeTop];
    CGFloat marginB = [self marginForType:SLWaterflowViewMarginTypeBottom];
    CGFloat marginL = [self marginForType:SLWaterflowViewMarginTypeLeft];
    CGFloat marginR = [self marginForType:SLWaterflowViewMarginTypeRight];
    CGFloat marginC = [self marginForType:SLWaterflowViewMarginTypeColumn];
    CGFloat marginRow = [self marginForType:SLWaterflowViewMarginTypeRow];
    
    //每个cell的宽度
    CGFloat cellW = (self.width - marginL - marginR - (numberOfColumns - 1) * marginC) / numberOfColumns;
   
    //用一个C语言的数组存放每一列的最大Y值
    CGFloat maxYOfColumns[numberOfColumns];
    //初始化这个C语言数组
    for (int i = 0; i < numberOfColumns; i++) {
        maxYOfColumns[i] = 0.0;
    }
    
    //计算cell的frame
    for (int i = 0; i < numberOfCells; i++) {
        //记录最短一列的最大Y值的那一列的列数
        NSUInteger cellColumn = 0;
        //记录最短一列的最大Y值的那个数组
        CGFloat maxYCellOfColumn = maxYOfColumns[cellColumn];
        for (int j = 1; j < numberOfColumns; j++) {
            if (maxYCellOfColumn > maxYOfColumns[j]) {
                maxYCellOfColumn = maxYOfColumns[j];
                cellColumn = j;
            }
        }
        
        //询问代理i位置的高度
        CGFloat cellH = [self heightForIndex:i];
        
        //cell的位置
        CGFloat cellX = marginL + (cellW + marginC) * cellColumn;
        
        CGFloat cellY = 0.0;
        if (0.0 == maxYCellOfColumn) {
            cellY = marginT;
        } else {
//            cellY = marginT + (cellH + marginRow) * cellColumn / numberOfColumns;
            cellY = maxYCellOfColumn + marginRow;
        }
        
        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        
        //更新最短那一列的Y值
        maxYOfColumns[cellColumn] = CGRectGetMaxY(cellFrame);
        //maxYCellOfColumn = CGRectGetMaxY(cellFrame); 这样写就会错误,因为不会遍历到,要存储每行到数组,供后面遍历,得到最矮的那个
    }
    
    CGFloat contentH = maxYOfColumns[0];
    for (int i = 1; i < numberOfColumns; i++) {
        if (contentH < maxYOfColumns[i]) {
            contentH = maxYOfColumns[i];
        }
    }
    contentH += marginB;
    self.contentSize = CGSizeMake(0, contentH);
}

/**
 *  当UIScrollView滚动的时候也会调用这个方法
 */
- (void)layoutSubviews {
    
    [super layoutSubviews];
    //取出cell的个数
    NSUInteger numberOfCells = self.cellFrames.count;
    for (int i = 0; i < numberOfCells; i++) {
        //取出对应cell的frame
        CGRect cellFrame = [self.cellFrames[i] CGRectValue];
        
        //优先在字典中取出i位置的cell
        SLWaterflowViewCell *cell = self.displayingCells[@(i)];
        
        //判断i位置的cell在不在屏幕上(是否看得见)
        if ([self isInScreen:cellFrame]) {
            if (cell == nil) {
                cell = [self.dataSource waterflowView:self cellAtIndex:i];
                cell.frame = cellFrame;
                [self addSubview:cell];
                
                //存放到字典中
                self.displayingCells[@(i)] = cell;
            }
        } else { //不在屏幕上
            if (cell) {
                //从scrollView和字典中移除
                [cell removeFromSuperview];
                [self.displayingCells removeObjectForKey:@(i)];
                
                //存放进缓存池
                [self.reusableCells addObject:cell];
            }
        }
    }
}

- (SLWaterflowViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    
    __block SLWaterflowViewCell *reusableCell = nil;
    [self.reusableCells enumerateObjectsUsingBlock:^(SLWaterflowViewCell *cell, BOOL * _Nonnull stop) {
        if ([cell.identifier isEqualToString:identifier]) {
            reusableCell = cell;
            *stop = YES;
        }
    }];
    
    //如果有了值(即已经重利用了),那么从缓存池中移除
    if (reusableCell) {
        [self.reusableCells removeObject:reusableCell];
    }
    return reusableCell;
}

#pragma mark -- 私有接口
/**
 *  判断一个cell有无显示在屏幕上
 */
- (BOOL)isInScreen:(CGRect)frame {
    
    return CGRectGetMaxY(frame) > self.contentOffset.y && (CGRectGetMinY(frame) < self.contentOffset.y + self.height);
}

- (NSUInteger)numberOfColumns {
    
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnInWaterflowView:)]) {
        return [self.dataSource numberOfColumnInWaterflowView:self];
    } else {
        return SLWaterflowDefaultColumns;
    }
}

- (CGFloat)marginForType:(SLWaterflowViewMarginType)type {
    
    if ([self.delegate respondsToSelector:@selector(waterflowView:marginForType:)]) {
        return [self.delegate waterflowView:self marginForType:type];
    } else {
        return SLWaterflowDefaultMargin;
    }
}

- (CGFloat)heightForIndex:(NSInteger)index {
    
    if ([self.delegate respondsToSelector:@selector(waterflowView:heightAtIndex:)]) {
        return [self.delegate waterflowView:self heightAtIndex:index];
    } else {
        return SLWaterflowDefaultHeight;
    }
}

#pragma mark -- 解决首次加载自动调用reloadData的方法
//此方法当即将加入到父控件的时候调用
- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    [self reloadData];
}

#pragma mark -- 处理点击事件
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    if (![self.delegate respondsToSelector:@selector(waterflowView:didSelectedAtIndex:)]) return;
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    __block NSNumber *selectedIndex = nil;
    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(id key, SLWaterflowViewCell *cell, BOOL *stop) {
        
        if (CGRectContainsPoint(cell.frame, point)) {
            selectedIndex = key;
            *stop = YES;
        }
    }];
    
    [self.delegate waterflowView:self didSelectedAtIndex:selectedIndex.unsignedIntegerValue];
}

@end
