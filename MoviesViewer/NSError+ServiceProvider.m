//
//  NSError+ServiceProvider.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "NSError+ServiceProvider.h"

@implementation NSError (ServiceProvider)

+ (instancetype)requestErrorWithCode:(NSInteger)code description:(NSString *)description {
    return [[self class] errorWithDomain:@"RequestError"
                                    code:code
                                userInfo:@{NSLocalizedDescriptionKey : description}];
}

@end