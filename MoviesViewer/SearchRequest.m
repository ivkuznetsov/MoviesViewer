//
//  SearchRequest.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "SearchRequest.h"

@implementation SearchRequest

- (NSString *)path {
    return @"";
}

- (NSDictionary *)requestDictionary {
    return @{ @"s" : _query, @"page" : @(_page) };
}

- (void)processResponse:(NSDictionary *)response {
    NSArray *results = [response validObjectForKey:@"Search"];
    if (results.count) {
        [Database performSync:^{
            NSArray *resultObjects = [Movie updateWithArray:results];
            [Database save];
            _results = [NSManagedObject objectIdsWithObjects:resultObjects];
            [NSManagedObject postUpdateForClasses:@[[Movie class], [MovieCategory class]] object:nil];
        }];
    }
}

@end