//
//  FavouritesViewController.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "FavouritesViewController.h"
#import "MovieCell.h"
#import "MovieDetailsViewController.h"

@interface FavouritesViewController ()<AMCollectionHelperDelegate>

@property (nonatomic) ObjectsContainer *container;
@property (nonatomic) AMCollectionHelper *collectionHelper;

@end

@implementation FavouritesViewController

- (instancetype)initWithContainer:(ObjectsContainer *)container {
    if (self = [super init]) {
        self.title = @"Favourites";
        _container = container;
        
        __weak typeof(self) wSelf = self;
        [ObjectsContainer addUpdatesObserver:self block:^(AMNotification *not) {
            if (not.object == wSelf.container) {
                [wSelf reloadBadge];
                [wSelf reloadViewAnimated:NO];
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadBadge];
        });
    }
    return self;
}

- (void)reloadBadge {
    NSUInteger count = _container.objectsCount;
    self.navigationController.tabBarItem.badgeValue = count ? [NSString stringWithFormat:@"%d", (int)count] : nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _collectionHelper = [[AMCollectionHelper alloc] initWithView:self.view delegate:self];
    _collectionHelper.noObjectsView.titleLabel.text = @"No Favorites";
    
    CGFloat space = 15;
    _collectionHelper.layout.minimumInteritemSpacing = space;
    _collectionHelper.layout.sectionInset = UIEdgeInsetsMake(space, space, space, space);
    
    [self reloadViewAnimated:NO];
}

- (void)reloadViewAnimated:(BOOL)animated {
    [self.collectionHelper setObjects:[_container allObjectsIn:AppContainer.shared.database.viewContext] animated:animated];
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
    return [MovieCell sizeForContentWidth:self.collectionHelper.collectionView.width space:15];
}

@end
