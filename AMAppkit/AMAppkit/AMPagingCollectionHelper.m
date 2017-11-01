//
//  AMPagingCollectionHelper.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 12/05/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMPagingCollectionHelper.h"
#import "UIView+LoadingFromFrameworkNib.h"

@interface AMPagingLoader()

- (void)endDecelerating;

@end

@interface AMCollectionHelper()

@property (nonatomic, readonly) id<AMPagingLoaderDelegate, AMCollectionHelperDelegate> delegate;

- (void)setup;

@end

@interface AMPagingCollectionHelper()

@property (nonatomic) AMPagingLoader *loader;

@end

@implementation AMPagingCollectionHelper

- (void)setup {
    [super setup];
    
    Class loaderClass = [self.delegate respondsToSelector:@selector(pagingLoaderClass)] ? [self.delegate pagingLoaderClass] : [AMPagingLoader class];
    
    __weak typeof(self) wSelf = self;
    _loader = [[loaderClass alloc] initWithScrollView:self.collectionView
                                             delegate:self.delegate
                                    addRefreshControl:^(UIRefreshControl *control) {
                                        
                                        if ([wSelf isVertical]) {
                                            [wSelf.collectionView insertSubview:control atIndex:0];
                                        }
                                    
                                    } scrollOnRefreshing:^(UIRefreshControl *control) {
                                        
                                        if ([wSelf isVertical]) {
                                            wSelf.collectionView.contentOffset = CGPointMake(0, -control.bounds.size.height);
                                        } else {
                                            wSelf.collectionView.contentOffset = CGPointMake(-control.bounds.size.width, 0);
                                        }
                                    } setFooterVisible:^(BOOL visible, UIView *footerView) {
                                        
                                        UIEdgeInsets insets = wSelf.collectionView.contentInset;
                                        
                                        if (visible) {
                                            [wSelf.collectionView addSubview:footerView];
                                            if ([wSelf isVertical]) {
                                                footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
                                                insets.bottom = footerView.frame.size.height;
                                            } else {
                                                insets.right = footerView.frame.size.width;
                                            }
                                        } else {
                                            [footerView removeFromSuperview];
                                            if ([wSelf isVertical]) {
                                                insets.bottom = 0;
                                            } else {
                                                insets.right = 0;
                                            }
                                        }
                                        wSelf.collectionView.contentInset = insets;
                                        [wSelf reloadFooterPosition];
                                    }];
}

- (BOOL)isVertical {
    return [self layout].scrollDirection == UICollectionViewScrollDirectionVertical;
}

- (void)reloadFooterPosition {
    CGSize contentSize = [self.collectionView.collectionViewLayout collectionViewContentSize];
    
    if ([self isVertical]) {
        self.loader.footerLoadingView.center = CGPointMake(contentSize.width / 2.0,
                                                           contentSize.height + self.loader.footerLoadingView.frame.size.height / 2.0);
    } else {
        self.loader.footerLoadingView.center = CGPointMake(contentSize.width + self.loader.footerLoadingView.frame.size.width / 2.0,
                                                           contentSize.height / 2.0);
    }
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [_loader endDecelerating];
    
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [_loader endDecelerating];
    }
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self reloadFooterPosition];
    
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
}

@end
