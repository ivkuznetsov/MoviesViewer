//
//  MovieCategory.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "MovieCategory.h"
#import "Movie.h"

@implementation MovieCategory

- (NSString *)title {
    return [self.uid capitalizedString];
}

@end
