//
//  AMPagingCollectionHelper.h
//  AMAppkit
//
//  Created by Ilya Kuznecov on 12/05/2017.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "AMCollectionHelper.h"
#import "AMPagingLoader.h"

@interface AMPagingCollectionHelper : AMCollectionHelper

@property (nonatomic, readonly) AMPagingLoader *loader;

@end
