//
//  ConfigurationRequest.m
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 10/31/17.
//  Copyright © 2017 Ilya Kuznetsov. All rights reserved.
//

#import "ConfigurationRequest.h"

@implementation ConfigurationRequest

- (NSString *)path {
    return @"configuration";
}

- (NSDictionary *)requestDictionary {
    return @{ };
}

- (void)processResponse:(NSDictionary *)response {
    _configuration = response;
}

@end
