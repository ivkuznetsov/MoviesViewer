//
//  DetailsRequest.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 17/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "DetailsRequest.h"

@implementation DetailsRequest

- (NSString *)path {
    return @"";
}

- (NSDictionary *)requestDictionary {
    return @{ @"i" : _uid };
}

- (void)processResponse:(NSDictionary *)response {
    [Database performSync:^{
        Movie *movie = [Movie findFirstByCriteria:@"uid == %@", _uid];
        [Movie updateWithArray:@[response]];
        movie.loaded = @YES;
        [Database save];
        [Movie postUpdateWithObject:movie.permanentObjectID];
    }];
}

@end