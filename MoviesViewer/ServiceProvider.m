//
//  ServiceProvider.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "ServiceProvider.h"
#import "NSDictionary+Validation.h"
#import "ConfigurationRequest.h"

@interface ServiceProvider()

@property (nonatomic) NSDictionary *configuration;

@end

@implementation ServiceProvider

- (instancetype)initWithBaseURL:(NSURL *)url {
    if (self = [super initWithBaseURL:url]) {
        self.parameterEncoding = AFJSONParameterEncoding;
        self.enableLogging = YES;
        self.operationQueue.maxConcurrentOperationCount = 5;
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityChangeNotification object:nil];
        }];
    }
    return self;
}

- (AFHTTPRequestOperation *)send:(ServiceRequest *)serviceRequest completion:(CompletionBlock)completion {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[serviceRequest requestDictionary]];
    dict[@"api_key"] = self.apiKey;
    
    NSMutableURLRequest *request = [self requestWithMethod:[serviceRequest method] path:serviceRequest.path parameters:dict];
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request serviceRequest:serviceRequest completion:completion];
    [self enqueueHTTPRequestOperation:operation];
    return operation;
}

- (AFHTTPRequestOperation *)HTTPRequestOperationWithRequest:(NSMutableURLRequest *)request
                                             serviceRequest:(ServiceRequest *)serviceRequest
                                                 completion:(CompletionBlock)completion {
    
    if ([serviceRequest acceptableContentType]) {
        [request setValue:[serviceRequest acceptableContentType] forHTTPHeaderField:@"Accept"];
    }
    
    [self log:@"request url:%@", request.URL];
    [self log:@"request headers:%@", request.allHTTPHeaderFields];
    if (request.HTTPBody.length > 0) {
        [self log:@"request body: %@", [[NSString alloc] initWithData:request.HTTPBody encoding:self.stringEncoding]];
    }
    
    return [self HTTPRequestOperationWithRequest:request
                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                             
                                             [self processSuccessForServiceRequest:serviceRequest
                                                                         operation:operation
                                                                    responseObject:responseObject
                                                                        completion:completion];
                                             
                                         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                             [self logOperation:operation error:error];
                                             
                                             if (completion) {
                                                 completion(serviceRequest, error);
                                             }
                                         }];
}

- (void)processSuccessForServiceRequest:(ServiceRequest *)serviceRequest
                              operation:(AFHTTPRequestOperation *)operation
                         responseObject:(id)responseObject
                             completion:(CompletionBlock)completion {
    
    [self logOperation:operation error:nil];
    NSError *error = [serviceRequest validateResponse:responseObject httpResponse:operation.response];
    if (error) {
        [self log:@"request error:%@", error];
        
        if (completion) {
            completion(serviceRequest, error);
        }
    } else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSDictionary *validResponseObject = [responseObject isKindOfClass:[NSDictionary class]] ? (NSDictionary *)responseObject : nil;
            [serviceRequest processResponse:validResponseObject];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(serviceRequest, nil);
                }
            });
        });
    }
}

- (void)logOperation:(AFHTTPRequestOperation *)operation error:(NSError *)error {
    if (operation.cancelled) {
        [self log:[NSString stringWithFormat:@"Request canceled: %@", operation.request.description]];
    }
    [self log:@"Response code: %d", operation.response.statusCode];
    [self log:@"Response headers: %@", operation.response.allHeaderFields];
    
    if (([operation.response.MIMEType hasPrefix:@"application"] || [operation.response.MIMEType hasPrefix:@"text"])) {
        [self log:@"Response body: %@", [[NSString alloc] initWithData:operation.responseData encoding:self.stringEncoding]];
    }
    if (error) {
        [self log:@"request error: %@", error.localizedDescription];
    }
}

- (void)log:(NSString *)logFormat, ... {
    if (_enableLogging) {
        va_list argumentList;
        va_start(argumentList, logFormat);
        NSLogv(logFormat, argumentList);
        va_end(argumentList);
    }
}

- (void)loadConfiguration:(void(^)(NSDictionary *configuration, NSError *error))completion {
    if (_configuration) {
        if (completion) {
            completion(_configuration, nil);
        }
        return;
    }
    
    //combine several load configuration requests in single fetch
    [AMUtils run:^NSOperation *(SuccessCallback success, FailCallback fail) {
        
        return [self send:[ConfigurationRequest new] completion:^(ConfigurationRequest *request, NSError *error) {
            if (error) {
                fail(nil, error);
            } else {
                success(request.configuration);
            }
        }];
        
    } success:^(NSDictionary *configuration) {
        _configuration = configuration;
        if (completion) {
            completion(configuration, nil);
        }
    } failure:^(id object, NSError *requestError) {
        if (completion) {
            completion(nil, requestError);
        }
    } key:@"configuration"];
}

@end
