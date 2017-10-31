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
    return [NSString stringWithFormat:@"movie/%@", _uid];
}

- (void)processResponse:(NSDictionary *)response {
    [AppContainer.shared.database perform:^(NSManagedObjectContext *ctx) {
        
        Movie *movie = [Movie findFirstIn:ctx criteria:@"uid == %@", _uid];
        [Movie updateWithArray:@[response] context:ctx];
        movie.loaded = @YES;
        [AMDatabase save:ctx];
        
        [NSManagedObject postUpdateForClasses:@[[Movie class]] notification:[AMNotification makeWithUpdated:[NSSet setWithObject:movie.permanentObjectID.URIRepresentation]]];
    }];
}

@end
