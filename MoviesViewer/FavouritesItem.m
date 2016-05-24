//
//  FavouritesItem.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 17/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "FavouritesItem.h"
#import "FavouritesManager.h"

@interface FavouritesItem()

@property (nonatomic) Movie *movie;

@end

@implementation FavouritesItem

- (instancetype)initWithMovie:(Movie *)movie {
    if (self = [super initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(favouriteAction)]) {
        [[FavouritesManager sharedManager] addUpdatesObserver:self selector:@selector(reloadState)];
        self.movie = movie;
    }
    return self;
}

- (void)setMovie:(Movie *)movie {
    _movie = movie;
    [self reloadState];
}

- (void)reloadState {
    self.image = [UIImage imageNamed:[[FavouritesManager sharedManager] isMovieFavourite:_movie] ? @"favouriteOn" : @"favouriteOff"];
}

- (void)favouriteAction {
    if ([[FavouritesManager sharedManager] isMovieFavourite:_movie]) {
        [[FavouritesManager sharedManager] removeMovie:_movie];
    } else {
        [[FavouritesManager sharedManager] addMovie:_movie];
    }
}

- (void)dealloc {
    [[FavouritesManager sharedManager] removeUpdatesObserver:self];
}

@end
