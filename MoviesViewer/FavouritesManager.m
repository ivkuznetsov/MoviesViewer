//
//  FavouritesManager.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 17/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "FavouritesManager.h"
#import "NSMutableArray+Validation.h"

#define kFavouritesManagerUpdateNotification @"kFavouritesManagerUpdateNotification"
#define kFavouritesManagerSaveKey @"kFavouritesManagerSaveKey"

@interface FavouritesManager()

@property (nonatomic) NSMutableSet *objects;

@end

@implementation FavouritesManager

+ (instancetype)sharedManager {
    static dispatch_once_t once;
    static FavouritesManager *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:kFavouritesManagerSaveKey];
        if (array) {
            _objects = [NSMutableSet setWithArray:array];
        } else {
            _objects = [NSMutableSet set];
        }
    }
    return self;
}

- (void)addMovie:(Movie *)movie {
    [_objects addObject:movie.uid];
    [self save];
}

- (void)removeMovie:(Movie *)movie {
    [_objects removeObject:movie.uid];
    [self save];
}

- (BOOL)isMovieFavourite:(Movie *)movie {
    return [_objects containsObject:movie.uid];
}

- (NSUInteger)favouritesCount {
    return _objects.count;
}

- (NSSet *)favouriteObjects {
    NSMutableSet *set = [NSMutableSet set];
    for (NSString *uid in _objects) {
        Movie *movie = [Movie findFirstByCriteria:@"uid == %@", uid];
        if (movie) {
            [set addObject:movie];
        }
    }
    return set;
}

- (void)addUpdatesObserver:(id)observer selector:(SEL)selector {
    [[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:kFavouritesManagerUpdateNotification object:nil];
}

- (void)removeUpdatesObserver:(id)observer {
    [[NSNotificationCenter defaultCenter] removeObserver:observer name:kFavouritesManagerUpdateNotification object:nil];
}

- (void)postUpdate {
    [[NSNotificationCenter defaultCenter] postNotificationName:kFavouritesManagerUpdateNotification object:nil];
}

- (void)save {
    [[NSUserDefaults standardUserDefaults] setObject:_objects.allObjects forKey:kFavouritesManagerSaveKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self postUpdate];
}

@end
