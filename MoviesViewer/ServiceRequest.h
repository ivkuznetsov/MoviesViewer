//
//  ServiceRequest.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSError+ServiceProvider.h"

@interface ServiceRequest : NSObject

//to override
- (NSString *)acceptableContentType;
- (NSString *)method;
- (NSString *)path;
- (NSDictionary *)requestDictionary;
- (void)processResponse:(NSDictionary *)response;
- (NSError *)validateResponse:(NSDictionary*)responseDictionary httpResponse:(NSHTTPURLResponse *)httpResponse;

@end