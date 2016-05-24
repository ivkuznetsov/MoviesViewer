//
//  NSMutableArray+Validation.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 17/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "NSMutableArray+Validation.h"

@implementation NSMutableArray (Validation)

- (void)addValidObject:(id)object {
    if (object) {
        [self addObject:object];
    }
}

@end
