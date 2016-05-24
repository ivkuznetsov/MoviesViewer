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

@interface SearchViewController ()<UISearchResultsUpdating>

@property (nonatomic) BOOL endReached;
@property (nonatomic) BOOL performedLoading;
@property (nonatomic) NSString *lastSearchTerm;
@property (nonatomic) NSUInteger currentPage;
@property (nonatomic) UISearchController *searchController;
@property (nonatomic, weak) UIViewController *rootViewController;

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

- (Class)cellClassForObjects:(id)object {
    return [MovieCell class];
}

- (void)fillCell:(MovieCell *)cell withObject:(id)object {
    cell.movie = object;
}

- (void)actionForObject:(id)object {
    [_rootViewController.navigationController pushViewController:[[MovieDetailsViewController alloc] initWithMovie:object] animated:YES];
}

- (CGSize)cellSizeForObject:(id)object {
    return [MovieCell sizeForContentWidth:self.collectionView.width - 20];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.collectionView.scrollIndicatorInsets = self.collectionView.contentInset; //fix indicators insets bug on ios 9
}

#pragma mark UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if ([searchController.searchBar.text isEqualToString:_lastSearchTerm]) {
        return;
    }
    
    _currentPage = 1;
    _endReached = NO;
    _lastSearchTerm = searchController.searchBar.text;
    [self.currentOperation cancel];
    if (searchController.searchBar.text.length > 2) {
        self.view.backgroundColor = [UIColor whiteColor];
        __weak typeof(self) weakSelf = self;
        [self runBlock:^(CompletionBlock completion, HandleOperation handleOperation) {
            
            SearchRequest *request = [SearchRequest new];
            request.query = searchController.searchBar.text;
            request.page = _currentPage;
            handleOperation([[ServiceProvider sharedProvider] sendRequest:request withCompletionBlock:completion]);
            
        } completion:^(SearchRequest *request, NSError *error) {
            
            if (!error || error.code != NSURLErrorCancelled) {
                [weakSelf setObjects:[NSManagedObject objectsWithObjectIds:request.results]];
            }
            
        } loading:self.objects.count ? LoadingTypeNone : LoadingTypeFull errorType:ErrorTypeFull];
        
    } else {
        self.view.backgroundColor = [UIColor clearColor];
        [self setObjects:nil];
    }
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _performedLoading = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentSize.height >= scrollView.height &&
        _performedLoading == NO &&
        !self.currentOperation &&
        !_endReached &&
        _lastSearchTerm.length > 2 &&
        scrollView.contentOffset.y > (scrollView.contentSize.height - scrollView.height)) {
        
        [self loadMore];
    }
}

- (void)loadMore {
    _performedLoading = YES;
    __weak typeof(self) weakSelf = self;
    NSUInteger newPage =  weakSelf.currentPage + 1;
    [self runBlock:^(CompletionBlock completion, HandleOperation handleOperation) {
        
        SearchRequest *request = [SearchRequest new];
        request.query = weakSelf.lastSearchTerm;
        request.page = newPage;
        handleOperation([[ServiceProvider sharedProvider] sendRequest:request withCompletionBlock:completion]);
        
    } completion:^(SearchRequest *request, NSError *error) {
        
        if (request.results.count) {
            weakSelf.performedLoading = NO;
            [weakSelf appendFetchedItems:[NSManagedObject objectsWithObjectIds:request.results]];
        } else {
            weakSelf.endReached = YES;
        }
        if (!error) {
            weakSelf.currentPage = newPage;
        }
        
    } loading:self.objects.count ? LoadingTypeNone : LoadingTypeNone errorType:ErrorTypeNone];
}

- (void)appendFetchedItems:(NSArray *)items {
    NSMutableArray *array = [self.objects mutableCopy];
    for (id object in items) {
        if (![array containsObject:object]) {
            [array addObject:object];
        }
    }
    [self setObjects:array animated:YES];
}

@end
