//
//  Movie+Additions.h
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 10/29/17.
//  Copyright © 2017 Ilya Kuznetsov. All rights reserved.
//

#import "Movie+CoreDataClass.h"
#import "ServiceProvider.h"

@interface Movie (Additions)

+ (NSArray<Movie *> *)updateWithArray:(NSArray<NSDictionary *> *)array context:(NSManagedObjectContext *)ctx;
- (void)updateWithDictionary:(NSDictionary *)dictionary;
- (BOOL)isLoaded;
- (AFHTTPRequestOperation *)updateDetails:(CompletionBlock)completion;
- (void)fullPosterPath:(void(^)(NSString *parh, NSError *error))completion;

@end
