//
//  AppContainer.m
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 10/29/17.
//  Copyright © 2017 Ilya Kuznetsov. All rights reserved.
//

#import "AppContainer.h"

#define kApiKey @"40dd6d254bb15a70311b60b8666a04ac"

@implementation AppContainer

+ (instancetype)shared {
    static AppContainer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [AppContainer new];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        
        _favorites = [[ObjectsContainer alloc] initWithClass:[Movie class] uidKey:@"uid"];
        
        _service = [[ServiceProvider alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.themoviedb.org/3"]];
        _service.apiKey = kApiKey;
        
        _database = [AMDatabase new];
    }
    return self;
}

@end
