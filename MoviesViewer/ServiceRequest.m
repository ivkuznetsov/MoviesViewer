//
//  ServiceRequest.m
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "ServiceRequest.h"
#import "NSDictionary+Validation.h"
#import "AppContainer.h"

@implementation ServiceRequest

- (NSString *)acceptableContentType {
	return @"application/json";
}

- (NSString *)method {
	return @"GET";
}

- (NSString *)path {
	return @"(request_path_here)";
}

- (NSDictionary *)requestDictionary {
    return @{};
}

- (void)processResponse:(NSDictionary *)response {
	
}

- (NSError *)validateResponse:(NSDictionary*)responseDictionary httpResponse:(NSHTTPURLResponse *)httpResponse {
    NSIndexSet *acceptableCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    
    NSString *errorMessage = [responseDictionary validObjectForKey:@"Error"];
    
	if (![acceptableCodes containsIndex:httpResponse.statusCode] || errorMessage) {
        if (errorMessage) {
			return [NSError requestErrorWithCode:httpResponse.statusCode description:errorMessage];
        } else {
			return [NSError requestErrorWithCode:httpResponse.statusCode description:@"Some server error occured."];
        }
	}
	return nil;
}

- (AFHTTPRequestOperation *)send:(CompletionBlock)completion {
    return [AppContainer.shared.service send:self completion:completion];
}

@end
