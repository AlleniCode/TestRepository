//
//  CustomScrollView.m
//
//  Created by Biroje on 14-3-21.
//  Copyright (c) 2014年 Biroje. All rights reserved.
//

#import "CustomScrollView.h"

@implementation CustomScrollView {
    BOOL _scrollerEnable;
}
@synthesize scrollView = _scrollView;
@synthesize curPage = _curPage;
@synthesize dataSource = _dataSource;
@synthesize scrollDelegate = _scrollDelegate;

- (id)initWithFrame:(CGRect)frame CurShowPage:(NSInteger)aPage ScrollerEnable:(BOOL)aEnable
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _curPage = aPage;
        _scrollerEnable = aEnable;
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        if (_curPage == 0) {
            _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 2, self.bounds.size.height);
            _scrollView.contentOffset = CGPointMake(0, 0);
        } else {
            _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
            _scrollView.contentOffset = CGPointMake(self.bounds.size.width, 0);
        }
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollsToTop = NO;
        [_scrollView setDelaysContentTouches:YES];
        [self addSubview:_scrollView];
        
        CGRect rect = self.bounds;
        rect.origin.y = rect.size.height - 30;
        rect.size.height = 30;
        _pageControl = [[UIPageControl alloc] initWithFrame:rect];
        _pageControl.userInteractionEnabled = NO;
        [_pageControl addTarget:self action:@selector(pageChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_pageControl];
    }
    return self;
}

-(void)pageChanged:(UIPageControl*)pageControl
{
    if ([_dataSource respondsToSelector:@selector(pageChanged:)]) {
        [_dataSource pageChanged:pageControl];
    }
}

- (void)reloadData
{
    _totalPages = [_dataSource numberOfPages];
    
    if (_totalPages == 0) {
        _scrollView.scrollEnabled = NO;
        NSArray *subViews = [_scrollView subviews];
        if ([subViews count] != 0) {
            [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }        
        return;
    
    } else if(_totalPages == 1) {
        _scrollView.scrollEnabled = NO;
    } else {
        if (_scrollerEnable == YES) {
            _scrollView.scrollEnabled = YES;
        } else{
            _scrollView.scrollEnabled = NO;
        }
    }
    
    _pageControl.numberOfPages = _totalPages;
    
    if (_usedViews == nil) {
        _usedViews = [[NSMutableArray alloc] initWithCapacity:4];
    }
    
    if (_reuseableViews == nil) {
        _reuseableViews = [[NSMutableArray alloc] initWithCapacity:4];
    }
    
    _curPage = [self validPageValue:_curPage];
    
    [self loadData];
    
    if (_scrollDelegate != nil && [_scrollDelegate respondsToSelector:@selector(scrollDidStopAtIndex:)]) {
        [_scrollDelegate scrollDidStopAtIndex:_curPage];
    }
}

- (void)loadData
{
    _pageControl.currentPage = _curPage;
    
    if ([_dataSource respondsToSelector:@selector(pageChanged:)]) {
        [_dataSource pageChanged:_pageControl];
    }
    
    if ([_usedViews count] != 0) {
        [_reuseableViews addObjectsFromArray:_usedViews];
        [_usedViews removeAllObjects];
    }
    if (_curPage > 0) {
        [_usedViews addObject:[_dataSource scrollView:self viewAtIndex:[self validPageValue:_curPage-1]]];
    }
    [_usedViews addObject:[_dataSource scrollView:self viewAtIndex:_curPage]];
    if (_curPage < _totalPages-1) {
        [_usedViews addObject:[_dataSource scrollView:self viewAtIndex:[self validPageValue:_curPage+1]]];
    }
    if (_curPage == 0 || _curPage == _totalPages-1) {
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 2, self.bounds.size.height);
    } else {
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
    }
    
    //重新加载ScrollView
    [self reloadScrollViewWithList:_usedViews];
    
    if(_curPage == 0) {
        [_scrollView setContentOffset:CGPointMake(0, 0)];
    } else {
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    }
}

/**
 重新加载ScrollView的subviews
 */
- (void)reloadScrollViewWithList:(NSMutableArray *)arrayViews {
    //从scrollView上移除所有的subview
    NSArray *subViews = [_scrollView subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    for (int i = 0; i < arrayViews.count; i++) {
        UIView *v = [arrayViews objectAtIndex:i];
        v.userInteractionEnabled = YES;
        v.frame = CGRectMake(v.frame.size.width * i, 0, v.frame.size.width, v.frame.size.height);
        [_scrollView addSubview:v];
    }
    
}

- (void)loadNextDataByAnimation{
    CGPoint newOffset = _scrollView.contentOffset;
    if (_curPage == 0) {
        newOffset.x = self.frame.size.width;
    } else {
        newOffset.x = self.frame.size.width*2;
    }
    newOffset.y = 0;
    
    [_scrollView setContentOffset:newOffset animated:YES];
}

- (void)loadPreDataByAnimation {
    CGPoint newOffset = _scrollView.contentOffset;
    newOffset.x = 0;
    newOffset.y = 0;
    
    [_scrollView setContentOffset:newOffset animated:YES];
}

/**
 外部调用,根据页码替换缓存中的下一页
 */
- (void)jumpToNextData:(NSInteger)aCurPage Animated:(BOOL)aAnimated {
    _curPage = [self validPageValue:aCurPage-1];
    [self loadData];
    
    CGPoint newOffset = _scrollView.contentOffset;
    if (_curPage == 0) {
        newOffset.x = self.frame.size.width;
    } else {
        newOffset.x = self.frame.size.width*2;
    }
    newOffset.y = 0;
    
    [_scrollView setContentOffset:newOffset animated:aAnimated];
    
//    UIView *lastView = [_usedViews lastObject];
//    [_usedViews removeObject:lastView];
//    [_usedViews addObject:[_dataSource scrollView:self viewAtIndex:[self validPageValue:aCurPage]]];
//    
//    //重新加载ScrollView
//    [self reloadScrollViewWithList:_usedViews];
    
//    [self loadNextDataByAnimation];
}

/**
 外部调用,根据页码替换缓存中的上一页
 */
- (void)jumpToPreData:(NSInteger)aCurPage Animated:(BOOL)aAnimated {
    _curPage = [self validPageValue:aCurPage+1];
    [self loadData];
    
    CGPoint newOffset = _scrollView.contentOffset;
    newOffset.x = 0;
    newOffset.y = 0;
    [_scrollView setContentOffset:newOffset animated:aAnimated];
    
//    UIView *firstView = [_usedViews objectAtIndex:0];
//    [_usedViews removeObject:firstView];
//    [_usedViews insertObject:[_dataSource scrollView:self viewAtIndex:[self validPageValue:aCurPage]] atIndex:0];
}

- (void)loadNextData:(NSInteger)aCurPage {
    //NSLog(@"loadNextData: %d",aCurPage);
    _pageControl.currentPage = aCurPage;
    
    if ([_dataSource respondsToSelector:@selector(pageChanged:)]) {
        [_dataSource pageChanged:_pageControl];
    }
    
    //从scrollView上移除所有的subview
    NSArray *subViews = [_scrollView subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    if (aCurPage != 1) { //当等于第二个时，不删除
        UIView *firstView = [_usedViews objectAtIndex:0];
        [_usedViews removeObject:firstView];
        [_reuseableViews addObject:firstView];
    }
    
    if (aCurPage == _totalPages-1) {
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 2, self.bounds.size.height);
    } else {
        [_usedViews addObject:[_dataSource scrollView:self viewAtIndex:[self validPageValue:aCurPage+1]]];
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
    }
    
    for (int i = 0; i < _usedViews.count; i++) {
        UIView *v = [_usedViews objectAtIndex:i];
        v.tag = 100+aCurPage-1+i;
        v.userInteractionEnabled = YES;
        v.frame = CGRectMake(v.frame.size.width * i, 0, v.frame.size.width, v.frame.size.height);
        [_scrollView addSubview:v];
    }
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    //NSLog(@"_usedViews: %d", _usedViews.count);
}

- (void)loadPreData:(NSInteger)aCurPage {
    //NSLog(@"loadPreData: %d",aCurPage);
    _pageControl.currentPage = aCurPage;
    
    if ([_dataSource respondsToSelector:@selector(pageChanged:)]) {
        [_dataSource pageChanged:_pageControl];
    }
    
    //从scrollView上移除所有的subview
    NSArray *subViews = [_scrollView subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    if (aCurPage != _totalPages-2) { //当等于倒数第二个时，不删除
        UIView *lastView = [_usedViews lastObject];
        [_usedViews removeObject:lastView];
        [_reuseableViews addObject:lastView];
    }
    
    if(aCurPage == 0){
         _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 2, self.bounds.size.height);
    } else {
        [_usedViews insertObject:[_dataSource scrollView:self viewAtIndex:[self validPageValue:aCurPage-1]] atIndex:0];
        _scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
    }
    
    for (int i = 0; i < _usedViews.count; i++) {
        UIView *v = [_usedViews objectAtIndex:i];
        v.tag = 100+aCurPage-1+i;
        v.userInteractionEnabled = YES;
        v.frame = CGRectMake(v.frame.size.width * i, 0, v.frame.size.width, v.frame.size.height);
        [_scrollView addSubview:v];
    }
    if(aCurPage == 0){
        [_scrollView setContentOffset:CGPointMake(0, 0)];
    } else {
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    }
    //NSLog(@"_usedViews: %d", _usedViews.count);
}

- (NSInteger)validPageValue:(NSInteger)value
{
    if(value == -1)
        value = _totalPages - 1;
    
    if(value == _totalPages)
        value = 0;
    
    return value;
}

- (id)dequeueReusableView
{
    if ([_reuseableViews count] == 0) {
        return nil;
    } else {
        id temp = [_reuseableViews objectAtIndex:0];
        [_reuseableViews removeObjectAtIndex:0];
        return temp;
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    int x = aScrollView.contentOffset.x;
    //NSLog(@"ScrollContentoffset: %d",x);
    
    //往下翻一张
    if(_curPage == 0){
        if(x >= self.frame.size.width) {
            //NSLog(@"scrollViewDidScroll");
            _curPage = [self validPageValue:_curPage+1];
            [self loadNextData:_curPage];
            
            if (_scrollDelegate != nil && [_scrollDelegate respondsToSelector:@selector(scrollDidStopAtIndex:)]) {
                [_scrollDelegate scrollDidStopAtIndex:_curPage];
            }
        }
    } else {
        if(x >= (2*self.frame.size.width)) {
            if(_curPage == _totalPages-1){
                return;
            }
            //NSLog(@"scrollViewDidScroll");
            _curPage = [self validPageValue:_curPage+1];
            [self loadNextData:_curPage];
            
            if (_scrollDelegate != nil && [_scrollDelegate respondsToSelector:@selector(scrollDidStopAtIndex:)]) {
                [_scrollDelegate scrollDidStopAtIndex:_curPage];
            }
        }
    }
    
    //往上翻
    if(x <= 0) {       
        if(_curPage == 0){
            return;
        }
        //NSLog(@"scrollViewDidScroll");
        _curPage = [self validPageValue:_curPage-1];
        [self loadPreData:_curPage];
        
        if (_scrollDelegate != nil && [_scrollDelegate respondsToSelector:@selector(scrollDidStopAtIndex:)]) {
            [_scrollDelegate scrollDidStopAtIndex:_curPage];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    NSLog(@"scrollViewDidEndDecelerating");
    if (_curPage == 0) {
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    } else {
       [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:YES];
    }
}

-(NSMutableArray *)currentUsedViews{
    return _usedViews;
}

-(void)dealloc{
    NSLog(@"CustomScrollView dealloc");
    _scrollView.delegate = nil;
}

@end
