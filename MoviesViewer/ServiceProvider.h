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

@interface ServiceProvider : AFHTTPClient

@property (nonatomic) NSString *apiKey;
@property (nonatomic) BOOL enableLogging;

- (AFHTTPRequestOperation *)send:(ServiceRequest *)serviceRequest completion:(CompletionBlock)completion;

- (void)loadConfiguration:(void(^)(NSDictionary *configuration, NSError *error))completion;

@end
