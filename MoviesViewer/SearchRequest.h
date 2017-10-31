//
//  SearchRequest.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "ServiceRequest.h"

@interface SearchRequest : ServiceRequest

@property (nonatomic) NSString *query;
@property (nonatomic) NSNumber *page;
@property (nonatomic) NSNumber *updatedPage;

//response
@property (nonatomic) NSArray<NSManagedObjectID *> *results;
@property (nonatomic) NSUInteger totalResults;

@end
