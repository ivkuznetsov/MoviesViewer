//
//  MovieCategory.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Movie;

NS_ASSUME_NONNULL_BEGIN

@interface MovieCategory : NSManagedObject

- (NSString *)title;

@end

NS_ASSUME_NONNULL_END

#import "MovieCategory+CoreDataProperties.h"
