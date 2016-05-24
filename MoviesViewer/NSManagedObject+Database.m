//
//  NSManagedObject+Database.h
//  MoviesViewer
//
//  Created by Ilya Kuznecov on 16/04/16.
//  Copyright © 2016 Ilya Kuznetsov. All rights reserved.
//

#import "NSManagedObject+Database.h"
#import "Database.h"
#import "NSObject+ClassName.h"

@implementation NSManagedObject (Database)

- (instancetype)init {
    return [self initWithEntity:[[self class] entityDescription] insertIntoManagedObjectContext:[Database managedObjectContext]];
}

- (NSManagedObjectID *)permanentObjectID {
    NSManagedObjectID *objectId = self.objectID;
    
    if (objectId.isTemporaryID) {
        [self.managedObjectContext performBlockAndWait:^{
            [self.managedObjectContext obtainPermanentIDsForObjects:@[self] error:nil];
        }];
        objectId = self.objectID;
    }
    return objectId;
}

+ (NSArray *)objectsWithObjectIds:(NSArray *)objectIds {
    NSMutableArray *results = [NSMutableArray array];
    for (NSManagedObjectID *objectId in objectIds) {
        [results addObject:[self findByObjectID:objectId]];
    }
    return results;
}

+ (NSArray *)objectIdsWithObjects:(NSArray *)objects {
    NSMutableArray *results = [NSMutableArray array];
    for (NSManagedObject *object in objects) {
        [results addObject:[object permanentObjectID]];
    }
    return results;
}

+ (instancetype)findByObjectID:(NSManagedObjectID *)objectId {
    __block NSManagedObject *object = nil;
    NSManagedObjectContext *context = [Database managedObjectContext];
    [context performBlockAndWait:^{
        object = [context existingObjectWithID:objectId error:nil];
    }];
    return object;
}

+ (NSString*)entityName {
    return [self className];
}

+ (NSEntityDescription *)entityDescription {
    __block NSEntityDescription *description = nil;
    NSManagedObjectContext *context = [Database managedObjectContext];
    [context performBlockAndWait:^{
        description = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
    }];
    return description;
}

- (NSEntityDescription *)entityDescription {
    return [[self class] entityDescription];
}

+ (NSArray *)executeFetchRequest:(NSFetchRequest *)request withError:(NSError **)error {
    __block NSArray *result = nil;
    NSManagedObjectContext *context = [Database managedObjectContext];
    [context performBlockAndWait:^{
        NSEntityDescription *entity = [self entityDescription];
        [request setEntity:entity];
        result = [context executeFetchRequest:request error:error];
    }];
    return result;
}

+ (NSArray *)allObjects {
    NSFetchRequest *allObjectsRequest = [NSFetchRequest new];
    
    NSError *error = nil;
    NSArray *result = [self executeFetchRequest:allObjectsRequest withError:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    return result;
}

+ (NSArray *)allObjectsSorted {
    return [[self allObjects] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"permanentObjectID.description" ascending:YES]]];
}

+ (NSArray *)allObjectsSortedByKey:(NSString*)key {
    return [self allObjectsSortedByKey:key ascending:YES];
}

+ (NSArray *)allObjectsSortedByKey:(NSString*)key ascending:(BOOL)ascending {
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:ascending];
    NSFetchRequest *allObjectsRequest = [[NSFetchRequest alloc] init];
    [allObjectsRequest setSortDescriptors:@[sortDescriptor]];
    NSArray *result = [self executeFetchRequest:allObjectsRequest withError:nil];
    return result;
}

+ (NSArray *)findByCriteria:(NSString *)criteriaString, ... {
    va_list argumentList;
    va_start(argumentList, criteriaString);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:criteriaString arguments:argumentList];
    NSFetchRequest *request = [NSFetchRequest new];
    [request setPredicate:predicate];
    
    va_end(argumentList);
    
    NSError *error = nil;
    NSArray *result = [[self class] executeFetchRequest:request withError:&error];
    
    if (error) {
        [[self class] logError: error];
    }
    return result;
}

+ (instancetype)findFirstByCriteria:(NSString *)criteriaString, ... {
    va_list argumentList;
    va_start(argumentList, criteriaString);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:criteriaString arguments:argumentList];
    NSFetchRequest *request = [NSFetchRequest new];
    request.fetchLimit = 1;
    [request setPredicate:predicate];
    
    va_end(argumentList);
    
    NSError *error = nil;
    NSArray *result = [[self class] executeFetchRequest:request withError:&error];
    if (error) {
        [[self class] logError: error];
    }
    return result.firstObject;
}

+ (instancetype)create {
    __block NSManagedObject *object = nil;
    NSManagedObjectContext *context = [Database managedObjectContext];
    [context performBlockAndWait:^{
        object = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
    }];
    return object;
}

- (void)delete {
    NSManagedObjectContext *context = [Database managedObjectContext];
    [context performBlockAndWait:^{
        [context deleteObject:self];
    }];
}

+ (void)logError:(NSError *)error {
    NSLog(@"Error: %@", error);
    NSArray* detailedErrors = [error userInfo][NSDetailedErrorsKey];
    if (detailedErrors.count) {
        for (NSError* detailedError in detailedErrors) {
            NSLog(@"  DetailedError: %@", [detailedError userInfo]);
        }
    } else {
        NSLog(@"  %@", [error userInfo]);
    }
}

@end