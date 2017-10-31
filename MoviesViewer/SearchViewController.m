//
//  SearchViewController.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "SearchViewController.h"
#import "MovieCell.h"
#import "SearchRequest.h"
#import "MovieDetailsViewController.h"

@interface SearchViewController ()<UISearchResultsUpdating, AMCollectionHelperDelegate, AMPagingLoaderDelegate>

@property (nonatomic) AMPagingCollectionHelper *collectionHelper;
@property (nonatomic) UISearchController *searchController;
@property (nonatomic, weak) UIViewController *rootViewController;
@property (nonatomic) NSString *lastSearchTerm;

@end

@implementation SearchViewController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    if (self = [super init]) {
        _rootViewController = rootViewController;
        
        _searchController = [[UISearchController alloc] initWithSearchResultsController:self];
        _searchController.searchResultsUpdater = self;
        _searchController.hidesNavigationBarDuringPresentation = NO;
        _searchController.dimsBackgroundDuringPresentation = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.operationHelper = [[AMOperationHelper alloc] initWithView:self.view];
    _collectionHelper = [[AMPagingCollectionHelper alloc] initWithView:self.view delegate:self];
    _collectionHelper.noObjectsView.titleLabel.text = @"No Results";
    
    CGFloat space = 15;
    _collectionHelper.layout.minimumInteritemSpacing = space;
    _collectionHelper.layout.sectionInset = UIEdgeInsetsMake(space, space, space, space);
}

#pragma mark AMCollectionHelperDelegate

- (Class)cellClassFor:(id)object {
    return [MovieCell class];
}

- (void)fillCell:(MovieCell *)cell object:(id)object {
    cell.movie = object;
}

- (BOOL)actionFor:(id)object {
    [_rootViewController.navigationController pushViewController:[[MovieDetailsViewController alloc] initWithMovie:object] animated:YES];
    return YES;
}

- (CGSize)cellSizeFor:(id)object {
    return [MovieCell sizeForContentWidth:_collectionHelper.collectionView.width space:15];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _collectionHelper.collectionView.scrollIndicatorInsets = _collectionHelper.collectionView.contentInset; //fix indicators insets bug on ios 9
}

- (BOOL)needsToShowNoObjectsView {
    return _searchController.searchBar.text.length && !_collectionHelper.loader.fetchedItems.count;
}

#pragma mark AMPagingLoaderDelegate

- (void)reloadView:(BOOL)animated {
    [_collectionHelper setObjects:_collectionHelper.loader.fetchedItems animated:NO];
}

- (void)loadWithOffset:(id)offset completion:(void(^)(NSArray *objects, NSError *error, id newOffset))completion {
    __weak typeof(self) wSelf = self;
    [self.operationHelper runBlock:^(AMCompletion completion, AMHandleOperation operation, AMProgress progress) {
        
        SearchRequest *request = [SearchRequest new];
        request.query = wSelf.searchController.searchBar.text;
        request.page = offset;
        operation([request send:completion]);
        
    } completion:^(SearchRequest *request, NSError *requestError) {
        completion([NSManagedObject objectsWithIds:request.results context:AppContainer.shared.database.viewContext], requestError, request.updatedPage);
        
    } loading:self.collectionHelper.loader.fetchedItems.count ? AMLoadingTypeNone : AMLoadingTypeFullscreen key:@"feed"];
}

- (BOOL)hasRefreshControl {
    return NO;
}

#pragma mark UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if ([_searchController.searchBar.text isEqualToString:_lastSearchTerm]) {
        return;
    }
    
    [self.operationHelper cancellOperations];
    _lastSearchTerm = searchController.searchBar.text;
    
    if (searchController.searchBar.text.length > 2) {
        [_collectionHelper.loader refreshFromBeginning:NO];
    }
}

@end
