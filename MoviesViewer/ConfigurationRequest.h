//
//  ConfigurationRequest.h
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 10/31/17.
//  Copyright © 2017 Ilya Kuznetsov. All rights reserved.
//

#import "ServiceRequest.h"

@interface ConfigurationRequest : ServiceRequest

@property (nonatomic) NSDictionary *configuration;

@end
