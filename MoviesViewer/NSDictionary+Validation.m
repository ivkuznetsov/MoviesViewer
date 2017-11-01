//
//  NSDictionary+Validation.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "NSDictionary+Validation.h"

@implementation NSDictionary (Validation)

- (id)validObjectForKey:(id)key {
    NSObject *obj = [self objectForKey:key];
    if ([obj isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return obj;
}

@end
