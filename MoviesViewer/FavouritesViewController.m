//
//  FavouritesViewController.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "FavouritesViewController.h"
#import "FavouritesManager.h"
#import "MovieCell.h"
#import "MovieDetailsViewController.h"
#import "CategoryCell.h"

@interface FavouritesViewController ()

@end

@implementation FavouritesViewController

- (instancetype)init {
    if (self = [super init]) {
        self.title = @"Favourites";
        [[FavouritesManager sharedManager] addUpdatesObserver:self selector:@selector(didUpdateFavourites)];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadBadge];
        });
    }
    return self;
}

- (void)reloadBadge {
    NSUInteger count = [FavouritesManager sharedManager].favouritesCount;
    self.navigationController.tabBarItem.badgeValue = count ? [NSString stringWithFormat:@"%d", (int)count] : nil;
}

- (void)didUpdateFavourites {
    [self reloadBadge];
    [self reloadViewAnimated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadViewAnimated:NO];
}

- (void)reloadViewAnimated:(BOOL)animated {
    NSSet *set = [FavouritesManager sharedManager].favouriteObjects;
    
    NSMutableSet *hasNoCategory = [NSMutableSet set];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSMutableArray *categories = [NSMutableArray array];
    for (Movie *movie in set) {
        if (!movie.category.uid) {
            [hasNoCategory addObject:movie];
            continue;
        }
        
        NSMutableSet *objectsSet = dictionary[movie.category.uid];
        if (!objectsSet) {
            objectsSet = [NSMutableSet set];
            dictionary[movie.category.uid] = objectsSet;
            [categories addObject:movie.category];
        }
        [objectsSet addObject:movie];
    }
    
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    
    NSMutableArray *objects = [NSMutableArray array];
    for (MovieCategory *category in [categories sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:YES]]]) {
        [objects addObject:category];
        [objects addObjectsFromArray:[dictionary[category.uid] sortedArrayUsingDescriptors:sortDescriptors]];
    }
    [objects addObjectsFromArray:[hasNoCategory sortedArrayUsingDescriptors:sortDescriptors]];
    
    [self setObjects:objects animated:animated];
}

- (Class)cellClassForObjects:(id)object {
    if ([object isKindOfClass:[Movie class]]) {
        return [MovieCell class];
    } else if ([object isKindOfClass:[MovieCategory class]]) {
        return [CategoryCell class];
    }
    return nil;
}

- (void)fillCell:(UICollectionViewCell *)cell withObject:(id)object {
    if ([object isKindOfClass:[Movie class]]) {
        ((MovieCell *)cell).movie = object;
    } else if ([object isKindOfClass:[MovieCategory class]]) {
        ((CategoryCell *)cell).titleLabel.text = [object title];
    }
}

- (void)actionForObject:(id)object {
    if ([object isKindOfClass:[Movie class]]) {
        [self.navigationController pushViewController:[[MovieDetailsViewController alloc] initWithMovie:object] animated:YES];
    }
}

- (CGSize)cellSizeForObject:(id)object {
    if ([object isKindOfClass:[Movie class]]) {
        return [MovieCell sizeForContentWidth:self.collectionView.width - 20];
    } else {
        return CGSizeMake(self.collectionView.width - 20, 40);
    }
}

- (void)dealloc {
    [[FavouritesManager sharedManager] removeUpdatesObserver:self];
}

@end
