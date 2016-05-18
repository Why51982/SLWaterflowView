//
//  SLWaterflowView.h
//  瀑布流
//
//  Created by CHEUNGYuk Hang Raymond on 16/5/12.
//  Copyright © 2016年 CHEUNGYuk Hang Raymond. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    SLWaterflowViewMarginTypeTop,
    SLWaterflowViewMarginTypeBottom,
    SLWaterflowViewMarginTypeLeft,
    SLWaterflowViewMarginTypeRight,
    SLWaterflowViewMarginTypeColumn,//每一行
    SLWaterflowViewMarginTypeRow,//每一列
} SLWaterflowViewMarginType;

@class SLWaterflowView, SLWaterflowViewCell;
/**
 *  数据源方法
 */
@protocol SLWaterflowDataSource <NSObject>
@required
//返回的数据个数(需要多少个cell)
- (NSUInteger)numberOfCellsInWaterflowView:(SLWaterflowView *)waterflowView;
//返回index对应位置的cell
- (SLWaterflowViewCell *)waterflowView:(SLWaterflowView *)waterflowView cellAtIndex:(NSUInteger)index;

@optional
//设置一行有多少列
- (NSUInteger)numberOfColumnInWaterflowView:(SLWaterflowView *)waterflowView;
@end


/**
 *  代理
 */
@protocol SLWaterflowDelegate <UIScrollViewDelegate>
@required
//设置index位置的cell的高度
- (CGFloat)waterflowView:(SLWaterflowView *)waterflowView heightAtIndex:(NSUInteger)index;
//监听index位置cell的点击
- (void)waterflowView:(SLWaterflowView *)waterflowView didSelectedAtIndex:(NSUInteger)index;
//设置cell四周的距离
- (CGFloat)waterflowView:(SLWaterflowView *)waterflowView marginForType:(SLWaterflowViewMarginType)type;
@end

@interface SLWaterflowView : UIScrollView

@property (nonatomic, weak) id <SLWaterflowDataSource> dataSource;
@property (nonatomic, weak) id <SLWaterflowDelegate> delegate;

//刷新数据
- (void)reloadData;

//根据标识到缓存池查找可循环利用的cell
- (SLWaterflowViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

@end
