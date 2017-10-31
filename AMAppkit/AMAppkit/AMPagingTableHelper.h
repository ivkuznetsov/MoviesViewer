//
//  AMPagingTableHelper.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 05/02/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMTableHelper.h"
#import "AMPagingLoader.h"

@interface AMPagingTableHelper : AMTableHelper

@property (nonatomic, readonly) AMPagingLoader *loader;

@end
