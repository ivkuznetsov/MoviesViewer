//
//  MovieCategory+CoreDataProperties.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MovieCategory.h"

NS_ASSUME_NONNULL_BEGIN

@interface MovieCategory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSSet<Movie *> *movies;

@end

@interface MovieCategory (CoreDataGeneratedAccessors)

- (void)addMoviesObject:(Movie *)value;
- (void)removeMoviesObject:(Movie *)value;
- (void)addMovies:(NSSet<Movie *> *)values;
- (void)removeMovies:(NSSet<Movie *> *)values;

@end

NS_ASSUME_NONNULL_END
