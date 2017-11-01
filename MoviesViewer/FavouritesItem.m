//
//  FavouritesItem.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 17/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "FavouritesItem.h"

@interface FavouritesItem()

@property (nonatomic) Movie *movie;
@property (nonatomic) ObjectsContainer *container;

@end

@implementation FavouritesItem

- (instancetype)initWithMovie:(Movie *)movie container:(ObjectsContainer *)container {
    if (self = [super initWithImage:nil style:UIBarButtonItemStylePlain target:self action:@selector(favouriteAction)]) {
        _container = container;
        self.movie = movie;
        
        __weak typeof(self) wSelf = self;
        [ObjectsContainer addUpdatesObserver:self block:^(AMNotification *not) {
            if (not.object == wSelf.container) {
                [wSelf reloadState];
            }
        }];
    }
    return self;
}

- (void)setMovie:(Movie *)movie {
    _movie = movie;
    [self reloadState];
}

- (void)reloadState {
    self.image = [UIImage imageNamed:[_container isFavourite:_movie] ? @"favouriteOn" : @"favouriteOff"];
}

- (void)favouriteAction {
    if ([_container isFavourite:_movie]) {
        [_container remove:_movie];
    } else {
        [_container add:_movie];
    }
}

@end
