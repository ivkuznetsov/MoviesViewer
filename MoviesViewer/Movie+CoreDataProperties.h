//
//  Movie+CoreDataProperties.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Movie.h"

NS_ASSUME_NONNULL_BEGIN

@interface Movie (CoreDataProperties)

@property (nonnull, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSNumber *loaded;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *poster;
@property (nullable, nonatomic, retain) NSString *year;
@property (nullable, nonatomic, retain) NSString *genre;
@property (nullable, nonatomic, retain) NSString *country;
@property (nullable, nonatomic, retain) NSString *director;
@property (nullable, nonatomic, retain) NSString *plot;
@property (nullable, nonatomic, retain) NSString *rated;
@property (nullable, nonatomic, retain) NSString *released;
@property (nullable, nonatomic, retain) NSString *runtime;
@property (nullable, nonatomic, retain) NSString *writer;
@property (nullable, nonatomic, retain) NSString *imdbRating;
@property (nullable, nonatomic, retain) NSString *imdbVotes;
@property (nullable, nonatomic, retain) NSString *actors;
@property (nullable, nonatomic, retain) MovieCategory *category;

@end

NS_ASSUME_NONNULL_END
