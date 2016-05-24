//
//  NSManagedObject+Database.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Database)

+ (NSArray *)objectsWithObjectIds:(NSArray *)objectIds;
+ (NSArray *)objectIdsWithObjects:(NSArray *)objects;

+ (NSString *)entityName;
+ (NSArray *)executeFetchRequest:(NSFetchRequest *)request withError:(NSError **)error;
+ (NSArray *)allObjects;

+ (NSArray *)allObjectsSorted;
+ (NSArray *)allObjectsSortedByKey:(NSString *)key;
+ (NSArray *)allObjectsSortedByKey:(NSString *)key ascending:(BOOL)ascending;

- (NSEntityDescription *)entityDescription;
- (NSManagedObjectID *) permanentObjectID;

+ (NSArray *)findByCriteria:(NSString *)criteriaString, ...;
+ (instancetype)findFirstByCriteria:(NSString *)criteriaString, ...;
+ (instancetype)findByObjectID:(NSManagedObjectID *)objectID;

+ (instancetype)create;
- (void)delete;

@end
