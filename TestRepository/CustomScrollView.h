//
//  CustomScrollView.h
//
//  Created by Biroje on 14-3-21.
//  Copyright (c) 2014年 Biroje. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  测试仓库提交
 */
@protocol CustomScrollViewDataSource;
@protocol CustomScrollViewDelegate;

/**
 自定义非循环滑动分页scrollview
 */
@interface CustomScrollView : UIView<UIScrollViewDelegate> {
    /**
     scrollview控件
     */
    UIScrollView *_scrollView;
    /**
     pageControl控件
     */
    UIPageControl *_pageControl;
    /**
     总页数
     */
    NSInteger _totalPages;
    /**
     当前页数
     */
    NSInteger _curPage;
    /**
     可复用的view的数组
     */
    NSMutableArray *_reuseableViews;
    /**
     当前使用的view的数组
     */
    NSMutableArray *_usedViews;
    /**
     控件数据源回调
     */
    __unsafe_unretained id<CustomScrollViewDataSource> _dataSource;
    /**
     控件滑动回调
     */
    __unsafe_unretained id<CustomScrollViewDelegate> _scrollDelegate;
}

@property (nonatomic,readonly) UIScrollView *scrollView;
@property (nonatomic,readonly) UIPageControl *pageControl;
@property (nonatomic, assign) NSInteger curPage;
@property (nonatomic, unsafe_unretained) id<CustomScrollViewDataSource> dataSource;
@property (nonatomic, unsafe_unretained) id<CustomScrollViewDelegate> scrollDelegate;

- (id)initWithFrame:(CGRect)frame CurShowPage:(NSInteger)aPage ScrollerEnable:(BOOL)aEnable;
/**
 重新刷新控件数据
 */
- (void)reloadData;

/**
 顺序加载下一页
 */
- (void)loadNextDataByAnimation;
/**
 顺序加载上一页
 */
- (void)loadPreDataByAnimation;
/**
 外部调用,根据页码替换缓存中的下一页
 */
- (void)jumpToNextData:(NSInteger)aCurPage Animated:(BOOL) aAnimated;

/**
 外部调用,根据页码替换缓存中的上一页
 */
- (void)jumpToPreData:(NSInteger)aCurPage Animated:(BOOL)aAnimated;

/**
 取当前可复用的view
 */
- (id)dequeueReusableView;

-(NSMutableArray *)currentUsedViews;

@end





@protocol CustomScrollViewDataSource <NSObject>

@required
/**
 获取控件的数据总数
 */
- (NSInteger)numberOfPages;
/**
 构建view
 */
- (UIView *)scrollView:(CustomScrollView *)csView viewAtIndex:(NSInteger)index;

@optional
/**
 定制pageControl的显示效果
 */
- (void)pageChanged:(UIPageControl*)pageControl;

@end

@protocol CustomScrollViewDelegate <NSObject>
/**
 构建view
 */
- (void)scrollDidStopAtIndex:(NSInteger)index;


@end







