//
//  NSManagedObject+AMDatabase.h
//  AMDatabase
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (AMDatabase)

+ (instancetype)createIn:(NSManagedObjectContext *)context;
+ (instancetype)createIn:(NSManagedObjectContext *)context configuration:(NSString *)configuration;
- (void)delete;
- (NSManagedObjectID *)permanentObjectID;
- (BOOL)isObjectDeleted;

+ (NSArray *)execute:(NSFetchRequest *)request context:(NSManagedObjectContext *)context error:(NSError **)error;
+ (NSArray *)allObjects:(NSManagedObjectContext *)context;

+ (NSArray *)allObjectsSorted:(NSManagedObjectContext *)context;
+ (NSArray *)allObjectsSortedBy:(NSString *)key context:(NSManagedObjectContext *)context;
+ (NSArray *)allObjectsSortedBy:(NSString *)key ascending:(BOOL)ascending context:(NSManagedObjectContext *)context;

+ (NSArray *)findIn:(NSManagedObjectContext *)context criteria:(NSString *)criteriaString, ...;
+ (instancetype)findFirstIn:(NSManagedObjectContext *)context criteria:(NSString *)criteriaString, ...;

+ (NSArray *)objectsWithIds:(NSObject<NSFastEnumeration> *)objectIds context:(NSManagedObjectContext *)context;
+ (NSArray *)idsWithObjects:(NSObject<NSFastEnumeration> *)objects;
+ (NSArray *)uriWithIds:(NSObject<NSFastEnumeration> *)ids;
+ (instancetype)findById:(NSManagedObjectID *)objectId context:(NSManagedObjectContext *)context;

@end
