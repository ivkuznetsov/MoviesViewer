//
//  SearchRequest.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "SearchRequest.h"
#import "NSDictionary+Validation.h"

@implementation SearchRequest

- (NSString *)path {
    return @"search/movie";
}

- (NSDictionary *)requestDictionary {
    return @{ @"query" : _query, @"page" : _page ?: @(1) };
}

- (void)processResponse:(NSDictionary *)response {
    NSArray *results = [response validObjectForKey:@"results"];
    if (results.count) {
        [AppContainer.shared.database perform:^(NSManagedObjectContext *ctx) {
            NSArray *resultObjects = [Movie updateWithArray:results context:ctx];
            [AMDatabase save:ctx];
            _results = [NSManagedObject idsWithObjects:resultObjects];
            
            NSMutableSet *updatedSet = [NSMutableSet set];
            for (Movie *movie in resultObjects) {
                [updatedSet addObject:movie.permanentObjectID.URIRepresentation];
            }
            [NSManagedObject postUpdateForClasses:@[[Movie class]] notification:[AMNotification makeWithUpdated:updatedSet]];
        }];
    }
    
    NSNumber *nextPage = response[@"page"];
    NSNumber *totalPages = response[@"total_pages"];
    _updatedPage = totalPages.integerValue != nextPage.integerValue ? @(nextPage.integerValue + 1) : nil;
}

@end
