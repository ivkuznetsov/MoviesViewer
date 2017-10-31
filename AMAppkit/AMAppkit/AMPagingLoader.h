//
//  AMPagingLoader.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 12/05/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMFooterLoadingView.h"
#import "AMAppearanceSupportObject.h"

@protocol AMPagingLoaderDelegate <NSObject>

- (void)reloadView:(BOOL)animated;
- (void)loadWithOffset:(id)offset completion:(void(^)(NSArray *objects, NSError *error, id newOffset))completion;

@optional
- (void)performOnRefresh; // use this to perform additional actions on refresh control pulling
- (BOOL)hasRefreshControl; // YES by default
- (BOOL)shouldLoadMore;

- (Class)pagingLoaderClass; // subclass of AMPagingLoader

// cache
- (void)saveFirstPageInCache:(NSArray *)objects;
- (NSArray *)loadFirstPageFromCache;

@end

@interface AMPagingLoader : AMAppearanceSupportObject

@property (nonatomic) void(^processPullToRefreshError)(NSError *error); //AMAppearance Support

@property (nonatomic, readonly) UIRefreshControl *refreshControl;
@property (nonatomic) CGSize footerLoadingInset; // additional inset from which start to load more

@property (nonatomic) Class footerLoadingClass; // AMFooterLoadingView subclasses //AMAppearance Support
@property (nonatomic, readonly) AMFooterLoadingView *footerLoadingView;

@property (nonatomic, readonly) BOOL isLoading;

@property (nonatomic) NSArray *fetchedItems;
@property (nonatomic) id offset;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView
                          delegate:(id<AMPagingLoaderDelegate>)delegate
                 addRefreshControl:(void(^)(UIRefreshControl *control))addControl
                scrollOnRefreshing:(void(^)(UIRefreshControl *control))scrollOnRefreshing
                  setFooterVisible:(void(^)(BOOL visible, UIView *footerView))setFooterVisible;

// manually reload starting from the first page, usualy you should run this method in viewDidLoad or viewWillAppear
- (void)refreshFromBeginning:(BOOL)showRefreshControl;

// iterates through fetched items and deletes the ones hasn't been validated. You can use this method for deleting objects, that no longer exist in database.
- (void)validateFetchedItems:(BOOL(^)(id object))block;

// load new page manually
- (void)loadMore;
// customize adding items behaviour in subclass if needed
- (void)appendFetchedItems:(NSArray *)items animated:(BOOL)animated; // append items to the end

@end
