//
//  Movie+CoreDataProperties.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Movie+CoreDataProperties.h"

@implementation Movie (CoreDataProperties)

@dynamic uid;
@dynamic loaded;
@dynamic title;
@dynamic poster;
@dynamic year;
@dynamic genre;
@dynamic country;
@dynamic director;
@dynamic plot;
@dynamic rated;
@dynamic released;
@dynamic runtime;
@dynamic writer;
@dynamic imdbRating;
@dynamic imdbVotes;
@dynamic actors;
@dynamic category;

@end
