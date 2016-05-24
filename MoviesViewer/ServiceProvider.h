//
//  ServiceProvider.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "ServiceRequest.h"
#import "AFNetworking.h"

#define kReachabilityChangeNotification @"kReachabilityChangeNotification"

typedef void(^CompletionBlock)(id request, NSError *error);

@interface ServiceProvider : AFHTTPClient

@property (nonatomic) BOOL enableLogging;

+ (instancetype)sharedProvider;
- (AFHTTPRequestOperation *)sendRequest:(ServiceRequest *)serviceRequest withCompletionBlock:(CompletionBlock)callback;

@end