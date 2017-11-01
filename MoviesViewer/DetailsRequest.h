//
//  DetailsRequest.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 17/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "ServiceRequest.h"

@interface DetailsRequest : ServiceRequest

@property (nonatomic) NSString *uid;

@end
