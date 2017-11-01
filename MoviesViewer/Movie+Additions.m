//
//  Movie+Additions.m
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 10/29/17.
//  Copyright © 2017 Ilya Kuznetsov. All rights reserved.
//

#import "Movie+Additions.h"
#import "NSDictionary+Validation.h"
#import "DetailsRequest.h"

@implementation Movie (Additions)

+ (NSArray<Movie *> *)updateWithArray:(NSArray<NSDictionary *> *)array context:(NSManagedObjectContext *)ctx {
    
    //dictionary is faster then fetchrequest
    NSMutableDictionary *cachedMovies = [NSMutableDictionary dictionary];
    for (Movie *movie in [Movie allObjects:ctx]) {
        cachedMovies[movie.uid] = movie;
    }
    
    NSMutableArray *results = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        NSString *uid = [[dict validObjectForKey:@"id"] stringValue];
        if (!uid) {
            continue;
        }
        
        Movie *movie = cachedMovies[uid];
        if (!movie) {
            movie = [Movie createIn:ctx];
            movie.uid = uid;
        }
        [movie updateWithDictionary:dict];
        [results addObject:movie];
    }
    return results;
}

- (void)updateWithDictionary:(NSDictionary *)dictionary {
    NSDictionary *properties = @{ @"title" : @"title",
                                  @"poster_path" : @"poster",
                                  @"overview" : @"overview",
                                  @"release_date" : @"released" };
    
    for (NSString *key in properties) {
        NSString *objectKey = properties[key];
        
        NSString *serviceValue = [dictionary validObjectForKey:key];
        if (serviceValue) {
            [self setValue:serviceValue forKey:objectKey];
        }
    }
    
    NSNumber *votes = dictionary[@"vote_average"];
    if (votes) {
        self.rated = [NSString stringWithFormat:@"%@ ★", votes.stringValue];
    }
    NSNumber *revenue = dictionary[@"revenue"];
    if (revenue) {
        self.revenue = revenue.stringValue;
    }
    NSArray *genres = dictionary[@"genres"];
    if (genres) {
        self.genres = [self parseArrayWith:genres key:@"name"];
    }
    NSArray *countries = dictionary[@"production_countries"];
    if (countries) {
        self.countries = [self parseArrayWith:countries key:@"iso_3166_1"];
    }
    NSArray *companies = dictionary[@"production_companies"];
    if (companies) {
        self.companies = [self parseArrayWith:companies key:@"name"];
    }
    NSString *runtime = [[dictionary validObjectForKey:@"runtime"] stringValue];
    if (runtime) {
        self.runtime = [runtime stringByAppendingString:@" m"];
    }
}

- (NSArray *)parseArrayWith:(NSArray *)array key:(NSString *)key {
    NSMutableArray *result = [NSMutableArray array];
    
    for (NSDictionary *dict in array) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            NSString *name = dict[@"name"];
            if (name) {
                [result addObject:name];
            }
        }
    }
    return result ?: nil;
}

- (BOOL)isLoaded {
    return self.loaded.boolValue;
}

- (AFHTTPRequestOperation *)updateDetails:(CompletionBlock)completion {
    DetailsRequest *detailsDequest = [DetailsRequest new];
    detailsDequest.uid = self.uid;
    return [detailsDequest send:completion];
}

- (void)fullPosterPath:(void(^)(NSString *parh, NSError *error))completion {
    if (!self.poster) {
        completion(nil, nil);
    } else {
        [AppContainer.shared.service loadConfiguration:^(NSDictionary *configuration, NSError *error) {
            if (error) {
                completion(nil, error);
            } else {
                NSDictionary *images = [configuration validObjectForKey:@"images"];
                NSString *baseURL = images[@"base_url"];
                
                completion([NSString stringWithFormat:@"%@w185%@", baseURL, self.poster], nil);
            }
        }];
    }
}

@end
