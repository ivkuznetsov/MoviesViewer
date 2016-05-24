//
//  Movie.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "Movie.h"
#import "MovieCategory.h"
#import "DetailsRequest.h"

@implementation Movie

+ (NSArray<Movie *> *)updateWithArray:(NSArray<NSDictionary *> *)array {
    
    //dictionary is faster then fetchrequest
    NSMutableDictionary *cachedMovies = [NSMutableDictionary dictionary];
    for (Movie *movie in [Movie allObjects]) {
        cachedMovies[movie.uid] = movie;
    }
    
    NSMutableDictionary *cachedCategories = [NSMutableDictionary dictionary];
    for (MovieCategory *category in [MovieCategory allObjects]) {
        cachedCategories[category.uid] = category;
    }
    
    NSMutableArray *results = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        NSString *uid = [dict validObjectForKey:@"imdbID"];
        if (!uid) {
            continue;
        }
        
        NSString *categoryUid = [dict validObjectForKey:@"Type"];
        if (!categoryUid) {
            continue;
        }
        
        MovieCategory *category = cachedCategories[categoryUid];
        if (!category) {
            category = [MovieCategory create];
            category.uid = categoryUid;
        }
        
        Movie *movie = cachedMovies[uid];
        if (!movie) {
            movie = [Movie create];
            movie.uid = uid;
        }
        [movie updateWithDictionary:dict];
        
        [category addMoviesObject:movie];
        [results addObject:movie];
    }
    return results;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    NSDictionary *properties = @{ @"Year" : @"year",
                                  @"Title" : @"title",
                                  @"Poster" : @"poster",
                                  @"Genre" : @"genre",
                                  @"Director" : @"director",
                                  @"Plot" : @"plot",
                                  @"Rated" : @"rated",
                                  @"Released" : @"released",
                                  @"Runtime" : @"runtime",
                                  @"Writer" : @"writer",
                                  @"imdbRating" : @"imdbRating",
                                  @"imdbVotes" : @"imdbVotes",
                                  @"Actors" : @"actors",
                                  @"Country" : @"country"};
    
    for (NSString *key in properties) {
        NSString *objectKey = properties[key];
        
        NSString *serviceValue = [dictionary validObjectForKey:key];
        if (serviceValue) {
            [self setValue:serviceValue forKey:objectKey];
        }
    }
}

- (BOOL)isLoaded {
    return self.loaded.boolValue;
}

- (AFHTTPRequestOperation *)updateDetailsWithCompletion:(CompletionBlock)completion {
    DetailsRequest *detailsDequest = [DetailsRequest new];
    detailsDequest.uid = self.uid;
    return [[ServiceProvider sharedProvider] sendRequest:detailsDequest withCompletionBlock:completion];
}

@end