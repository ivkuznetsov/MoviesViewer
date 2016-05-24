//
//  FavouritesManager.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 17/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavouritesManager : NSObject

+ (instancetype)sharedManager;

- (void)addMovie:(Movie *)movie;
- (void)removeMovie:(Movie *)movie;
- (BOOL)isMovieFavourite:(Movie *)move;
- (NSUInteger)favouritesCount;
- (NSSet *)favouriteObjects;

- (void)addUpdatesObserver:(id)observer selector:(SEL)selector;
- (void)removeUpdatesObserver:(id)observer;

@end
