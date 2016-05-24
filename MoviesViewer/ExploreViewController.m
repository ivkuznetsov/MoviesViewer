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

@interface ExploreViewController ()

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
    
    // container view for UISearchBar is needed to fix issue of missing Cancel button on iPad
    UIView *view = [[UIView alloc] initWithFrame:_searchVC.searchController.searchBar.bounds];
    view.backgroundColor = [UIColor clearColor];
    [_searchVC.searchController.searchBar setBackgroundImage:[UIImage new]];
    _searchVC.searchController.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view addSubview:_searchVC.searchController.searchBar];
    self.navigationItem.titleView = view;
    
    NSArray *allMovies = [Movie allObjects];
    self.objects = [allMovies subarrayWithRange:NSMakeRange(0, MIN(18, allMovies.count))];
}

- (Class)cellClassForObjects:(id)object {
    return [MovieCell class];
}

- (void)fillCell:(MovieCell *)cell withObject:(id)object {
    cell.movie = object;
}

- (void)actionForObject:(id)object {
    [self.navigationController pushViewController:[[MovieDetailsViewController alloc] initWithMovie:object] animated:YES];
}

- (CGSize)cellSizeForObject:(id)object {
    return [MovieCell sizeForContentWidth:self.collectionView.width - 20];
}

@end