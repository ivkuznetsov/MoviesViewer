//
//  AMPagingTableHelper.m
//  AMAppkit
//
//  Created by Ilya Kuznecov on 05/02/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMPagingTableHelper.h"
#import "PrivateTableViewController.h"
#import "UIView+LoadingFromFrameworkNib.h"

@interface AMPagingLoader()

- (void)endDecelerating;

@end

@interface AMTableHelper()

@property (nonatomic, readonly) id<AMPagingLoaderDelegate, AMTableHelperDelegate> delegate;

- (void)setup;

@end

@interface AMPagingTableHelper()

@property (nonatomic) AMPagingLoader *loader;
@property (nonatomic) UITableViewController *tableVC;

@end

@implementation AMPagingTableHelper

- (void)setup {
    [super setup];
    
    self.tableView.tableFooterView = [UIView new];
    
    Class loaderClass = [self.delegate respondsToSelector:@selector(pagingLoaderClass)] ? [self.delegate pagingLoaderClass] : [AMPagingLoader class];
    
    __weak typeof(self) wSelf = self;
    _loader = [[loaderClass alloc] initWithScrollView:self.tableView
                                             delegate:self.delegate
                                    addRefreshControl:^(UIRefreshControl *control) {
                                        
                                        wSelf.tableVC = [PrivateTableViewController new];
                                        wSelf.tableVC.automaticallyAdjustsScrollViewInsets = NO;
                                        wSelf.tableVC.refreshControl = control;
                                        [wSelf.tableView insertSubview:control atIndex:0];
                                    
                                    } scrollOnRefreshing:^(UIRefreshControl *control) {
                                        
                                        wSelf.tableView.contentOffset = CGPointMake(0, -control.bounds.size.height);
                                    
                                    } setFooterVisible:^(BOOL visible, UIView *footerView) {
                                        
                                        if (visible) {
                                            wSelf.tableView.tableFooterView = footerView;
                                        } else {
                                            wSelf.tableView.tableFooterView = [UIView new];
                                        }
                                    }];
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

@end
