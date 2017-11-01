//
//  ExploreViewController.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "ExploreViewController.h"
#import "MovieCell.h"
#import "MovieDetailsViewController.h"
#import "SearchViewController.h"

@interface ExploreViewController ()<AMCollectionHelperDelegate>

@property (nonatomic) AMCollectionHelper *collectionHelper;
@property (nonatomic) SearchViewController *searchVC;

@end

@implementation ExploreViewController

- (instancetype)init {
    if (self = [super init]) {
        _searchVC = [[SearchViewController alloc] initWithRootViewController:self];
        self.title = @"Search";
        self.definesPresentationContext = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _collectionHelper = [[AMCollectionHelper alloc] initWithView:self.view delegate:self];
    
    CGFloat space = 15;
    _collectionHelper.layout.minimumInteritemSpacing = space;
    _collectionHelper.layout.sectionInset = UIEdgeInsetsMake(space, space, space, space);
    _collectionHelper.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = _searchVC.searchController;
    } else {
        // container view for UISearchBar is needed to fix issue of missing Cancel button on iPad
        UIView *view = [[UIView alloc] initWithFrame:_searchVC.searchController.searchBar.bounds];
        view.backgroundColor = [UIColor clearColor];
        [_searchVC.searchController.searchBar setBackgroundImage:[UIImage new]];
        _searchVC.searchController.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view addSubview:_searchVC.searchController.searchBar];
        self.navigationItem.titleView = view;
    }
    
    NSArray *allMovies = [Movie allObjectsSortedBy:@"uid" context:AppContainer.shared.database.viewContext];
    [_collectionHelper setObjects:[allMovies subarrayWithRange:NSMakeRange(0, MIN(18, allMovies.count))] animated:NO];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.hidesSearchBarWhenScrolling = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.navigationItem.hidesSearchBarWhenScrolling = YES;
        });
    }
}

#pragma mark AMCollectionHelperDelegate

- (Class)cellClassFor:(id)object {
    return [MovieCell class];
}

- (void)fillCell:(MovieCell *)cell object:(id)object {
    cell.movie = object;
}

- (BOOL)actionFor:(id)object {
    [self.navigationController pushViewController:[[MovieDetailsViewController alloc] initWithMovie:object] animated:YES];
    return YES;
}

- (CGSize)cellSizeFor:(id)object {
    return [MovieCell sizeForContentWidth:_collectionHelper.collectionView.width space:15];
}

@end
