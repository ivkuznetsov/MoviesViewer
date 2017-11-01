//
//  NSManagedObjectContext+AMDatabase.m
//  AMDatabase
//
//  Created by Ilya Kuznetsov on 10/29/17.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import "NSManagedObjectContext+AMDatabase.h"
#import <objc/runtime.h>

@implementation NSManagedObjectContext (AMDatabase)
@dynamic database;

- (void)setDatabase:(AMDatabase *)database {
    objc_setAssociatedObject(self, @"database", database, OBJC_ASSOCIATION_ASSIGN);
}

- (AMDatabase *)database {
    return objc_getAssociatedObject(self, @"database");
}

@end
