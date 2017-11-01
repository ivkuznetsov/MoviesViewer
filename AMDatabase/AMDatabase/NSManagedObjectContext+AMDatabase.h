//
//  NSManagedObjectContext+AMDatabase.h
//  AMDatabase
//
//  Created by Ilya Kuznetsov on 10/29/17.
//  Copyright © 2017 Arello Mobile. All rights reserved.
//

#import <CoreData/CoreData.h>

@class AMDatabase;

@interface NSManagedObjectContext (AMDatabase)

@property (nonatomic, weak) AMDatabase *database;

@end
