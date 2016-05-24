//
//  Movie.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MovieCategory;

@interface Movie : NSManagedObject

+ (NSArray<Movie *> *)updateWithArray:(NSArray<NSDictionary *> *)array;
- (void)updateWithDictionary:(NSDictionary *)dictionary;
- (BOOL)isLoaded;
- (AFHTTPRequestOperation *)updateDetailsWithCompletion:(CompletionBlock)completion;

@end

#import "Movie+CoreDataProperties.h"
