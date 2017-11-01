//
//  AMPagingLoader.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 12/05/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMPagingLoader.h"
#import "UIView+LoadingFromFrameworkNib.h"

NSString * const kContentOffsetKey = @"contentOffset";

@interface AMPagingLoader ()

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) AMFooterLoadingView *footerLoadingView;
@property (nonatomic) BOOL performedLoading;
@property (nonatomic) BOOL isLoading;
@property (nonatomic) BOOL shouldEndRefreshing;
@property (nonatomic) BOOL shouldBeginRefreshing;
@property (nonatomic, weak) id<AMPagingLoaderDelegate> delegate;

@property (nonatomic) void(^scrollOnRefreshing)(UIRefreshControl *control);
@property (nonatomic) void(^setFooterVisible)(BOOL visible, UIView *footerView);

@end

@implementation AMPagingLoader

- (instancetype)initWithScrollView:(UIScrollView *)scrollView
                          delegate:(id<AMPagingLoaderDelegate>)delegate
                 addRefreshControl:(void(^)(UIRefreshControl *control))addControl
                scrollOnRefreshing:(void(^)(UIRefreshControl *control))scrollOnRefreshing
                  setFooterVisible:(void(^)(BOOL visible, UIView *footerView))setFooterVisible {
    
    if (self = [self init]) {
        _scrollView = scrollView;
        _delegate = delegate;
        _scrollOnRefreshing = scrollOnRefreshing;
        _setFooterVisible = setFooterVisible;
        
        if ((![self.delegate respondsToSelector:@selector(hasRefreshControl)] || [self.delegate hasRefreshControl]) &&
            addControl) {
            _refreshControl = [UIRefreshControl new];
            [_refreshControl addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventValueChanged];
            addControl(_refreshControl);
        }
        
        self.footerLoadingClass = _footerLoadingClass;
        if ([self.delegate respondsToSelector:@selector(loadFirstPageFromCache)]) {
            _fetchedItems = [self.delegate loadFirstPageFromCache];
        }
        
        [scrollView addObserver:self
                     forKeyPath:kContentOffsetKey
                        options:NSKeyValueObservingOptionNew
                        context:nil];
    }
    return self;
}

- (void)setFooterLoadingClass:(Class)footerLoadingClass {
    _footerLoadingClass = footerLoadingClass;
    _footerLoadingView = [_footerLoadingClass ?: [AMFooterLoadingView class] loadFromFrameworkNib];
    __weak typeof(self) weakSelf = self;
    _footerLoadingView.retryAction = ^{
        [weakSelf loadMore];
    };
}

- (void)refreshFromBeginning:(BOOL)showRefreshControl {
    if (showRefreshControl) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadFromBeginningWithRefreshControl:_refreshControl];
        });
        if (_scrollOnRefreshing) {
            _scrollOnRefreshing(_refreshControl);
        }
    } else {
        [self loadFromBeginningWithRefreshControl:nil];
    }
}

- (void)refreshAction {
    _shouldBeginRefreshing = YES;
}

- (void)loadMore {
    _performedLoading = YES;
    
    __weak typeof(self) weakSelf = self;
    _footerLoadingView.state = AMFooterStateLoading;
    
    _isLoading = YES;
    [self.delegate loadWithOffset:_offset completion:^(NSArray *objects, NSError *error, id newOffset) {
        weakSelf.isLoading = NO;
        if (error) {
            if (error.code == NSURLErrorCancelled) {
                weakSelf.footerLoadingView.state = AMFooterStateStop;
            } else {
                weakSelf.footerLoadingView.state = AMFooterStateFailed;
            }
        } else {
            if (objects.count && newOffset) {
                weakSelf.performedLoading = NO;
            } else {
                [UIView animateWithDuration:0.25 animations:^{
                    if (weakSelf.setFooterVisible) {
                        weakSelf.setFooterVisible(NO, weakSelf.footerLoadingView);
                    }
                }];
            }
            weakSelf.offset = newOffset;
            [weakSelf appendFetchedItems:objects animated:NO];
            weakSelf.footerLoadingView.state = AMFooterStateStop;
        }
    }];
}

- (void)appendFetchedItems:(NSArray *)items animated:(BOOL)animated {
    NSMutableArray *array = [self.fetchedItems mutableCopy];
    if (!array) {
        array = [NSMutableArray array];
    }
    for (id object in items) {
        if (![array containsObject:object]) {
            [array addObject:object];
        }
    }
    self.fetchedItems = array;
    [self.delegate reloadView:animated];
}

- (void)loadFromBeginningWithRefreshControl:(UIRefreshControl *)refreshControl {
    __weak typeof(self) weakSelf = self;
    
    if ([self.delegate respondsToSelector:@selector(performOnRefresh)]) {
        [self.delegate performOnRefresh];
    }
    
    _isLoading = YES;
    if (_setFooterVisible) {
        _setFooterVisible(YES, _footerLoadingView);
    }
    _footerLoadingView.state = AMFooterStateStop;
    
    if (!refreshControl) {
        if (!_fetchedItems.count) {
            _footerLoadingView.state = AMFooterStateLoading;
        }
    } else if (!refreshControl.isRefreshing) {
        [refreshControl beginRefreshing];
        _scrollOnRefreshing(_refreshControl);
    }
    
    [self.delegate loadWithOffset:nil completion:^(NSArray *objects, NSError *error, id newOffset) {
        weakSelf.isLoading = NO;
        if (error) {
            if (error.code != NSURLErrorCancelled) {
                weakSelf.footerLoadingView.state = AMFooterStateFailed;
                if (refreshControl && weakSelf.processPullToRefreshError) {
                    weakSelf.processPullToRefreshError(error);
                }
            } else {
                weakSelf.footerLoadingView.state = AMFooterStateStop;
            }
            [weakSelf.delegate reloadView:NO];
        } else {
            weakSelf.offset = newOffset;
            NSArray *oldObject = weakSelf.fetchedItems;
            weakSelf.fetchedItems = nil;
            
            [weakSelf appendFetchedItems:objects animated:[oldObject count]];
            if ([weakSelf.delegate respondsToSelector:@selector(saveFirstPageInCache:)]) {
                [weakSelf.delegate saveFirstPageInCache:objects];
            }
            weakSelf.footerLoadingView.state = AMFooterStateStop;
            if (!weakSelf.offset) {
                if (weakSelf.setFooterVisible) {
                    weakSelf.setFooterVisible(NO, weakSelf.footerLoadingView);
                }
            }
        }
        [weakSelf endRefreshing];
    }];
}

- (void)endRefreshing {
    if (_scrollView.isDecelerating || _scrollView.isDragging) {
        _shouldEndRefreshing = YES;
    } else {
        if (_scrollView.window && [_refreshControl isRefreshing]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [_refreshControl endRefreshing];
            });
        } else {
            [_refreshControl endRefreshing];
        }
    }
}

- (void)validateFetchedItems:(BOOL(^)(id object))block {
    NSMutableArray *items = [self.fetchedItems mutableCopy];
    for (id object in [items copy]) {
        if (!block(object)) {
            [items removeObject:object];
        }
    }
    self.fetchedItems = items;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    BOOL shouldLoadMore = NO;
    
    if (![_delegate respondsToSelector:@selector(shouldLoadMore)] || [_delegate shouldLoadMore]) {
        shouldLoadMore = YES;
    }
    
    if ([keyPath isEqualToString:kContentOffsetKey] && shouldLoadMore) {
        // on scroll view did scroll
        
        if (_footerLoadingView.state == AMFooterStateFailed && ![self isFooterVisible]) {
            _footerLoadingView.state = AMFooterStateStop;
        }
        
        if (_footerLoadingView.state != AMFooterStateFailed &&
            _footerLoadingView.state != AMFooterStateLoading &&
            _performedLoading == NO &&
            !_isLoading &&
            [self isFooterVisible]) {
            
            [self loadMore];
        }
    }
}

- (BOOL)isFooterVisible {
    if ([_scrollView.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_scrollView.delegate scrollViewDidScroll:_scrollView];
    }
    
    CGRect frame = [_scrollView convertRect:_footerLoadingView.bounds fromView:_footerLoadingView];
    frame.origin.x -= _footerLoadingInset.width;
    frame.size.width += _footerLoadingInset.width;
    frame.origin.y -= _footerLoadingInset.height;
    frame.size.height += _footerLoadingInset.height;
    
    return (_footerLoadingView &&
            [_footerLoadingView isDescendantOfView:_scrollView] &&
            (_scrollView.contentSize.height > _scrollView.frame.size.height ||
             _scrollView.contentSize.width > _scrollView.frame.size.width ||
             /*_fetchedItems.count */_scrollView.contentSize.height > 0) &&
            CGRectIntersectsRect(_scrollView.bounds,frame));
}

- (void)endDecelerating {
    _performedLoading = NO;
    if (_shouldEndRefreshing && !_scrollView.isDecelerating && !_scrollView.isDragging) {
        _shouldEndRefreshing = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [_refreshControl endRefreshing];
        });
    }
    if (_shouldBeginRefreshing) {
        _shouldBeginRefreshing = NO;
        [self loadFromBeginningWithRefreshControl:_refreshControl];
    }
}

- (void)dealloc {
    [_scrollView removeObserver:self forKeyPath:kContentOffsetKey];
}

@end
